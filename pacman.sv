module pacman(input          Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input logic [7:0] keycode,	output logic is_pacman, output logic [3:0] pacman_sprite, output logic [9:0] pacmanPosX, pacmanPosY, output logic [3:0] currentDirection);

logic [3:0] nextDirection, nextDirection_;	// 0 (no move), 1 (left), 2(up), 3(right), 4(down)

enum logic [5:0] { Halted, 
						left_fr1, left_fr2, left_fr3, left_fr4, left_fr5, left_fr6, left_fr7, left_fr8, left_fr9,
						right_fr1, right_fr2, right_fr3, right_fr4, right_fr5, right_fr6, right_fr7, right_fr8, right_fr9,
						up_fr1, up_fr2, up_fr3, up_fr4, up_fr5, up_fr6, up_fr7, up_fr8, up_fr9,
						down_fr1, down_fr2, down_fr3, down_fr4, down_fr5, down_fr6, down_fr7, down_fr8, down_fr9} State, Next_state;
	
	logic [3:0] availible_dir;
	valid_moves moves(.*);
	
	initial
	begin
		State = Halted;
		currentDirection = 3'd0;
		nextDirection = 3'd0;
		pacmanPosY = 10'd336;
		pacmanPosX = 10'd228;
		reset_completed = 1'b0;
		reset_next_frame = 1'b0;		
	end	
		


		
always_comb
begin

	is_pacman = 1'b0;
	
	if((DrawY - pacmanPosY - 6 < 24) && (DrawY - pacmanPosY - 6 >= 0) && (DrawX - pacmanPosX < 24) && (DrawX - pacmanPosX >= 0))
		is_pacman = 1'b1;

	nextDirection_ = 0;
	case(keycode)
		8'h04:	//A LEFT
			begin
				nextDirection_ = 3'd1;
			end
		8'h07:	//D RIGHT
			begin
				nextDirection_ = 3'd3;
			end
		8'h1A:	//W UP
			begin
				nextDirection_ = 3'd2;
			end
		8'h16:	//D Down
			begin
				nextDirection_ = 3'd4;
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
		currentDirection <= 3'd0;
		nextDirection <= 3'd0;
		pacmanPosY <= 10'd336;
		pacmanPosX <= 10'd228;
		reset_completed <= 1'b1;
	end
	
		State <= Next_state;
				
		case(currentDirection)
			3'd1: 
			begin
				if(availible_dir[0])
					pacmanPosX <= pacmanPosX - 1;
			end
			3'd2:
			begin
				if(availible_dir[1])
					pacmanPosY <= pacmanPosY - 1;
			end
			3'd3:
			begin
				if(availible_dir[2])
					pacmanPosX <= pacmanPosX + 1;
			end
			3'd4:
			begin
				if(availible_dir[3])
					pacmanPosY <= pacmanPosY + 1;
			end
			
			
		endcase
		if(nextDirection != currentDirection)
		begin
			case(nextDirection)
				3'd1:
				begin
					if(availible_dir[0])
					begin
						currentDirection <= nextDirection;
						State <= left_fr3;
					end
				end
				3'd2:
				begin
					if(availible_dir[1])
					begin
						currentDirection <= nextDirection;
						State <= up_fr3;
					end
				end
				3'd3:
				begin
					if(availible_dir[2])
					begin
						currentDirection <= nextDirection;
						State <= right_fr3;
					end
				end
				3'd4:
				begin
					if(availible_dir[3])
					begin
						currentDirection <= nextDirection;
						State <= down_fr3;
					end
				end
			endcase
		end
		case(currentDirection)
			3'd1: 
			begin
				if(~availible_dir[0])
					currentDirection <= 0;
			end
			3'd2:
			begin
				if(~availible_dir[1])
					currentDirection <= 0;
			end
			3'd3:
			begin
				if(~availible_dir[2])
					currentDirection <= 0;
			end
			3'd4:
			begin
				if(~availible_dir[3])
					currentDirection <= 0;
			end
		
		endcase
		
		if(nextDirection_ > 0)
			nextDirection <= nextDirection_;
end
	
	
	
always_comb
begin 
	pacman_sprite = 4'd8;
	Next_state = State;
			
	unique case (State)
		Halted :
		begin
			if (currentDirection > 0) 
			begin
				case(currentDirection)
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
		left_fr8: Next_state = left_fr9;
		left_fr9: Next_state = left_fr1;
		
		right_fr1: Next_state = right_fr2;
		right_fr2: Next_state = right_fr3;
		right_fr3: Next_state = right_fr4;
		right_fr4: Next_state = right_fr5;
		right_fr5: Next_state = right_fr6;
		right_fr6: Next_state = right_fr7;
		right_fr7: Next_state = right_fr8;
		right_fr8: Next_state = right_fr9;
		right_fr9: Next_state = right_fr1;
		
		down_fr1: Next_state = down_fr2;
		down_fr2: Next_state = down_fr3;
		down_fr3: Next_state = down_fr4;
		down_fr4: Next_state = down_fr5;
		down_fr5: Next_state = down_fr6;
		down_fr6: Next_state = down_fr7;
		down_fr7: Next_state = down_fr8;
		down_fr8: Next_state = down_fr9;
		down_fr9: Next_state = down_fr1;
		
		up_fr1: Next_state = up_fr2;
		up_fr2: Next_state = up_fr3;
		up_fr3: Next_state = up_fr4;
		up_fr4: Next_state = up_fr5;
		up_fr5: Next_state = up_fr6;
		up_fr6: Next_state = up_fr7;
		up_fr7: Next_state = up_fr8;
		up_fr8: Next_state = up_fr9;
		up_fr9: Next_state = up_fr1;
	endcase
	
	case (State)
		Halted: pacman_sprite = 4'd8;
		
		left_fr1: pacman_sprite = 4'd8;
		left_fr2: pacman_sprite = 4'd8;
		left_fr3: pacman_sprite = 4'd2;
		left_fr4: pacman_sprite = 4'd2;
		left_fr5: pacman_sprite = 4'd0;
		left_fr6: pacman_sprite = 4'd0;
		left_fr7: pacman_sprite = 4'd0;
		left_fr8: pacman_sprite = 4'd2;
		left_fr9: pacman_sprite = 4'd2;
		
		right_fr1: pacman_sprite = 4'd8;
		right_fr2: pacman_sprite = 4'd8;
		right_fr3: pacman_sprite = 4'd6;
		right_fr4: pacman_sprite = 4'd6;
		right_fr5: pacman_sprite = 4'd4;
		right_fr6: pacman_sprite = 4'd4;
		right_fr7: pacman_sprite = 4'd4;
		right_fr8: pacman_sprite = 4'd6;
		right_fr9: pacman_sprite = 4'd6;
		
		
		up_fr1: pacman_sprite = 4'd8;
		up_fr2: pacman_sprite = 4'd8;
		up_fr3: pacman_sprite = 4'd3;
		up_fr4: pacman_sprite = 4'd3;
		up_fr5: pacman_sprite = 4'd1;
		up_fr6: pacman_sprite = 4'd1;
		up_fr7: pacman_sprite = 4'd1;
		up_fr8: pacman_sprite = 4'd3;
		up_fr9: pacman_sprite = 4'd3;
		
		down_fr1: pacman_sprite = 4'd8;
		down_fr2: pacman_sprite = 4'd8;
		down_fr3: pacman_sprite = 4'd7;
		down_fr4: pacman_sprite = 4'd7;
		down_fr5: pacman_sprite = 4'd5;
		down_fr6: pacman_sprite = 4'd5;
		down_fr7: pacman_sprite = 4'd5;
		down_fr8: pacman_sprite = 4'd7;
		down_fr9: pacman_sprite = 4'd7;
		
	endcase
end
	
	
	
endmodule