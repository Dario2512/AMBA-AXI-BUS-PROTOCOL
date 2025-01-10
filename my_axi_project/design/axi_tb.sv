module axi_tb;

  // Declare signals
  reg clk;
  reg reset;
  reg [31:0] addr;
  reg [31:0] wr_data;
  wire [31:0] rd_data;
  reg [3:0] axi_arvalid;
  reg [3:0] axi_awvalid;
  reg [3:0] axi_wvalid;
  wire [3:0] axi_rvalid;
  wire [3:0] axi_bvalid;
  reg [3:0] axi_rready;
  reg [3:0] axi_bready;
  
  // Instantiate master, slave, and interconnect
  axi_master master1 (
    .clk(clk), 
    .reset(reset), 
    .addr(addr), 
    .wr_data(wr_data), 
    .axi_arvalid(axi_arvalid), 
    .axi_awvalid(axi_awvalid), 
    .axi_wvalid(axi_wvalid), 
    .axi_rready(axi_rready), 
    .axi_bready(axi_bready)
  );

  axi_slave slave1 (
    .clk(clk), 
    .reset(reset), 
    .addr(addr), 
    .wr_data(wr_data), 
    .rd_data(rd_data), 
    .axi_arvalid(axi_arvalid), 
    .axi_awvalid(axi_awvalid), 
    .axi_wvalid(axi_wvalid), 
    .axi_rvalid(axi_rvalid), 
    .axi_bvalid(axi_bvalid)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Reset logic
  initial begin
    clk = 0;
    reset = 1;
    #10 reset = 0;
  end

  // Test sequence
  initial begin
    // Test 1: Single Read Transaction
    addr = 32'h0000_0000;
    wr_data = 32'hA5A5_A5A5;
    axi_arvalid = 4'b0001;
    axi_awvalid = 4'b0000;
    axi_wvalid = 4'b0000;
    #10;
    axi_arvalid = 4'b0000;
    #10; // Wait for response
    
    // Test 2: Burst Write Transaction
    addr = 32'h1000_0000;
    wr_data = 32'h1234_5678;
    axi_awvalid = 4'b0001;
    axi_wvalid = 4'b0001;
    #20;
    axi_awvalid = 4'b0000;
    axi_wvalid = 4'b0000;
    #10;
    
    // Test 3: Out-of-Order Transactions
    addr = 32'h2000_0000;
    wr_data = 32'hDEAD_BEEF;
    axi_awvalid = 4'b0001;
    axi_wvalid = 4'b0001;
    #10;
    addr = 32'h3000_0000;
    wr_data = 32'hBEEF_DEAD;
    axi_awvalid = 4'b0001;
    axi_wvalid = 4'b0001;
    #10;
    axi_awvalid = 4'b0000;
    axi_wvalid = 4'b0000;
    #10;

    // Test 4: Error Handling (e.g., invalid address)
    addr = 32'hFF00_FFFF;
    wr_data = 32'h9999_9999;
    axi_awvalid = 4'b0001;
    axi_wvalid = 4'b0001;
    #10;
    axi_awvalid = 4'b0000;
    axi_wvalid = 4'b0000;
    #10;
    
  end
endmodule
