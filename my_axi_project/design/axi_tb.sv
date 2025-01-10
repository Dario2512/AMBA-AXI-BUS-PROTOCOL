module axi_tb;

  // Declare signals
  reg clk;
  reg reset;
  reg [31:0] addr;
  reg [31:0] wr_data;
  wire [31:0] rd_data;
  reg axi_arvalid;
  reg axi_awvalid;
  reg axi_wvalid;
  wire axi_rvalid;
  wire axi_bvalid;
  reg axi_rready;
  reg axi_bready;

  // Interconnect connections to Slaves
  wire [31:0] s1_rd_data, s2_rd_data;
  wire s1_axi_rvalid, s2_axi_rvalid;
  wire s1_axi_bvalid, s2_axi_bvalid;

  // Instantiate AXI Master
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

  // Instantiate AXI Interconnect
  axi_interconnect interconnect1 (
    .clk(clk),
    .reset(reset),
    .axi_araddr(addr),
    .axi_awaddr(addr),
    .axi_wdata(wr_data),
    .axi_arvalid(axi_arvalid),
    .axi_awvalid(axi_awvalid),
    .axi_wvalid(axi_wvalid),
    .axi_rdata(rd_data),
    .axi_rvalid(axi_rvalid),
    .axi_bvalid(axi_bvalid),

    // Slave 1 Connections
    .s1_araddr(),
    .s1_awaddr(),
    .s1_wdata(),
    .s1_arvalid(),
    .s1_awvalid(),
    .s1_wvalid(),
    .s1_rdata(s1_rd_data),
    .s1_rvalid(s1_axi_rvalid),
    .s1_bvalid(s1_axi_bvalid),

    // Slave 2 Connections
    .s2_araddr(),
    .s2_awaddr(),
    .s2_wdata(),
    .s2_arvalid(),
    .s2_awvalid(),
    .s2_wvalid(),
    .s2_rdata(s2_rd_data),
    .s2_rvalid(s2_axi_rvalid),
    .s2_bvalid(s2_axi_bvalid)
  );

  // Instantiate AXI Slave 1
  axi_slave slave1 (
    .clk(clk), 
    .reset(reset), 
    .addr(addr), 
    .wr_data(wr_data), 
    .rd_data(s1_rd_data), 
    .axi_arvalid(axi_arvalid), 
    .axi_awvalid(axi_awvalid), 
    .axi_wvalid(axi_wvalid), 
    .axi_rvalid(s1_axi_rvalid), 
    .axi_bvalid(s1_axi_bvalid)
  );

  // Instantiate AXI Slave 2
  axi_slave slave2 (
    .clk(clk), 
    .reset(reset), 
    .addr(addr), 
    .wr_data(wr_data), 
    .rd_data(s2_rd_data), 
    .axi_arvalid(axi_arvalid), 
    .axi_awvalid(axi_awvalid), 
    .axi_wvalid(axi_wvalid), 
    .axi_rvalid(s2_axi_rvalid), 
    .axi_bvalid(s2_axi_bvalid)
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
    $display("Starting AXI Testbench...");

    // Test 1: Single Read Transaction
    $display("Test 1: Single Read Transaction");
    addr = 32'h0000_0000; // Address in Slave 1 range
    wr_data = 32'hA5A5_A5A5;
    axi_arvalid = 1;
    axi_awvalid = 0;
    axi_wvalid = 0;
    #10;
    axi_arvalid = 0;
    #10;

    // Test 2: Burst Write Transaction
    $display("Test 2: Burst Write Transaction");
    addr = 32'h1000_0000; // Address in Slave 2 range
    wr_data = 32'h1234_5678;
    axi_awvalid = 1;
    axi_wvalid = 1;
    #20;
    axi_awvalid = 0;
    axi_wvalid = 0;
    #10;

    // Test 3: Out-of-Order Transactions
    $display("Test 3: Out-of-Order Transactions");
    addr = 32'h2000_0000; // Address in Slave 1 range
    wr_data = 32'hDEAD_BEEF;
    axi_awvalid = 1;
    axi_wvalid = 1;
    #10;
    addr = 32'h3000_0000; // Address in Slave 2 range
    wr_data = 32'hBEEF_DEAD;
    axi_awvalid = 1;
    axi_wvalid = 1;
    #10;
    axi_awvalid = 0;
    axi_wvalid = 0;
    #10;

    // Test 4: Error Handling (Invalid Address)
    $display("Test 4: Error Handling - Invalid Address");
    addr = 32'hFF00_FFFF; // Invalid address
    wr_data = 32'h9999_9999;
    axi_awvalid = 1;
    axi_wvalid = 1;
    #10;
    axi_awvalid = 0;
    axi_wvalid = 0;
    #10;

    $display("Testbench Completed.");
    $finish;
  end
endmodule

