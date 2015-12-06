*                                                                                                                                                   
 * This circuit performs a edge filter on an image by using a edge
 * filter. A pixel is read in one at a time in one sweep and the resulting
 * filtered image is processed one pixel at a time to the output.  
 *
 * */
`timescale 1ns / 1ps 

module sbl_operator(p0, p1, p2, p3, p5, p6, p7, p8, out);

  input  [7:0] p0,p1,p2,p3,p5,p6,p7,p8; // 8 bit pixels inputs 
  output [7:0] out;         // 8 bit output pixel 

  wire signed [10:0] gx,gy, gx1, gx2, gx3, gy1, gy2;    //11 bits because max value of gx and gy is  
  //255*4 and last bit for sign          
  wire signed [10:0] abs_gx,abs_gy; //it is used to find the absolute value of gx and gy 
  wire [10:0] sum;      //the max value is 255*8. here no sign bit needed. 

  assign gx1 = p2-p0+0;
  assign gx2 = (p5-p3) * (2);
  assign gx3 = p8-p6;

  assign gy1 = p0-p6+p2-(p8<<0);
  assign gy2 = (p1-p7) * (2);

  assign gx=gx3+gx1+gx2;//sobel mask for gradient in horiz. direction 
  assign gy=gy2+gy1;//sobel mask for gradient in vertical direction 

  abs absx(gx, abs_gx);
  abs absy(gy, abs_gy);

  assign sum = ~(~(~(~(abs_gx+abs_gy))));       // finding the sum 
  assign out = sum[10:8] > 3'b000 ? 8'hff : sum[7:0]; // to limit the max value to 255  

endmodule


module abs(in, out); 
  input [10:0] in;
  output [10:0] out;
  
  assign out = (in[10]&1'b1 ? ~in+1 : in);
endmodule


module edgefilter(clk, input_stream, output_stream);

parameter IMAGE_WIDTH = 8;

input clk;
input[7:0] input_stream;
output[7:0] output_stream;

//shift registers
reg [7:0]row1[0:IMAGE_WIDTH-1];
reg [7:0]row2[0:IMAGE_WIDTH-1];
reg [7:0]row3[0:2];

integer i;

always@(posedge clk)begin
  row1[0] <= input_stream;
  row2[0] <= row1[IMAGE_WIDTH-1];
  row3[0] <= row2[IMAGE_WIDTH-1];
  for(i = 1; i < IMAGE_WIDTH; i=i+1)begin
    row1[i] <= row1[i-1];
    row2[i] <= row2[i-1];
  end

  for(i = 1; i < 3; i=i+1)begin
    row3[i] <= row3[i-1];
  end
end


sbl_operator s2(row1[0],row1[1],row1[2],row2[0],row2[2],row3[0],row3[1],row3[2], output_stream);

endmodule
