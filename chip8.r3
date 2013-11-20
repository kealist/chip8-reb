REBOL[
    ; -- Core Header attributes --
    title: "Chip8 Emulator"
    file: %chip8.r3
    version: 0.0.8
    date: 2013-11-14/21:03:26
    author: "Joshua Shireman"
    purpose: {To emulate the CHIP8 instruction set interpreter with display}
    web: http://www.github.com/kealist
    source-encoding: "Windows-1252"

    ; -- Licensing details  --
    copyright: "Copyright © 2013 Joshua Shireman"
    license-type: "Apache License v2.0"
    license: {Copyright © 2013 Joshua Shireman

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.}

    ;-  / history
    history: {
        v0.0.1 - 2013-11-14
            -Initial header entry. There are a few things needed to implement.  This most recent version has implemented file loading for the games.
        v0.0.2 - 2013-11-14
            -Fixed a few OPCODE bugs related to poking binary values.   Started implementation of controls, but unfunctional
        v0.0.3 - 2013-11-14
            -Implemented Cyphre's sytle to detect the key presses for the 16 keypad.  Currently they just print, but they will be extended to set a variable when pressed or NONE when the key up event occurs
        v0.0.4 - 2013-11-19
            - Cleaned up some code repetition by creating two new functions set-vx and set-vy
        v0.0.5 - 2013-11-19
            -Cleaned up more repetition with new functions get-vx and get-vy
        v0.0.6 - 2013-11-19
            -Removed extraneous code and changed keyboard control code to be tested.
        v0.0.7 - 2013-11-19
            -Substituted vprint for print in preparation for using SLIM.  Cleaned up some various comments and code.  Added a KEYPRESSED? variable initialization
        v0.0.8 - 2013-11-20
            -fixed collision detection by adding alpha channel to logic test}
    ;-  \ history

    ;-  / documentation
    documentation: {    
         Only requirements are to run the file with (do %chip8.r3) and
         Currently it requires a folder full of %games/}
    ;-  \ documentation
]



vprint: :print

load-gui
keypressed?: none
moved?: false

stylize [
    ;backup the original window style to be able call the original key actor
    window-orig: window []

    ;override window style with our key actor
    window: window [
        actors: [
            on-key: [
                ;execute our key controls prior to 'system' key handling
                switch arg/type [
                    key [
                        ;here you can handle key-down events
                        keypressed?: switch/default arg/key [
                            #"1" [1]
                            #"2" [2]
                            #"3" [3]
                            #"4" [4]
                            #"q" [5]
                            #"w" [6]
                            #"e" [7]
                            #"r" [8]
                            #"a" [9]
                            #"s" [10]
                            #"d" [11]
                            #"f" [12]
                            #"z" [13]
                            #"x" [14]
                            #"c" [15]
                            #"v" [16]
                            
                        ][
                            false
                        ]
                    ]
                    key-up [
                        ;here you can handle key-up events
                    ]
                ]
                ;for example filter out faces that shouldn't get the system key events (for example editable styles)
                 unless all [
                    ;moved?
                    guie/focal-face
                    tag-face? guie/focal-face 'edit
                 ][
                    ;handle the system key handling
                    do-actor/style face 'on-key arg 'window-orig
                ]
            ]
        ]
    ]
]


load-files: func [dir /local data files] [
    data: copy []
    files: read dir
    foreach file files [
        append data to-string file
        insert head file dir
        append/only data read file
    ]
    data
]   

game-list: load-files %games/

chip8: make object! [
    ;;opcode must be 2 bytes
    opcode: none
    
    ; 4k memory total
    ;;;0x000-0x1FF - Chip 8 interpreter (contains font set in emu)
    ;;;0x050-0x0A0 - Used for the built in 4x5 pixel font set (0-F)
    ;;;0x200-0xFFF - Program ROM and work RAM

    program: none
    memory: #{00}

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
    ;The system's buzzer sounds whenever the sound timer reaches zero.
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
        print "Chip 8 Emulator Initialized..."
        
        game-names: copy []
        game-data: copy []
        foreach [game data] game-list [
            append game-names game
            append game-data data
        ]
        program: pick game-data 1
        
        view m: layout [
            drop-down game-names on-action [
                set 'program pick game-data (get-face face)
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
                    ;vprint reduce ["Setting memory location " (num + 512) " to value of " (pick program num)] 
                    poke memory (num + 512) to-integer (pick program num)
                ]
                vprint "Chip 8 Emulator Running Program..."
                code: [chip8/emulate-cycle]
                set-timer/repeat code (0:0:1 / chip8/hertz)
            ]
            button "Stop" on-action [
                foreach [t code] guie/timers [
                    clear-timer t
                ]
            ]
            screen: image ; options [min-size: 640x320 max-size: 640x320]
            when [enter] on-action [        
                ;initialize game object             
                set-face screen gfx-img
            ]
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
    get-vx: func [
        o-c [binary!]
    ][
        pick v (get-x o-c)
    ]
    get-vy: func [
        o-c [binary!]
    ][
        pick v (get-y o-c)
    ]
    set-vx: func [
        o-c [binary!]
        value
    ][
        poke v (get-x o-c) value
    ]
    set-vy: func [
        o-c [binary!]
        value
    ][
        poke v (get-y o-c) value
    ]

    increment-pc: does [pc: pc + 2]
    
    fetch-opcode: func [/local u] [
        u: copy #{0000}
        vprint [{>>PC:} pc]
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
                        vprint [{------------------------>Clearing the screen}]
                        gfx-img: make image! to-pair reduce [64 * gfx-scale 32 * gfx-scale] bg-color
                        draw-face/now screen
                        increment-pc
                    ]
                    #{000E} [
                        ; returns from subroutine
                        sp: sp - 1
                        pc: pick stack sp
                        increment-pc
                        vprint [{------------------------>Returning from subroutine to pc =} pc]
                    ]
                    
                ] [
                    ;0NNN; Run program at address NNN
                    
                    pc: 1 + to-integer (oc and #{0FFF})
                    vprint [{------------------------>Running program at address} pc]
                    ;prin "ERROR: Unknown 0x0XXX OPCODE:" print oc 
                    ;increment-pc
                ]
            ]
            #{1000} [
                ;; Jumps to address NNN.
                vprint [{------------------------>} oc {: Jumping to address} 1 + to-integer (oc and #{0FFF})]
                pc: 1 + to-integer (oc and #{0FFF})
            ]
            #{2000} [
                ;; Calls subroutine at NNN.
                poke stack sp pc
                sp: sp + 1
                u: (oc and #{0FFF})
                ;pc: to-integer (oc and #{0FFF})
                pc: 1 + to-integer (oc and #{0FFF})
                vprint ["------------------------>Subroutine at memory index " pc " = " (pick memory pc) (pick memory (pc + 1))]
            ]
            #{3000} [
                ;; Skips the next instruction if VX equals NN.
                nn: to-integer (oc and #{00FF})
                vprint [{------------------------>V[} (get-x oc) {] =} (get-vx oc) {will skip if equal to} nn {and is} ((get-vx oc) = nn)]
                either ((get-vx oc) = nn) [
                    increment-pc
                    increment-pc
                ] [increment-pc]        
            ]
            #{4000} [
                ;; Skips the next instruction if VX doesn't equal NN.
                nn: (oc and #{00FF})
                vprint [{------------------------>V[} (get-x oc) {] =} (get-vx oc) {will skip if not equal to} nn {and is} ((get-vx oc) = nn)]
                either ((get-vx oc) != nn) [
                    increment-pc
                    increment-pc
                ] [increment-pc]
            ]
            #{5000} [
                ;; Skips the next instruction if VX equals VY.
                vprint [{------------------------>v[x]:} (get-vx oc) {v[y]} (get-vy oc) {=} ((get-vx oc) = (get-vy oc))]
                either ((get-vx oc) = (get-vy oc)) [
                    increment-pc
                    increment-pc
                ] [increment-pc]
            ]
            #{6000} [
                ;; Sets VX to NN.
                nn: to-integer (oc and #{00FF})
                vprint [{------------------------>Set V[} (get-x oc) {] to } nn {-->} to-integer nn]
                set-vx oc nn
                increment-pc
            ]
            #{7000} [
                ;; Adds NN to VX.
                nn: to-integer (oc and #{00FF})
                vprint [{------------------------>Adding} nn {to the value of v[} (get-x oc) {]=} get-vx oc {=>} (nn + to-integer (get-vx oc))]
                set-vx oc (remainder (num: nn + (get-vx oc)) 256)
                if ((num / 256) > 1) [poke v 15 1]
                increment-pc
            ]
            #{8000} [
                switch/default (oc and #{000F}) [
                    #{0000} [
                        ;8XY0;Sets VX to the value of VY.
                        vprint [{------------------------>Set v[x]=} (get-x oc) {to} (get-vy oc)]
                        set-vx oc (get-vy oc)
                        increment-pc
                    ]
                    #{0001} [
                        ;8XY1;Sets VX to VX or VY.
                        vprint [{------------------------>Set v[x]=} (get-x oc) {to} ((get-vx oc) or (get-vy oc))]
                        set-vx oc ((get-vx oc) or (get-vy oc))
                        increment-pc
                    ]
                    #{0002} [
                        ;8XY2;Sets VX to VX and VY.
                        vprint [{------------------------>Set v[x]=} (get-x oc) {to} ((get-vx oc) and (get-vy oc))]
                        set-vx oc ((get-vx oc) and (get-vy oc))
                        increment-pc
                    ]
                    #{0003} [
                        ;8XY3;Sets VX to VX xor VY.
                        vprint [{------------------------>Set v[x]=} (get-x oc) {to} ((get-vx oc) xor (get-vy oc))]
                        set-vx oc ((get-vx oc) xor (get-vy oc))
                        increment-pc
                    ]
                    #{0004} [
                        ;; 8XY4 adds register V[x] and V[y], setting v[16] flag if overflowed
                        vprint [{------------------------>}]
                        either (w: get-vy oc) > (255 - x: get-vx oc) [
                            poke v 16 1
                        ] [
                            poke v 16 0
                        ]
                        set-vy oc (w + x)
                        increment-pc
                    ]
                    #{0005} [
                        ;8XY5;VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
                        vprint [{------------------------>}]
                        increment-pc
                    ]
                    #{0006} [
                        ;8XY6;Shifts VX right by one. VF is set to the value of the least significant bit of VX before the shift.
                        vprint [{------------------------>}]
                        increment-pc
                    ]
                    #{0007} [
                        ;8XY6;Sets VX to VY minus VX. VF is set to 0 when there's a borrow, and 1 when there isn't.
                        vprint [{------------------------>}]
                        increment-pc
                    ]
                    #{000E} [
                        ;;Shifts VX left by one. VF is set to the value of the most significant bit of VX before the shift.
                        vprint [{------------------------>}]
                        increment-pc
                    ]
                ] [prin "ERROR: Unknown 0x8XXX OPCODE:" print oc increment-pc]
            ]
            #{9000} [
                ;; Skips the next instruction if VX doesn't equal VY.
                nn: to-integer (oc and #{00FF})
                vprint [{------------------------>V[ } (get-x oc) {] =} (get-vx oc) {will skip if not equal to} nn {and is} ((get-vx oc) = nn)]
                either ((get-vx oc) != nn) [
                    increment-pc
                    increment-pc
                ] [increment-pc]    
            ]
            #{A000} [
                ;;Sets I to the address NNN.
                vprint[{------------------------>Set I to} to-integer (oc and #{0FFF})]
                i: to-integer (oc and #{0FFF})
                increment-pc
            ]
            #{B000} [
                ;;Jumps to the address NNN plus V0.
                
                nnn: to-integer (oc and #{0FFF})
                vprint [{------------------------>Jump to address} nnn + (pick v 0)]
                pc: nnn + (pick v 0)
            ]
            #{C000} [
                ;;Sets VX to a random number and NN.
                nn: to-integer oc and #{00FF}
                m: random 256
                vprint[{------------------------>Setting v[} get-x oc {]:} m {and} nn {=} m and nn]
                set-vx oc to-integer ((random 256) and nn)
                increment-pc
            ]
            #{D000} [
                ;;0xDXYN Draws a sprite at coordinate vx, vy that has a width of 8 pixels and a height of N pixels.  Each row of 8 pixels is read as bit-coded starting from memory location I; I value doesnâ€™t change after the execution of this instruction. As described above, VF is set to 1 if any screen pixels are flipped from set to unset when the sprite is drawn, and to 0 if that doesnâ€™t happen.
                ;print ["0xDXYN:" opcode]
                
                height: to-integer (oc and #{000F})
                poke v 16 0
                x-coord: (to-integer get-vx oc)
                y-coord: (to-integer get-vy oc)
                vprint [{------------------------>Draw sprite} i {at} x-coord {x} y-coord {of height} height]
                
                repeat num height [
                    ;print (i + num - 1)
                    r: (pick memory (i + num))
                    w: enbase/base (append copy #{} r) 2
                    vprint [{pattern is} w]
                    ;;m corresponds to the number of bits in m
                    repeat m 8 [
                        if ((first w) = #"1") [
                            coord-pair: to-pair reduce [(gfx-scale * (x-coord + m - 1)) (gfx-scale * (y-coord + num - 1))]
                            ;;Collision Detection
                            ;;vprint [{Collision Detection:} (pick gfx-img coord-pair)  bg-color "="(pick gfx-img coord-pair) = bg-color]
                            either  ((pick gfx-img coord-pair) = 0.0.0.255) [
                                vprint {Collision detected}
                                ;;Draw a GFX-SCALE x GFX-SCALE pixel
                                poke v 16 1
                                repeat num-y gfx-scale [
                                    repeat num-x gfx-scale [
                                        draw-pair: coord-pair + to-pair reduce [num-x - 1 num-y - 1]
                                        ;vprint [{Drew at} draw-pair {from} coord-pair]
                                        poke gfx-img draw-pair ink-color
                                    ]
                                ]
                            ] [
                                ;;Draw a GFX-SCALE x GFX-SCALE pixel
            
                                repeat num-y gfx-scale [
                                    repeat num-x gfx-scale [
                                        draw-pair: coord-pair + to-pair reduce [num-x - 1 num-y - 1]
                                        ;vprint [{Drew at} draw-pair {from} coord-pair]
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
                        vprint [{------------------------>}]
                        either ((get-vx oc) = keypressed?) [
                            increment-pc
                            increment-pc
                        ][
                            increment-pc
                        ]
                    ]
                    #{00A1} [
                        ;;Skips the next instruction if the key stored in VX isn't pressed.
                        vprint [{------------------------>}]
                        either (get-vx oc) = keypressed? [
                            increment-pc
                        ][
                            increment-pc
                            increment-pc
                        ]
                    ]
                ] [prin "ERROR: Unknown 0xEXXX OPCODE:" print oc increment-pc]
            ]
            #{F000} [
                switch/default (oc and #{00FF}) [
                    #{0007} [
                        ;;Sets VX to the value of the delay timer.
                        vprint [{------------------------>Set V[} get-x oc {:} (get-timer-value delay-timer)]
                        set-vx oc (get-timer-value delay-timer)
                        increment-pc
                    ]
                    #{000A} [
                        ;;A key press is awaited, and then stored in VX.
                        vprint [{------------------------>}]
                        increment-pc
                    ]
                    #{0015} [
                        ;;Sets the delay timer to VX.
                        vprint [{------------------------>Set delay-timer to} get-vx oc]
                        delay-timer: set-timer [vprint "Delay timer done"] get-vx oc
                        increment-pc
                    ]
                    #{0018} [
                        ;;Sets the sound timer to VX.
                        vprint [{------------------------>Play Sound (unimplemented)}]
                        sound-timer: set-timer [vprint BEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEP!] get-vx oc
                        increment-pc
                    ]
                    #{001E} [
                        ;;Adds VX to I.
                        m: i
                        i: i + get-vx oc
                        vprint [{------------------------>Set i:} i {=} m {+ v[x]=} get-vx oc]
                        increment-pc
                    ]
                    #{0029} [
                        ;;Sets I to the location of the sprite for the character in VX. Characters 0-F (in hexadecimal) are represented by a 4x5 font.
                        i: to-integer get-vx oc
                        vprint [{------------------------>Set i:} i {to the value of v[} (get-x oc) {] =} to-integer get-vx oc {which is the character} (pick memory to-integer (get-vx oc))]
                        increment-pc    
                    ]
                    #{0033} [
                        ;; Stores BCD representation of VX at address I, I + 1 and I + 2
                        m: to-integer get-vx oc
                        poke memory i (x: remainder m 10)
                        poke memory (i + 1) (((y: remainder m 100) - x) / 10)
                        poke memory (i + 2) ((m - y) / 100)
                        vprint [{------------------------>Set BCD at memory[i]:} x {memory[i+1]:} y {memory [i+2]:} (m - y) / 100]
                        increment-pc
                    ]
                    #{0055} [
                        ;;Stores V0 to VX in memory starting at address I.
                        repeat num 16 [
                            vprint [{------------------------>Set memory[} (i - 1 + num) {] =} (pick v num)]
                            poke memory (i - 1 + num) (pick v num)
                        ]
                        increment-pc
                    ]
                    #{0065} [
                        ;;Fills V0 to VX with values from memory starting at address I.
                        repeat num 16 [
                            vprint [{------------------------>Set V[} num {] =} (pick memory (i + num - 1))]
                            poke v num (pick memory (i + num - 1))
                        ]
                        increment-pc
                    ]
                ] [prin "ERROR: Unknown 0xFXXX OPCODE:" print oc increment-pc]
            ]
        ] [prin "ERROR: Unknown OPCODE:" print oc increment-pc]
    ]

    update-gfx: does [
        draw-face/now screen; gfx-img
        ;wait 1
    ]
    
    update-timers: does [
        
    ]
    emulate-cycle: does [
        opcode: fetch-opcode
        vprint [{>Fetched opcode:} opcode]
        decode-opcode opcode
        update-timers
    ]
]

vprint "Chip 8 Emulator Starting..."

chip8/initialize

vprint "Clearing Timers"
foreach [t code] guie/timers [
    clear-timer t
]

vprint "Chip 8 Emulator Halting..."
halt
