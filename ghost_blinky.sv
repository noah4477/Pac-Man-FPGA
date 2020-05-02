module ghost_blinky(input          Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [9:0]   pacmanPosX, pacmanPosY,
					input logic [7:0] keycode,
					input [3:0] PacmanCurrentDir,
					output logic is_blinky, output logic [3:0] blinky_sprite, 
					output logic [9:0] blinkyPosX, blinkyPosY, output logic [3:0] BlinkycurrentDirection, availible_dir);
					
	logic [9:0] targetX, targetY, last_direction_squareX, last_direction_squareY;
	logic [3:0] nextDirection, nextDirectionCalc, frames_since_last;
	//logic [3:0] availible_dir;
	
	valid_moves moves(.*, .PosX(blinkyPosX), .PosY(blinkyPosY), .is_Ghost(1));
	next_dir nextDir_calc(.targetX(targetX), .targetY(targetY), .ghostPosX(blinkyPosX), .ghostPosY(blinkyPosY), .availible_dir(availible_dir),
		.currentDirection(BlinkycurrentDirection), .nextDirection(nextDirectionCalc));
	
	enum logic [5:0] { Halted, 
					left_fr1, left_fr2, left_fr3, left_fr4, left_fr5, left_fr6, left_fr7, left_fr8,
					right_fr1, right_fr2, right_fr3, right_fr4, right_fr5, right_fr6, right_fr7, right_fr8,
					up_fr1, up_fr2, up_fr3, up_fr4, up_fr5, up_fr6, up_fr7, up_fr8,
					down_fr1, down_fr2, down_fr3, down_fr4, down_fr5, down_fr6, down_fr7, down_fr8} State, Next_state;
		
	initial
	begin
		BlinkycurrentDirection = 3'd2;
		nextDirection = 3'd0;
		//blinkyPosY = 10'D192;
		//blinkyPosX = 10'd228;
		blinkyPosY = 10'D192 + 10'd36;
		blinkyPosX = 10'd228; //+ 10'd24;
		//blinkyPosY = 10'd336;
		//blinkyPosX = 10'd228;
		blinky_sprite = 3'd4;
				reset_completed = 1'b0;
		reset_next_frame = 1'b0;
		State = Halted;
		ghostState = waitforLevelStart;
		frames_since_last = 4'd0;
		timer_seconds = 0;
	end

	
	
	logic [6:0] timer;
	logic [6:0] timer_seconds;
	
	
	always_comb
	begin
		is_blinky = 1'b0;
	if((DrawY - blinkyPosY - 6 < 24) && (DrawY - blinkyPosY - 6 >= 0) && (DrawX - blinkyPosX < 24) && (DrawX - blinkyPosX >= 0) && DrawX >= 72 && DrawX < 408)
		is_blinky = 1'b1;
	end	

	
	
	
	enum logic [1:0] { waitforLevelStart, chase, scatter, frightened } ghostState, ghostNext_state;
	
logic timer_reset;

always_ff @ (posedge frame_clk)
begin

	if (reset_next_frame)
	begin
		timer <= 0;
		timer_seconds <= 0;
	end
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
	ghostState <= ghostNext_state;
	

end
	logic ghost_in_box;

always_comb
begin
	ghostNext_state = ghostState;
	targetX = pacmanPosX;
	targetY = pacmanPosY;
	timer_reset = 1'b0;
	
	ghost_in_box = 1'b0;
	if(blinkyPosY >= 216 && blinkyPosY <= 240 && ((((blinkyPosX / 12) - 6) == 15) || (((blinkyPosX / 12) - 6) == 14) || (((blinkyPosX / 12) - 6) == 13)))
	begin
		ghost_in_box = 1'b1;
	end
	if(((((blinkyPosX / 12) - 6) == 13)) && ((blinkyPosY / 12 - 6) == 11 || (blinkyPosY / 12 - 6) == 10))
	begin
		ghost_in_box = 1'b1;
	end
	
	
	case(ghostState)
		waitforLevelStart:
		begin
			if(PacmanCurrentDir > 0)
			begin
				ghostNext_state = scatter;
			end
		end
		
		chase: 
		begin
			if(timer_seconds > 19) 
			begin
				//ghostNext_state = scatter;
				timer_reset = 1'b1;
			end
		end
		
		scatter:
		begin
			if(timer_seconds > 10) 
			begin
				ghostNext_state = chase;
				timer_reset = 1'b1;
			end
		end
		frightened: ;
	endcase
	
	nextDirection = 0;
	
	case(ghostState)
		waitforLevelStart:
		begin
			if(blinkyPosY <= 222 )	//228
				nextDirection = 4;
			else if(blinkyPosY >= 234)
				nextDirection = 2;
		end
		
		chase:
		begin
			targetX = pacmanPosX;
			targetY = pacmanPosY;
			nextDirection = nextDirectionCalc;
		end
		
		scatter:
		begin
			if(((blinkyPosX / 12) - 6) == 15 && ghost_in_box)
				nextDirection = 1;
			else if(((blinkyPosX / 12) - 6) == 13 && ghost_in_box)
				nextDirection = 2;
			else if(((blinkyPosX / 12) - 6) == 11 && ghost_in_box)
				nextDirection = 3;
			else
			begin
				targetX = 10'd372;
				targetY = 10'd6;
				nextDirection = nextDirectionCalc;
			end
		end
		
		frightened:
		begin
			
		end
	
	endcase
	
end
	
	
	
	
	
	
	
	

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
end



always_ff @ (posedge frame_clk)
begin
	if(reset_completed)
	begin
		reset_completed <= 1'b0;
	end
	
	if (reset_next_frame)
	begin
		State <= Halted;
		BlinkycurrentDirection <= 3'd2;
		blinkyPosY <= 10'D192 + 10'd36;
		blinkyPosX <= 10'd228 + 10'd24;
		reset_completed <= 1'b1;
		last_direction_squareX <= 123456;
		last_direction_squareY <= 123456;
		frames_since_last <= 0;
	end
	
		State <= Next_state;
				
		case(BlinkycurrentDirection)
			3'd1: 
			begin
				if(availible_dir[0] || ghost_in_box == 1'b1)
					blinkyPosX <= blinkyPosX - 1;
			end
			3'd2:
			begin
				if(availible_dir[1] || ghost_in_box == 1'b1)
					blinkyPosY <= blinkyPosY - 1;
			end
			3'd3:
			begin
				if(availible_dir[2] || ghost_in_box == 1'b1)
					blinkyPosX <= blinkyPosX + 1;
			end
			3'd4:
			begin
				if(availible_dir[3] || ghost_in_box == 1'b1)
					blinkyPosY <= blinkyPosY + 1;
			end			
		endcase
		
		if(blinkyPosX + 24 < 72)
			blinkyPosX <= 408;
		else if(blinkyPosX - 24 > 408)
			blinkyPosX <= 48;
				
		if(nextDirection != BlinkycurrentDirection)
		begin
			case(nextDirection)
				3'd1:
				begin
					if((availible_dir[0] && frames_since_last >= 4) || ghost_in_box == 1'b1)
					begin
						BlinkycurrentDirection <= nextDirection;
						State <= left_fr1;
						frames_since_last <= 0;
					end
				end
				3'd2:
				begin
					if((availible_dir[1] && frames_since_last >= 4 )|| ghost_in_box == 1'b1)
					begin
						BlinkycurrentDirection <= nextDirection;
						State <= up_fr1;
						frames_since_last <= 0;
					end
				end
				3'd3:
				begin
					if((availible_dir[2] && frames_since_last >= 4)|| ghost_in_box == 1'b1)
					begin
						BlinkycurrentDirection <= nextDirection;
						State <= right_fr1;
						frames_since_last <= 0;
					end
				end
				3'd4:
				begin
					if((availible_dir[3] && frames_since_last >= 4)|| ghost_in_box == 1'b1)
					begin
						BlinkycurrentDirection <= nextDirection;
						State <= down_fr1;
						frames_since_last <= 0;
					end
				end
			endcase
		end
		if(frames_since_last < 8)
			frames_since_last <= frames_since_last + 1;
		
		case(BlinkycurrentDirection)
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
		
		
end
	
	
	
always_comb
begin 
	blinky_sprite = 4'd8;
	Next_state = State;
			
	unique case (State)
		Halted :
		begin
			if (BlinkycurrentDirection > 0) 
			begin
				case(BlinkycurrentDirection)
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
		Halted: blinky_sprite = 4'd4;
		
		left_fr1: blinky_sprite = 4'd4;
		left_fr2: blinky_sprite = 4'd4;
		left_fr3: blinky_sprite = 4'd4;
		left_fr4: blinky_sprite = 4'd4;
		left_fr5: blinky_sprite = 4'd5;
		left_fr6: blinky_sprite = 4'd5;
		left_fr7: blinky_sprite = 4'd5;
		left_fr8: blinky_sprite = 4'd5;
		
		right_fr1: blinky_sprite = 4'd0;
		right_fr2: blinky_sprite = 4'd0;
		right_fr3: blinky_sprite = 4'd0;
		right_fr4: blinky_sprite = 4'd0;
		right_fr5: blinky_sprite = 4'd1;
		right_fr6: blinky_sprite = 4'd1;
		right_fr7: blinky_sprite = 4'd1;
		right_fr8: blinky_sprite = 4'd1;
		
		
		up_fr1: blinky_sprite = 4'd6;
		up_fr2: blinky_sprite = 4'd6;
		up_fr3: blinky_sprite = 4'd6;
		up_fr4: blinky_sprite = 4'd6;
		up_fr5: blinky_sprite = 4'd7;
		up_fr6: blinky_sprite = 4'd7;
		up_fr7: blinky_sprite = 4'd7;
		up_fr8: blinky_sprite = 4'd7;

		down_fr1: blinky_sprite = 4'd2;
		down_fr2: blinky_sprite = 4'd2;
		down_fr3: blinky_sprite = 4'd2;
		down_fr4: blinky_sprite = 4'd2;
		down_fr5: blinky_sprite = 4'd3;
		down_fr6: blinky_sprite = 4'd3;
		down_fr7: blinky_sprite = 4'd3;
		down_fr8: blinky_sprite = 4'd3;
		
	endcase
end
	
endmodule