//TODO:
class mac_model;
    rand bit signed [ 7:0] a;
    rand bit signed [ 7:0] b;
    rand bit               valid;
    bit signed      [ 7:0] x[*];
    bit signed      [ 7:0] y[*];
    bit signed      [15:0] f[*];
    bit                    overflow;
    logic signed    [15:0] f_int;
    logic signed    [15:0] g_int;

    static int      idx = 0;
    
    constraint a_con {a >= 8'h00; a <= 8'hff;}
    constraint b_con {b >= 8'h00; b <= 8'hff;}
    constraint valid_con {valid dist{0:/1, 1:/1};}

    function void post_randomize();
    begin
        if (idx == 0) begin
            f_int    = 0;
            overflow = 0;
        end
        else begin
            g_int    = (a * b);
            f_int    = g_int + f[idx-1]; 
            overflow = ((f[idx-1] > 0 && g_int > 0 && f_int < 0) ||
                        (f[idx-1] < 0 && g_int < 0 && f_int > 0));
            //if (valid) $display("a: %d, b: %d, Gint: %d, F_prev: %d, Fint: %d",a, b, g_int, f[idx-1], f_int);
        end

        if (valid) begin
            if (overflow) begin
                $display("Overflow Injected - idx: %d, a: %d, b: %d, f_prev: %d", idx, a, b, f[idx-1]);
                f[idx] = f[idx-1] + (a * b);
                x[idx] = a;
                y[idx] = b;
                x[idx+1] = a;
                y[idx+1] = b;
                x[idx+2] = a;
                y[idx+2] = b;
                x[idx+3] = a;
                y[idx+3] = b;
                idx = 0;
            end
            else if (idx == 0) begin
                x[idx] = a;
                y[idx] = b;
                f[idx] = (a * b); 
                idx++;
            end
            else begin
                x[idx] = a;
                y[idx] = b;
                f[idx] = f[idx-1] + (a * b);
                idx++;
            end
        end
    end
    endfunction
endclass

module tb_part3_mac();

   logic clk, reset, valid_in, valid_out, overflow;
   logic signed [7:0] a, b;
   logic signed [15:0] f;
   int idx = 0;
   int idy = 0;

   part3_mac dut(.*);

   initial clk = 0;
   always #5 clk = ~clk;

   mac_model mac_m = new();

   initial begin

      // Before first clock edge, initialize
      reset = 1;
      {a, b} = {8'b0,8'b0};
      valid_in = 0;

      for (int i = 0; i < 2000; i++) begin
          @(posedge clk);
          #1;
          if (reset) begin
             $display("Reseting DUT!");
             reset = 0; 
             a = 1; 
             b = 1; 
             valid_in = 0;
             idy = 0;
          end
          if (overflow) begin
             $display("Overflow Dectected By DUT!");
             reset = 1;
             {a, b} = {8'b0, 8'b0};
             valid_in = 0;
             mac_m.idx = 0;
          end
          else begin
             mac_m.randomize();
             valid_in = mac_m.valid;
             a   = (valid_in) ? mac_m.x[idy] : mac_m.a;
             b   = (valid_in) ? mac_m.y[idy] : mac_m.b;
             idy = (valid_in) ? idy+1 : idy;
          end
      end

      @(posedge clk);
      #1;
      valid_in = 1'b0;

      #100 $display("!!!Verification PASSED!!!");

      #100 $finish();

   end // initial begin

   always @(posedge clk) begin
       if(valid_out && !reset) begin
           if(f == mac_m.f[idx])
               $display("Validation PASSED - idx: %d, a: %d, b: %d, f: %d, f_exp: %d", idx,mac_m.x[idx], mac_m.y[idx], f, mac_m.f[idx]);
           else begin
               $display("Validation FAILED - idx: %d, a: %d, b: %d, f: %d, f_exp: %d", idx, mac_m.x[idx], mac_m.y[idx], f, mac_m.f[idx]);
               $display("!!!Verification FAILED!!!");
               $finish();
           end
           idx++;
       end
       else if (reset) begin
           idx = 0;
       end
   end

endmodule // tb_part2_mac
