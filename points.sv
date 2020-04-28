module points(input Reset, input Clk, is_pacman, input [3:0] currentDirection, input [9:0] pacmanPosX, pacmanPosY,
				  input [9:0] DrawX, DrawY, output is_point, is_pellet, output [19:0] score);

	 logic[0:30][0:27] points;
	 logic[0:30][0:27] pellets;
	
	initial
	begin
		pellets[0] = 28'h0;
		pellets[1] = 28'h0;
		pellets[2] = 28'h0;
		pellets[3] = 28'h4000002;
		pellets[4] = 28'h0;
		pellets[5] = 28'h0;
		pellets[6] = 28'h0;
		pellets[7] = 28'h0;
		pellets[8] = 28'h0;
		pellets[9] = 28'h0;
		pellets[10] = 28'h0;
		pellets[11] = 28'h0;
		pellets[12] = 28'h0;
		pellets[13] = 28'h0;
		pellets[14] = 28'h0;
		pellets[15] = 28'h0;
		pellets[16] = 28'h0;
		pellets[17] = 28'h0;
		pellets[18] = 28'h0;
		pellets[19] = 28'h0;
		pellets[20] = 28'h0;
		pellets[21] = 28'h0;
		pellets[22] = 28'h0;
		pellets[23] = 28'h4000002;
		pellets[24] = 28'h0;
		pellets[25] = 28'h0;
		pellets[26] = 28'h0;
		pellets[27] = 28'h0;
		pellets[28] = 28'h0;
		pellets[29] = 28'h0;
		pellets[30] = 28'h0;
		
		points[0] = 28'h0;
		points[1] = 28'h7FF9FFE;
		points[2] = 28'h4209042;
		points[3] = 28'h0209040;
		points[4] = 28'h4209042;
		points[5] = 28'h7FFFFFE;
		points[6] = 28'h4240242;
		points[7] = 28'h4240242;
		points[8] = 28'h7E79E7E;
		points[9] = 28'h0200040;
		points[10] = 28'h0200040;
		points[11] = 28'h0200040;
		points[12] = 28'h0200040;
		points[13] = 28'h0200040;
		points[14] = 28'h0200040;
		points[15] = 28'h0200040;
		points[16] = 28'h0200040;
		points[17] = 28'h0200040;
		points[18] = 28'h0200040;
		points[19] = 28'h0200040;
		points[20] = 28'h7FF9FFE;
		points[21] = 28'h4209042;
		points[22] = 28'h4209042;
		points[23] = 28'h33F9FCC;
		points[24] = 28'h1240248;
		points[25] = 28'h1240248;
		points[26] = 28'h7E79E7E;
		points[27] = 28'h4009002;
		points[28] = 28'h4009002;
		points[29] = 28'h7FFFFFE;
		points[30] = 28'h0;
		
		score <= 0;
	end
	
	

	always_comb
	begin
		is_point = 0;
		is_pellet = 0;
		if(DrawY >= 72 && DrawY < 444 && DrawX >= 72 && DrawX < 408)
		begin
			case(points[((DrawY/12) - 6)][((DrawX/12) - 6)])
				1'b1: is_point = 1;
			endcase
			case(pellets[((DrawY/12) - 6)][((DrawX/12) - 6)])
				1'b1: is_pellet = 1;
			endcase
		end
	end
	
	
	always_ff @ (posedge Clk)
	begin
		if (Reset)
		begin
			pellets[0] <= 28'h0;
			pellets[1] <= 28'h0;
			pellets[2] <= 28'h0;
			pellets[3] <= 28'h4000002;
			pellets[4] <= 28'h0;
			pellets[5] <= 28'h0;
			pellets[6] <= 28'h0;
			pellets[7] <= 28'h0;
			pellets[8] <= 28'h0;
			pellets[9] <= 28'h0;
			pellets[10] <= 28'h0;
			pellets[11] <= 28'h0;
			pellets[12] <= 28'h0;
			pellets[13] <= 28'h0;
			pellets[14] <= 28'h0;
			pellets[15] <= 28'h0;
			pellets[16] <= 28'h0;
			pellets[17] <= 28'h0;
			pellets[18] <= 28'h0;
			pellets[19] <= 28'h0;
			pellets[20] <= 28'h0;
			pellets[21] <= 28'h0;
			pellets[22] <= 28'h0;
			pellets[23] <= 28'h4000002;
			pellets[24] <= 28'h0;
			pellets[25] <= 28'h0;
			pellets[26] <= 28'h0;
			pellets[27] <= 28'h0;
			pellets[28] <= 28'h0;
			pellets[29] <= 28'h0;
			pellets[30] <= 28'h0;
			
			points[0] <= 28'h0;
			points[1] <= 28'h7FF9FFE;
			points[2] <= 28'h4209042;
			points[3] <= 28'h0209042;
			points[4] <= 28'h4209042;
			points[5] <= 28'h7FFFFFE;
			points[6] <= 28'h4240242;
			points[7] <= 28'h4240242;
			points[8] <= 28'h7E79E7E;
			points[9] <= 28'h0200040;
			points[10] <= 28'h0200040;
			points[11] <= 28'h0200040;
			points[12] <= 28'h0200040;
			points[13] <= 28'h0200040;
			points[14] <= 28'h0200040;
			points[15] <= 28'h0200040;
			points[16] <= 28'h0200040;
			points[17] <= 28'h0200040;
			points[18] <= 28'h0200040;
			points[19] <= 28'h0200040;
			points[20] <= 28'h7FF9FFE;
			points[21] <= 28'h4209042;
			points[22] <= 28'h4209042;
			points[23] <= 28'h33F9FCC;
			points[24] <= 28'h1240248;
			points[25] <= 28'h1240248;
			points[26] <= 28'h7E79E7E;
			points[27] <= 28'h4009002;
			points[28] <= 28'h4009002;
			points[29] <= 28'h7FFFFFE;
			points[30] <= 28'h0;
			
			score <= 0;
		end
			if(is_point && is_pacman)
			begin
				if(points[(((pacmanPosY + 12)/12) - 6)][(((pacmanPosX + 8)/12) - 6)] != 0)
				begin
					points[(((pacmanPosY + 12)/12) - 6)][(((pacmanPosX + 8)/12) - 6)] <= 0;
					score <= score + 10;
				end
				
			end
			
			if(is_pellet && is_pacman)
			begin
				if(pellets[(((pacmanPosY + 12)/12) - 6)][(((pacmanPosX + 8)/12) - 6)] != 0)
				begin
					pellets[(((pacmanPosY + 12)/12) - 6)][(((pacmanPosX + 8)/12) - 6)] <= 0;
					score <= score + 50;
				end
				
			end
		
	end
endmodule