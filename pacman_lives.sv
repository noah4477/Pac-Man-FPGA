module pacman_lives(input [1:0] lives, input [9:0] DrawX, DrawY, output is_pacman_life);

	always_comb
	begin
		is_pacman_life = 1'b0;
		
		if(DrawY >= 450 && DrawY < 450 + 24)
		begin
			if(DrawX >= 72 && DrawX < 72 + 24 && (lives == 2'b01 || lives == 2'b10))
			begin
				is_pacman_life = 1'b1;
			end
			if(DrawX >= 72 + 24 && DrawX < 72 + 48 && lives == 2'b10)
			begin
				is_pacman_life = 1'b1;
			end
		end
	end

endmodule