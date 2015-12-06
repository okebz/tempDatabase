`timescale 1ns / 1ps 
                                                                                                                                                     
module max_pool(p0, p1, p2, p3, out);
input [7:0] p0, p1, p2, p3; 
output[7:0] out;

  assign out = p0 > p1 && p0 > p2 && p0 > p3 ? p0 :
               p1 > p2 && p1 > p3            ? p1 :
               p2 > p3                       ? p2 : p3; 

endmodule


module custom_max_pool(clk, input_stream, reset, output_stream, data_valid);

parameter IMAGE_WIDTH = 8;

input clk, reset;
input[7:0] input_stream;
output[7:0] output_stream;
output reg  data_valid;

//shift registers
reg [7:0]row1[0:IMAGE_WIDTH-1];
reg [7:0]row2[0:1];

integer i;

reg [1:0] STATE;
reg [3:0] counter;
reg [6:0] counter_finish;

always@(posedge clk)begin
  //RESET STATE
  if(reset == 1'b1)begin
    STATE <= 0;
    counter <= 1;
    counter_finish <= 0;
     data_valid <= 0;
  end

  //INITIAL STATE. FILL UP THE BUFFER
  else if(STATE == 0)begin
    if(counter == 10)begin
      STATE <= 1;     
      counter <= 1;
      data_valid <= 1;
    end
    else begin
      STATE <= 0;     
      counter <= counter + 1;
      data_valid <= 0;
    end
    
    counter_finish <= counter_finish + 1;
  end


  //Data VALID
  else if(STATE == 1)begin
    if(counter_finish == 7'd64)begin
      STATE <= 3;     
      counter<= 0;
      data_valid <= 0;
    end
    else if(counter == 5'd7)begin
      STATE <= 2;     
      counter<= 1;
      data_valid <= 0;
    end
    else begin  
      STATE <= 1;     
      counter<= counter+1;
      data_valid <= 1;
    end
      counter_finish <= counter_finish + 1;
  end

  //Data not valid
  else if(STATE == 2)begin
    if(counter == 5'd1)begin
      STATE <= 1;     
      counter <= 1;
      data_valid <=1;
    end
    else begin  
      STATE <= 2;     
      counter<= counter+1;
      data_valid <=0;
    end
    
    counter_finish <= counter_finish + 1;
  end

  //Data not valid
  else if(STATE == 3)begin
    STATE <= 3;     
    data_valid <= 0;
    counter<= 0;
    counter_finish <= 0;
  end

end


always@(posedge clk)begin
  row1[0] <= input_stream;
  row2[0] <= row1[IMAGE_WIDTH-1];
  row2[1] <= row2[0];
  for(i = 1; i < IMAGE_WIDTH; i=i+1)begin
    row1[i] <= row1[i-1];
  end
end           

max_pool mp(row1[0],row1[1], row2[0],row2[1], output_stream);

endmodule
