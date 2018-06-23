// ------------------------------------------//
// Matrix Vector Multiplier Part-1
// ------------------------------------------//
// NAME:  Atif Iqbal
// NETID: aahangar
// SBUID: 111416569
// ------------------------------------------//

import defines_pkg::*;

module mvma4_part3 #(parameter NROWS_A = NROWS_A,
                    parameter NCOLS_A = NCOLS_A,
                    parameter NROWS_B = NROWS_B,
                    parameter NCOLS_B = NCOLS_B)
(
    input  logic                clk,
    input  logic                reset,
    input  logic                s_valid,
    input  logic                m_ready,
    input  logic signed [7:0]   data_in,
    output logic signed [15:0]  data_out,
    output logic                m_valid,
    output logic                s_ready,
    output logic                overflow
);

    localparam MAT_A_SIZE  = NROWS_A * NCOLS_A;
    localparam MAT_B_SIZE  = NROWS_B * NCOLS_B;
    localparam MAT_A_LSIZE = $clog2(MAT_A_SIZE);
    localparam MAT_B_LSIZE = $clog2(MAT_B_SIZE);
    localparam VCNT_LSIZE  = $clog2(VEC_S+1);

    enum logic [1:0] {WRITE_A=0, WRITE_B=1, WRITE_X=2, READ=3} state, next_state;

    logic        [MAT_A_LSIZE-1:0] addr_a;
    logic        [MAT_A_LSIZE-1:0] wr_addr_a;
    logic        [MAT_A_LSIZE-1:0] rd_addr_a;
    logic        [MAT_B_LSIZE-1:0] addr_b;
    logic        [MAT_B_LSIZE-1:0] wr_addr_b;
    logic        [MAT_B_LSIZE-1:0] rd_addr_b;
    logic        [MAT_B_LSIZE-1:0] addr_x;
    logic        [MAT_B_LSIZE-1:0] wr_addr_x;
    logic        [MAT_B_LSIZE-1:0] rd_addr_x;
    logic signed             [7:0] data_out_a;
    logic signed             [7:0] data_out_b;
    logic                    [7:0] data_out_x;
    logic                          wr_en_a;
    logic                          wr_en_b;
    logic                          wr_en_x;
    logic         [VCNT_LSIZE-1:0] vec_cnt;

    logic signed             [7:0] mac1_a;
    logic signed             [7:0] mac1_b;
    logic                    [7:0] mac1_x;
    logic                          mac1_valid_in;
    logic signed            [15:0] mac1_f;
    logic                          mac1_valid_out;
    logic                          mac1_overflow;

    logic                          next_req;
    logic                          valid_int;
    logic                          overflow_int;

    assign data_out      = mac1_f;
    assign m_valid       = valid_int;
    assign overflow      = overflow_int;
    assign mac1_a        = data_out_a;
    assign mac1_b        = data_out_b;
    assign mac1_x        = data_out_x;
    assign s_ready       = (state != READ);

    assign addr_a   = (state == WRITE_A) ? wr_addr_a : rd_addr_a;
    assign addr_b   = (state == WRITE_B) ? wr_addr_b : rd_addr_b;
    assign addr_x   = (state == WRITE_X) ? wr_addr_x : rd_addr_x;
    assign wr_en_a  = (state == WRITE_A) & s_valid;
    assign wr_en_b  = (state == WRITE_B) & s_valid;
    assign wr_en_x  = (state == WRITE_X) & s_valid;

    memory #(
        .WIDTH    ( 8               ),
        .SIZE     ( MAT_A_SIZE      ),
        .LOGSIZE  ( MAT_A_LSIZE     ))
    u_mat_a_mem (
        .clk      ( clk             ),
        .data_in  ( data_in         ),
        .data_out ( data_out_a      ),
        .addr     ( addr_a          ),
        .wr_en    ( wr_en_a         ));

    memory #(
        .WIDTH    ( 8               ),
        .SIZE     ( MAT_B_SIZE      ),
        .LOGSIZE  ( MAT_B_LSIZE     ))
    u_mat_b_mem (
        .clk      ( clk             ),
        .data_in  ( data_in         ),
        .data_out ( data_out_b      ),
        .addr     ( addr_b          ),
        .wr_en    ( wr_en_b         ));

    memory #(
        .WIDTH    ( 8               ),
        .SIZE     ( MAT_B_SIZE      ),
        .LOGSIZE  ( MAT_B_LSIZE     ))
    u_mat_x_mem (
        .clk      ( clk             ),
        .data_in  ( data_in         ),
        .data_out ( data_out_x      ),
        .addr     ( addr_x          ),
        .wr_en    ( wr_en_x         ));

    part3_mac #(
        .NUM_S     ( NUM_S          ),
        .VEC_S     ( VEC_S          ))
    u_mac_1 (
        .clk       ( clk            ),
        .reset     ( reset          ),
        .a         ( mac1_a         ),
        .b         ( mac1_b         ),
        .x         ( mac1_x         ),
        .valid_in  ( mac1_valid_in  ),
        .f         ( mac1_f         ),
        .valid_out ( mac1_valid_out ),
        .overflow  ( mac1_overflow  ));

    //FSM
    always_ff @(posedge clk)
        if(reset) begin
            state <= WRITE_A;
        end
        else begin
            state <= next_state;
        end

    always_comb begin
        next_state = WRITE_A;

        case (state)

            WRITE_A: begin
                if(wr_addr_a == MAT_A_SIZE-1 && s_valid)
                    next_state = WRITE_X;
                else
                    next_state = WRITE_A;
            end

            WRITE_X: begin
                if(wr_addr_x == MAT_B_SIZE-1 && s_valid)
                    next_state = WRITE_B;
                else
                    next_state = WRITE_X;
            end

            WRITE_B: begin
                if(wr_addr_b == MAT_B_SIZE-1 && s_valid)
                    next_state = READ;
                else
                    next_state = WRITE_B;
            end


            READ: begin
                if(rd_addr_a == MAT_A_SIZE-1 && rd_addr_b == MAT_B_SIZE-1 && next_req)
                    next_state = WRITE_A;
                else
                    next_state = READ;
            end

        endcase
    end

    always_ff @(posedge clk)
        if(reset) begin
            wr_addr_a <= 'd0;
            wr_addr_b <= 'd0;
            wr_addr_x <= 'd0;
        end
        else begin
            if (wr_addr_a == MAT_A_SIZE-1 && s_valid) begin
                wr_addr_a <= 'd0;
            end
            else if (wr_addr_b == MAT_B_SIZE-1 && s_valid) begin
                wr_addr_b <=  'd0;
            end
            else if (wr_addr_x == MAT_B_SIZE-1 && s_valid) begin
                wr_addr_x <=  'd0;
            end
            else if (state == WRITE_A && s_valid) begin
                wr_addr_a <= wr_addr_a + 1'd1;
            end
            else if (state == WRITE_B && s_valid) begin
                wr_addr_b <= wr_addr_b + 1'd1;
            end
            else if (state == WRITE_X && s_valid) begin
                wr_addr_x <= wr_addr_x + 1'd1;
            end
        end

    always_ff @(posedge clk)
        if(reset) begin
            rd_addr_a <= 'd0;
            rd_addr_b <= 'd0;
            rd_addr_x <= 'd0; //TODO: can use rd_addr_b instead. Keeping now for consistency.
        end
        else begin
            if (rd_addr_a == MAT_A_SIZE-1 && next_req) begin
                rd_addr_a <= 'd0;
                rd_addr_b <= 'd0;
                rd_addr_x <= 'd0;
            end
            else if (rd_addr_b == MAT_B_SIZE-1 && next_req) begin
                rd_addr_a <= rd_addr_a + 1'd1;
                rd_addr_x <= rd_addr_x + 1'd1;
                rd_addr_b <= 'd0;
            end
            else if ((state == READ) && vec_cnt < NROWS_A && next_req) begin
                rd_addr_a <= rd_addr_a + 1'd1;
                rd_addr_b <= rd_addr_b + 1'd1;
            end
        end

    always_ff @(posedge clk)
        if(reset) begin
            next_req      <= 1'b1;
            mac1_valid_in <= 1'b0;
            vec_cnt       <=  'd0;
        end
        else begin
            if (vec_cnt == NROWS_A) begin
                next_req      <= 1'b0;
                mac1_valid_in <= 1'b0;
                vec_cnt       <= 2'd0;
            end
            else if (m_valid && m_ready) begin
                next_req      <= 1'b1;
            end
            else if (next_req && (state == READ)) begin
                next_req      <= 1'b1;
                mac1_valid_in <= 1'b1;
                vec_cnt       <= vec_cnt + 1'd1;
            end
        end

    always_ff @(posedge clk)
        if(reset) begin
            valid_int <= 1'b0;
            overflow_int <= 1'b0;
        end
        else begin
            if (mac1_valid_out) begin
                valid_int <= 1'b1;
                overflow_int <= mac1_overflow;
            end
            else if (valid_int && m_ready) begin
                valid_int <= 1'b0;
                overflow_int <= 1'b0;
            end
        end

endmodule
//end of file.
