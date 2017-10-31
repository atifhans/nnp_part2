// ------------------------------------------//
// Matrix Vector Multiplier Part-4
// ------------------------------------------//
// NAME:  Atif Iqbal
// NETID: aahangar
// SBUID: 111416569
// ------------------------------------------//

import defines_pkg::*;

module mvm4a_part4 #(parameter NROWS_A = NROWS_A,
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
    localparam MAT_A_LSIZE = $clog2(NROWS_A);
    localparam MAT_B_LSIZE = $clog2(MAT_B_SIZE);
    localparam VCNT_LSIZE  = $clog2(VEC_S+1);

    enum logic [1:0] {IDLE=0, WRITE_A=1, WRITE_B=2, WRITE_X=3} state, next_state;

    logic        [MAT_A_LSIZE-1:0] ping_addr_a;
    logic        [MAT_A_LSIZE-1:0] pong_addr_a;
    logic        [MAT_A_LSIZE-1:0] wr_addr_a;
    logic        [MAT_A_LSIZE-1:0] rd_addr_a;
    logic        [MAT_B_LSIZE-1:0] ping_addr_b;
    logic        [MAT_B_LSIZE-1:0] pong_addr_b;
    logic        [MAT_B_LSIZE-1:0] wr_addr_b;
    logic        [MAT_B_LSIZE-1:0] rd_addr_b;
    logic        [MAT_B_LSIZE-1:0] ping_addr_x;
    logic        [MAT_B_LSIZE-1:0] pong_addr_x;
    logic        [MAT_B_LSIZE-1:0] wr_addr_x;
    logic        [MAT_B_LSIZE-1:0] rd_addr_x;
    logic                          pp_flag;
    logic                          next_pp_flag;
    logic                    [1:0] pp_wr_cnt;
    logic                          pp_flag_rd;
    logic signed             [7:0] ping_data_out_a[NROWS_A];
    logic signed             [7:0] ping_data_out_b;
    logic                    [7:0] ping_data_out_x;
    logic                          ping_wr_en_a[NROWS_A];
    logic                          ping_wr_en_b;
    logic                          ping_wr_en_x;
    logic signed             [7:0] pong_data_out_a[NROWS_A];
    logic signed             [7:0] pong_data_out_b;
    logic                    [7:0] pong_data_out_x;
    logic                          pong_wr_en_a[NROWS_A];
    logic                          pong_wr_en_b;
    logic                          pong_wr_en_x;
    logic                          pp_wr_done;
    logic                          pp_rd_done;
    logic                          pp_rd_done_dly;
    logic         [VCNT_LSIZE-1:0] vec_cnt;
    logic         [VCNT_LSIZE-1:0] row_cnt;
    logic         [VCNT_LSIZE-1:0] vld_in_cnt;
    logic         [VCNT_LSIZE-1:0] vld_out_cnt;

    logic signed             [7:0] mac_a[NROWS_A];
    logic signed             [7:0] mac_b;
    logic                    [7:0] mac_x;
    logic                          mac_valid_in;
    logic signed            [15:0] mac_f[NROWS_A];
    logic                          mac_valid_out[NROWS_A];
    logic                          mac_overflow[NROWS_A];

    logic        [MAT_A_LSIZE-1:0] mem_sel;

    logic                          next_req;
    logic                          valid_int[NROWS_A];
    logic                          overflow_int[NROWS_A];
    logic                          rd_done_prev;

    assign pp_wr_done    = (wr_addr_b   == NROWS_A-1) & s_valid & s_ready;
    assign pp_rd_done    = (vld_out_cnt == NROWS_A-1) & m_valid & m_ready;
    assign s_ready       = (pp_wr_cnt != 2'd2) && (state != IDLE);

    assign mac_b         = (pp_flag) ? ping_data_out_b : pong_data_out_b;
    assign mac_x         = (pp_flag) ? ping_data_out_x : pong_data_out_x;

    assign ping_addr_a   = ((state == WRITE_A) & !pp_flag) ? wr_addr_a : rd_addr_a;
    assign pong_addr_a   = ((state == WRITE_A) &  pp_flag) ? wr_addr_a : rd_addr_a;

    assign ping_addr_b   = ((state == WRITE_B) & !pp_flag) ? wr_addr_b : rd_addr_b;
    assign pong_addr_b   = ((state == WRITE_B) &  pp_flag) ? wr_addr_b : rd_addr_b;
    assign ping_addr_x   = ((state == WRITE_X) & !pp_flag) ? wr_addr_x : rd_addr_x;
    assign pong_addr_x   = ((state == WRITE_X) &  pp_flag) ? wr_addr_x : rd_addr_x;

    assign ping_wr_en_b  = (state == WRITE_B) & s_valid & !pp_flag;
    assign ping_wr_en_x  = (state == WRITE_X) & s_valid & !pp_flag;
    assign pong_wr_en_b  = (state == WRITE_B) & s_valid &  pp_flag;
    assign pong_wr_en_x  = (state == WRITE_X) & s_valid &  pp_flag;

    always_comb begin
        data_out = 'bx;
        m_valid  = 'bx;
        overflow = 'bx;
        for(int i = 0; i <= NROWS_A; i++) begin

            if(vld_out_cnt == i) begin
                data_out = mac_f[i];
                m_valid  = valid_int[i];
                overflow = overflow_int[i];
            end

            if(mem_sel == i) begin
                ping_wr_en_a[i] = (state == WRITE_A) & s_valid & !pp_flag;
                pong_wr_en_a[i] = (state == WRITE_A) & s_valid &  pp_flag;
            end
            else begin
                ping_wr_en_a[i] = 1'b0;
                pong_wr_en_a[i] = 1'b0;
            end

            mac_a[i] = (pp_flag) ? ping_data_out_a[i] : pong_data_out_a[i];
        end
    end

    genvar j;
    generate 
        for(j = 0; j < NROWS_A; j++) begin
            part3_mac #(
                .NUM_S     ( NUM_S             ),
                .IDX       ( j                 ),
                .VEC_S     ( VEC_S             ))
            u_mac (
                .clk       ( clk               ),
                .reset     ( reset             ),
                .a         ( mac_a[j]          ),
                .b         ( mac_b             ),
                .x         ( mac_x             ),
                .valid_in  ( mac_valid_in      ),
                .f         ( mac_f[j]          ),
                .valid_out ( mac_valid_out[j]  ),
                .overflow  ( mac_overflow[j]   ));

            memory #(
                .WIDTH    ( 8                  ),
                .SIZE     ( NROWS_A            ),
                .LOGSIZE  ( MAT_A_LSIZE        ))
            u_mat_a_mem_ping (
                .clk      ( clk                ),
                .data_in  ( data_in            ),
                .data_out ( ping_data_out_a[j] ),
                .addr     ( ping_addr_a        ),
                .wr_en    ( ping_wr_en_a[j]    ));

            memory #(
                .WIDTH    ( 8                  ),
                .SIZE     ( NROWS_A            ),
                .LOGSIZE  ( MAT_A_LSIZE        ))
            u_mat_a_mem_pong (
                .clk      ( clk                ),
                .data_in  ( data_in            ),
                .data_out ( pong_data_out_a[j] ),
                .addr     ( pong_addr_a        ),
                .wr_en    ( pong_wr_en_a[j]    ));
        end
    endgenerate

    memory #(
        .WIDTH    ( 8               ),
        .SIZE     ( MAT_B_SIZE      ),
        .LOGSIZE  ( MAT_B_LSIZE     ))
    u_mat_b_mem_ping (
        .clk      ( clk             ),
        .data_in  ( data_in         ),
        .data_out ( ping_data_out_b ),
        .addr     ( ping_addr_b     ),
        .wr_en    ( ping_wr_en_b    ));

    memory #(
        .WIDTH    ( 8               ),
        .SIZE     ( MAT_B_SIZE      ),
        .LOGSIZE  ( MAT_B_LSIZE     ))
    u_mat_b_mem_pong (
        .clk      ( clk             ),
        .data_in  ( data_in         ),
        .data_out ( pong_data_out_b ),
        .addr     ( pong_addr_b     ),
        .wr_en    ( pong_wr_en_b    ));

    memory #(
        .WIDTH    ( 8               ),
        .SIZE     ( MAT_B_SIZE      ),
        .LOGSIZE  ( MAT_B_LSIZE     ))
    u_mat_x_mem_ping (
        .clk      ( clk             ),
        .data_in  ( data_in         ),
        .data_out ( ping_data_out_x ),
        .addr     ( ping_addr_x     ),
        .wr_en    ( ping_wr_en_x    ));

    memory #(
        .WIDTH    ( 8               ),
        .SIZE     ( MAT_B_SIZE      ),
        .LOGSIZE  ( MAT_B_LSIZE     ))
    u_mat_x_mem_pong (
        .clk      ( clk             ),
        .data_in  ( data_in         ),
        .data_out ( pong_data_out_x ),
        .addr     ( pong_addr_x     ),
        .wr_en    ( pong_wr_en_x    ));

    //Write FSM
    always_ff @(posedge clk)
        if(reset) begin
            pp_flag <= 1'b0;
            pp_rd_done_dly <= 1'b0;
        end
        else begin
            pp_flag <= next_pp_flag;
            pp_rd_done_dly <= pp_rd_done;
        end

    always_ff @(posedge clk)
        if(reset) begin
            state <= WRITE_A;
        end
        else begin
            state <= next_state;
        end

    always_comb begin
        next_state = WRITE_A;
        next_pp_flag = 0;

        case (state)

            IDLE: begin
                if(rd_done_prev) begin
                    next_state = WRITE_A;
                    next_pp_flag = ~pp_flag;
                end
                else begin
                    next_state = IDLE;
                    next_pp_flag = pp_flag;
                end
            end

            WRITE_A: begin
                if((wr_addr_a == NROWS_A-1) & (mem_sel == NROWS_A-1) & s_valid) begin
                    next_state = WRITE_X;
                    next_pp_flag = pp_flag;
                end
                else begin
                    next_state = WRITE_A;
                    next_pp_flag = pp_flag;
                end
            end

            WRITE_X: begin
                if((wr_addr_x == NROWS_A-1) & s_valid) begin
                    next_state = WRITE_B;
                    next_pp_flag = pp_flag;
                end
                else begin
                    next_state = WRITE_X;
                    next_pp_flag = pp_flag;
                end
            end

            WRITE_B: begin
                if(pp_wr_done & (rd_done_prev | pp_rd_done_dly)) begin
                    next_state = WRITE_A;
                    next_pp_flag = ~pp_flag;
                end
                else if (pp_wr_done) begin
                    next_state = IDLE;
                    next_pp_flag = pp_flag;
                end
                else begin
                    next_state = WRITE_B;
                    next_pp_flag = pp_flag;
                end
            end

        endcase
    end

    always_ff @(posedge clk)
        if(reset) begin
            pp_wr_cnt <= 'd0;
            rd_done_prev <= 1'b1;
        end
        else begin
            if(state == IDLE && rd_done_prev) begin
                rd_done_prev <= 1'b0;
            end
            else if (pp_wr_done && pp_rd_done_dly) begin
                pp_wr_cnt <= pp_wr_cnt;
                rd_done_prev <= 1'b0;
            end
            else if (pp_wr_done) begin
                pp_wr_cnt <= pp_wr_cnt + 1'b1;
                rd_done_prev <= 1'b0;
            end
            else if (pp_rd_done_dly) begin
                pp_wr_cnt <= pp_wr_cnt - 1'b1;
                rd_done_prev <= 1'b1;
            end
        end

    always_ff @(posedge clk)
        if(reset) begin
            wr_addr_a <= 'd0;
            wr_addr_b <= 'd0;
            wr_addr_x <= 'd0;
            mem_sel   <= 'd0;
        end
        else begin
            if (wr_addr_a == NROWS_A-1 && s_valid) begin
                wr_addr_a <= 'd0;
                mem_sel   <= (mem_sel == NROWS_A-1) ? 0 : mem_sel + 1'b1;
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
            rd_addr_a  <=  'd0;
            rd_addr_b  <=  'd0;
            rd_addr_x  <=  'd0;
            row_cnt    <=  'd0;
            pp_flag_rd <= 1'b0;
        end
        else begin
            if ((rd_addr_a == NROWS_A-1) & (row_cnt == NROWS_A-1) & next_req) begin
                rd_addr_a  <= 'd0;
                rd_addr_b  <= 'd0;
                rd_addr_x  <= 'd0;
                row_cnt    <= 'd0;
                pp_flag_rd <= !pp_flag_rd;
            end
            else if ((rd_addr_a == NROWS_A-1) & next_req) begin
                rd_addr_a <= 'd0;
                rd_addr_x <= 'd0;
                rd_addr_b <= 'd0;
                row_cnt   <= row_cnt + 1'b1;
            end
            else if ((pp_wr_cnt > 0) & next_req & (vld_in_cnt != NROWS_A)) begin
                rd_addr_a <= rd_addr_a + 1'd1;
                rd_addr_b <= rd_addr_b + 1'd1;
                rd_addr_x <= rd_addr_x + 1'd1;
            end
        end

    always_ff @(posedge clk)
        if(reset) begin
            mac_valid_in <= 1'b0;
            vld_in_cnt   <=  'd0;
            next_req     <= 1'b1;
            vec_cnt      <=  'd0;
        end
        else begin
            if (vld_in_cnt == NROWS_A) begin
                next_req      <= 1'b0;
                mac_valid_in  <= 1'b0;
                vld_in_cnt    <=  'd0;
                vec_cnt       <= 2'd0;
            end
            else if (next_req && (pp_wr_cnt > 0)) begin
                mac_valid_in  <= (vec_cnt < NROWS_A) ? 1'b1 : 1'b0; 
                vld_in_cnt    <= vld_in_cnt + 1'b1;
                next_req      <= 1'b1;
                vec_cnt       <= vec_cnt + 1'd1;
            end
            else if (pp_rd_done_dly) begin
                next_req      <= 1'b1;
            end
        end

    always_ff @(posedge clk)
        if(reset) begin
            vld_out_cnt <= 'd0;
        end
        else begin
            if(vld_out_cnt == NROWS_A-1) begin
                vld_out_cnt <= 'd0;
            end
            else if(m_valid & m_ready) begin
                vld_out_cnt <= vld_out_cnt + 1'b1;
            end
        end

    always_ff @(posedge clk)
        if(reset) begin
            for(int i = 0; i < NROWS_A; i++) begin
                valid_int[i]    <= 1'b0;
                overflow_int[i] <= 1'b0;
            end
        end
        else begin
            if ((vld_out_cnt == NROWS_A-1) & m_ready & m_valid) begin
                for(int i = 0; i < NROWS_A; i++) begin
                    valid_int[i]    <= 1'b0;
                    overflow_int[i] <= 1'b0;
                end
            end
            else begin
                for(int i = 0; i < NROWS_A; i++) begin
                    valid_int[i]    <= (mac_valid_out[i]) ? 1'b1 : valid_int[i];
                    overflow_int[i] <= (mac_overflow[i] ) ? 1'b1 : overflow_int[i];
                end
            end
        end

endmodule
//end of file.
