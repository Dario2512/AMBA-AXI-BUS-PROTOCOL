module axi_slave(
  input clk,
  input reset,
  input [31:0] addr,
  input [31:0] wr_data,
  output reg [31:0] rd_data,
  input [3:0] axi_arvalid,
  input [3:0] axi_awvalid,
  input [3:0] axi_wvalid,
  output reg [3:0] axi_rvalid,
  output reg [3:0] axi_bvalid
);
  reg [31:0] memory [0:255]; // Memory simulation for slave
  reg [31:0] rd_data_buffer;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      rd_data <= 0;
      axi_rvalid <= 0;
      axi_bvalid <= 0;
    end else begin
      // Handle read
      if (axi_arvalid) begin
        rd_data <= memory[addr[7:0]]; // Read from memory
        axi_rvalid <= 4'b0001; // Assert read valid
      end
      // Handle write
      if (axi_awvalid && axi_wvalid) begin
        memory[addr[7:0]] <= wr_data; // Write to memory
        axi_bvalid <= 4'b0001; // Assert write valid
      end
    end
  end
endmodule
