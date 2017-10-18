//-------------------------------------------//
// Matrix Vector Multiplier Testbench Part-1
// ------------------------------------------//
// NAME:  Atif Iqbal
// NETID: aahangar
// SBUID: 111416569
// ------------------------------------------//

import defines_pkg::*;

class mat_mult_model;

    localparam M_SIZE_A = NROWS_A * NCOLS_A;
    localparam M_SIZE_B = NROWS_B * NCOLS_B;
    localparam M_SIZE_Z = NROWS_A * NCOLS_B;

    rand bit signed   [ 7:0] mat_a_in[M_SIZE_A];
    rand bit signed   [ 7:0] mat_b_in[M_SIZE_B];
    
    bit signed        [15:0] int_a;
    bit signed        [15:0] int_b;

    bit signed        [ 7:0] mat_a[M_SIZE_A][*];
    bit signed        [ 7:0] mat_b[M_SIZE_B][*];
    bit signed        [15:0] mat[M_SIZE_Z][*];
    bit                      ovf[NCOLS_A][*];

    static int idx = 0;
    
    function void post_randomize();
    begin
        for(int i = 0; i < M_SIZE_A; i++) begin
            mat_a[i][idx] = mat_a_in[i];
        end
        for(int i = 0; i < M_SIZE_B; i++) begin
            mat_b[i][idx] = mat_b_in[i];
        end
        for(int i = 0; i < NCOLS_A; i++) begin
            mat[i][idx] = 0;
            for(int j = 0; j < NCOLS_A; j++) begin
                int_a = mat_a[j+i*NCOLS_A][idx] * mat_b[j][idx];
                int_b = mat[i][idx] + int_a;
                ovf[i][idx] = ((mat[i][idx] > 0 && int_a > 0 && int_b < 0) ||
                               (mat[i][idx] < 0 && int_a < 0 && int_b > 0));
                mat[i][idx] = int_b;
            end
        end
        idx++;
    end
    endfunction
endclass

module tb_part1_mvm();

    localparam M_SIZE_A = NROWS_A * NCOLS_A;
    localparam M_SIZE_B = NROWS_B * NCOLS_B;
    localparam M_SIZE_Z = NROWS_A * NCOLS_B;

    logic               clk; 
    logic               reset;
    logic               s_valid;
    logic               m_ready;
    logic signed [7:0]  data_in;
    logic signed [15:0] data_out;
    logic               m_valid;
    logic               s_ready;
    logic               overflow;

    int idr;
    int idx;
    int j;
    int num_trans = 4000;
    
    mvm3_part1 #(
        .NROWS_A ( NROWS_A ),
        .NCOLS_A ( NCOLS_A ),
        .NROWS_B ( NROWS_B ),
        .NCOLS_B ( NCOLS_B )) 
    dut(.*);

    initial clk = 0;
    always #5 clk = ~clk;

    mat_mult_model matm_m = new();

    initial begin

        // Before first clock edge, initialize
        reset   = 1;
        s_valid = 0;
        m_ready = 0;
        data_in = 0;

        if (reset) begin
           @(posedge clk);
           #1;
           $display("Reseting DUT!");
           reset = 0; 
        end

        for (int i = 0; i < num_trans; i++) begin
            if(overflow) $display("Overflow Dectected By DUT!");
            matm_m.randomize();
            data_in = matm_m.mat_a_in[0];
            for (j = 0; j < M_SIZE_A; ) begin
                @(posedge clk);
                #1;
                j = (s_valid && s_ready) ? j+1 : j;
                data_in = matm_m.mat_a_in[j];
                std::randomize(s_valid, m_ready);
            end
            j = 0;
            data_in = matm_m.mat_b_in[j];
            for (j = 0; j < M_SIZE_B; ) begin
                @(posedge clk);
                #1;
                j = (s_valid && s_ready) ? j+1 : j;
                data_in = matm_m.mat_b_in[j];
                std::randomize(s_valid, m_ready);
            end
        end

        s_valid = 0;
        m_ready = 1;

        wait(idx == num_trans);

        #10 $display("!!!Verification PASSED!!!");

        #10 $finish();

    end // initial begin

    always @(posedge clk) begin
        if(m_valid && m_ready && !reset) begin

            if(idr == 0) begin
                $display("------Transaction Data Start--------");
                $display("Matrix A:");
                for(int i = 0; i < M_SIZE_A; i++) begin
                    $write("%d ", matm_m.mat_a[i][idx]);
                    if((i+1) % NCOLS_A == 0) $write("\n");
                end
                $display("Matrix B:");
                for(int i = 0; i < M_SIZE_B; i++) begin
                    $write("%d ", matm_m.mat_b[i][idx]);
                end
                $write("\n");
                $display("Matrix Z:");
                for(int i = 0; i < NCOLS_A; i++) begin
                    $write("%d ", matm_m.mat[i][idx]);
                end
                $write("\n");
                $display("------Transaction Data End----------");
            end
            
            if(data_out == matm_m.mat[idr][idx])
                $display("PASSED - IDX: %d, IDR: %d, Output: %d, Exp Output: %d", idx, idr, data_out, matm_m.mat[idr][idx]);
            else begin
                $display("FAILED - IDX: %d, IDR: %d, Output: %d, Exp Output: %d", idx, idr, data_out, matm_m.mat[idr][idx]);
                $display("!!!Verification FAILED!!!");
                $finish();
            end
            idx = (idr == NCOLS_A-1) ? idx+1 : idx;
            idr = (idr == NCOLS_A-1) ? 0 : idr+1;
        end
    end

endmodule // tb_part2_mac
