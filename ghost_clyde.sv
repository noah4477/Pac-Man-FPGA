module ghost_clyde(input          Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [9:0]   pacmanPosX, pacmanPosY,
					input 		  ate_pellet, soft_reset, hard_reset, new_map,
					input logic [7:0] keycode,
					input [3:0] PacmanCurrentDir,
					input [19:0] points_eaten,
					output logic is_clyde, is_clyde_dead, pacman_dead, output logic [3:0] clyde_sprite, clyde_is_frightened,
					output logic [9:0] clydePosX, clydePosY, output [19:0] score);
					
	logic [9:0] targetX, targetY, last_direction_squareX, last_direction_squareY, targetY_rand, targetX_rand;
	logic [3:0] nextDirection, nextDirectionCalc, frames_since_last, clydecurrentDirection;
	logic is_collision, forceDown;
	
	logic [3:0] availible_dir;
	
	valid_moves moves(.*, .PosX(clydePosX), .PosY(clydePosY), .is_Ghost(1));
	next_dir nextDir_calc(.targetX(targetX), .targetY(targetY), .ghostPosX(clydePosX), .ghostPosY(clydePosY), .availible_dir(availible_dir),
		.currentDirection(clydecurrentDirection), .nextDirection(nextDirectionCalc));
	
	enum logic [5:0] { Halted, 
					left_fr1, left_fr2, left_fr3, left_fr4, left_fr5, left_fr6, left_fr7, left_fr8,
					right_fr1, right_fr2, right_fr3, right_fr4, right_fr5, right_fr6, right_fr7, right_fr8,
					up_fr1, up_fr2, up_fr3, up_fr4, up_fr5, up_fr6, up_fr7, up_fr8,
					down_fr1, down_fr2, down_fr3, down_fr4, down_fr5, down_fr6, down_fr7, down_fr8} State, Next_state;
		
	initial
	begin
		clydecurrentDirection = 3'd2;
		nextDirection = 3'd2;
		clydePosY = 10'D192 + 10'd36;
		clydePosX = 10'd228 - 10'd24;
		clyde_sprite = 3'd4;
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
	logic [9:0] distX, distY;
	always_comb
	begin
		is_clyde = 1'b0;
		is_collision = 1'b0;

		if((DrawY - clydePosY - 6 < 24) && (DrawY - clydePosY - 6 >= 0) && (DrawX - clydePosX < 24) && (DrawX - clydePosX >= 0) && DrawX >= 72 && DrawX < 408)
			is_clyde = 1'b1;
		if(clydePosY - pacmanPosY >= 0 && clydePosY - pacmanPosY < 18)
		begin
			if(clydePosX - pacmanPosX >= 0 && clydePosX - pacmanPosX < 18)
			begin
				is_collision = 1'b1;
			end
			else if(pacmanPosX - clydePosX >= 0 && pacmanPosX - clydePosX < 18)
			begin
				is_collision = 1'b1;
			end
		end
		else if(pacmanPosY - clydePosY >= 0 && pacmanPosY - clydePosY < 18)
		begin
			if(clydePosX - pacmanPosX >= 0 && clydePosX - pacmanPosX < 18)
			begin
				is_collision = 1'b1;
			end
			else if(pacmanPosX - clydePosX >= 0 && pacmanPosX - clydePosX < 18)
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
	
	if(clydePosY >= 216 && clydePosY <= 240 && ((((clydePosX / 12) - 6) == 15) || (((clydePosX / 12) - 6) == 14) || (((clydePosX / 12) - 6) == 13) || (((clydePosX / 12) - 6) == 12)) || (((clydePosX / 12) - 6) == 11))
	begin
		ghost_in_box = 1'b1;
	end
	if(((((clydePosX / 12) - 6) == 13)) && ((clydePosY / 12 - 6) == 11 || (clydePosY / 12 - 6) == 10))
	begin
		ghost_in_box = 1'b1;
	end
	
	
	case(ghostState)
		waitforLevelStart:
		begin
			if(PacmanCurrentDir > 0 && points_eaten >= 80)
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
		dead: if(((clydePosX / 12) - 6) >= 12 && (((clydePosX / 12) - 6) <= 15) && (((clydePosY / 12) - 6) == 14 || ((clydePosY / 12) - 6) == 13))
			begin
				ghostNext_state = ghostLastState;
			end
	endcase
	
	nextDirection = 0;
	forceDown = 0;
	clyde_is_frightened = 0;
	random_seed1 = random_seed % 372;
	random_seed2 = random_seed % 336;
	is_clyde_dead = 1'b0;
	distX = 0;
	distY = 0;
	case(ghostState)
		waitforLevelStart:
		begin
			if(clydePosY <= 222 )	//228
				nextDirection = 4;
			else if(clydePosY >= 234)
				nextDirection = 2;
		end
		
		chase:
		begin
			if(((clydePosX / 12) - 6) == 15 && ghost_in_box)
				nextDirection = 1;
			else if(((clydePosX / 12) - 6) == 13 && ghost_in_box)
				nextDirection = 2;
			else if(((clydePosX / 12) - 6) == 11 && ghost_in_box)
				nextDirection = 3;
			else
			begin
//				if(pacmanPosX > clydePosX)
//					 distX = pacmanPosX - clydePosX;
//				else
//					 distX = clydePosX - pacmanPosX;
//				if(pacmanPosY > clydePosY)
//					 distY = pacmanPosY - clydePosY;
//				else
//					 distY = clydePosY - pacmanPosY;	
//					 
//				if(distY + distX > 96)
//				begin
					targetX = pacmanPosX;
					targetY = pacmanPosY;
					nextDirection = nextDirectionCalc;
//				end
//				else
//				begin
//					targetX = 10'd6;
//					targetY = 10'd450;
//					nextDirection = nextDirectionCalc;
//				end
				
			end
		end
		
		scatter:
		begin
			if((((clydePosX / 12) - 6) == 15 || ((clydePosX / 12) - 6) == 14) && ghost_in_box)
				nextDirection = 1;
			else if(((clydePosX / 12) - 6) == 13 && ghost_in_box)
				nextDirection = 2;
			else if((((clydePosX / 12) - 6) == 11 || ((clydePosX / 12) - 6) == 12) && ghost_in_box)
				nextDirection = 3;
			else
			begin
				targetX = 10'd78;
				targetY = 10'd450;
				nextDirection = nextDirectionCalc;
			end
		end
		
		frightened:
		begin
			if(frightened_timer < 5)
			begin
				clyde_is_frightened = 4'd1;
			end
			else
			begin
				if(frightened_timer_ticks <= 10 || ( frightened_timer_ticks > 20 && frightened_timer_ticks <= 30 ) || (frightened_timer_ticks > 40 && frightened_timer_ticks <= 50))
				begin
					clyde_is_frightened = 4'd1;
				end
				else
				begin
					clyde_is_frightened = 4'd2;
				end
			end
			if(frightened_timer == 0 && frightened_timer_ticks < 4 && ~ghost_in_box)
			begin
				case(clydecurrentDirection)
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
			if((clydePosX == 228) && ((((clydePosY / 12) - 6) >= 10) && (((clydePosY / 12) - 6) <= 14)))
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
			is_clyde_dead = 1'b1;
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
		clydecurrentDirection <= 3'd2;
		reset_completed <= 1'b1;
		last_direction_squareX <= 123456;
		last_direction_squareY <= 123456;
		frames_since_last <= 0;
	end
	
		State <= Next_state;
				
		case(clydecurrentDirection)
			3'd1: 
			
			
			begin
				if(availible_dir[0] || ghost_in_box == 1'b1)
				begin
					clydePosX <= clydePosX - 1;
				end
			end
			3'd2:
			begin
				if(availible_dir[1] || ghost_in_box == 1'b1)
				begin
					clydePosY <= clydePosY - 1;
				end
					
			end
			3'd3:
			begin
				if(availible_dir[2] || ghost_in_box == 1'b1)
				begin
					clydePosX <= clydePosX + 1;
				end
			end
			3'd4:
			begin
				if(availible_dir[3] || ghost_in_box == 1'b1 || forceDown)
				begin
					clydePosY <= clydePosY + 1;
				end
					
			end			
		endcase
		
		if(clydePosX + 24 < 72)
			clydePosX <= 408;
		else if(clydePosX - 24 > 408)
			clydePosX <= 48;
				
		if(nextDirection != clydecurrentDirection)
		begin
			case(nextDirection)
				3'd1:
				begin
					if((availible_dir[0] && frames_since_last >= 4) || (ghost_in_box == 1'b1 && (ghostNext_state == waitforLevelStart || ghostNext_state == dead)))
					begin
						clydecurrentDirection <= nextDirection;
						State <= left_fr1;
						frames_since_last <= 0;
					end
				end
				3'd2:
				begin
					if((availible_dir[1] && frames_since_last >= 4 )|| (ghost_in_box == 1'b1 && (ghostNext_state == waitforLevelStart || ghostNext_state == dead)))
					begin
						clydecurrentDirection <= nextDirection;
						State <= up_fr1;
						frames_since_last <= 0;
					end
				end
				3'd3:
				begin
					if((availible_dir[2] && frames_since_last >= 4)|| (ghost_in_box == 1'b1 && (ghostNext_state == waitforLevelStart || ghostNext_state == dead)))
					begin
						clydecurrentDirection <= nextDirection;
						State <= right_fr1;
						frames_since_last <= 0;
					end
				end
				3'd4:
				begin
					if((availible_dir[3] && frames_since_last >= 4)|| (ghost_in_box == 1'b1 && (ghostNext_state == waitforLevelStart || ghostNext_state == dead)) || forceDown)
					begin
						clydecurrentDirection <= nextDirection;
						State <= down_fr1;
						frames_since_last <= 0;
					end
				end
			endcase
		end
		if(frames_since_last < 8)
			frames_since_last <= frames_since_last + 1;
		
		case(clydecurrentDirection)
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
		clydePosY <= 10'D192 + 10'd36;
		clydePosX <= 10'd228 - 10'd24;
	end
end
	
	
	
always_comb
begin 
	clyde_sprite = 4'd8;
	Next_state = State;
	
	unique case (State)
		Halted :
		begin
			if (clydecurrentDirection > 0) 
			begin
				case(clydecurrentDirection)
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
		Halted: clyde_sprite = 4'd4;
		
		left_fr1: clyde_sprite = 4'd4;
		left_fr2: clyde_sprite = 4'd4;
		left_fr3: clyde_sprite = 4'd4;
		left_fr4: clyde_sprite = 4'd4;
		left_fr5: clyde_sprite = 4'd5;
		left_fr6: clyde_sprite = 4'd5;
		left_fr7: clyde_sprite = 4'd5;
		left_fr8: clyde_sprite = 4'd5;
		
		right_fr1: clyde_sprite = 4'd0;
		right_fr2: clyde_sprite = 4'd0;
		right_fr3: clyde_sprite = 4'd0;
		right_fr4: clyde_sprite = 4'd0;
		right_fr5: clyde_sprite = 4'd1;
		right_fr6: clyde_sprite = 4'd1;
		right_fr7: clyde_sprite = 4'd1;
		right_fr8: clyde_sprite = 4'd1;
		
		
		up_fr1: clyde_sprite = 4'd6;
		up_fr2: clyde_sprite = 4'd6;
		up_fr3: clyde_sprite = 4'd6;
		up_fr4: clyde_sprite = 4'd6;
		up_fr5: clyde_sprite = 4'd7;
		up_fr6: clyde_sprite = 4'd7;
		up_fr7: clyde_sprite = 4'd7;
		up_fr8: clyde_sprite = 4'd7;

		down_fr1: clyde_sprite = 4'd2;
		down_fr2: clyde_sprite = 4'd2;
		down_fr3: clyde_sprite = 4'd2;
		down_fr4: clyde_sprite = 4'd2;
		down_fr5: clyde_sprite = 4'd3;
		down_fr6: clyde_sprite = 4'd3;
		down_fr7: clyde_sprite = 4'd3;
		down_fr8: clyde_sprite = 4'd3;
		
	endcase
end
	
endmodule