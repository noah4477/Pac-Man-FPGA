module scoreboard(input [9:0] DrawX, DrawY, input [19:0] score, output is_scoreboard, 
						output [3:0] scoreboard_sprite, output is_scoreboard_1up, output [1:0] scoreboard_1up_sprite);

	always_comb
	begin
		is_scoreboard = 1'b0;
		scoreboard_sprite = 4'd0;
		is_scoreboard_1up = 1'b0;
		scoreboard_1up_sprite = 0;
				
		//1 20 15
		if(DrawY >= 36 && DrawY < 48)
		begin
			if(DrawX >= 72 && DrawX < 72 + 12)
			begin
				is_scoreboard_1up = 1'b1;
				scoreboard_1up_sprite = 2'd0;
			end
			else if(DrawX >= 72 + 12 && DrawX < 72 + 24)
			begin
				is_scoreboard_1up = 1'b1;
				scoreboard_1up_sprite = 2'd1;
			end 
			else if(DrawX >= 72 + 24 && DrawX < 72 + 36)
			begin
				is_scoreboard_1up = 1'b1;
				scoreboard_1up_sprite = 2'd2;
			end
		end
		
		if(DrawY >= 54 && DrawY < 66)
		begin
			if(DrawX >= 72 && DrawX < 72 + 12)
			begin
				is_scoreboard = 1'b1;
				scoreboard_sprite = score / 100000;
			end
			else if(DrawX >= 72 + 12 * 1 && DrawX < 72 + 12 * 2)
			begin
				is_scoreboard = 1'b1;
				scoreboard_sprite = (score / 10000) % 10;
			end
			else if(DrawX >= 72 + 12 * 2 && DrawX < 72 + 12 * 3)
			begin
				is_scoreboard = 1'b1;
				scoreboard_sprite = (score / 1000) % 10;
			end
			else if(DrawX >= 72 + 12 * 3 && DrawX < 72 + 12 * 4)
			begin
				is_scoreboard = 1'b1;
				scoreboard_sprite = (score / 100) % 10;
			end
			else if(DrawX >= 72 + 12 * 4 && DrawX < 72 + 12 * 5)
			begin
				is_scoreboard = 1'b1;
				scoreboard_sprite = (score / 10) % 10;
			end
			else if(DrawX >= 72 + 12 * 5 && DrawX < 72 + 12 * 6)
			begin
				is_scoreboard = 1'b1;
				scoreboard_sprite = 0;
			end
		end
	end

endmodule