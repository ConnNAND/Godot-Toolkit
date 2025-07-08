extends Node

#my beloved: https://www.youtube.com/watch?v=P27ml4M3V7A

var divisions = 192 #48?

#midi is stored as events and deltas
#the event is the thing that happened, and the delta is how much time has passed since the last event
#if the delta is 0, it occurs at the same time as the previous event
#each midi file has multiple event lists, known as "tracks"
#midi files are stored in chunks, with a label, a size, and the actual data
#the first 4 bytes of a chunk store its label

#midi data is stored in a list-in-list format, inner lists store data, while outer list is the track number.
#each data entry holds [dt since last event, event type, note value*, velocity*]
#the exception to this is the first entry, which holds exclusively the channel # of the track, stored as an 0x_
#example: 
#[											#this list holds all of the data
#	[										#this list marks a new track
		#[0, "tempo", 120],					#this event marks the tempo, in this case, it's 120 bpm
		#[0, "time_signature", 3, 4],		#this event marks the time signature, in this case, it's 3/4 time
		#[0, "note_on", 60, 100, 0],		#this event marks a note-on, that being middle C
		#[48, "note_off", 60, 0, 0]			#this event marks a note-off, shutting off the middle C that was playing, 1 beat after it was turned on
	#]
#]


func make_midi(song:Array, num_tracks:int=1, file_path="user://output.mid"):
#the first 4 bytes of a midi file encoded from bytes to ascii make 'MThd', or '4D 54 68 64' this denotes a midi header
	var midi_file = FileAccess.open(file_path, FileAccess.WRITE_READ)
	midi_file.big_endian = true
	midi_file.store_buffer("MThd".to_ascii_buffer())
#following this is 4 bytes that tell the size. for our header it should say 6 bytes, or '00 00 00 06'
	#this is stored in big endian, meaning the most significant byte comes first
	midi_file.store_32(6)
#next is the data, this is split into 3 separate values
	#the first two bytes represent the format, '00 00' is a single track, '00 01' is multiple tracks
		#'00 02' is for multiple patterns with one track each, 2 is rarely used so basically you can ignore it
	if num_tracks > 1:
		midi_file.store_16(1)
	else:
		midi_file.store_16(0)
	#the 2nd two bytes tell us how many tracks are in the file
	midi_file.store_16(num_tracks)
	#the last two bytes tell us the number of divisions, aka how long a tick of delta-time is
		#the first bit of divisions tells us if we are using SMPTE time
			#if you aren't using SMPTE, the rest of the bits tell the length in ticks of a quarter note
			#if you ARE using SMPTE, the rest of the first byte are a 'negative framerate', 
				#then the final byte stores a 'frame resolution'. For our case, we can pretty much ignore SMPTE
	midi_file.store_16(divisions)
	
	#Now that we are past the header, each midi track gets its own chunk:
	for track in song:
		#starting with the label, which is 'MTrk', or '4D 54 72 6B'
		midi_file.store_buffer("MTrk".to_ascii_buffer())
		var track_bytes = PackedByteArray()
		#we again have a 4 byte big endian size value (which we must wait until our data is converted into bits to get)
		#and then our giant data chunk, which is just a big array of events, with each event being 4 bytes
		var channel:int = track[0]	#MAKE SURE TO STORE THIS AS 0x_
		for event in track:
			if event is int:
				continue
			#basic midi events start with a delta time byte
				#midi uses 'variable length quantity', meaning the left-most bit in a byte is either 0 or 1
					#if it is 1, this is a signal that the following byte is also part of the value
					#if it is a 0, this marks the end of the value
						#when this happens, the left-most bits are cut off, and the remaining is stitched together
			print(track_bytes.hex_encode())
			track_bytes.append_array(to_vlq(event[0]))
			#it is followed by a status byte... sometimes
				#when using a status byte, the first nibble is the event type. 
					#a nibble of '9' states that it is a note-on event, and the data bytes are the note and velocity
					#a nibble of '8' is note-off, 						    the data bytes are the note and velocity
					#a nibble of 'A' is polyphonic key pressure, 			note and pressure
					#a nibble of 'B' is a control change					control and value
					#a nibble of 'C' is a program change					program
					#a nibble of 'D' is channel pressure					pressure
					#a nibble of 'E' is a pitch wheel change				LSB and MSB
					#polyphonic key and channel pressure are used for 'after-touch'
						#some keyboards allow pressing harder/lighter to change effects after the initial press
					#control change and pitch wheel change signal buttons and knobs being pressed from a device
					#programs define an instrument, a standardized list can be found online
				#the second nibble tells us the event is happening on the midi channel at the given index
				#sometimes there is a 'running status', 
					#if the status is the same as the previous event, this byte is skipped
					#you know to skip if the left-most bit is a 0, as status bytes always start with 1
						#for our case, we'll skip making these
			print(event)
			match event[1]:
				"note_on":
					track_bytes.push_back(0x90|("%x" %channel).hex_to_int()) #this is definitely wrong
					#if we are handling a note-on/off event, this tells us which note
						#for notes, we start with octave -1 and C at 0, C# at 1, and so on until we reach B at 11
						#we now go back to C at 12, and octave increased to 0. Continue this pattern until 9G at 127
						#this is done purposefully to keep the left-most bit a 0
					# middle C is 4C, or 60
					track_bytes.push_back(("%x" %event[2]).hex_to_int())
					#the next byte tells us the velocity of the note being pressed
					track_bytes.push_back(("%x" %event[3]).hex_to_int())
				"note_off":
					track_bytes.push_back(0x80|("%x" %channel).hex_to_int())
					track_bytes.push_back(("%x" %event[2]).hex_to_int())
					track_bytes.push_back(("%x" %event[3]).hex_to_int())
		#if we aren't looking at a basic midi event, it could be a common system event!
			#these have the first byte as a status F0 - F1, a Length, and space for 2 data bytes
				#F0 and F7 are system exclusive event start and ends, allowing manufacturers to make their own events
				#F1 is Time Code Quarter Frame, only relevant when working with SMPTE
		#there are also real-time system events, F8-FF, which also aren't relevant for us
		#it may also be a Meta Event, containing text. These are status - type - length - data bytes:
			#FF 01 is a text event
			#FF 02 is a Copyright Notice
			#FF 03 is a sequence/track name
			#FF 04 is an instrument name
			#FF 05 is a lyric
			#FF 06 is a marker
			#FF 07 is a point
		#it could also be a Meta Event not containing text:
			#FF 00 01 is a sequence number, with data containing a number
			#FF 20 01 is a channel prefix, 						 a channel
			#FF 2F 00 marks the end of the track
			#FF 51 03 sets the tempo, 							 MSB byte LSB, (number of microseconds in quarter note)
			#FF 54 05 is SMPTE offset							 hour, min, sec, frame, frac
			#FF 58 04 is a time signature, 						 num, den, clocks, 32nd, (den stored as power of 2)
				"tempo":
					track_bytes.push_back(0xFF)
					track_bytes.push_back(0x51)
					track_bytes.push_back(0x03)
					track_bytes.push_back((bpm_to_tempo(event[2])>>16)&0xFF)
					track_bytes.push_back((bpm_to_tempo(event[2])>>8)&0xFF)
					track_bytes.push_back(bpm_to_tempo(event[2])&0xFF)
				"time_signature":
					track_bytes.push_back(0xFF)
					track_bytes.push_back(0x58)
					track_bytes.push_back(0x04)
					track_bytes.push_back(("%x" %event[2]).hex_to_int())	#Nunmerator
					track_bytes.push_back(int(log(event[3])/log(2)))	#Denominator as exponent
					track_bytes.push_back(("%x" %24).hex_to_int())			#clocks per tick
					track_bytes.push_back(("%x" %8).hex_to_int())			#32nd notes per quarter
		
		#now that we have processed our midi events, we can mark the end of track
		track_bytes.append_array(to_vlq(0))
		track_bytes.push_back(0xFF)	#marking a meta event
		track_bytes.push_back(0x2F)	#marking end of track type
		track_bytes.push_back(0x00)	#marking the length
		
		midi_file.store_32(track_bytes.size())
		midi_file.store_buffer(track_bytes)
		midi_file.close()
		print(track_bytes.hex_encode())
		return


func to_vlq(value:int):
	assert(value >= 0, "n must be non-negative")
	var chunks := []
	if value < 254:
		return PackedByteArray([("%x" %value).hex_to_int()])
	else:
		while value > 0:
			var chunk = value & 0x7F  # Extract the least significant 7 bits
			chunks.append(chunk)
			value = value >> 7            # Right shift to process the next 7 bits
		chunks.reverse()          # Reverse to place the most significant chunk first
		# Set the continuation bit on all chunks except the last
		for i in range(chunks.size() - 1):
			chunks[i] |= 0x80
		return PackedByteArray(chunks)


func bpm_to_tempo(bpm:int):
	# Microseconds per quarter note = 60,000,000 / BPM
	return int(60_000_000.0 / bpm)

func tempo_to_bpm(tempo:int):
	# Microseconds per quarter note = 60,000,000 / BPM
	return int(tempo * 60_000_000.0)
