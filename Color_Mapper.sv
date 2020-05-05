//-------------------------------------------------------------------------
//    Color_Mapper.sv             X                                         --
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

// color_mapper: Decide which color to be 								 to VGA for each pixel.
module  color_mapper ( 
                       input        	[9:0] DrawX, DrawY,       // Current pixel coordinates
							  input 					is_map, is_point, is_pellet, is_scoreboard, is_pacman, is_scoreboard_1up, is_pacman_life,
							  input					is_blinky, is_dead, pacman_dead,
							  input 			[3:0] blinky_sprite, BlinkycurrentDirection, is_frightened,
							  input			[3:0] scoreboard_sprite, pacman_sprite,
							  input 			[9:0] pacmanPosX, pacmanPosY,
							  input 			[9:0] blinkyPosX, blinkyPosY,
							  input			[1:0] scoreboard_1up_sprite,
							  input 			[3:0] availible_dir,
							  output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB 								
                     );

    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
	 
	 //logic [3:0] spritesheet[0:92159];
	 
	 logic [3:0] pointSprite[0:863];
	 logic [3:0] pacman_sprites[0:5183];
	 logic map[0:134663];
	 logic number_sprites[0:2303];	//192 x 12
	 logic alphabet_sprites[0:4319];	//260 x 12
	 logic [3:0] blinky_sprites[0:4607];	//192 X 24
	 logic [3:0] ghost_pellets[0:2303];
	 logic [3:0] ghost_dead[0:4607];
	 logic [3:0] pacman_dead_sprite[0:6335];
	 
	 initial
	 begin
		//$readmemh("assets/pacman.txt", spritesheet);
		$readmemb("assets/map.txt", map);
		$readmemh("assets/points.txt", pointSprite);
		$readmemh("assets/pacman_sprites.txt", pacman_sprites);
		$readmemb("assets/numbers.txt", number_sprites);
		$readmemb("assets/alphabet.txt", alphabet_sprites);
		$readmemh("assets/blinky.txt", blinky_sprites);
		$readmemh("assets/ghost_pellet.txt", ghost_pellets);
		$readmemh("assets/ghost_dead.txt", ghost_dead);
		$readmemh("assets/pacman_dead.txt", pacman_dead_sprite);
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
						1'b1:
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


			
			case(is_pacman)
				default:
				begin
					Red = Red;
					Green = Green;
					Blue = Blue;
				end
				1'b1:
				begin
					if(pacman_dead)
					begin
						case(pacman_dead_sprite[(264 * (DrawY - pacmanPosY - 6)) + (DrawX - pacmanPosX) + (24*pacman_sprite)])
							4'd7:	//FFFF21
							begin
								Red = 8'hFF;
								Green = 8'hFF;
								Blue = 8'h21;
							end
						endcase
					end
					else
					begin
						case(pacman_sprites[(216 * (DrawY - pacmanPosY - 6)) + (DrawX - pacmanPosX) + (24*pacman_sprite)])
							4'd6:	//949400
							begin
								Red = 8'h94;
								Green = 8'h94;
								Blue = 8'h00;
							end
							4'd7:	//FFFF21
							begin
								Red = 8'hFF;
								Green = 8'hFF;
								Blue = 8'h21;
							end
							default:
							begin
								Red = Red;
								Green = Green;
								Blue = Blue;
							end
						endcase
					end
					
				end
			
			endcase
			
			if(~pacman_dead)
			begin
				
				case(is_blinky)
					1'b1:
					begin
						if(is_dead)
						begin
							case(ghost_dead[192 * (DrawY - blinkyPosY - 6) + (DrawX - blinkyPosX) + (24*blinky_sprite)])
								//0, b, f
								4'd0:	//DEDEDE
								begin
									Red = 8'hDE;
									Green = 8'hDE;
									Blue = 8'hDE;
								end
								4'd11:	//2121FF
								begin
									Red = 8'h21;
									Green = 8'h21;
									Blue = 8'hFF;
								end
							endcase
						end
						else
						begin
							case(is_frightened)
								4'd0:
								begin
									case(blinky_sprites[192 * (DrawY - blinkyPosY - 6) + (DrawX - blinkyPosX) + (24*blinky_sprite)])
										//0, 1, b, f
										4'd0:	//DEDEDE
										begin
											Red = 8'hDE;
											Green = 8'hDE;
											Blue = 8'hDE;
										end
										4'd1:	//DE0000
										begin
											Red = 8'hDE;
											Green = 8'h00;
											Blue = 8'h00;
										end
										4'd11:	//2121FF
										begin
											Red = 8'h21;
											Green = 8'h21;
											Blue = 8'hFF;
										end
									endcase
								end
								4'd1:
								begin
									case(ghost_pellets[96 * (DrawY - blinkyPosY - 6) + (DrawX - blinkyPosX) + (24*(blinky_sprite % 2) + 48)])
										4'd0:	//DEDEDE
										begin
											Red = 8'hDE;
											Green = 8'hDE;
											Blue = 8'hDE;
										end
										4'd1:	//DE0000
										begin
											Red = 8'hDE;
											Green = 8'h00;
											Blue = 8'h00;
										end
										4'd11:	//2121FF
										begin
											Red = 8'h21;
											Green = 8'h21;
											Blue = 8'hFF;
										end
										4'd12: //FFB5FF
										begin
											Red = 8'hFF;
											Green = 8'hB5;
											Blue = 8'hFF;
										end
									endcase
								end
								4'd2:
								begin
									case(ghost_pellets[96 * (DrawY - blinkyPosY - 6) + (DrawX - blinkyPosX) + (24*(blinky_sprite % 2))])
										4'd0:	//DEDEDE
										begin
											Red = 8'hDE;
											Green = 8'hDE;
											Blue = 8'hDE;
										end
										4'd1:	//DE0000
										begin
											Red = 8'hDE;
											Green = 8'h00;
											Blue = 8'h00;
										end
										4'd11:	//2121FF
										begin
											Red = 8'h21;
											Green = 8'h21;
											Blue = 8'hFF;
										end
										4'd12: //FFB5FF
										begin
											Red = 8'hFF;
											Green = 8'hB5;
											Blue = 8'hFF;
										end
									endcase
								end
							endcase
						end
					end
				endcase
			end
			
			if((pacmanPosY == DrawY && pacmanPosX == DrawX) || ((pacmanPosY == DrawY - 12) && (pacmanPosX == DrawX)))
			begin
				Red = 8'hFF;
				Green = 8'hB5;
				Blue = 8'hB5;
			end
			
			if(is_scoreboard)
			begin
				case(number_sprites[(192 * ((DrawY + 6) % 12)) + (DrawX % 12) + (12*scoreboard_sprite)])
						1'b1:
						begin
							Red = 8'hFF;
							Green = 8'hFF;
							Blue = 8'hFF;
						end
						default:
						begin
							Red = Red;
							Green = Green;
							Blue = Blue;
						end
					endcase
			end
			
			if(is_scoreboard_1up)
			begin
				case(scoreboard_1up_sprite)
					2'b00:
					begin
						case(number_sprites[(192 * (DrawY % 12)) + (DrawX % 12) + (12*1)])
							1'b1:
							begin
								Red = 8'hFF;
								Green = 8'hFF;
								Blue = 8'hFF;
							end
						endcase
					end
					2'b01:
					begin
						case(alphabet_sprites[(360 * (DrawY % 12)) + (DrawX % 12) + (12*20)])
							1'b1:
							begin
								Red = 8'hFF;
								Green = 8'hFF;
								Blue = 8'hFF;
							end
						endcase
					end
					2'b10:
					begin
						case(alphabet_sprites[(360 * (DrawY % 12)) + (DrawX % 12) + (12*15)])
							1'b1:
							begin
								Red = 8'hFF;
								Green = 8'hFF;
								Blue = 8'hFF;
							end
						endcase
					end
				endcase
			end
			if(is_pacman_life)
			begin
				case(pacman_sprites[(216 * ((DrawY + 6) % 24)) + (DrawX % 24)])
					4'd6:	//949400
					begin
						Red = 8'h94;
						Green = 8'h94;
						Blue = 8'h00;
					end
					4'd7:	//FFFF21
					begin
						Red = 8'hFF;
						Green = 8'hFF;
						Blue = 8'h21;
					end
					default:
					begin
						Red = Red;
						Green = Green;
						Blue = Blue;
					end
				endcase
			end
			if(availible_dir[0])	// LEFT UP RIGHT DOWN
			begin
				if(DrawY >= 450 && DrawY < 450 + 12)
				begin
					if(DrawX >= 168 && DrawX < 168 + 12)
					begin
						case(alphabet_sprites[(360 * ((DrawY + 6) % 12)) + (DrawX % 12) + (12*11)])
							1'b1:
							begin
								if(BlinkycurrentDirection == 4'd1)
								begin
									Red = 8'hFF;
									Green = 8'h00;
									Blue = 8'h00;
								end
								else
								begin
								Red = 8'hFF;
								Green = 8'hFF;
								Blue = 8'hFF;
								end
							end
						endcase
					end
				end
			end
			if(availible_dir[1])	//up
			begin
				if(DrawY >= 450 && DrawY < 450 + 12)
				begin
					if(DrawX >= 168 + 12 && DrawX < 168 + 24)
					begin
						case(alphabet_sprites[(360 * ((DrawY + 6) % 12)) + (DrawX % 12) + (12*20)])
							1'b1:
							begin
								if(BlinkycurrentDirection == 4'd2)
								begin
									Red = 8'hFF;
									Green = 8'h00;
									Blue = 8'h00;
								end
								else
								begin
								Red = 8'hFF;
								Green = 8'hFF;
								Blue = 8'hFF;
								end
							end
						endcase
					end
				end
			end
			if(availible_dir[2])
			begin
				if(DrawY >= 450 && DrawY < 450 + 12)
				begin
					if(DrawX >= 168 + 24 && DrawX < 168 + 36)
					begin
						case(alphabet_sprites[(360 * ((DrawY + 6) % 12)) + (DrawX % 12) + (12*17)])
							1'b1:
							begin
								if(BlinkycurrentDirection == 4'd3)
								begin
									Red = 8'hFF;
									Green = 8'h00;
									Blue = 8'h00;
								end
								else
								begin
								Red = 8'hFF;
								Green = 8'hFF;
								Blue = 8'hFF;
								end
							end
						endcase
					end
				end
			end
			if(availible_dir[3])
			begin
				if(DrawY >= 450 && DrawY < 450 + 12)
				begin
					if(DrawX >= 168 + 36 && DrawX < 168 + 48)
					begin
						case(alphabet_sprites[(360 * ((DrawY + 6) % 12)) + (DrawX % 12) + (12*3)])
							1'b1:
							begin
								if(BlinkycurrentDirection == 4'd4)
								begin
									Red = 8'hFF;
									Green = 8'h00;
									Blue = 8'h00;
								end
								else
								begin
								Red = 8'hFF;
								Green = 8'hFF;
								Blue = 8'hFF;
								end
							end
						endcase
					end
				end
			end
    end 
    
endmodule
