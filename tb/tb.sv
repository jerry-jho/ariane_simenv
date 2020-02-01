

module tb;
    
    reg clk = 1'b0;
    initial forever #5 clk = ~clk; //100MHz
    
    reg rst_n = 1'b0;
    initial #112 rst_n = 1'b1;
    
    initial begin
        $display("===== SIM =====");
        `ifdef _FSDB
            $fsdbDumpfile("top.fsdb");
            $fsdbDumpvars(0,tb);
		`endif
        
        repeat(10000) @(posedge clk);
		$finish;
    end
    string m64_file;
    initial begin
        if ($value$plusargs("MEM_IN=%s", m64_file)) begin
            $display("-- Reading %s",m64_file);
            $readmemh(m64_file,mem.mem);
        end
    end
    
    always @(negedge clk) begin
        if (mem.mem_wr_en && mem.write_addr_valid == 'b0) begin
            $display("-- Exit code %016X",axi_wdata);
            repeat(20) @(posedge clk);
            $finish;
        end
    end
    
    localparam AXI_DATA_WIDTH = 64;
    localparam AXI_ADDR_WIDTH = 64;
    localparam AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8);
    localparam AXI_ID_WIDTH   = ariane_soc::IdWidth;
    
    wire   [AXI_ID_WIDTH-1:0]   axi_awid;
    wire   [AXI_ADDR_WIDTH-1:0] axi_awaddr;
    wire   [7:0]                axi_awlen;
    wire   [2:0]                axi_awsize;
    wire   [1:0]                axi_awburst;
    wire                        axi_awlock;
    wire   [3:0]                axi_awcache;
    wire   [2:0]                axi_awprot;
    wire                        axi_awvalid;
    wire                        axi_awready;
    wire   [AXI_DATA_WIDTH-1:0] axi_wdata;
    wire   [AXI_STRB_WIDTH-1:0] axi_wstrb;
    wire                        axi_wlast;
    wire                        axi_wvalid;
    wire                        axi_wready;
    wire   [AXI_ID_WIDTH-1:0]   axi_bid;
    wire   [1:0]                axi_bresp;
    wire                        axi_bvalid;
    wire                        axi_bready;
    wire   [AXI_ID_WIDTH-1:0]   axi_arid;
    wire   [AXI_ADDR_WIDTH-1:0] axi_araddr;
    wire   [7:0]                axi_arlen;
    wire   [2:0]                axi_arsize;
    wire   [1:0]                axi_arburst;
    wire                        axi_arlock;
    wire   [3:0]                axi_arcache;
    wire   [2:0]                axi_arprot;
    wire                        axi_arvalid;
    wire                        axi_arready;
    wire   [AXI_ID_WIDTH-1:0]   axi_rid;
    wire   [AXI_DATA_WIDTH-1:0] axi_rdata;
    wire   [1:0]                axi_rresp;
    wire                        axi_rlast;
    wire                        axi_rvalid;
    wire                        axi_rready;
    
    localparam BOOT_ADDR = 64'h100A0;
    
    ariane_single_core (
        .clk(clk),
        .rst_n(rst_n),

        .boot_addr(BOOT_ADDR),
        .hart_id(64'b0),

        .mirq(1'b0),
        .sirq(1'b0),
        .tirq(1'b0),
        .debug_req(1'b0),
    
        .m_axi_awid(axi_awid),
        .m_axi_awaddr(axi_awaddr),
        .m_axi_awlen(axi_awlen),
        .m_axi_awsize(axi_awsize),
        .m_axi_awburst(axi_awburst),
        .m_axi_awlock(axi_awlock),
        .m_axi_awcache(axi_awcache),
        .m_axi_awprot(axi_awprot),
        .m_axi_awvalid(axi_awvalid),
        .m_axi_awready(axi_awready),
        .m_axi_wdata(axi_wdata),
        .m_axi_wstrb(axi_wstrb),
        .m_axi_wlast(axi_wlast),
        .m_axi_wvalid(axi_wvalid),
        .m_axi_wready(axi_wready),
        .m_axi_bid(axi_bid),
        .m_axi_bresp(axi_bresp),
        .m_axi_bvalid(axi_bvalid),
        .m_axi_bready(axi_bready),
        .m_axi_arid(axi_arid),
        .m_axi_araddr(axi_araddr),
        .m_axi_arlen(axi_arlen),
        .m_axi_arsize(axi_arsize),
        .m_axi_arburst(axi_arburst),
        .m_axi_arlock(axi_arlock),
        .m_axi_arcache(axi_arcache),
        .m_axi_arprot(axi_arprot),
        .m_axi_arvalid(axi_arvalid),
        .m_axi_arready(axi_arready),
        .m_axi_rid(axi_rid),
        .m_axi_rdata(axi_rdata),
        .m_axi_rresp(axi_rresp),
        .m_axi_rlast(axi_rlast),
        .m_axi_rvalid(axi_rvalid),
        .m_axi_rready(axi_rready)
    );    
    
    axi_ram #(
        .DATA_WIDTH(AXI_DATA_WIDTH),
        .ADDR_WIDTH(AXI_ADDR_WIDTH),
        .ID_WIDTH(AXI_ID_WIDTH),
        .MEM_ADDR_WIDTH(18) //128KB
    ) mem (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi_awid(axi_awid),
        .s_axi_awaddr(axi_awaddr),
        .s_axi_awlen(axi_awlen),
        .s_axi_awsize(axi_awsize),
        .s_axi_awburst(axi_awburst),
        .s_axi_awlock(axi_awlock),
        .s_axi_awcache(axi_awcache),
        .s_axi_awprot(axi_awprot),
        .s_axi_awvalid(axi_awvalid),
        .s_axi_awready(axi_awready),
        .s_axi_wdata(axi_wdata),
        .s_axi_wstrb(axi_wstrb),
        .s_axi_wlast(axi_wlast),
        .s_axi_wvalid(axi_wvalid),
        .s_axi_wready(axi_wready),
        .s_axi_bid(axi_bid),
        .s_axi_bresp(axi_bresp),
        .s_axi_bvalid(axi_bvalid),
        .s_axi_bready(axi_bready),
        .s_axi_arid(axi_arid),
        .s_axi_araddr(axi_araddr),
        .s_axi_arlen(axi_arlen),
        .s_axi_arsize(axi_arsize),
        .s_axi_arburst(axi_arburst),
        .s_axi_arlock(axi_arlock),
        .s_axi_arcache(axi_arcache),
        .s_axi_arprot(axi_arprot),
        .s_axi_arvalid(axi_arvalid),
        .s_axi_arready(axi_arready),
        .s_axi_rid(axi_rid),
        .s_axi_rdata(axi_rdata),
        .s_axi_rresp(axi_rresp),
        .s_axi_rlast(axi_rlast),
        .s_axi_rvalid(axi_rvalid),
        .s_axi_rready(axi_rready)
    );        


endmodule