; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$" 
    window_width dw 140h                 ;the width of the window (320 pixels)
	window_height dw 0c8h                ;the height of the window (200 pixels)
	window_bounds dw 6                   ;variable used to check collisions early
	
	time_aux db 0                        ;variable used when checking if the time has changed
	game_active db 1                     ;is the game active? (1 -> yes, 0 -> no (game over))
	exiting_game db 0
	winner_index db 0                    ;the index of the winner (1 -> player one, 2 -> player two)
	current_scene db 0                   ;the index of the current scene (0 -> main menu, 1 -> game)
	
	text_player_one_points db '0','$'    ;text with the player one points
	text_player_two_points db '0','$'    ;text with the player two points
	text_game_over_title db 'game over','$' ;text with the game over menu title
	text_game_over_winner db 'player 0 won','$' ;text with the winner text
	text_game_over_play_again db 'press r to play again','$' ;text with the game over play again message
	text_game_over_main_menu db 'press e to exit to main menu','$' ;text with the game over main menu message
	text_main_menu_title db 'main menu','$' ;text with the main menu title
	text_main_menu_game db 'game - s key','$' ;text with the singleplayer message
	text_main_menu_exit db 'exit game - e key','$' ;text with the exit game message
	
	ball_original_x dw 0a0h              ;x position of the ball on the beginning of a game
	ball_original_y dw 64h               ;y position of the ball on the beginning of a game
	
	ball_two_original_x dw 0a0h              ;x position of the ball 2 on the beginning of a game
	ball_two_original_y dw 46h               ;y position of the ball 2 on the beginning of a game
	
	ball_three_original_x dw 0a0h              ;x position of the ball 3 on the beginning of a game
	ball_three_original_y dw 28h               ;y position of the ball 3 on the beginning of a game 
	
	ball_four_original_x dw 0a0h              ;x position of the ball 4 on the beginning of a game
	ball_four_original_y dw 78h               ;y position of the ball 4 on the beginning of a game
	
	ball_five_original_x dw 0a0h              ;x position of the ball 5 on the beginning of a game
	ball_five_original_y dw 96h               ;y position of the ball 5 on the beginning of a game
	
	ball_x dw 0a0h                       ;current x position (column) of the ball
	ball_y dw 64h                        ;current y position (line) of the ball 
	
	ball_two_x dw 0a0h                       ;current x 2 position (column) of the ball
	ball_two_y dw 46h                        ;current y 2 position (line) of the ball 
	
	ball_three_x dw 0a0h                       ;current x 3 position (column) of the ball
	ball_three_y dw 28h                        ;current y 3 position (line) of the ball 
	
	ball_four_x dw 0a0h                       ;current x 4 position (column) of the ball
	ball_four_y dw 78h                        ;current y 4 position (line) of the ball  
	
	ball_five_x dw 0a0h                       ;current x 5 position (column) of the ball
	ball_five_y dw 96h                        ;current y 5 position (line) of the ball 
	
	ball_size dw 06h                     ;size of the ball (how many pixels does the ball have in width and height) 
	
	ball_velocity_x dw 0bh               ;x (horizontal) velocity of the ball
	ball_velocity_y dw 02h               ;y (vertical) velocity of the ball 
	
	ball_two_velocity_x dw 0bh               ;x 2 (horizontal) velocity of the ball 
	ball_two_velocity_y dw 02h               ;y 2 (vertical) velocity of the ball  
	
	ball_three_velocity_x dw 0bh               ;x 3 (horizontal) velocity of the ball 
	ball_three_velocity_y dw 02h               ;y 3 (vertical) velocity of the ball
	 
	ball_four_velocity_x dw 0bh               ;x 4 (horizontal) velocity of the ball 
	ball_four_velocity_y dw 02h               ;y 4 (vertical) velocity of the ball 
	
	ball_five_velocity_x dw 0bh               ;x 5 (horizontal) velocity of the ball 
	ball_five_velocity_y dw 02h               ;y 5 (vertical) velocity of the ball
	
	rocket_left_original_x  dw 43h
	rocket_left_original_y  dw 0afh
	
	rocket_right_original_x dw 0eeh
	rocket_right_original_y dw 0afh
	
	rocket_left_x dw 43h                 ;current x position of the left rocket
	rocket_left_y dw 0afh                 ;current y position of the left rocket
	player_one_points db 0              ;current points of the left player (player one)
	
	rocket_right_x dw 0eeh               ;current x position of the right rocket
	rocket_right_y dw 0afh                ;current y position of the right rocket
	player_two_points db 0             ;current points of the right player (player two)
	
	rocket_width dw 0ah                  ;default rocket width
	rocket_height dw 11h                 ;default rocket height
	rocket_velocity dw 05h              ;default rocket velocity
	
	middle_line_x dw 99h
	middle_line_y dw 0h
	
	middle_line_width dw 05h
	middle_line_height dw 0c8h  
	
	temp_ball_x dw 0h
	temp_ball_y dw 0h
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here
            
    push ds                              ;push to the stack the ds segment
	sub ax,ax                            ;clean the ax register
	push ax                              ;push ax to the stack
	mov ax,data                          ;save on the ax register the contents of the data segment
	mov ds,ax                            ;save on the ds segment the contents of ax
	pop ax                               ;release the top item from the stack to the ax register
	pop ax                               ;release the top item from the stack to the ax register
		
		call clear_screen                ;set initial video mode configurations
		
		check_time:                      ;time checking loop
			
			cmp exiting_game,01h
			je start_exit_process
			
			cmp current_scene,00h
			je show_main_menu
			
			cmp game_active,00h
			je show_game_over
			
			mov ah,2ch 					 ;get the system time
			int 21h    					 ;ch = hour cl = minute dh = second dl = 1/100 seconds
			
			cmp dl,time_aux  			 ;is the current time equal to the previous one(time_aux)?
			je check_time    		     ;if it is the same, check again 
			
			
;           if it reaches this point, it's because the time has passed
  
			mov time_aux,dl              ;update time
			
			call clear_screen            ;clear the screen by restarting the video mode
			
			call draw_middle_line
			
			call move_ball               ;move the ball
			call draw_ball               ;draw the ball
			
			call move_rockets            ;move the two rockets (check for pressing of keys)
			call draw_rockets            ;draw the two rockets with the updated positions
			
			call draw_ui                 ;draw the game user interface
			
			jmp check_time               ;after everything checks time again
			
			show_game_over:
				call draw_game_over_menu
				jmp check_time
				
			show_main_menu:
				call draw_main_menu
				jmp check_time
				
			start_exit_process:
				call conclude_exit_game
				

	
	
	
	
	proc move_ball                   ;proccess the movement of the ball
		
;       move the ball horizontally
		mov ax,ball_velocity_x    
		add ball_x,ax
		mov ax,ball_x
		mov temp_ball_x,ax 
		mov ax,ball_y  
		mov temp_ball_y,ax 
		call check_collision_with_right_rocket  
				
		mov ax,ball_two_velocity_x    
		sub ball_two_x,ax  
		mov ax,ball_two_x
		mov temp_ball_x,ax 
		mov ax,ball_two_y  
		mov temp_ball_y,ax 
		call check_collision_with_right_rocket
		
		mov ax,ball_three_velocity_x    
		add ball_three_x,ax
		mov ax,ball_three_x
		mov temp_ball_x,ax 
		mov ax,ball_three_y  
		mov temp_ball_y,ax 
		call check_collision_with_right_rocket
		
		mov ax,ball_four_velocity_x    
		sub ball_four_x,ax 
		mov ax,ball_four_x
		mov temp_ball_x,ax 
		mov ax,ball_four_y  
		mov temp_ball_y,ax 
		call check_collision_with_right_rocket 
		
		mov ax,ball_five_velocity_x    
		add ball_five_x,ax    
		mov ax,ball_five_x
		mov temp_ball_x,ax 
		mov ax,ball_five_y  
		mov temp_ball_y,ax 
		call check_collision_with_right_rocket
		
	
		                 
		
;       check if the ball has passed the left boundarie (ball_x < 0 + window_bounds)
;       if is colliding, restart its position		
		mov ax,window_bounds
		cmp ball_x,ax                    ;ball_x is compared with the left boundarie of the screen (0 + window_bounds) 
		jl reset_balls                                          
                                         ;if is less, give one point to the player two and reset ball position
	
		
;       check if the ball has passed the right boundarie (ball_x > window_width - ball_size  - window_bounds)
;       if is colliding, restart its position		
		mov ax,window_width
		sub ax,ball_size
		sub ax,window_bounds
		cmp ball_x,ax                ;ball_x is compared with the right boundarie of the screen (ball_x > window_width - ball_size  - window_bounds) 
		jg reset_balls  ;if is greater, give one point to the player one and reset ball position
		jmp check_win 
								

		reset_balls:
		    call reset_ball_position     ;reset ball position to the center of the screen
			call reset_ball_two_position 
			call reset_ball_three_position
			call reset_ball_four_position 
			call reset_ball_five_position
			ret 
	    
	    check_win:
		          
		mov ax,window_bounds
		add ax,rocket_height 
		cmp rocket_left_y,ax                    ;ball_x is compared with the left boundarie of the screen (0 + window_bounds) 
		jl give_point_to_player_one 
		
		mov ax,window_bounds 
		add ax,rocket_height 
		cmp rocket_right_y,ax                    ;ball_x is compared with the left boundarie of the screen (0 + window_bounds) 
		jl give_point_to_player_two
		jmp close
		
		give_point_to_player_one:		 ;give one point to the player one and reset ball position
			inc player_one_points       ;increment player one points
			call update_text_player_one_points ;update the text of the player one points
			call reset_rocket_left_position
			cmp player_one_points,05h   ;check if this player has reached 5 points
			jge game_over                ;if this player points is 5 or more, the game is over
			ret
		
		give_point_to_player_two:        ;give one point to the player two and reset ball position
			inc player_two_points      ;increment player two points
			call update_text_player_two_points ;update the text of the player two points
			call reset_rocket_right_position
			cmp player_two_points,05h  ;check if this player has reached 5 points
			jge game_over                ;if this player points is 5 or more, the game is over
			ret
			
		game_over:                       ;someone has reached 5 points
			cmp player_one_points,05h    ;check wich player has 5 or more points
			jnl winner_is_player_one     ;if the player one has not less than 5 points is the winner
			jmp winner_is_player_two     ;if not then player two is the winner
			
			winner_is_player_one:
				mov winner_index,01h     ;update the winner index with the player one index
				jmp continue_game_over
			winner_is_player_two:
				mov winner_index,02h     ;update the winner index with the player two index
				jmp continue_game_over
				
			continue_game_over:
				mov player_one_points,00h   ;restart player one points
				mov player_two_points,00h  ;restart player two points
				call update_text_player_one_points
				call update_text_player_two_points
				mov game_active,00h            ;stops the game
				ret 

		
	    		
                                
        
                                    
		
		close:		
			mov ax,00h
			add ball_y,ax  
			
			
                    
		ret	
	move_ball endp 
	
	proc check_collision_with_right_rocket 
        ; check if the ball is colliding with the right rocket
		; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
		; ball_x + ball_size > rocket_right_x && ball_x < rocket_right_x + rocket_width 
		; && ball_y + ball_size > rocket_right_y && ball_y < rocket_right_y + rocket_height
		
		mov ax,temp_ball_x
		add ax,ball_size
		cmp ax,rocket_right_x
		jng check_collision_with_left_rocket  ;if there's no collision check for the left rocket collisions
		
		mov ax,rocket_right_x
		add ax,rocket_width
		cmp temp_ball_x,ax
		jnl check_collision_with_left_rocket  ;if there's no collision check for the left rocket collisions
		
		mov ax,temp_ball_y
		add ax,ball_size
		cmp ax,rocket_right_y
		jng check_collision_with_left_rocket  ;if there's no collision check for the left rocket collisions
		
		mov ax,rocket_right_y
		add ax,rocket_height
		cmp temp_ball_y,ax
		jnl check_collision_with_left_rocket  ;if there's no collision check for the left rocket collisions 

		
;       if it reaches this point, the ball is colliding with the right rocket

		jmp reset_player_right_pos
		
	    
		

;       check if the ball is colliding with the left rocket
	    check_collision_with_left_rocket:
		; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
		; ball_x + ball_size > rocket_left_x && ball_x < rocket_left_x + rocket_width 
		; && ball_y + ball_size > rocket_left_y && ball_y < rocket_left_y + rocket_height
		
		mov ax,temp_ball_x
		add ax,ball_size
		cmp ax,rocket_left_x
		jng exit_collision_check  ;if there's no collision exit procedure
		
		mov ax,rocket_left_x
		add ax,rocket_width
		cmp temp_ball_x,ax
		jnl exit_collision_check ;if there's no collision exit procedure
		
		mov ax,temp_ball_y
		add ax,ball_size
		cmp ax,rocket_left_y
		jng exit_collision_check  ;if there's no collision exit procedure
		
		mov ax,rocket_left_y
		add ax,rocket_height
		cmp temp_ball_y,ax
		jnl exit_collision_check  ;if there's no collision exit procedure 
		
		
;       if it reaches this point, the ball is colliding with the left rocket	

		jmp reset_player_left_pos 
		
		reset_player_left_pos: 
	        mov ax,43h
            mov rocket_left_x,ax
        
            mov ax,0afh
            mov	rocket_left_y,ax
			ret
	    reset_player_right_pos: 
	        mov ax,0eeh
            mov rocket_right_x,ax
        
            mov ax,0afh
            mov	rocket_right_y,ax
			ret                            
			
		exit_collision_check:
			ret
		   
		    
		check_collision_with_right_rocket endp
	
	
	
	proc move_rockets               ;process movement of the rockets
		
;       left rocket movement
		
		;check if any key is being pressed (if not check the other rocket)
		mov ah,01h
		int 16h
		jz check_right_rocket_movement ;zf = 1, jz -> jump if zero
		
		;check which key is being pressed (al = ascii character)
		mov ah,00h
		int 16h
		
		;if it is 'w' or 'w' move up
		cmp al,77h ;'w'
		je move_left_rocket_up
		cmp al,57h ;'w'
		je move_left_rocket_up
		
		;if it is 's' or 's' move down
		cmp al,73h ;'s'
		je move_left_rocket_down
		cmp al,53h ;'s'
		je move_left_rocket_down
		jmp check_right_rocket_movement
		
		move_left_rocket_up:
			mov ax,rocket_velocity
			sub rocket_left_y,ax
			
			mov ax,window_bounds
			cmp rocket_left_y,ax
			jl fix_rocket_left_top_position
			jmp check_right_rocket_movement
			
			fix_rocket_left_top_position:
				mov rocket_left_y,ax
				jmp check_right_rocket_movement
			
		move_left_rocket_down:
			mov ax,rocket_velocity
			add rocket_left_y,ax
			mov ax,window_height
			sub ax,window_bounds
			sub ax,rocket_height
			cmp rocket_left_y,ax
			jg fix_rocket_left_bottom_position
			jmp check_right_rocket_movement
			
			fix_rocket_left_bottom_position:
				mov rocket_left_y,ax
				jmp check_right_rocket_movement
		
		
;       right rocket movement
		check_right_rocket_movement:
		
			;if it is 'o' or 'o' move up
			cmp al,6fh ;'o'
			je move_right_rocket_up
			cmp al,4fh ;'o'
			je move_right_rocket_up
			
			;if it is 'l' or 'l' move down
			cmp al,6ch ;'l'
			je move_right_rocket_down
			cmp al,4ch ;'l'
			je move_right_rocket_down
			jmp exit_rocket_movement
			

			move_right_rocket_up:
				mov ax,rocket_velocity
				sub rocket_right_y,ax
				
				mov ax,window_bounds
				cmp rocket_right_y,ax
				jl fix_rocket_right_top_position
				jmp exit_rocket_movement
				
				fix_rocket_right_top_position:
					mov rocket_right_y,ax
					jmp exit_rocket_movement
			
			move_right_rocket_down:
				mov ax,rocket_velocity
				add rocket_right_y,ax
				mov ax,window_height
				sub ax,window_bounds
				sub ax,rocket_height
				cmp rocket_right_y,ax
				jg fix_rocket_right_bottom_position
				jmp exit_rocket_movement
				
				fix_rocket_right_bottom_position:
					mov rocket_right_y,ax
					jmp exit_rocket_movement
		
		exit_rocket_movement:
		
			ret
		
	move_rockets endp
	
	proc reset_ball_position         ;restart ball position to the original position
		
		mov ax,ball_original_x
		mov ball_x,ax
		
		mov ax,ball_original_y
		mov ball_y,ax
		
		neg ball_velocity_x
		neg ball_velocity_y
		
		ret
	reset_ball_position endp
	
	proc reset_ball_two_position 
	    mov ax,ball_two_original_x
		mov ball_two_x,ax
		
		mov ax,ball_two_original_y
		mov ball_two_y,ax
		
		neg ball_two_velocity_x
		neg ball_two_velocity_y
		
		ret
	reset_ball_two_position endp 
	
	proc reset_ball_three_position 
	    mov ax,ball_three_original_x
		mov ball_three_x,ax
		
		mov ax,ball_three_original_y
		mov ball_three_y,ax
		
		neg ball_three_velocity_x
		neg ball_three_velocity_y
		
		ret
	reset_ball_three_position endp 
	
	proc reset_ball_four_position 
	    mov ax,ball_four_original_x
		mov ball_four_x,ax
		
		mov ax,ball_four_original_y
		mov ball_four_y,ax
		
		neg ball_four_velocity_x
		neg ball_four_velocity_y
		
		ret
	reset_ball_four_position endp 
	
	proc reset_ball_five_position 
	    mov ax,ball_five_original_x
		mov ball_five_x,ax
		
		mov ax,ball_five_original_y
		mov ball_five_y,ax
		
		neg ball_five_velocity_x
		neg ball_five_velocity_y
		
		ret
	reset_ball_five_position endp
	
	proc reset_rocket_left_position 
	    mov ax,rocket_left_original_x
		mov rocket_left_x,ax
		
		mov ax,rocket_left_original_y
		mov rocket_left_y,ax
		
		ret
	reset_rocket_left_position endp 
	                                 
	proc reset_rocket_right_position 
	    mov ax,rocket_right_original_x
		mov rocket_right_x,ax
		
		mov ax,rocket_right_original_y
		mov rocket_right_y,ax 
		
		ret
	reset_rocket_right_position endp
	
	proc draw_middle_line  
	    mov cx,middle_line_x                    ;set the initial column (x)
		mov dx,middle_line_y                    ;set the initial line (y) 
		
		draw_middle_line_horizontal:
			mov ah,0ch                   ;set the configuration to writing a pixel
			mov al,0fh 					 ;choose white as color
			mov bh,00h 					 ;set the page number 
			int 10h    					 ;execute the configuration
			
			inc cx     					 ;cx = cx + 1
			mov ax,cx          	  		 
			sub ax,middle_line_x
			cmp ax,middle_line_width
			jng draw_middle_line_horizontal
			
			mov cx,middle_line_x 				 ;the cx register goes back to the initial column
			inc dx       				 ;we advance one line
			
			mov ax,dx             		 
			sub ax,middle_line_y
			cmp ax,middle_line_height
			jng draw_middle_line_horizontal
	    
	    ret
	draw_middle_line endp
	    
	
	proc draw_ball                  
		
		mov cx,ball_x                    ;set the initial column (x)
		mov dx,ball_y                    ;set the initial line (y)
		
		draw_ball_horizontal:
			mov ah,0ch                   ;set the configuration to writing a pixel
			mov al,0fh 					 ;choose white as color
			mov bh,00h 					 ;set the page number 
			int 10h    					 ;execute the configuration
			
			inc cx     					 ;cx = cx + 1
			mov ax,cx          	  		 ;cx - ball_x > ball_size (y -> we go to the next line,n -> we continue to the next column
			sub ax,ball_x
			cmp ax,ball_size
			jng draw_ball_horizontal
			
			mov cx,ball_x 				 ;the cx register goes back to the initial column
			inc dx       				 ;we advance one line
			
			mov ax,dx             		 ;dx - ball_y > ball_size (y -> we exit this procedure,n -> we continue to the next line
			sub ax,ball_y
			cmp ax,ball_size
			jng draw_ball_horizontal
			
		mov cx,ball_two_x                    ;set the initial column (x)
		mov dx,ball_two_y                    ;set the initial line (y)
		
		draw_ball_two_horizontal:
			mov ah,0ch                   ;set the configuration to writing a pixel
			mov al,0fh 					 ;choose white as color
			mov bh,00h 					 ;set the page number 
			int 10h    					 ;execute the configuration
			
			inc cx     					 ;cx = cx + 1
			mov ax,cx          	  		 ;cx - ball_x > ball_size (y -> we go to the next line,n -> we continue to the next column
			sub ax,ball_two_x
			cmp ax,ball_size
			jng draw_ball_two_horizontal
			
			mov cx,ball_two_x 				 ;the cx register goes back to the initial column
			inc dx       				 ;we advance one line
			
			mov ax,dx             		 ;dx - ball_y > ball_size (y -> we exit this procedure,n -> we continue to the next line
			sub ax,ball_two_y
			cmp ax,ball_size
			jng draw_ball_two_horizontal  
		
		mov cx,ball_three_x                    ;set the initial column (x)
		mov dx,ball_three_y                    ;set the initial line (y)
		
		draw_ball_three_horizontal:
			mov ah,0ch                   ;set the configuration to writing a pixel
			mov al,0fh 					 ;choose white as color
			mov bh,00h 					 ;set the page number 
			int 10h    					 ;execute the configuration
			
			inc cx     					 ;cx = cx + 1
			mov ax,cx          	  		 ;cx - ball_x > ball_size (y -> we go to the next line,n -> we continue to the next column
			sub ax,ball_three_x
			cmp ax,ball_size
			jng draw_ball_three_horizontal
			
			mov cx,ball_three_x 				 ;the cx register goes back to the initial column
			inc dx       				 ;we advance one line
			
			mov ax,dx             		 ;dx - ball_y > ball_size (y -> we exit this procedure,n -> we continue to the next line
			sub ax,ball_three_y
			cmp ax,ball_size
			jng draw_ball_three_horizontal 
		
		mov cx,ball_four_x                    ;set the initial column (x)
		mov dx,ball_four_y                    ;set the initial line (y)
		
		draw_ball_four_horizontal:
			mov ah,0ch                   ;set the configuration to writing a pixel
			mov al,0fh 					 ;choose white as color
			mov bh,00h 					 ;set the page number 
			int 10h    					 ;execute the configuration
			
			inc cx     					 ;cx = cx + 1
			mov ax,cx          	  		 ;cx - ball_x > ball_size (y -> we go to the next line,n -> we continue to the next column
			sub ax,ball_four_x
			cmp ax,ball_size
			jng draw_ball_four_horizontal
			
			mov cx,ball_four_x 				 ;the cx register goes back to the initial column
			inc dx       				 ;we advance one line
			
			mov ax,dx             		 ;dx - ball_y > ball_size (y -> we exit this procedure,n -> we continue to the next line
			sub ax,ball_four_y
			cmp ax,ball_size
			jng draw_ball_four_horizontal
			
		mov cx,ball_five_x                    ;set the initial column (x)
		mov dx,ball_five_y                    ;set the initial line (y)
		
		draw_ball_five_horizontal:
			mov ah,0ch                   ;set the configuration to writing a pixel
			mov al,0fh 					 ;choose white as color
			mov bh,00h 					 ;set the page number 
			int 10h    					 ;execute the configuration
			
			inc cx     					 ;cx = cx + 1
			mov ax,cx          	  		 ;cx - ball_x > ball_size (y -> we go to the next line,n -> we continue to the next column
			sub ax,ball_five_x
			cmp ax,ball_size
			jng draw_ball_five_horizontal
			
			mov cx,ball_five_x 				 ;the cx register goes back to the initial column
			inc dx       				 ;we advance one line
			
			mov ax,dx             		 ;dx - ball_y > ball_size (y -> we exit this procedure,n -> we continue to the next line
			sub ax,ball_five_y
			cmp ax,ball_size
			jng draw_ball_five_horizontal
		
		ret
	draw_ball endp
	
	proc draw_rockets 
		
		mov cx,rocket_left_x 			 ;set the initial column (x)
		mov dx,rocket_left_y 			 ;set the initial line (y)
		
		draw_rocket_left_horizontal:
			mov ah,0ch 					 ;set the configuration to writing a pixel
			mov al,0fh 					 ;choose white as color
			mov bh,00h 					 ;set the page number 
			int 10h    					 ;execute the configuration
			
			inc cx     				 	 ;cx = cx + 1
			mov ax,cx         			 ;cx - rocket_left_x > rocket_width (y -> we go to the next line,n -> we continue to the next column
			sub ax,rocket_left_x
			cmp ax,rocket_width
			jng draw_rocket_left_horizontal
			
			mov cx,rocket_left_x 		 ;the cx register goes back to the initial column
			inc dx       				 ;we advance one line
			
			mov ax,dx            	     ;dx - rocket_left_y > rocket_height (y -> we exit this procedure,n -> we continue to the next line
			sub ax,rocket_left_y
			cmp ax,rocket_height
			jng draw_rocket_left_horizontal
			
			
		mov cx,rocket_right_x 			 ;set the initial column (x)
		mov dx,rocket_right_y 			 ;set the initial line (y)
		
		draw_rocket_right_horizontal:
			mov ah,0ch 					 ;set the configuration to writing a pixel
			mov al,0fh 					 ;choose white as color
			mov bh,00h 					 ;set the page number 
			int 10h    					 ;execute the configuration
			
			inc cx     					 ;cx = cx + 1
			mov ax,cx         			 ;cx - rocket_right_x > rocket_width (y -> we go to the next line,n -> we continue to the next column
			sub ax,rocket_right_x
			cmp ax,rocket_width
			jng draw_rocket_right_horizontal
			
			mov cx,rocket_right_x		 ;the cx register goes back to the initial column
			inc dx       				 ;we advance one line
			
			mov ax,dx            	     ;dx - rocket_right_y > rocket_height (y -> we exit this procedure,n -> we continue to the next line
			sub ax,rocket_right_y
			cmp ax,rocket_height
			jng draw_rocket_right_horizontal
			
		ret
	draw_rockets endp
	
	proc draw_ui 
		
;       draw the points of the left player (player one)
		
		mov ah,02h                       ;set cursor position
		mov bh,00h                       ;set page number
		mov dh,01h                       ;set row 
		mov dl,09h						 ;set column
		int 10h							 
		
		mov ah,09h                       ;write string to standard output
		lea dx,text_player_one_points    ;give dx a pointer to the string text_player_one_points
		int 21h                          ;print the string 
		
;       draw the points of the right player (player two)
		
		mov ah,02h                       ;set cursor position
		mov bh,00h                       ;set page number
		mov dh,01h                       ;set row 
		mov dl,1eh						 ;set column
		int 10h							 
		
		mov ah,09h                       ;write string to standard output
		lea dx,text_player_two_points    ;give dx a pointer to the string text_player_one_points
		int 21h                          ;print the string 
		
		ret
	draw_ui endp
	
	proc update_text_player_one_points 
		
		xor ax,ax
		mov al,player_one_points ;given, for example that p1 -> 2 points => al,2
		
		;now, before printing to the screen, we need to convert the decimal value to the ascii code character 
		;we can do this by adding 30h (number to ascii)
		;and by subtracting 30h (ascii to number)
		add al,30h                       ;al,'2'
		mov [text_player_one_points],al
		
		ret
	update_text_player_one_points endp
	
	proc update_text_player_two_points 
		
		xor ax,ax
		mov al,player_two_points ;given, for example that p2 -> 2 points => al,2
		
		;now, before printing to the screen, we need to convert the decimal value to the ascii code character 
		;we can do this by adding 30h (number to ascii)
		;and by subtracting 30h (ascii to number)
		add al,30h                       ;al,'2'
		mov [text_player_two_points],al
		
		ret
	update_text_player_two_points endp
	
	proc draw_game_over_menu         ;draw the game over menu
		
		call clear_screen                ;clear the screen before displaying the menu

;       shows the menu title
		mov ah,02h                       ;set cursor position
		mov bh,00h                       ;set page number
		mov dh,04h                       ;set row 
		mov dl,04h						 ;set column
		int 10h							 
		
		mov ah,09h                       ;write string to standard output
		lea dx,text_game_over_title      ;give dx a pointer 
		int 21h                          ;print the string

;       shows the winner
		mov ah,02h                       ;set cursor position
		mov bh,00h                       ;set page number
		mov dh,06h                       ;set row 
		mov dl,04h						 ;set column
		int 10h							 
		
		call update_winner_text
		
		mov ah,09h                       ;write string to standard output
		lea dx,text_game_over_winner      ;give dx a pointer 
		int 21h                          ;print the string
		
;       shows the play again message
		mov ah,02h                       ;set cursor position
		mov bh,00h                       ;set page number
		mov dh,08h                       ;set row 
		mov dl,04h						 ;set column
		int 10h							 

		mov ah,09h                       ;write string to standard output
		lea dx,text_game_over_play_again      ;give dx a pointer 
		int 21h                          ;print the string
		
;       shows the main menu message
		mov ah,02h                       ;set cursor position
		mov bh,00h                       ;set page number
		mov dh,0ah                       ;set row 
		mov dl,04h						 ;set column
		int 10h							 

		mov ah,09h                       ;write string to standard output
		lea dx,text_game_over_main_menu      ;give dx a pointer 
		int 21h                          ;print the string
		
;       waits for a key press
		mov ah,00h
		int 16h

;       if the key is either 'r' or 'r', restart the game		
		cmp al,'r'
		je restart_game
		cmp al,'r'
		je restart_game
;       if the key is either 'e' or 'e', exit to main menu
		cmp al,'e'
		je exit_to_main_menu
		cmp al,'e'
		je exit_to_main_menu
		ret
		
		restart_game: 
		    call reset_rocket_left_position
		    call reset_rocket_right_position
			mov game_active,01h
			ret
		
		exit_to_main_menu:
			mov game_active,00h
			mov current_scene,00h
			ret
			
	draw_game_over_menu endp
	
	proc draw_main_menu 
		
		call clear_screen
		
;       shows the menu title
		mov ah,02h                       ;set cursor position
		mov bh,00h                       ;set page number
		mov dh,04h                       ;set row 
		mov dl,04h						 ;set column
		int 10h							 
		
		mov ah,09h                       ;write string to standard output
		lea dx,text_main_menu_title      ;give dx a pointer 
		int 21h                          ;print the string
		
;       shows the game message
		mov ah,02h                       ;set cursor position
		mov bh,00h                       ;set page number
		mov dh,06h                       ;set row 
		mov dl,04h						 ;set column
		int 10h							 
		
		mov ah,09h                       ;write string to standard output
		lea dx,text_main_menu_game      ;give dx a pointer 
		int 21h                          ;print the string
		
		
;       shows the exit message
		mov ah,02h                       ;set cursor position
		mov bh,00h                       ;set page number
		mov dh,08h                       ;set row 
		mov dl,04h						 ;set column
		int 10h							 
		
		mov ah,09h                       ;write string to standard output
		lea dx,text_main_menu_exit      ;give dx a pointer 
		int 21h                          ;print the string	
		
		main_menu_wait_for_key:
;       waits for a key press
			mov ah,00h
			int 16h
		
;       check whick key was pressed
			cmp al,'s'
			je start_game
			cmp al,'S'
			je start_game

			cmp al,'e'
			je exit_game
			cmp al,'E'
			je exit_game
			jmp main_menu_wait_for_key
			
		start_game:
			mov current_scene,01h
			mov game_active,01h
			ret
		
		exit_game:
			mov exiting_game,01h
			ret

	draw_main_menu endp
	
	proc update_winner_text 
		
		mov al,winner_index              ;if winner index is 1 => al,1
		add al,30h                       ;al,31h => al,'1'
		mov [text_game_over_winner+7],al ;update the index in the text with the character
		
		ret
	update_winner_text endp
	
	proc clear_screen                ;clear the screen by restarting the video mode
	
			mov ah,00h                   ;set the configuration to video mode
			mov al,13h                   ;choose the video mode
			int 10h    					 ;execute the configuration 
		
			mov ah,0bh 					 ;set the configuration
			mov bh,00h 					 ;to the background color
			mov bl,00h 					 ;choose black as background color
			int 10h    					 ;execute the configuration
			
			ret
			
	clear_screen endp
	
	proc conclude_exit_game         ;goes back to the text mode
		
		mov ah,00h                   ;set the configuration to video mode
		mov al,02h                   ;choose the video mode
		int 10h    					 ;execute the configuration 
		
		mov ah,4ch                   ;terminate program
		int 21h  
		
        ret
	conclude_exit_game endp
	
ends

end start ; set entry point and stop the assembler.
