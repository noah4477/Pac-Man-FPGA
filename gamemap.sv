module gamemap(input [9:0] DrawX, DrawY, output logic is_map);

	
	always_comb
	begin
		is_map = 0;
		
		if(DrawY >= 72 && DrawY < 444 && DrawX >= 72 && DrawX < 408)
		begin
			is_map = 1;
		end
	end
endmodule