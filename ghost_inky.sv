module ghost_inky(input          Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [9:0]   pacmanPosX, pacmanPosY,
					input [9:0]	  blinkyPosX, blinkyPosY,
					input 		  ate_pellet, soft_reset, hard_reset, new_map,
					input logic [7:0] keycode,
					input [3:0] PacmanCurrentDir,
					input [19:0] points_eaten,
					output logic is_inky, is_inky_dead, pacman_dead, output logic [3:0] inky_sprite, inky_is_frightened,
					output logic [9:0] inkyPosX, inkyPosY, output [19:0] score);
					
	logic [9:0] targetX, targetY, last_direction_squareX, last_direction_squareY, targetY_rand, targetX_rand;
	logic [3:0] nextDirection, nextDirectionCalc, frames_since_last, inkycurrentDirection;
	logic is_collision, forceDown;
	
	logic [3:0] availible_dir;
	
	valid_moves moves(.*, .PosX(inkyPosX), .PosY(inkyPosY), .is_Ghost(1));
	next_dir nextDir_calc(.targetX(targetX), .targetY(targetY), .ghostPosX(inkyPosX), .ghostPosY(inkyPosY), .availible_dir(availible_dir),
		.currentDirection(inkycurrentDirection), .nextDirection(nextDirectionCalc));
	
	enum logic [5:0] { Halted, 
					left_fr1, left_fr2, left_fr3, left_fr4, left_fr5, left_fr6, left_fr7, left_fr8,
					right_fr1, right_fr2, right_fr3, right_fr4, right_fr5, right_fr6, right_fr7, right_fr8,
					up_fr1, up_fr2, up_fr3, up_fr4, up_fr5, up_fr6, up_fr7, up_fr8,
					down_fr1, down_fr2, down_fr3, down_fr4, down_fr5, down_fr6, down_fr7, down_fr8} State, Next_state;
		
	initial
	begin
		inkycurrentDirection = 3'd2;
		nextDirection = 3'd2;
		inkyPosY = 10'D192 + 10'd36;
		inkyPosX = 10'd228 + 10'd24;
		inky_sprite = 3'd4;
				reset_completed = 1'b0;
		reset_next_frame = 1'b0;
		State = Halted;
		ghostState = waitforLevelStart;
		frames_since_last = 4'd0;
		timer_seconds = 0;
		round = 0;
		ghostLastState = scatter;
		pacman_dead = 0;
		score = 0;
	end

	
	
	logic [6:0] timer, timer_seconds, round, frightened_timer, frightened_timer_ticks;
	logic round_add;
	
	always_comb
	begin
		is_inky = 1'b0;
		is_collision = 1'b0;

		if((DrawY - inkyPosY - 6 < 24) && (DrawY - inkyPosY - 6 >= 0) && (DrawX - inkyPosX < 24) && (DrawX - inkyPosX >= 0) && DrawX >= 72 && DrawX < 408)
			is_inky = 1'b1;
		if(inkyPosY - pacmanPosY >= 0 && inkyPosY - pacmanPosY < 18)
		begin
			if(inkyPosX - pacmanPosX >= 0 && inkyPosX - pacmanPosX < 18)
			begin
				is_collision = 1'b1;
			end
			else if(pacmanPosX - inkyPosX >= 0 && pacmanPosX - inkyPosX < 18)
			begin
				is_collision = 1'b1;
			end
		end
		else if(pacmanPosY - inkyPosY >= 0 && pacmanPosY - inkyPosY < 18)
		begin
			if(inkyPosX - pacmanPosX >= 0 && inkyPosX - pacmanPosX < 18)
			begin
				is_collision = 1'b1;
			end
			else if(pacmanPosX - inkyPosX >= 0 && pacmanPosX - inkyPosX < 18)
			begin
				is_collision = 1'b1;
			end
		end
		
	end	

	
	
	
	enum logic [2:0] { waitforLevelStart, chase, scatter, frightened, dead } ghostState, ghostNext_state, ghostLastState;
	
logic timer_reset;

always_ff @ (posedge frame_clk)
begin
	if(round_add)
		round <= round + 1;
		
	if(ghostState == scatter || ghostState == chase)
		timer <= timer + 1;
		
	if(timer >= 60)
	begin
		timer_seconds <= timer_seconds + 1;
		timer <= 0;
	end
	
	if(timer_reset)
	begin
		timer <= 0;
		timer_seconds <= 0;
	end
	
	if(ghostState == frightened)
	begin
		frightened_timer_ticks <= frightened_timer_ticks + 1;
	end
	if(frightened_timer_ticks >= 60 && frightened_timer <= 16)
	begin
		frightened_timer <= frightened_timer + 1;
		frightened_timer_ticks <= 0;
	end
	if(ate_pellet && ghostState == frightened)
	begin
		frightened_timer <= 0;
		frightened_timer_ticks <= 0;
	end
	
	if(ghostNext_state == frightened && ghostState != frightened && ghostState != dead)
	begin
		frightened_timer <= 0;
		ghostLastState <= ghostState;
	end
	
	if(is_collision && (ghostState != frightened && ghostState != dead))
	begin
		pacman_dead <= 1'b1;
	end
	
	if(is_collision && ghostState == frightened)
	begin
		score <= score + 200;
	end
	
	ghostState <= ghostNext_state;
	targetY_rand <= random_seed1[10:0];
	targetX_rand <= random_seed2[10:0];
	
	if (reset_next_frame || hard_reset)
	begin
		timer <= 0;
		timer_seconds <= 0;
		round <= 0;
		ghostLastState <= scatter;
		ghostState <= waitforLevelStart;
		
		frightened_timer <= 0;
		frightened_timer_ticks <= 0;
		targetY_rand <= 0;
		targetX_rand <= 0;
		pacman_dead <= 0;
		score <= 0;
	end
	
	if(soft_reset || new_map)
	begin
		timer <= 0;
		timer_seconds <= 0;
		round <= 0;
		ghostLastState <= scatter;
		ghostState <= waitforLevelStart;
		
		frightened_timer <= 0;
		frightened_timer_ticks <= 0;
		targetY_rand <= 0;
		targetX_rand <= 0;
		pacman_dead <= 0;
	end
	
	
end
	logic ghost_in_box;
	
always_comb
begin
	ghostNext_state = ghostState;
	targetX = pacmanPosX;
	targetY = pacmanPosY;
	timer_reset = 1'b0;
	round_add = 1'b0;
	ghost_in_box = 1'b0;
	
	if(inkyPosY >= 216 && inkyPosY <= 240 && ((((inkyPosX / 12) - 6) == 15) || (((inkyPosX / 12) - 6) == 14) || (((inkyPosX / 12) - 6) == 13)))
	begin
		ghost_in_box = 1'b1;
	end
	if(((((inkyPosX / 12) - 6) == 13)) && ((inkyPosY / 12 - 6) == 11 || (inkyPosY / 12 - 6) == 10))
	begin
		ghost_in_box = 1'b1;
	end
	
	
	case(ghostState)
		waitforLevelStart:
		begin
			if(PacmanCurrentDir > 0 && points_eaten >= 30)
			begin
				ghostNext_state = scatter;
			end
		end
		
		chase: 
		begin
			if(ate_pellet && ghostState != waitforLevelStart && ghostState != dead && ~ghost_in_box)
			begin
				ghostNext_state = frightened;
			end
			else if(timer_seconds > 19 && round < 3 ) 
			begin
				ghostNext_state = scatter;
				timer_reset = 1'b1;
				round_add = 1'b1;
			end
		end
		
		scatter:
		begin
			if(ate_pellet && ghostState != dead && ~ghost_in_box)
			begin
				ghostNext_state = frightened;
			end
			else if((timer_seconds > 6 && (round == 0 || round == 1)) || (timer_seconds > 4 && (round == 2 || round == 3))) 
			begin
				ghostNext_state = chase;
				timer_reset = 1'b1;
			end
		end
		frightened:
		begin
			if(frightened_timer > 10)
			begin
				ghostNext_state = ghostLastState;
			end
			if(is_collision)
			begin
				ghostNext_state = dead;
			end
		end
		dead: if(((inkyPosX / 12) - 6) >= 12 && (((inkyPosX / 12) - 6) <= 15) && (((inkyPosY / 12) - 6) == 14 || ((inkyPosY / 12) - 6) == 13))
			begin
				ghostNext_state = ghostLastState;
			end
	endcase
	
	nextDirection = 0;
	forceDown = 0;
	inky_is_frightened = 0;
	random_seed1 = random_seed % 372;
	random_seed2 = random_seed % 336;
	is_inky_dead = 1'b0;
	case(ghostState)
		waitforLevelStart:
		begin
			if(inkyPosY <= 222 )	//228
				nextDirection = 4;
			else if(inkyPosY >= 234)
				nextDirection = 2;
		end
		
		chase:
		begin
			if(((inkyPosX / 12) - 6) == 15 && ghost_in_box)
				nextDirection = 1;
			else if(((inkyPosX / 12) - 6) == 13 && ghost_in_box)
				nextDirection = 2;
			else if(((inkyPosX / 12) - 6) == 11 && ghost_in_box)
				nextDirection = 3;
			else
			begin
				case(PacmanCurrentDir)
					3'd1: 
					begin
						if((pacmanPosX - 24) > blinkyPosX)
							 targetX = ((pacmanPosX - 24) - blinkyPosX) + ((pacmanPosX - 24) - blinkyPosX) + blinkyPosX;
						else
							 targetX = blinkyPosX - ((blinkyPosX -  (pacmanPosX - 24)) + (blinkyPosX -  (pacmanPosX - 24)));
						if(pacmanPosY > blinkyPosY)
							 targetY = (pacmanPosY - blinkyPosY) + (pacmanPosY - blinkyPosY) + blinkyPosY;
						else
							 targetY = blinkyPosY - ((blinkyPosY - pacmanPosY) + (blinkyPosY - pacmanPosY));	 
						nextDirection = nextDirectionCalc;
					end
					3'd2:
					begin
						if(pacmanPosX > blinkyPosX)
							targetX = (pacmanPosX - blinkyPosX) + (pacmanPosX - blinkyPosX) + blinkyPosX;
						else
							targetX = blinkyPosX - ((blinkyPosX - pacmanPosX) + (blinkyPosX - pacmanPosX));
							
						if((pacmanPosY - 24) > blinkyPosY)
							targetY = ((pacmanPosY - 24) - blinkyPosY) + ((pacmanPosY - 24) - blinkyPosY) + blinkyPosY;
						else
							targetY = blinkyPosY - ((blinkyPosY -  (pacmanPosY - 24)) + (blinkyPosY -  (pacmanPosY - 24)));
						nextDirection = nextDirectionCalc;
					end
					3'd3:
					begin
						if((pacmanPosX + 24) > blinkyPosX)
							 targetX = ((pacmanPosX + 24) - blinkyPosX) + ((pacmanPosX + 24) - blinkyPosX) + blinkyPosX;
						else
							 targetX = blinkyPosX - ((blinkyPosX -  (pacmanPosX + 24)) + (blinkyPosX -  (pacmanPosX + 24)));
						if(pacmanPosY > blinkyPosY)
							 targetY = (pacmanPosY - blinkyPosY) + (pacmanPosY - blinkyPosY) + blinkyPosY;
						else
							 targetY = blinkyPosY - ((blinkyPosY - pacmanPosY) + (blinkyPosY - pacmanPosY));	 
						 
						nextDirection = nextDirectionCalc;
					end
					3'd4:
					begin
						if(pacmanPosX > blinkyPosX)
							targetX = (pacmanPosX - blinkyPosX) + (pacmanPosX - blinkyPosX) + blinkyPosX;
						else
							targetX = blinkyPosX - ((blinkyPosX - pacmanPosX) + (blinkyPosX - pacmanPosX));
							
						if((pacmanPosY + 24) > blinkyPosY)
							targetY = ((pacmanPosY + 24) - blinkyPosY) + ((pacmanPosY + 24) - blinkyPosY) + blinkyPosY;
						else
							targetY = blinkyPosY - ((blinkyPosY -  (pacmanPosY + 24)) + (blinkyPosY -  (pacmanPosY + 24)));
						nextDirection = nextDirectionCalc;
					end			
				endcase
			end
		end
		
		scatter:
		begin
			if((((inkyPosX / 12) - 6) == 15 || ((inkyPosX / 12) - 6) == 14) && ghost_in_box)
				nextDirection = 1;
			else if(((inkyPosX / 12) - 6) == 13 && ghost_in_box)
				nextDirection = 2;
			else if((((inkyPosX / 12) - 6) == 11 || ((inkyPosX / 12) - 6) == 12) && ghost_in_box)
				nextDirection = 3;
			else
			begin
				targetX = 10'd372;
				targetY = 10'd450;
				nextDirection = nextDirectionCalc;
			end
		end
		
		frightened:
		begin
			if(frightened_timer < 5)
			begin
				inky_is_frightened = 4'd1;
			end
			else
			begin
				if(frightened_timer_ticks <= 10 || ( frightened_timer_ticks > 20 && frightened_timer_ticks <= 30 ) || (frightened_timer_ticks > 40 && frightened_timer_ticks <= 50))
				begin
					inky_is_frightened = 4'd1;
				end
				else
				begin
					inky_is_frightened = 4'd2;
				end
			end
			if(frightened_timer == 0 && frightened_timer_ticks < 4  && ~ghost_in_box)
			begin
				case(inkycurrentDirection)
					4'd1: nextDirection = 3;
					4'd2: nextDirection = 4;
					4'd3: nextDirection = 1;
					4'd4: nextDirection = 2;
				endcase
			end
			else
			begin
				targetX = targetX_rand;
				targetY = targetY_rand;
				nextDirection = nextDirectionCalc;
			end
		end
		dead:
		begin
			if((inkyPosX == 228) && ((((inkyPosY / 12) - 6) >= 10) && (((inkyPosY / 12) - 6) <= 14)))
			begin
				nextDirection = 4'd4;
				if(ghost_in_box == 1'b0)
					forceDown = 1'b1;
			end
			else
			begin
				targetX = 10'd228;
				targetY = 10'd204;
				nextDirection = nextDirectionCalc;
			end
			is_inky_dead = 1'b1;
		end
	endcase
end
	

logic [19:0] random_seed, random_seed1, random_seed2;
logic reset_next_frame, reset_completed;
always_ff @ (posedge Clk)
begin
	if (Reset)
	begin
		reset_next_frame <= 1'b1;
	end
	
	if(reset_completed)	
	begin
		reset_next_frame <= 1'b0;
	end
	
	random_seed <= random_seed + 1;
	
	
end



always_ff @ (posedge frame_clk)
begin
	if(reset_completed)
	begin
		reset_completed <= 1'b0;
	end
	
	if (reset_next_frame || soft_reset || hard_reset || new_map)
	begin
		State <= Halted;
		inkycurrentDirection <= 3'd2;
		reset_completed <= 1'b1;
		last_direction_squareX <= 123456;
		last_direction_squareY <= 123456;
		frames_since_last <= 0;
	end
	
		State <= Next_state;
				
		case(inkycurrentDirection)
			3'd1: 
			
			
			begin
				if(availible_dir[0] || ghost_in_box == 1'b1)
				begin
					inkyPosX <= inkyPosX - 1;
				end
			end
			3'd2:
			begin
				if(availible_dir[1] || ghost_in_box == 1'b1)
				begin
					inkyPosY <= inkyPosY - 1;
				end
					
			end
			3'd3:
			begin
				if(availible_dir[2] || ghost_in_box == 1'b1)
				begin
					inkyPosX <= inkyPosX + 1;
				end
			end
			3'd4:
			begin
				if(availible_dir[3] || ghost_in_box == 1'b1 || forceDown)
				begin
					inkyPosY <= inkyPosY + 1;
				end
					
			end			
		endcase
		
		if(inkyPosX + 24 < 72)
			inkyPosX <= 408;
		else if(inkyPosX - 24 > 408)
			inkyPosX <= 48;
				
		if(nextDirection != inkycurrentDirection)
		begin
			case(nextDirection)
				3'd1:
				begin
					if((availible_dir[0] && frames_since_last >= 4) || ghost_in_box == 1'b1)
					begin
						inkycurrentDirection <= nextDirection;
						State <= left_fr1;
						frames_since_last <= 0;
					end
				end
				3'd2:
				begin
					if((availible_dir[1] && frames_since_last >= 4 )|| ghost_in_box == 1'b1)
					begin
						inkycurrentDirection <= nextDirection;
						State <= up_fr1;
						frames_since_last <= 0;
					end
				end
				3'd3:
				begin
					if((availible_dir[2] && frames_since_last >= 4)|| ghost_in_box == 1'b1)
					begin
						inkycurrentDirection <= nextDirection;
						State <= right_fr1;
						frames_since_last <= 0;
					end
				end
				3'd4:
				begin
					if((availible_dir[3] && frames_since_last >= 4)|| ghost_in_box == 1'b1 || forceDown)
					begin
						inkycurrentDirection <= nextDirection;
						State <= down_fr1;
						frames_since_last <= 0;
					end
				end
			endcase
		end
		if(frames_since_last < 8)
			frames_since_last <= frames_since_last + 1;
		
		case(inkycurrentDirection)
			3'd1: 
			begin
				if(~availible_dir[0])
					State <= left_fr1;
			end
			3'd2:
			begin
				if(~availible_dir[1])
					State <= up_fr1;
			end
			3'd3:
			begin
				if(~availible_dir[2])
					State <= right_fr1;
			end
			3'd4:
			begin
				if(~availible_dir[3])
					State <= down_fr1;
			end
		
		endcase
		
		
	if (reset_next_frame || soft_reset || hard_reset || new_map)
	begin	
		inkyPosY <= 10'D192 + 10'd36;
		inkyPosX <= 10'd228 + 10'd24;
	end
end
	
	
	
always_comb
begin 
	inky_sprite = 4'd8;
	Next_state = State;
	
	unique case (State)
		Halted :
		begin
			if (inkycurrentDirection > 0) 
			begin
				case(inkycurrentDirection)
					4'd0: Next_state = Halted;
					4'd1: Next_state = left_fr3;
					4'd2: Next_state = up_fr3;
					4'd3: Next_state = right_fr3;
					4'd4: Next_state = down_fr3;
				endcase
			end
		end
		
		left_fr1: Next_state = left_fr2;
		left_fr2: Next_state = left_fr3;
		left_fr3: Next_state = left_fr4;
		left_fr4: Next_state = left_fr5;
		left_fr5: Next_state = left_fr6;
		left_fr6: Next_state = left_fr7;
		left_fr7: Next_state = left_fr8;
		left_fr8: Next_state = left_fr1;
		
		
		right_fr1: Next_state = right_fr2;
		right_fr2: Next_state = right_fr3;
		right_fr3: Next_state = right_fr4;
		right_fr4: Next_state = right_fr5;
		right_fr5: Next_state = right_fr6;
		right_fr6: Next_state = right_fr7;
		right_fr7: Next_state = right_fr8;
		right_fr8: Next_state = right_fr1;
		
		down_fr1: Next_state = down_fr2;
		down_fr2: Next_state = down_fr3;
		down_fr3: Next_state = down_fr4;
		down_fr4: Next_state = down_fr5;
		down_fr5: Next_state = down_fr6;
		down_fr6: Next_state = down_fr7;
		down_fr7: Next_state = down_fr8;
		down_fr8: Next_state = down_fr1;
		
		up_fr1: Next_state = up_fr2;
		up_fr2: Next_state = up_fr3;
		up_fr3: Next_state = up_fr4;
		up_fr4: Next_state = up_fr5;
		up_fr5: Next_state = up_fr6;
		up_fr6: Next_state = up_fr7;
		up_fr7: Next_state = up_fr8;
		up_fr8: Next_state = up_fr1;
	endcase
	
	case (State)
		Halted: inky_sprite = 4'd4;
		
		left_fr1: inky_sprite = 4'd4;
		left_fr2: inky_sprite = 4'd4;
		left_fr3: inky_sprite = 4'd4;
		left_fr4: inky_sprite = 4'd4;
		left_fr5: inky_sprite = 4'd5;
		left_fr6: inky_sprite = 4'd5;
		left_fr7: inky_sprite = 4'd5;
		left_fr8: inky_sprite = 4'd5;
		
		right_fr1: inky_sprite = 4'd0;
		right_fr2: inky_sprite = 4'd0;
		right_fr3: inky_sprite = 4'd0;
		right_fr4: inky_sprite = 4'd0;
		right_fr5: inky_sprite = 4'd1;
		right_fr6: inky_sprite = 4'd1;
		right_fr7: inky_sprite = 4'd1;
		right_fr8: inky_sprite = 4'd1;
		
		
		up_fr1: inky_sprite = 4'd6;
		up_fr2: inky_sprite = 4'd6;
		up_fr3: inky_sprite = 4'd6;
		up_fr4: inky_sprite = 4'd6;
		up_fr5: inky_sprite = 4'd7;
		up_fr6: inky_sprite = 4'd7;
		up_fr7: inky_sprite = 4'd7;
		up_fr8: inky_sprite = 4'd7;

		down_fr1: inky_sprite = 4'd2;
		down_fr2: inky_sprite = 4'd2;
		down_fr3: inky_sprite = 4'd2;
		down_fr4: inky_sprite = 4'd2;
		down_fr5: inky_sprite = 4'd3;
		down_fr6: inky_sprite = 4'd3;
		down_fr7: inky_sprite = 4'd3;
		down_fr8: inky_sprite = 4'd3;
		
	endcase
end
	
endmodule