module valid_moves(input [9:0] PosX, PosY, input is_Ghost ,output [3:0] availible_dir);

	logic[0:30][0:27] moveable;

	initial
	begin
		moveable[0] = 28'h0;
		moveable[1] = 28'h7FF9FFE;
		moveable[2] = 28'h4209042;
		moveable[3] = 28'h4209042;
		moveable[4] = 28'h4209042;
		moveable[5] = 28'h7FFFFFE;
		moveable[6] = 28'h4240242;
		moveable[7] = 28'h4240242;
		moveable[8] = 28'h7E79E7E;
		moveable[9] = 28'h0209040;
		moveable[10] = 28'h0209040;
		moveable[11] = 28'h027FE40;
		moveable[12] = 28'h0240240;
		moveable[13] = 28'h0240240;
		moveable[14] = 28'hFFC03FF;
		moveable[15] = 28'h0240240;
		moveable[16] = 28'h0240240;
		moveable[17] = 28'h027FE40;
		moveable[18] = 28'h0240240;
		moveable[19] = 28'h0240240;
		moveable[20] = 28'h7FF9FFE;
		moveable[21] = 28'h4209042;
		moveable[22] = 28'h4209042;
		moveable[23] = 28'h73FFFCE;
		moveable[24] = 28'h1240248;
		moveable[25] = 28'h1240248;
		moveable[26] = 28'h7E79E7E;
		moveable[27] = 28'h4009002;
		moveable[28] = 28'h4009002;
		moveable[29] = 28'h7FFFFFE;
		moveable[30] = 28'h0;
	end
	



	always_comb
	begin
	
		availible_dir = 4'h0;
		
		//horizontal movement
		if(moveable[((PosY + 17) / 12) - 6 ][((PosX + 5) / 12) - 6] == 1'b1 && ((PosY) % 12 == 0 || (PosY) % 12 == 1 || (PosY) % 12 == 11) && moveable[((PosY + 18) / 12) - 6 ][((PosX + 5) / 12) - 6] == 1'b1)
			availible_dir[0] = 1'b1;
		if(moveable[((PosY + 17) / 12) - 6 ][((PosX + 18) / 12) - 6] == 1'b1 && ((PosY) % 12 == 0 || (PosY) % 12 == 1 || (PosY) % 12 == 11) && moveable[((PosY + 18) / 12) - 6 ][((PosX + 18) / 12) - 6] == 1'b1)
			availible_dir[2] = 1'b1;
			
		//vertical movement
		if(moveable[((PosY + 11) / 12) - 6 ][((PosX + 11) / 12) - 6] == 1'b1 && (PosX % 12 == 5 || PosX % 12 == 6 || PosX % 12 == 7))
			availible_dir[1] = 1'b1;
		if(moveable[((PosY + 24) / 12) - 6 ][((PosX + 11) / 12) - 6] == 1'b1 && (PosX % 12 == 5 || PosX % 12 == 6 || PosX % 12 == 7))
			availible_dir[3] = 1'b1;
		
		
	end
	
	

endmodule