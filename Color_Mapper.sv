//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_ball,            // Whether current pixel belongs to ball 
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
							  input 					is_map, is_point, is_pellet,
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
	 
	 
	 //logic [3:0] spritesheet[0:92159];
	 logic [3:0] map[0:134663];
	 logic [3:0] pointSprite[0:863];
	 
	 initial
	 begin
		//$readmemh("assets/pacman.txt", spritesheet);
		$readmemh("assets/map.txt", map);
		$readmemh("assets/points.txt", pointSprite);
	 end
	 
	  
    // Assign color based on is_ball signal
    always_comb
    begin
			
			Red = 8'h00;
			Green = 8'h00;
			Blue = 8'h00;
			case(is_map)
				default:
				begin
					Red = Red;
					Green = Green;
					Blue = Blue;
				end
				1'b1:
				begin
					case(map[(336 * (DrawY - 72)) + (DrawX - 72)])
						default:
						begin
							Red = Red;
							Green = Green;
							Blue = Blue;
						end
						4'd11:
						begin
							Red = 8'h21;
							Green = 8'h21;
							Blue = 8'hFF;
						end
					endcase
				end
				
			endcase
			
			case (is_point)
				default:
				begin
					Red = Red;
					Green = Green;
					Blue = Blue;
				end
				1'b1:
				begin
					case(pointSprite[(72 * (DrawY % 12)) + (DrawX % 12)])
						4'd2:	//FFB5B5
						begin
							Red = 8'hFF;
							Green = 8'hB5;
							Blue = 8'hB5;
						end
						default:
						begin
							Red = Red;
							Green = Green;
							Blue = Blue;
						end
				  endcase
				end
			endcase
			
			case (is_pellet)
				default:
				begin
					Red = Red;
					Green = Green;
					Blue = Blue;
				end
				1'b1:
				begin
					case(pointSprite[(72 * (DrawY % 12)) + (DrawX % 12) + 48])
						4'd2:	//FFB5B5
						begin
							Red = 8'hFF;
							Green = 8'hB5;
							Blue = 8'hB5;
						end
						default:
						begin
							Red = Red;
							Green = Green;
							Blue = Blue;
						end
				  endcase
				end
			endcase

    end 
    
endmodule
