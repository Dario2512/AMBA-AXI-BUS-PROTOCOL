module axi_interconnect(
    input clk,
    input reset,
    
    // Master Interface
    input [31:0] axi_araddr,  // Read address
    input [31:0] axi_awaddr,  // Write address
    input [31:0] axi_wdata,   // Write data
    input axi_arvalid,
    input axi_awvalid,
    input axi_wvalid,
    
    output reg axi_arready,
    output reg axi_awready,
    output reg axi_wready,
    
    output reg [31:0] axi_rdata,
    output reg axi_rvalid,
    output reg axi_bvalid,
    
    // Slave 1 Interface
    output reg [31:0] s1_araddr,
    output reg [31:0] s1_awaddr,
    output reg [31:0] s1_wdata,
    output reg s1_arvalid,
    output reg s1_awvalid,
    output reg s1_wvalid,
    
    input s1_arready,
    input s1_awready,
    input s1_wready,
    
    input [31:0] s1_rdata,
    input s1_rvalid,
    input s1_bvalid,
    
    // Slave 2 Interface
    output reg [31:0] s2_araddr,
    output reg [31:0] s2_awaddr,
    output reg [31:0] s2_wdata,
    output reg s2_arvalid,
    output reg s2_awvalid,
    output reg s2_wvalid,
    
    input s2_arready,
    input s2_awready,
    input s2_wready,
    
    input [31:0] s2_rdata,
    input s2_rvalid,
    input s2_bvalid
);

    // Address Decoding: Define address ranges for each slave
    localparam S1_BASE_ADDR = 32'h0000_0000;
    localparam S2_BASE_ADDR = 32'h1000_0000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            axi_arready <= 0;
            axi_awready <= 0;
            axi_wready <= 0;
            axi_rvalid <= 0;
            axi_bvalid <= 0;
            axi_rdata <= 32'b0;
            
            s1_arvalid <= 0;
            s1_awvalid <= 0;
            s1_wvalid <= 0;
            
            s2_arvalid <= 0;
            s2_awvalid <= 0;
            s2_wvalid <= 0;
        end else begin
            // Address decoding for READ transactions
            if (axi_arvalid) begin
                if (axi_araddr >= S1_BASE_ADDR && axi_araddr < S2_BASE_ADDR) begin
                    s1_arvalid <= 1;
                    s1_araddr <= axi_araddr;
                end else if (axi_araddr >= S2_BASE_ADDR) begin
                    s2_arvalid <= 1;
                    s2_araddr <= axi_araddr;
                end
            end

            // Address decoding for WRITE transactions
            if (axi_awvalid) begin
                if (axi_awaddr >= S1_BASE_ADDR && axi_awaddr < S2_BASE_ADDR) begin
                    s1_awvalid <= 1;
                    s1_awaddr <= axi_awaddr;
                    s1_wvalid <= axi_wvalid;
                    s1_wdata <= axi_wdata;
                end else if (axi_awaddr >= S2_BASE_ADDR) begin
                    s2_awvalid <= 1;
                    s2_awaddr <= axi_awaddr;
                    s2_wvalid <= axi_wvalid;
                    s2_wdata <= axi_wdata;
                end
            end

            // Pass responses from slaves back to master
            axi_rvalid <= s1_rvalid | s2_rvalid;
            axi_rdata <= s1_rvalid ? s1_rdata : s2_rdata;
            axi_bvalid <= s1_bvalid | s2_bvalid;
        end
    end

endmodule
