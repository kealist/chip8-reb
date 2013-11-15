REBOL [    author: "cyphre@seznam.cz"] 

load-gui 

;image for game 

screenimg: make image! 400x400 

;just some example game object

game-object: context [
    offset: 0x0
    draw-block: [
		pen red        
		fill-pen white        
		line-width 5        
		circle offset 20
	]    
	move: func [
		delta [pair!]
	][   
		offset: offset + delta
        screenimg/rgb: black
        ;note: this is not optimal way how to render DRAW objects
        ;but I use image! here because the asking SO user uses image! as well
        ;better way is to just use DRAWING style for DRAW based graphics
        draw screenimg to-draw draw-block copy []
        draw-face game-screen        
		;signal true move has been executed        
		return true    
	]
] 

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
							moved?: switch/default arg/key [
								up [
									game-object/move 0x-5
								]
								down [
									game-object/move 0x5
								]                            
								left [                                
									game-object/move -5x0
								]                            
								right [                                
									game-object/move 5x0                            
								]                        
							][                            
								false                        
							]                    
						]                    
						key-up [                      
							;here you can handle key-up events   
							false
						]
					]                
					
					;for example filter out faces that shouldn't get the system key events (for example editable styles) 
					unless all [                    
						moved?
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

view [
    title "Custom keyboard handling (whole window)"    
	text "press cursor keys to move the box"    
	game-screen: image options [min-size: 400x400 max-size: 400x400]    
	text 400 "focus the field below and press to see these keys are filtered out, but other keys works normally"    
	field "lorem ipsum"    
	when [enter] on-action [        
		;initialize game object        
		game-object/move 200x200  	
		set-face game-screen screenimg
	]
]