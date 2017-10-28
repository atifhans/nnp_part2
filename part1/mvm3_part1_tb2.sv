// ESE-507 Project 2, Fall 2017

// This simple testbench is provided to help you in testing Project 2, Part 1.
// This testbench is not sufficient to test the full correctness of your system, it's just
// a relatively small test to help you get started.

// This testbench will test three matrix-vector multiplications. One of the outputs will
// overflow.

// The testbench will also check if your result is correct or not. If your design works
// correctly, you will see the following when you simulate:

/*
 # SUCCESS:          y[    0] =    186; overflow = 0
 # SUCCESS:          y[    1] =    152; overflow = 0
 # SUCCESS:          y[    2] =   -210; overflow = 0
 # SUCCESS:          y[    3] =   4191; overflow = 0
 # SUCCESS:          y[    4] = -17149; overflow = 1
 # SUCCESS:          y[    5] =    762; overflow = 0
 # SUCCESS:          y[    6] =   -494; overflow = 0
 # SUCCESS:          y[    7] =   1012; overflow = 0
 # SUCCESS:          y[    8] =    808; overflow = 0
 */

// If there is an error, you will see something like:
/*
 # SUCCESS:          y[    0] =    186; overflow = 0
 # SUCCESS:          y[    1] =    152; overflow = 0
 # SUCCESS:          y[    2] =   -210; overflow = 0
 # SUCCESS:          y[    3] =   4191; overflow = 0
 # ERROR:   Expected y[    4] = -17149; overflow = 1.   Instead your system produced: y[    4] = -17149; overflow = 0
 # SUCCESS:          y[    5] =    762; overflow = 0
 # SUCCESS:          y[    6] =   -494; overflow = 0
 # SUCCESS:          y[    7] =   1012; overflow = 0
 # SUCCESS:          y[    8] =    808; overflow = 0
 */

// Please let me know if you have any problems.

module check_timing();

   logic clk, s_valid, s_ready, m_valid, m_ready, reset, overflow;
   logic signed [7:0] data_in;
   logic signed [15:0] data_out;
   
   initial clk=0;
   always #5 clk = ~clk;
   

   mvm3_part1 dut (.clk(clk), .reset(reset), .s_valid(s_valid), .m_ready(m_ready), 
		   .data_in(data_in), .m_valid(m_valid), .s_ready(s_ready), .data_out(data_out),
		   .overflow(overflow));


   //////////////////////////////////////////////////////////////////////////////////////////////////
   // code to feed some test inputs

   // rb and rb2 represent random bits. Each clock cycle, we will randomize the value of these bits.
   // When rb is 0, we will not let our testbench send new data to the DUT.
   // When rb is 1, we can send data.
   logic rb, rb2;
   always begin
      @(posedge clk);
      #1;
      std::randomize(rb, rb2); // randomize rb
   end

   // Put our test data into this array. These are the values we will feed as input into the system.
   logic [7:0] invals[0:35] = '{1, -8, 3, 9, -5, 11, -7, 8, -9, 1,  -22, 3, 
				10, 11, 12, 127, 127, 127, 1,  2, 3, 127, 127, 127,
				19, 18, -17,  16,  -15,  14, 13, -12, 11, 19, -22, 27 
				};

   
   
   logic signed [15:0] expVals[0:8]  = {186, 152, -210, 4191, -17149, 762, -494, 1012, 808};
   logic 	expOverflow[0:8] = {0, 0, 0, 0, 1, 0, 0, 0, 0};
   
   logic [15:0] j;

   // If s_valid is set to 1, we will put data on data_in.
   // If s_valid is 0, we will put an X on the data_in to test that your system does not 
   // process the invalid input.
   always @* begin
      if (s_valid == 1)
         data_in = invals[j];
      else
         data_in = 'x;
   end

   // If our random bit rb is set to 1, and if j is within the range of our test vector (invals),
   // we will set s_valid to 1.
   always @* begin
      if ((j>=0) && (j<36) && (rb==1'b1)) begin
         s_valid=1;
      end
      else
         s_valid=0;
   end

   // If we set s_valid and s_ready on this clock edge, we will increment j just after
   // this clock edge.
   always @(posedge clk) begin
      if (s_valid && s_ready)
         j <= #1 j+1;
   end
   ////////////////////////////////////////////////////////////////////////////////////////
   // code to receive the output values

   // we will use another random bit (rb2) to determine if we can assert m_ready.
   logic [15:0] i;
   always @* begin
      if ((i>=0) && (i<36) && (rb2==1'b1))
         m_ready = 1;
      else
         m_ready = 0;
   end

   always @(posedge clk) begin
      if (m_ready && m_valid) begin
	 if ((data_out == expVals[i]) && (overflow == expOverflow[i]))
           $display("SUCCESS:          y[%d] = %d; overflow = %b" , i, data_out, overflow);
	 else
	   $display("ERROR:   Expected y[%d] = %d; overflow = %b.   Instead your system produced: y[%d] = %d; overflow = %b" , i, expVals[i], expOverflow[i], i, data_out, overflow);
         i=i+1; 
      end 
   end

   ////////////////////////////////////////////////////////////////////////////////

   initial begin
      j=0; i=0;

      // Before first clock edge, initialize
      m_ready = 0; 
      reset = 0;
   
      // reset
      @(posedge clk); #1; reset = 1; 
      @(posedge clk); #1; reset = 0; 

      // wait until 3 outputs have come out, then finish.
      wait(i==9);
      $finish;
   end


   // This is just here to keep the testbench from running forever in case of error.
   // In other words, if your system never produces three outputs, this code will stop 
   // the simulation after 1000 clock cycles.
   initial begin
      repeat(1000) begin
         @(posedge clk);
      end
      $display("Warning: Output not produced within 1000 clock cycles; stopping simulation so it doens't run forever");
      $stop;
   end

endmodule
