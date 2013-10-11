REBOL[
	title: "Chip 8 Emulator"
	author: "Joshua Shireman"
	version: 0.0.1
	date: Aug-08-2013
]

load-gui

fonttest: #{
60006106620C63126418A000D005A005D105A00AD205A00FD305A014D015A019
D115A01ED215A023D315A028D025A02DD125A032D225A037D325A03CD035A041
D135A046D235A04BD335
}

merlin: #{
1219204D45524C494E2042792044617669642057494E54455222F9A31D601061
0022CBA331600B611B22CB640422DF6500622822C1C2038020A359F51EF05560
176108630183223300700A630283223300710AA317D016621422C1D016620522
C1750154501235650060176108A317F30A330412796300129733051283700A63
0112973307128D710A6302129733081269700A710A6303D016621422C1D016A3
59F51EF0657501503012B55540126922DF7401122D22F9A3456010610E22CB12
BFF215F207320012C300EE83006205D015F21E700885307520505012CF00EEA3
59834073FDF333F265F129602B631BD0357005F229D03500EEA30F60176107D0
18700AD018710AD01870F6D01800EEFF818181818181FF7E7E7E7E7E7EDBAA8B
CBCBEF088F0DECA0A0B030BE5F5151D9D983828382FBE8088805E2BEA0B8203E
80808080F8F785B795F576545654563A2A2A2A39B6A5B6A535
}

pong: #{
6A026B0C6C3F6D0CA2EADAB6DCD66E0022D4660368026060F015F0073000121A
C717770869FFA2F0D671A2EADAB6DCD66001E0A17BFE6004E0A17B02601F8B02
DAB6600CE0A17DFE600DE0A17D02601F8D02DCD6A2F0D67186848794603F8602
611F871246021278463F1282471F69FF47006901D671122A68026301807080B5
128A68FE630A807080D53F0112A2610280153F0112BA80153F0112C880153F01
12C26020F01822D48E3422D4663E3301660368FE33016802121679FF49FE69FF
12C87901490269016004F0187601464076FE126CA2F2FE33F265F12964146500
D4557415F229D45500EE808080808080800000000000
}

wall: #{
12182057414C4C2062792044617669642057494E54455220A2E460006100621E
D011D021700830401220A2DF603E6101D0157105311A1230D0146300C40F7408
650184516503660267018840780269016A046B00A2DAD345D781FC0A22C46C01
FC15FC073C001262A2DA8C708D80E99E127C4401127CD34574FED345EA9E128A
4419128AD3457402D3458754886447016503473D65FD48016602481D66FEDCD1
D7813701125E8C808C456D009CD012BE7D013D0512ACFC0A22C46B00125C22C4
7B01125CA2E5FB336C346D02F265F129DCD57C05F229DCD500EE8080808080E0
E0E0E0E0FF
}

chip8: make object! [
	;;opcode must be 2 bytes
	opcode: none

	
	; 4k memory total
	;;;0x000-0x1FF - Chip 8 interpreter (contains font set in emu)
	;;;0x050-0x0A0 - Used for the built in 4x5 pixel font set (0-F)
	;;;0x200-0xFFF - Program ROM and work RAM

	program: none
	memory: #{00}
	;memory-test: ;

	;CPU Register, 15 8-bit registers, 16th is carry flag
	v: #{00}
	
	;index register I
	i: none

	; program counter PC
	pc: none

	;gfx: array gfx-size: (64 * 32)
	gfx-scale: 10
	bg-color: black
	ink-color: white
	gfx-img: make image! reduce [to-pair reduce [64 * gfx-scale 32 * gfx-scale] ink-color]
	draw-flag: false
	
	hertz: 20
	
	;Timers count at 60 Hz. When set above zero they will count down to zero
	;The system’s buzzer sounds whenever the sound timer reaches zero.
	delay-timer: 0
	sound-timer: 0
	
	get-timer-value: func [
		timer-id [integer!]
		/local u
	][
		either (u: second select guie/timers timer-id) [
			either ((m: now/time - u/time) < 0:0:0) [0] [to-integer m]
		][
			0
		]
	]
	

	stack: copy array 16
	sp: none

	key: copy array 16
	fontset: #{F0909090F02060202070F010F080F0F010F010F09090F01010F080F010F0F080F090F0F010204040F090F090F0F090F010F0F090F09090E090E090E0F0808080F0E0909090E0F080F080F0F080F08080} 
	
	initialize: func [/local u] [
		random/seed now/time/precise
		repeat num 4095 [append memory #{00}]
		repeat num 15 [append v #{00}]
		pc: 513
		opcode: #{0000}
		i: 1
		sp: 1
		
		;;load fontset --> Should be in #{0050} to #{00A0} which translates to memory index 81 to 161
		repeat num 80 [poke memory (num) to-integer (pick fontset num)]
		
		
		program: merlin
		

		print "Chip 8 Emulator Initialized..."
		
		view/maximized m: layout [
			drop-down ["merlin" "pong" "wall" "fonttest"] on-action [
				switch (get-face face) [
					1 [set 'program merlin] 
					2 [set 'program pong] 
					3 [set 'program wall] 
					4 [set 'program fonttest] 
				]
			]
			button "Start" on-action [
				;set 'gfx-img make image! reduce [to-pair reduce [64 * gfx-scale 32 * gfx-scale] ink-color]
				set 'memory copy #{00}
				set 'v copy #{00}
				repeat num 4095 [append memory #{00}]
				repeat num 15 [append v #{00}]
				set 'pc 513
				set 'opcode copy #{0000}
				i: 1
				sp: 1
		
				set 'stack copy array 16
				set 'key copy array 16
				
				;;load fontset --> Should be in #{0050} to #{00A0} which translates to memory index 81 to 161
				repeat num 80 [poke memory (num) to-integer (pick fontset num)]

				;;load game to memory -> 
				repeat num (length? program) [
					;print reduce ["Setting memory location " (num + 512) " to value of " (pick program num)] 
					poke memory (num + 512) to-integer (pick program num)
				]
			    print "Chip 8 Emulator Running Program..."
				code: [chip8/emulate-cycle]
				set-timer/repeat code (0:0:1 / chip8/hertz)
			]
			button "Stop" on-action [
				foreach [t code] guie/timers [
					clear-timer t
				]
			]
			img1: image gfx-img 
			
		] 
	]
	load-program: does [
		repeat num (length? program) [
			poke memory (num + 512) (pick program num)
		]
	]
	get-x: func [
		o-c [binary!]
	] [
		(1 + shift to-integer (o-c and #{0F00}) -8)
	]
	get-y: func [o-c] [
		(1 + shift to-integer (o-c and #{00F0}) -4)
	]
	
	increment-pc: does [pc: pc + 2]
	
	fetch-opcode: func [/local u] [
		u: copy #{0000}
		print [{>>PC:} pc]
		poke u 1 to-integer (pick memory pc)
		poke u 2 to-integer (pick memory pc + 1)
		u
		;return append copy (pick memory pc) copy (pick memory (pc + 1))
	]
	
	decode-opcode: func [
		oc /local n m w x u x-coord y-coord height
	] [
		wait 0
		switch/default (oc and #{F000}) [
			
			#{0000} [
				switch/default (oc and #{000F}) [
					#{0000} [					
						;;clear the screen
						print [{------------------------>Clearing the screen}]
						gfx-img: make image! to-pair reduce [64 * gfx-scale 32 * gfx-scale] bg-color
						draw-face/now img1
						increment-pc
					]
					#{000E} [
						; returns from subroutine
						sp: sp - 1
						pc: pick stack sp
						increment-pc
						print [{------------------------>Returning from subroutine to pc =} pc]
					]
					
				] [
					;0NNN; Run program at address NNN
					
					pc: 1 + to-integer (oc and #{0FFF})
					print [{------------------------>Running program at address} pc]
					;prin "ERROR: Unknown 0x0XXX OPCODE:" print oc 
					;increment-pc
				]
			]
			#{1000} [
				;; Jumps to address NNN.
				print [{------------------------>} oc {: Jumping to address} 1 + to-integer (oc and #{0FFF})]
				pc: 1 + to-integer (oc and #{0FFF})
			]
			#{2000} [
				;; Calls subroutine at NNN.
				poke stack sp pc
				sp: sp + 1
				u: (oc and #{0FFF})
				;pc: to-integer (oc and #{0FFF})
				pc: 1 + to-integer (oc and #{0FFF})
				print ["------------------------>Subroutine at memory index " pc " = " (pick memory pc) (pick memory (pc + 1))]
			]
			#{3000} [
				;; Skips the next instruction if VX equals NN.
				nn: to-integer (oc and #{00FF})
				print [{------------------------>V[ } (get-x oc) {] =} (pick v (get-x oc)) {will skip if equal to} nn {and is} ((pick v (get-x oc)) = nn)]
				either ((pick v (get-x oc)) = nn) [
					increment-pc
					increment-pc
				] [increment-pc]		
			]
			#{4000} [
				;; Skips the next instruction if VX doesn't equal NN.
				nn: (oc and #{00FF})
				print [{------------------------>V[ } (get-x oc) {] =} (pick v (get-x oc)) {will skip if not equal to} nn {and is} ((pick v (get-x oc)) = nn)]
				either ((pick v (get-x oc)) != nn) [
					increment-pc
					increment-pc
				] [increment-pc]
			]
			#{5000} [
				;; Skips the next instruction if VX equals VY.
				print [{------------------------>v[x]:} (pick v (get-x oc)) {v[y]} (pick v (get-y oc)) {=} ((pick v (get-x oc)) = (pick v (get-y oc)))]
				either ((pick v (get-x oc)) = (pick v (get-y oc))) [
					increment-pc
					increment-pc
				] [increment-pc]
			]
			#{6000} [
				;; Sets VX to NN.
				nn: to-integer (oc and #{00FF})
				print [{------------------------>Set V[} (get-x oc) {] to } nn {-->} to-integer nn]
				poke v (get-x oc) nn
				increment-pc
			]
			#{7000} [
				;; Adds NN to VX.
				nn: to-integer (oc and #{00FF})
				print [{------------------------>Adding} nn {to the value of v[} (get-x oc) {]=} pick v (get-x oc) {=>} (nn + to-integer (pick v (get-x oc)))]
				poke v (get-x oc) (remainder (num: nn + (pick v (get-x oc))) 256)
				if ((num / 256) > 1) [poke v 15 1]
				increment-pc
			]
			#{8000} [
				switch/default (oc and #{000F}) [
					#{0000} [
						;8XY0;Sets VX to the value of VY.
						print [{------------------------>Set v[x]=} (get-x oc) {to} (pick v (get-y oc))]
						poke v (get-x oc) (pick v (get-y oc))
						increment-pc
					]
					#{0001} [
					;8XY1;Sets VX to VX or VY.
						print [{------------------------>Set v[x]=} (get-x oc) {to} ((pick v (get-x oc)) or (pick v (get-y oc)))]
						poke v (get-x oc) ((pick v (get-x oc)) or (pick v (get-y oc)))
						increment-pc
					]
					#{0002} [
					;8XY2;Sets VX to VX and VY.
						print [{------------------------>Set v[x]=} (get-x oc) {to} ((pick v (get-x oc)) and (pick v (get-y oc)))]
						poke v (get-x oc) ((pick v (get-x oc)) and (pick v (get-y oc)))
						increment-pc
					]
					#{0003} [
					;8XY3;Sets VX to VX xor VY.
						print [{------------------------>Set v[x]=} (get-x oc) {to} ((pick v (get-x oc)) xor (pick v (get-y oc)))]
						poke v (get-x oc) ((pick v (get-x oc)) xor (pick v (get-y oc)))
						increment-pc
					]
					#{0004} [
						;; 8XY4 adds register V[x] and V[y], setting v[16] flag if overflowed
						print [{------------------------>}]
						either (w: pick v get-y) > (255 - x: pick v get-x) [
							poke v 16 #{01}
						] [
							poke v 16 #{00}
						]
						poke v (get-y oc) (w + x)
						increment-pc
					]
					#{0005} [
						;8XY5;VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
						print [{------------------------>}]
						increment-pc
					]
					#{0006} [
						;8XY6;Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.
						print [{------------------------>}]
						increment-pc
					]
					#{0007} [
						;8XY6;Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
						print [{------------------------>}]
						increment-pc
					]
					#{000E} [
						;;Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.
						print [{------------------------>}]
						increment-pc
					]
				] [prin "ERROR: Unknown 0x8XXX OPCODE:" print oc increment-pc]
			]
			#{9000} [
				;; Skips the next instruction if VX doesn't equal VY.
				nn: to-integer (oc and #{00FF})
				print [{------------------------>V[ } (get-x oc) {] =} (pick v (get-x oc)) {will skip if not equal to} nn {and is} ((pick v (get-x oc)) = nn)]
				either ((pick v (get-x oc)) != nn) [
					increment-pc
					increment-pc
				] [increment-pc]	
			]
			#{A000} [
				;;Sets I to the address NNN.
				print[{------------------------>Set I to} to-integer (oc and #{0FFF})]
				i: to-integer (oc and #{0FFF})
				increment-pc
			]
			#{B000} [
				;;Jumps to the address NNN plus V0.
				
				nnn: to-integer (oc and #{0FFF})
				print [{------------------------>Jump to address} nnn + (pick v 0)]
				pc: nnn + (pick v 0)
			]
			#{C000} [
				;;Sets VX to a random number and NN.
				nn: to-integer oc and #{00FF}
				m: random 256
				print[{------------------------>Setting v[} get-x oc {]:} m {and} nn {=} m and nn]
				poke v (get-x oc) to-integer ((random 256) and nn)
				increment-pc
			]
			#{D000} [
				;;0xDXYN Draws a sprite at coordinate vx, vy that has a width of 8 pixels and a height of N pixels.  Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesn’t change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesn’t happen.
				;print ["0xDXYN:" opcode]
				
				height: to-integer (oc and #{000F})
				poke v 16 0
				x-coord: (to-integer pick v (get-x oc))
				y-coord: (to-integer pick v (get-y oc))
				print [{------------------------>Draw sprite} i {at} x-coord {x} y-coord {of height} height]
				
				repeat num height [
					;print (i + num - 1)
					r: (pick memory (i + num))
					w: enbase/base (append copy #{} r) 2
					print [{pattern is} w]
					;;m corresponds to the number of bits in m
					repeat m 8 [
						if ((first w) = #"1") [
							coord-pair: to-pair reduce [(gfx-scale * (x-coord + m - 1)) (gfx-scale * (y-coord + num - 1))]
							;;Collision Detection
							either  ((pick gfx-img coord-pair) = bg-color) [
								print {Collision detected}
								poke v 16 #{01}
								repeat num-y gfx-scale [
									repeat num-x gfx-scale [
										draw-pair: coord-pair + to-pair reduce [num-x - 1 num-y - 1]
										;print [{Drew at} draw-pair {from} coord-pair]
										poke gfx-img draw-pair ink-color
									]
								]
							] [
								;;Draw a GFX-SCALE x GFX-SCALE pixel
			
								repeat num-y gfx-scale [
									repeat num-x gfx-scale [
										draw-pair: coord-pair + to-pair reduce [num-x - 1 num-y - 1]
										;print [{Drew at} draw-pair {from} coord-pair]
										poke gfx-img draw-pair bg-color
									]
								]						
							]
						]
						w: next w
					]					
				]
				increment-pc
				update-gfx
				draw-flag: true				
			]
			#{E000} [
				switch/default (oc and #{00FF}) [
					#{009E} [
						;;Skips the next instruction if the key stored in VX is pressed.
						print[{------------------------>}]
						(oc and #{0F00})
					]
					#{00A1} [
						;;Skips the next instruction if the key stored in VX isn't pressed.
						print[{------------------------>}]
					]
				] [prin "ERROR: Unknown 0xEXXX OPCODE:" print oc increment-pc]
			]
			#{F000} [
				switch/default (oc and #{00FF}) [
					#{0007} [
						;;Sets VX to the value of the delay timer.
						print[{------------------------>Set V[} get-x oc {:} (get-timer-value delay-timer)]
						;print (get-timer-value delay-timer)
						poke v (get-x oc) (get-timer-value delay-timer)
						increment-pc
					]
					#{000A} [
						;;A key press is awaited, and then stored in VX.
						print[{------------------------>}]
						increment-pc
					]
					#{0015} [
						;;Sets the delay timer to VX.
						print[{------------------------>Set delay-timer to} pick v (get-x oc)]
						delay-timer: set-timer [print "Delay timer done"] pick v (get-x oc)
						increment-pc
					]
					#{0018} [
						;;Sets the sound timer to VX.
						print[{------------------------>}]
						sound-timer: set-timer [print BEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEP!] pick v (get-x oc)
						increment-pc
					]
					#{001E} [
						;;Adds VX to I.
						m: i
						i: i + pick v (get-x oc)
						print[{------------------------>Set i:} i {=} m {+ v[x]=} pick v (get-x oc)]
						increment-pc
					]
					#{0029} [
						;;Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
						;i: 1 + (5 * to-integer pick v (get-x oc))
						i: to-integer pick v (get-x oc)
						print [{------------------------>Set i:} i {to the value of v[} (get-x oc) {] =} to-integer pick v (get-x oc) {which is the character} (pick memory to-integer (pick v (get-x oc)))]
						increment-pc	
					]
					#{0033} [
						;; Stores BCD representation of VX at address I, I + 1 and I + 2
						m: to-integer pick v (get-x oc)
						poke memory i (x: remainder m 10)
						poke memory (i + 1) (((y: remainder m 100) - x) / 10)
						poke memory (i + 2) ((m - y) / 100)
						print [{------------------------>Set BCD at memory[i]:} x {memory[i+1]:} y {memory [i+2]:} (m - y) / 100]
						increment-pc
					]
					#{0055} [
						;;Stores V0 to VX in memory starting at address I.
						repeat num 16 [
							print [{------------------------>Set memory[} (i - 1 + num) {] =} (pick v num)]
							poke memory (i - 1 + num) (pick v num)
						]
						increment-pc
					]
					#{0065} [
						;;Fills V0 to VX with values from memory starting at address I.
						repeat num 16 [
							print [{------------------------>Set V[} num {] =} (pick memory (i + num - 1))]
							poke v num (pick memory (i + num - 1))
						]
						increment-pc
					]
				] [prin "ERROR: Unknown 0xFXXX OPCODE:" print oc increment-pc]
			]
		] [prin "ERROR: Unknown OPCODE:" print oc increment-pc]
	]
	to-bcd: func [bin /local bcd-table w x y z] [
		bcd-table: [
			0	[2#{00000000}]
			1	[2#{00010001}]
			2	[2#{00100010}]
			3	[2#{00110011}]
			4	[2#{01000100}]
			5	[2#{01010101}]
			6	[2#{01100110}]
			7	[2#{01110111}]
			8	[2#{10001000}]
			9	[2#{10011001}]
		]
		w: to-integer bin
		x: remainder w 10
		y: ((remainder w 100) - x) / 10
		z: (w -(remainder w 100)) / 100
		append (#{00} or ((switch z bcd-table) and #{0F}))
			((switch x bcd-table) and #{0F}) or ((switch y bcd-table) and #{F0})
	]

	update-gfx: does [
		draw-face/now img1; gfx-img
		;wait 1
	]
	
	update-timers: does [
		
	]
	emulate-cycle: does [
		opcode: fetch-opcode
		print [{>Fetched opcode:} opcode]
		decode-opcode opcode
		update-timers
	]
]

print "Chip 8 Emulator Starting..."

chip8/initialize

print "Clearing Timers"
foreach [t code] guie/timers [
	clear-timer t
]

print "Chip 8 Emulator Halting..."
halt
