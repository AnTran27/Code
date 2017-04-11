module test_lru_finder ;
parameter HF_CYCL = 5 ;
parameter CYCL = HF_CYCL*2 ;
//
reg clk, rst_n ;
reg b_rq ;
reg [1:0] ref ;
wire [1:0] rplc ;
//
// connect signals to game
lru_finder lru_finder_01( .clk( clk ), .rst_n( rst_n ),
.new_buf_req( b_rq ), .ref_buf_numbr( ref ),
.buf_num_replc( rplc )
) ;
always begin // clock generator
clk = 1'b0 ; #HF_CYCL ;
clk = 1'b1 ; #HF_CYCL ;
end
initial begin // give value to control variable
rst_n = 1'b0 ;
#1 rst_n = 1'b1 ;
#(CYCL * 35 ) $display("test end with no error");
#1 $finish ;
end
always @ ( posedge clk ) begin
        # 2 $strobe("t=%d, rst=%b, rq=%b, ref= %d, rplc=%b",
                $stime, rst_n, b_rq, ref, rplc
        ) ;
end
//
task chk_and_stop ; // check target result and stop if error
input [7:0] seq ; // buffer sequence
reg [1:0] w_seq [0:3] ;
integer k ;
begin
{ w_seq[0], w_seq[1], w_seq[2], w_seq[3] } = seq[7:0] ;
for ( k = 0 ; k <=3 ; k = k+1 ) begin
@(posedge clk) begin
#2 if ( rplc != w_seq[k] ) begin
$strobe("error at t=%d, buf_num_rplc shall be %d, but was
%d",
$stime, w_seq[k], rplc ) ;
#5 $finish;
end
end
end
end
endtask
initial begin
        b_rq = 1'b0 ;
        ref = 2'd0 ;
        #CYCL ref = 2'd1 ;
        #CYCL ref = 2'd0 ;
        #CYCL ref = 2'd3 ;
        #CYCL ref = 2'd2 ;
        #CYCL b_rq = 1'b1 ;
        ref = 2'dx ;
        chk_and_stop( 8'b01_00_11_10 ) ;
        @(negedge clk) b_rq = 1'b0 ;
        ref = 2'd0 ;
        #CYCL b_rq = 1'b1 ;
        ref = 2'dx ;
        chk_and_stop( 8'b01_11_10_00 ) ; // 1320
        @(negedge clk) b_rq = 1'b0 ;
        ref = 2'd2 ;
        #CYCL b_rq = 1'b1 ;
        ref = 2'dx ;
        chk_and_stop( 8'b01_11_00_10 ) ;//1302
@(negedge clk) b_rq = 1'b0 ;
ref = 2'd1 ;
#CYCL b_rq = 1'b1 ;
ref = 2'dx ;
chk_and_stop( 8'b11_00_10_01 ) ; //3021
@(negedge clk) b_rq = 1'b0 ;
ref = 2'd1 ;
#CYCL b_rq = 1'b1 ;
ref = 2'dx ;
chk_and_stop( 8'b11_00_10_01 ) ; //3021
@(negedge clk) b_rq = 1'b0 ;
ref = 2'd3 ;
#CYCL b_rq = 1'b1 ;
ref = 2'dx ;
chk_and_stop( 8'b00_10_01_11 ) ; // 0213
@(negedge clk) b_rq = 1'b0 ;
ref = 2'd0 ;
#10 b_rq = 1'b1 ;
ref = 2'dx ;
chk_and_stop( 8'b10_01_11_00 ) ; // 2130
end
//
endmodule
