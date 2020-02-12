

module tb;
    
    reg clk = 1'b0;
    initial forever #5ns clk = ~clk; //100MHz
    
    reg rst_n = 1'b1;
    initial begin
        #112ns rst_n = 1'b0;
        #112ns rst_n = 1'b1;
    end
  
    string fsdb_name = "top.fsdb";
    
    initial begin
        $value$plusargs("FSDB_NAME=%s", fsdb_name);
                  
        $display("===== SIM =====");
        `ifdef _FSDB
            $fsdbDumpfile(fsdb_name);
            $fsdbDumpvars(0,tb);
		`endif
        
        repeat(10000) @(posedge clk);
		$finish;
    end
    string im64_file;
    string xm64_file;
    
    logic [63:0] BOOT_ADDR = 'h1000;
    
    logic check_a0 = 0;
    logic [63:0] expect_a0_data;
    logic [63:0] fetch_a0_data;
    
    initial begin
        if ($value$plusargs("MEM_IN=%s", im64_file)) begin
            $display("-- Reading imem = %s",im64_file);
            $readmemh(im64_file,imem.mem);
        end
        if ($value$plusargs("MEM_XN=%s", xm64_file)) begin
            $display("-- Reading xmem = %s",xm64_file);
            $readmemh(xm64_file,xmem.mem);
        end    
        if ($value$plusargs("BOOT_ADDR=%x", BOOT_ADDR)) begin
            
        end
        $display("-- BOOT_ADDR = %016X",BOOT_ADDR);
        if ($value$plusargs("CHECK_A0=%x", expect_a0_data)) begin
            check_a0 = 1'b1;
        end        
    end
    `ifndef NETLIST
    always @(posedge i_ariane_single_core.i_ariane.id_stage_i.decoder_i.ecall) begin
        fetch_a0_data = i_ariane_single_core.i_ariane.instr_tracer_i.gp_reg_file[10];
        $display("-- Exit code %016X",fetch_a0_data);
        if (check_a0) begin
            $display("--------------------------------------");
            if (expect_a0_data === fetch_a0_data)
            $display("                 PASS");    
            else
            $display("        FAIL: Expect: %016X, Get: %016X",expect_a0_data,fetch_a0_data); 
            $display("--------------------------------------");
        end
        repeat(20) @(posedge clk);
        $finish;
    end
    `endif
    localparam AXI_DATA_WIDTH = 64;
    localparam AXI_ADDR_WIDTH = 64;
    localparam AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8);
    localparam AXI_ID_WIDTH   = ariane_soc::IdWidth;
    
    wire   [AXI_ID_WIDTH-1:0]   i_axi_awid;
    wire   [AXI_ADDR_WIDTH-1:0] i_axi_awaddr;
    wire   [7:0]                i_axi_awlen;
    wire   [2:0]                i_axi_awsize;
    wire   [1:0]                i_axi_awburst;
    wire                        i_axi_awlock;
    wire   [3:0]                i_axi_awcache;
    wire   [2:0]                i_axi_awprot;
    wire                        i_axi_awvalid;
    wire                        i_axi_awready;
    wire   [AXI_DATA_WIDTH-1:0] i_axi_wdata;
    wire   [AXI_STRB_WIDTH-1:0] i_axi_wstrb;
    wire                        i_axi_wlast;
    wire                        i_axi_wvalid;
    wire                        i_axi_wready;
    wire   [AXI_ID_WIDTH-1:0]   i_axi_bid;
    wire   [1:0]                i_axi_bresp;
    wire                        i_axi_bvalid;
    wire                        i_axi_bready;
    wire   [AXI_ID_WIDTH-1:0]   i_axi_arid;
    wire   [AXI_ADDR_WIDTH-1:0] i_axi_araddr;
    wire   [7:0]                i_axi_arlen;
    wire   [2:0]                i_axi_arsize;
    wire   [1:0]                i_axi_arburst;
    wire                        i_axi_arlock;
    wire   [3:0]                i_axi_arcache;
    wire   [2:0]                i_axi_arprot;
    wire                        i_axi_arvalid;
    wire                        i_axi_arready;
    wire   [AXI_ID_WIDTH-1:0]   i_axi_rid;
    wire   [AXI_DATA_WIDTH-1:0] i_axi_rdata;
    wire   [1:0]                i_axi_rresp;
    wire                        i_axi_rlast;
    wire                        i_axi_rvalid;
    wire                        i_axi_rready;
    
    wire   [AXI_ID_WIDTH-1:0]   x_axi_awid;
    wire   [AXI_ADDR_WIDTH-1:0] x_axi_awaddr;
    wire   [7:0]                x_axi_awlen;
    wire   [2:0]                x_axi_awsize;
    wire   [1:0]                x_axi_awburst;
    wire                        x_axi_awlock;
    wire   [3:0]                x_axi_awcache;
    wire   [2:0]                x_axi_awprot;
    wire                        x_axi_awvalid;
    wire                        x_axi_awready;
    wire   [AXI_DATA_WIDTH-1:0] x_axi_wdata;
    wire   [AXI_STRB_WIDTH-1:0] x_axi_wstrb;
    wire                        x_axi_wlast;
    wire                        x_axi_wvalid;
    wire                        x_axi_wready;
    wire   [AXI_ID_WIDTH-1:0]   x_axi_bid;
    wire   [1:0]                x_axi_bresp;
    wire                        x_axi_bvalid;
    wire                        x_axi_bready;
    wire   [AXI_ID_WIDTH-1:0]   x_axi_arid;
    wire   [AXI_ADDR_WIDTH-1:0] x_axi_araddr;
    wire   [7:0]                x_axi_arlen;
    wire   [2:0]                x_axi_arsize;
    wire   [1:0]                x_axi_arburst;
    wire                        x_axi_arlock;
    wire   [3:0]                x_axi_arcache;
    wire   [2:0]                x_axi_arprot;
    wire                        x_axi_arvalid;
    wire                        x_axi_arready;
    wire   [AXI_ID_WIDTH-1:0]   x_axi_rid;
    wire   [AXI_DATA_WIDTH-1:0] x_axi_rdata;
    wire   [1:0]                x_axi_rresp;
    wire                        x_axi_rlast;
    wire                        x_axi_rvalid;
    wire                        x_axi_rready;    
    
    
    
    ariane_single_core i_ariane_single_core (
        .clk(clk),
        .rst_n(rst_n),

        .boot_addr(BOOT_ADDR),
        .hart_id(64'b0),

        .tx(),
        .rx(1'b1),
        
        .gpio_io_i(32'hdeadbeef),
        .gpio_io_o(),
        .gpio_io_t(),  
        
        .test_en(1'b0),
        .jtag_TCK(1'b0),
        .jtag_TMS(1'b0),
        .jtag_TDI(1'b0),
        .jtag_TRSTn(1'b1),
        .jtag_TDO_data(),
        .jtag_TDO_driven(),
    
        .mi_axi_awid(i_axi_awid),
        .mi_axi_awaddr(i_axi_awaddr),
        .mi_axi_awlen(i_axi_awlen),
        .mi_axi_awsize(i_axi_awsize),
        .mi_axi_awburst(i_axi_awburst),
        .mi_axi_awlock(i_axi_awlock),
        .mi_axi_awcache(i_axi_awcache),
        .mi_axi_awprot(i_axi_awprot),
        .mi_axi_awvalid(i_axi_awvalid),
        .mi_axi_awready(i_axi_awready),
        .mi_axi_wdata(i_axi_wdata),
        .mi_axi_wstrb(i_axi_wstrb),
        .mi_axi_wlast(i_axi_wlast),
        .mi_axi_wvalid(i_axi_wvalid),
        .mi_axi_wready(i_axi_wready),
        .mi_axi_bid(i_axi_bid),
        .mi_axi_bresp(i_axi_bresp),
        .mi_axi_bvalid(i_axi_bvalid),
        .mi_axi_bready(i_axi_bready),
        .mi_axi_arid(i_axi_arid),
        .mi_axi_araddr(i_axi_araddr),
        .mi_axi_arlen(i_axi_arlen),
        .mi_axi_arsize(i_axi_arsize),
        .mi_axi_arburst(i_axi_arburst),
        .mi_axi_arlock(i_axi_arlock),
        .mi_axi_arcache(i_axi_arcache),
        .mi_axi_arprot(i_axi_arprot),
        .mi_axi_arvalid(i_axi_arvalid),
        .mi_axi_arready(i_axi_arready),
        .mi_axi_rid(i_axi_rid),
        .mi_axi_rdata(i_axi_rdata),
        .mi_axi_rresp(i_axi_rresp),
        .mi_axi_rlast(i_axi_rlast),
        .mi_axi_rvalid(i_axi_rvalid),
        .mi_axi_rready(i_axi_rready),
        
        .mx_axi_awid(x_axi_awid),
        .mx_axi_awaddr(x_axi_awaddr),
        .mx_axi_awlen(x_axi_awlen),
        .mx_axi_awsize(x_axi_awsize),
        .mx_axi_awburst(x_axi_awburst),
        .mx_axi_awlock(x_axi_awlock),
        .mx_axi_awcache(x_axi_awcache),
        .mx_axi_awprot(x_axi_awprot),
        .mx_axi_awvalid(x_axi_awvalid),
        .mx_axi_awready(x_axi_awready),
        .mx_axi_wdata(x_axi_wdata),
        .mx_axi_wstrb(x_axi_wstrb),
        .mx_axi_wlast(x_axi_wlast),
        .mx_axi_wvalid(x_axi_wvalid),
        .mx_axi_wready(x_axi_wready),
        .mx_axi_bid(x_axi_bid),
        .mx_axi_bresp(x_axi_bresp),
        .mx_axi_bvalid(x_axi_bvalid),
        .mx_axi_bready(x_axi_bready),
        .mx_axi_arid(x_axi_arid),
        .mx_axi_araddr(x_axi_araddr),
        .mx_axi_arlen(x_axi_arlen),
        .mx_axi_arsize(x_axi_arsize),
        .mx_axi_arburst(x_axi_arburst),
        .mx_axi_arlock(x_axi_arlock),
        .mx_axi_arcache(x_axi_arcache),
        .mx_axi_arprot(x_axi_arprot),
        .mx_axi_arvalid(x_axi_arvalid),
        .mx_axi_arready(x_axi_arready),
        .mx_axi_rid(x_axi_rid),
        .mx_axi_rdata(x_axi_rdata),
        .mx_axi_rresp(x_axi_rresp),
        .mx_axi_rlast(x_axi_rlast),
        .mx_axi_rvalid(x_axi_rvalid),
        .mx_axi_rready(x_axi_rready)        
    );    
    
    axi_ram #(
        .DATA_WIDTH(AXI_DATA_WIDTH),
        .ADDR_WIDTH(AXI_ADDR_WIDTH),
        .ID_WIDTH(AXI_ID_WIDTH),
        .MEM_ADDR_WIDTH(18) //128KB
    ) imem (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi_awid(i_axi_awid),
        .s_axi_awaddr(i_axi_awaddr),
        .s_axi_awlen(i_axi_awlen),
        .s_axi_awsize(i_axi_awsize),
        .s_axi_awburst(i_axi_awburst),
        .s_axi_awlock(i_axi_awlock),
        .s_axi_awcache(i_axi_awcache),
        .s_axi_awprot(i_axi_awprot),
        .s_axi_awvalid(i_axi_awvalid),
        .s_axi_awready(i_axi_awready),
        .s_axi_wdata(i_axi_wdata),
        .s_axi_wstrb(i_axi_wstrb),
        .s_axi_wlast(i_axi_wlast),
        .s_axi_wvalid(i_axi_wvalid),
        .s_axi_wready(i_axi_wready),
        .s_axi_bid(i_axi_bid),
        .s_axi_bresp(i_axi_bresp),
        .s_axi_bvalid(i_axi_bvalid),
        .s_axi_bready(i_axi_bready),
        .s_axi_arid(i_axi_arid),
        .s_axi_araddr(i_axi_araddr),
        .s_axi_arlen(i_axi_arlen),
        .s_axi_arsize(i_axi_arsize),
        .s_axi_arburst(i_axi_arburst),
        .s_axi_arlock(i_axi_arlock),
        .s_axi_arcache(i_axi_arcache),
        .s_axi_arprot(i_axi_arprot),
        .s_axi_arvalid(i_axi_arvalid),
        .s_axi_arready(i_axi_arready),
        .s_axi_rid(i_axi_rid),
        .s_axi_rdata(i_axi_rdata),
        .s_axi_rresp(i_axi_rresp),
        .s_axi_rlast(i_axi_rlast),
        .s_axi_rvalid(i_axi_rvalid),
        .s_axi_rready(i_axi_rready)
    );        

    axi_ram #(
        .DATA_WIDTH(AXI_DATA_WIDTH),
        .ADDR_WIDTH(AXI_ADDR_WIDTH),
        .ID_WIDTH(AXI_ID_WIDTH),
        .MEM_ADDR_WIDTH(18) //128KB
    ) xmem (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi_awid(x_axi_awid),
        .s_axi_awaddr(x_axi_awaddr),
        .s_axi_awlen(x_axi_awlen),
        .s_axi_awsize(x_axi_awsize),
        .s_axi_awburst(x_axi_awburst),
        .s_axi_awlock(x_axi_awlock),
        .s_axi_awcache(x_axi_awcache),
        .s_axi_awprot(x_axi_awprot),
        .s_axi_awvalid(x_axi_awvalid),
        .s_axi_awready(x_axi_awready),
        .s_axi_wdata(x_axi_wdata),
        .s_axi_wstrb(x_axi_wstrb),
        .s_axi_wlast(x_axi_wlast),
        .s_axi_wvalid(x_axi_wvalid),
        .s_axi_wready(x_axi_wready),
        .s_axi_bid(x_axi_bid),
        .s_axi_bresp(x_axi_bresp),
        .s_axi_bvalid(x_axi_bvalid),
        .s_axi_bready(x_axi_bready),
        .s_axi_arid(x_axi_arid),
        .s_axi_araddr(x_axi_araddr),
        .s_axi_arlen(x_axi_arlen),
        .s_axi_arsize(x_axi_arsize),
        .s_axi_arburst(x_axi_arburst),
        .s_axi_arlock(x_axi_arlock),
        .s_axi_arcache(x_axi_arcache),
        .s_axi_arprot(x_axi_arprot),
        .s_axi_arvalid(x_axi_arvalid),
        .s_axi_arready(x_axi_arready),
        .s_axi_rid(x_axi_rid),
        .s_axi_rdata(x_axi_rdata),
        .s_axi_rresp(x_axi_rresp),
        .s_axi_rlast(x_axi_rlast),
        .s_axi_rvalid(x_axi_rvalid),
        .s_axi_rready(x_axi_rready)
    );
endmodule