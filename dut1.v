module lru_finder (clk, rst_n,
        new_buf_req, ref_buf_numbr,
        buf_num_replc
) ;
input clk, rst_n ;
input new_buf_req ;
input [1:0] ref_buf_numbr ;
output[1:0] buf_num_replc ;
wire clk, rst_n ;
wire new_buf_req ;
wire [1:0] ref_buf_numbr ;
reg [1:0] buf_num_replc ;
// internal signals
reg [5:0] ref_seq ; // FF
reg [5:0] next_seq ; // non-FF
reg [1:0] oldest_buf ; // non-FF
wire [1:0] ref_numbr ;
// ======= find the oldest entry ==========
always @ ( ref_seq[5:0] ) begin
casez ( ref_seq[5:0] )
6'b111??? : begin
oldest_buf[1:0] = 2'b00 ;
end
6'b0??11? : begin
oldest_buf[1:0] = 2'b01 ;
end
6'b?0?0?1 : begin
oldest_buf[1:0] = 2'b10 ;
end
6'b??0?00 : begin
oldest_buf[1:0] = 2'b11 ;
end
default : begin
oldest_buf[1:0] = 2'bxx ;
end
endcase
end
//********* select buffer to be replaced ***************
always @ ( posedge clk ) begin
if ( new_buf_req == 1'b1 ) begin
buf_num_replc[1:0] <= oldest_buf[1:0] ;
end
end
assign ref_numbr[1:0] = ( new_buf_req == 1'b1 )?
oldest_buf[1:0] : ref_buf_numbr[1:0] ;
//********* reference sequence *****************
always @ ( posedge clk or negedge rst_n ) begin
if ( rst_n == 1'b0 ) begin // initialize reference sequence
ref_seq[5:0] <= 6'b111_11_1 ; // #0(old), #1, #2, and
#3(new) order
end
else begin
ref_seq[5:0] <= next_seq[5:0] ;
end
end
always @ ( ref_seq[5:0] or ref_numbr[1:0] ) begin
        case ( ref_numbr[1:0] )
                2'b00 : begin // update pattern 000xxx
                next_seq[5:0] = { 3'b000, ref_seq[2:0] } ;
        end
        2'b01 : begin // update pattern 1xx00x
        next_seq[5:0] = { 1'b1, ref_seq[4:3], 2'b0, ref_seq[0] } ;
end
2'b10 : begin // update pattern x1x1x0
next_seq[5:0] = { ref_seq[5], 1'b1,ref_seq[3],1'b1,ref_seq[1], 1'b0 } ;
end
2'b11 : begin // update pattern xx1x11
next_seq[5:0] = { ref_seq[5:4], 1'b1, ref_seq[2], 2'b11 } ;
end
default : begin
        next_seq[5:0] = 6'bxxxxxx ;
end
endcase
end
endmodule
