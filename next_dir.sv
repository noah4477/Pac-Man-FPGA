module next_dir(input [9:0] targetX, targetY, ghostPosX, ghostPosY, currentDirection, input [3:0] availible_dir, output [3:0] nextDirection);

	logic [9:0] distance1, distance2, distance3, distance4;
	logic [9:0] dist1_x, dist1_y, dist2_x, dist2_y, dist3_x, dist3_y, dist4_x, dist4_y;
	
	
	
	
	always_comb
	begin
		nextDirection = currentDirection;
		
		dist1_x = 0; 
		dist1_y = 0; 
		dist2_x = 0; 
		dist2_y = 0;
		dist3_x = 0;
		dist3_y = 0;
		dist4_x = 0;
		dist4_y = 0;
		
		
			//DIRECTION 1		LEFT
			if((targetX / 12) - ((ghostPosX - 12) / 12) < 0)
			begin
				dist1_x = ((ghostPosX - 12) / 12) - (targetX / 12);
			end
			else
			begin
				dist1_x = (targetX / 12) - ((ghostPosX - 12) / 12);
			end
			//DIRECTION 1		LEFT
			if((targetY / 12) - (ghostPosY / 12) < 0)
			begin
				dist1_y = (ghostPosY / 12) - (targetY / 12);
			end
			else
			begin
				dist1_y = (targetY / 12) - (ghostPosY / 12);
			end
			
			//DIRECTION 2		UP
			if((targetX / 12) - (ghostPosX / 12) < 0)
			begin
				dist2_x = (ghostPosX / 12) - (targetX / 12);
			end
			else
			begin
				dist2_x = (targetX / 12) - (ghostPosX / 12);
			end
			//DIRECTION 2		UP
			if((targetY / 12) - ((ghostPosY - 12) / 12) < 0)
			begin
				dist2_y = ((ghostPosY - 12) / 12) - (targetY / 12);
			end
			else
			begin
				dist2_y = (targetY / 12) - ((ghostPosY - 12) / 12);
			end
			
			
			//DIRECTION 3		RIGHT
			if((targetX / 12) - ((ghostPosX + 12) / 12) < 0)
			begin
				dist3_x = ((ghostPosX + 12) / 12) - (targetX / 12);
			end
			else
			begin
				dist3_x = (targetX / 12) - ((ghostPosX + 12) / 12);
			end
			//DIRECTION 3		RIGHT
			if((targetY / 12) - (ghostPosY / 12) < 0)
			begin
				dist3_y = (ghostPosY / 12) - (targetY / 12);
			end
			else
			begin
				dist3_y = (targetY / 12) - (ghostPosY / 12);
			end
			
			
			//DIRECTION 4		DOWN
			if((targetX / 12) - (ghostPosX / 12) < 0)
			begin
				dist4_x = (ghostPosX / 12) - (targetX / 12);
			end
			else
			begin
				dist4_x = (targetX / 12) - (ghostPosX / 12);
			end
			//DIRECTION 4		DOWN
			if((targetY / 12) - ((ghostPosY + 12) / 12) < 0)
			begin
				dist4_y = ((ghostPosY + 12) / 12) - (targetY / 12);
			end
			else
			begin
				dist4_y = (targetY / 12) - ((ghostPosY + 12) / 12);
			end
			
			// ORDER UP LEFT DOWN RIGHT
			
			distance1 = (dist1_y * 1)  + (dist1_x * 1);	//left
			distance2 = (dist2_y * 1)  + (dist2_x * 1);	//up
			distance3 = (dist3_y * 1)  + (dist3_x * 1);	//right
			distance4 = (dist4_y * 1)  + (dist4_x * 1);	//down
			
			distance1 = (dist1_y * dist1_y)  + (dist1_x * dist1_x);	//left
			distance2 = (dist2_y * dist2_y)  + (dist2_x * dist2_x);	//up
			distance3 = (dist3_y * dist3_y)  + (dist3_x * dist3_x);	//right
			distance4 = (dist4_y * dist4_y)  + (dist4_x * dist4_x);	//down
			
			case(currentDirection)
				4'd1:	//LEFT
				begin
					if(distance2 <= distance4 && distance2 <= distance1 && availible_dir[1])
					begin
						nextDirection = 4'd2;
					end
					else if(distance1 <= distance2 && distance1 <= distance4 && availible_dir[0])
						nextDirection = 4'd1;
					else if(distance4 <= distance2 && distance4 <= distance1 && availible_dir[3])
						nextDirection = 4'd4;
						
					else if(~availible_dir[1] && availible_dir[0] && distance1 <= distance4)
						nextDirection = 4'd1;
					else if(~availible_dir[1] && availible_dir[3] && distance4 <= distance1)
						nextDirection = 4'd4;
					else if(~availible_dir[0] && availible_dir[1] && distance2 <= distance4)
						nextDirection = 4'd2;
					else if(~availible_dir[0] && availible_dir[3] && distance4 <= distance2)
						nextDirection = 4'd4;
					else if(~availible_dir[3] && availible_dir[0] && distance1 <= distance2)
						nextDirection = 4'd1;
					else if(~availible_dir[3] && availible_dir[1] && distance2 <= distance1)
						nextDirection = 4'd2;
						
					else if(~availible_dir[1] && ~availible_dir[0])
						nextDirection = 4'd4;
					else if(~availible_dir[1] && ~availible_dir[3])
						nextDirection = 4'd1;
					else if(~availible_dir[0] && ~availible_dir[1])
						nextDirection = 4'd4;
					else if(~availible_dir[0] && ~availible_dir[3])
						nextDirection = 4'd2;
					else if(~availible_dir[3] && ~availible_dir[0])
						nextDirection = 4'd2;
					else if(~availible_dir[3] && ~availible_dir[1])
						nextDirection = 4'd1;
				end
				4'd2:	//UP
				begin
					if(distance2 <= distance1 && distance2 <= distance3 && availible_dir[1])
						nextDirection = 4'd2;
					else if(distance1 <= distance2 && distance1 <= distance3 && availible_dir[0])
						nextDirection = 4'd1;
					else if(distance3 <= distance1 && distance3 <= distance2 && availible_dir[2])
						nextDirection = 4'd3;
						
					else if(~availible_dir[1] && availible_dir[0] && distance1 <= distance3)
						nextDirection = 4'd1;
					else if(~availible_dir[1] && availible_dir[2] && distance3 <= distance1)
						nextDirection = 4'd3;
					else if(~availible_dir[0] && availible_dir[1] && distance2 <= distance3)
						nextDirection = 4'd2;
					else if(~availible_dir[0] && availible_dir[2] && distance3 <= distance2)
						nextDirection = 4'd3;
					else if(~availible_dir[2] && availible_dir[0] && distance1 <= distance2)
						nextDirection = 4'd1;
					else if(~availible_dir[2] && availible_dir[1] && distance2 <= distance1)
						nextDirection = 4'd2;
						
					else if(~availible_dir[1] && ~availible_dir[0])
						nextDirection = 4'd3;
					else if(~availible_dir[1] && ~availible_dir[2])
						nextDirection = 4'd1;
					else if(~availible_dir[0] && ~availible_dir[1])
						nextDirection = 4'd3;
					else if(~availible_dir[0] && ~availible_dir[2])
						nextDirection = 4'd2;
					else if(~availible_dir[2] && ~availible_dir[0])
						nextDirection = 4'd2;
					else if(~availible_dir[2] && ~availible_dir[1])
						nextDirection = 4'd1;
					
				end
				4'd3:	//RIGHT
				begin
					if(distance2 <= distance3 && distance2 <= distance4 && availible_dir[1])
						nextDirection = 4'd2;
					else if(distance4 <= distance2 && distance4 <= distance3 && availible_dir[3])
						nextDirection = 4'd4;
					else if(distance3 <= distance2 && distance3 <= distance4 && availible_dir[2])
						nextDirection = 4'd3; 
						
					else if(~availible_dir[1] && availible_dir[2] && distance3 <= distance4)
						nextDirection = 4'd3;
					else if(~availible_dir[1] && availible_dir[3] && distance4 <= distance3)
						nextDirection = 4'd4;
					else if(~availible_dir[2] && availible_dir[1] && distance2 <= distance4)
						nextDirection = 4'd2;
					else if(~availible_dir[2] && availible_dir[3] && distance4 <= distance2)
						nextDirection = 4'd4;
					else if(~availible_dir[3] && availible_dir[2] && distance3 <= distance2)
						nextDirection = 4'd3;
					else if(~availible_dir[3] && availible_dir[1] && distance2 <= distance3)
						nextDirection = 4'd2;
						
					else if(~availible_dir[1] && ~availible_dir[2])
						nextDirection = 4'd4;
					else if(~availible_dir[1] && ~availible_dir[3])
						nextDirection = 4'd3;
					else if(~availible_dir[2] && ~availible_dir[1])
						nextDirection = 4'd4;
					else if(~availible_dir[2] && ~availible_dir[3])
						nextDirection = 4'd2;
					else if(~availible_dir[3] && ~availible_dir[2])
						nextDirection = 4'd2;
					else if(~availible_dir[3] && ~availible_dir[1])
						nextDirection = 4'd3;
					
				end
				4'd4:	//DOWN
				begin
					if(distance1 <= distance4 && distance1 <= distance3 && availible_dir[0])
						nextDirection = 4'd1;
					else if(distance4 <= distance1 && distance4 <= distance3 && availible_dir[3])
						nextDirection = 4'd4;
					else if(distance3 <= distance1 && distance3 <= distance4 && availible_dir[2])
						nextDirection = 4'd3;
						
					else if(~availible_dir[0] && availible_dir[3] && distance4 <= distance3)
						nextDirection = 4'd4;
					else if(~availible_dir[0] && availible_dir[2] && distance3 <= distance4)
						nextDirection = 4'd3;
					else if(~availible_dir[2] && availible_dir[3] && distance4 <= distance1)
						nextDirection = 4'd4;
					else if(~availible_dir[2] && availible_dir[0] && distance1 <= distance4)
						nextDirection = 4'd1;
					else if(~availible_dir[3] && availible_dir[0] && distance1 <= distance3)
						nextDirection = 4'd1;
					else if(~availible_dir[3] && availible_dir[2] && distance3 <= distance1)
						nextDirection = 4'd3;
						
					else if(~availible_dir[0] && ~availible_dir[3])
						nextDirection = 4'd3;
					else if(~availible_dir[0] && ~availible_dir[2])
						nextDirection = 4'd4;
					else if(~availible_dir[2] && ~availible_dir[3])
						nextDirection = 4'd1;
					else if(~availible_dir[2] && ~availible_dir[0])
						nextDirection = 4'd4;
					else if(~availible_dir[3] && ~availible_dir[0])
						nextDirection = 4'd3;
					else if(~availible_dir[3] && ~availible_dir[2])
						nextDirection = 4'd1;
				end
			endcase

	end



endmodule