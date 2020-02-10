module ariane_single_core #(
    parameter AXI_DATA_WIDTH = 64,
    parameter AXI_ADDR_WIDTH = 64,
    parameter AXI_USER_WIDTH = 1,
    parameter AXI_STRB_WIDTH = 8,
    parameter AXI_ID_WIDTH   = 4
)(
    input  clk,
    input  rst_n,

    input  [63:0]               boot_addr,
    input  [63:0]               hart_id,

    output                      tx,
    input                       rx,
    
    input                       test_en,
    input                       jtag_TCK,
    input                       jtag_TMS,
    input                       jtag_TDI,
    input                       jtag_TRSTn,
    output                      jtag_TDO_data,
    output                      jtag_TDO_driven,
    
    output [AXI_ID_WIDTH-1:0]   mi_axi_awid,
    output [AXI_ADDR_WIDTH-1:0] mi_axi_awaddr,
    output [7:0]                mi_axi_awlen,
    output [2:0]                mi_axi_awsize,
    output [1:0]                mi_axi_awburst,
    output                      mi_axi_awlock,
    output [3:0]                mi_axi_awcache,
    output [2:0]                mi_axi_awprot,
    output                      mi_axi_awvalid,
    input                       mi_axi_awready,
    output [AXI_DATA_WIDTH-1:0] mi_axi_wdata,
    output [AXI_STRB_WIDTH-1:0] mi_axi_wstrb,
    output                      mi_axi_wlast,
    output                      mi_axi_wvalid,
    input                       mi_axi_wready,
    input  [AXI_ID_WIDTH-1:0]   mi_axi_bid,
    input  [1:0]                mi_axi_bresp,
    input                       mi_axi_bvalid,
    output                      mi_axi_bready,
    output [AXI_ID_WIDTH-1:0]   mi_axi_arid,
    output [AXI_ADDR_WIDTH-1:0] mi_axi_araddr,
    output [7:0]                mi_axi_arlen,
    output [2:0]                mi_axi_arsize,
    output [1:0]                mi_axi_arburst,
    output                      mi_axi_arlock,
    output [3:0]                mi_axi_arcache,
    output [2:0]                mi_axi_arprot,
    output                      mi_axi_arvalid,
    input                       mi_axi_arready,
    input  [AXI_ID_WIDTH-1:0]   mi_axi_rid,
    input  [AXI_DATA_WIDTH-1:0] mi_axi_rdata,
    input  [1:0]                mi_axi_rresp,
    input                       mi_axi_rlast,
    input                       mi_axi_rvalid,
    output                      mi_axi_rready,
    
    output [AXI_ID_WIDTH-1:0]   mx_axi_awid,
    output [AXI_ADDR_WIDTH-1:0] mx_axi_awaddr,
    output [7:0]                mx_axi_awlen,
    output [2:0]                mx_axi_awsize,
    output [1:0]                mx_axi_awburst,
    output                      mx_axi_awlock,
    output [3:0]                mx_axi_awcache,
    output [2:0]                mx_axi_awprot,
    output                      mx_axi_awvalid,
    input                       mx_axi_awready,
    output [AXI_DATA_WIDTH-1:0] mx_axi_wdata,
    output [AXI_STRB_WIDTH-1:0] mx_axi_wstrb,
    output                      mx_axi_wlast,
    output                      mx_axi_wvalid,
    input                       mx_axi_wready,
    input  [AXI_ID_WIDTH-1:0]   mx_axi_bid,
    input  [1:0]                mx_axi_bresp,
    input                       mx_axi_bvalid,
    output                      mx_axi_bready,
    output [AXI_ID_WIDTH-1:0]   mx_axi_arid,
    output [AXI_ADDR_WIDTH-1:0] mx_axi_araddr,
    output [7:0]                mx_axi_arlen,
    output [2:0]                mx_axi_arsize,
    output [1:0]                mx_axi_arburst,
    output                      mx_axi_arlock,
    output [3:0]                mx_axi_arcache,
    output [2:0]                mx_axi_arprot,
    output                      mx_axi_arvalid,
    input                       mx_axi_arready,
    input  [AXI_ID_WIDTH-1:0]   mx_axi_rid,
    input  [AXI_DATA_WIDTH-1:0] mx_axi_rdata,
    input  [1:0]                mx_axi_rresp,
    input                       mx_axi_rlast,
    input                       mx_axi_rvalid,
    output                      mx_axi_rready    
);


    AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH   ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH      ),
        .AXI_ID_WIDTH   ( ariane_soc::IdWidth ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH      )
    ) slave[ariane_soc::NrSlaves-1:0]();

    AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH        ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH           ),
        .AXI_ID_WIDTH   ( ariane_soc::IdWidthSlave ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH           )
    ) master[ariane_soc::NB_PERIPHERALS-1:0]();

///////////////////////// JTAG /////////////////////////
    wire ndmreset;
    wire ndmreset_n;
    
    rstgen i_rstgen_main (
        .clk_i        ( clk                  ),
        .rst_ni       ( rst_n  & (~ndmreset) ),
        .test_mode_i  ( test_en              ),
        .rst_no       ( ndmreset_n           ),
        .init_no      (                      ) // keep open
    );
  
    
    
///////////////////////// JTAG /////////////////////////
    logic                debug_req_core;
    ariane_axi::req_t    dm_axi_m_req;
    ariane_axi::resp_t   dm_axi_m_resp; 
    logic                dm_slave_req;
    logic                dm_slave_we;
    logic [AXI_ADDR_WIDTH-1:0]       dm_slave_addr;
    logic [AXI_STRB_WIDTH-1:0]       dm_slave_be;
    logic [AXI_DATA_WIDTH-1:0]       dm_slave_wdata;
    logic [AXI_DATA_WIDTH-1:0]       dm_slave_rdata;
  
    axi2mem #(
        .AXI_ID_WIDTH   ( ariane_soc::IdWidthSlave ),
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH        ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH           ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH           )
    ) i_dm_axi2mem (
        .clk_i      ( clk                       ),
        .rst_ni     ( rst_n                     ),
        .slave      ( master[ariane_soc::Debug] ),
        .req_o      ( dm_slave_req              ),
        .we_o       ( dm_slave_we               ),
        .addr_o     ( dm_slave_addr             ),
        .be_o       ( dm_slave_be               ),
        .data_o     ( dm_slave_wdata            ),
        .data_i     ( dm_slave_rdata            )
    );

    axi_master_connect i_dm_axi_master_connect (
        .axi_req_i(dm_axi_m_req),
        .axi_resp_o(dm_axi_m_resp),
        .master(slave[1])
    );
    
    dm_axi_top i_dm_axi_top (
        .clk_i                (clk                   ),
        .rst_ni               (rst_n                 ),
        .ndmreset_o           (ndmreset              ),
        .debug_req_core       (debug_req_core        ),
        .test_en              (test_en               ),
        .jtag_TCK             ( jtag_TCK             ),
        .jtag_TMS             ( jtag_TMS             ),
        .jtag_TDI             ( jtag_TDI             ),
        .jtag_TRSTn           ( jtag_TRSTn           ),
        .jtag_TDO_data        ( jtag_TDO_data        ),
        .jtag_TDO_driven      ( jtag_TDO_driven      ),

        .slave_req_i          ( dm_slave_req         ),
        .slave_we_i           ( dm_slave_we          ),
        .slave_addr_i         ( dm_slave_addr        ),
        .slave_be_i           ( dm_slave_be          ),
        .slave_wdata_i        ( dm_slave_wdata       ),
        .slave_rdata_o        ( dm_slave_rdata       ),

        .dm_axi_m_req         (dm_axi_m_req          ),
        .dm_axi_m_resp        (dm_axi_m_resp         )
    );    
      
///////////////////////// MI BUS /////////////////////////  
    ariane_axi::req_t    mi_axi_s_req;
    ariane_axi::resp_t   mi_axi_s_resp;
    
    axi_slave_connect i_mi_axi_slave_connect (
        .slave      ( master[ariane_soc::ROM] ),
        .axi_req_o  ( mi_axi_s_req            ),
        .axi_resp_i ( mi_axi_s_resp           )
    );
    
    axim2p #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_USER_WIDTH(AXI_USER_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH)
    ) i_mi_axi_m2p ( 
        
        .axi_ariane_req(mi_axi_s_req),
        .axi_ariane_resp(mi_axi_s_resp),
    
        .m_axi_awid(mi_axi_awid),
        .m_axi_awaddr(mi_axi_awaddr),
        .m_axi_awlen(mi_axi_awlen),
        .m_axi_awsize(mi_axi_awsize),
        .m_axi_awburst(mi_axi_awburst),
        .m_axi_awlock(mi_axi_awlock),
        .m_axi_awcache(mi_axi_awcache),
        .m_axi_awprot(mi_axi_awprot),
        .m_axi_awvalid(mi_axi_awvalid),
        .m_axi_awready(mi_axi_awready),
        .m_axi_wdata(mi_axi_wdata),
        .m_axi_wstrb(mi_axi_wstrb),
        .m_axi_wlast(mi_axi_wlast),
        .m_axi_wvalid(mi_axi_wvalid),
        .m_axi_wready(mi_axi_wready),
        .m_axi_bid(mi_axi_bid),
        .m_axi_bresp(mi_axi_bresp),
        .m_axi_bvalid(mi_axi_bvalid),
        .m_axi_bready(mi_axi_bready),
        .m_axi_arid(mi_axi_arid),
        .m_axi_araddr(mi_axi_araddr),
        .m_axi_arlen(mi_axi_arlen),
        .m_axi_arsize(mi_axi_arsize),
        .m_axi_arburst(mi_axi_arburst),
        .m_axi_arlock(mi_axi_arlock),
        .m_axi_arcache(mi_axi_arcache),
        .m_axi_arprot(mi_axi_arprot),
        .m_axi_arvalid(mi_axi_arvalid),
        .m_axi_arready(mi_axi_arready),
        .m_axi_rid(mi_axi_rid),
        .m_axi_rdata(mi_axi_rdata),
        .m_axi_rresp(mi_axi_rresp),
        .m_axi_rlast(mi_axi_rlast),
        .m_axi_rvalid(mi_axi_rvalid),
        .m_axi_rready(mi_axi_rready)
    );
    
    ///////////////////////// MX BUS /////////////////////////
/*    
    AXI_BUS #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH        ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH           ),
        .AXI_ID_WIDTH   ( ariane_soc::IdWidthSlave ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH           )
    ) mx_axi_atomics();

    axi_riscv_atomics_wrap #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH        ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH           ),
        .AXI_ID_WIDTH   ( ariane_soc::IdWidthSlave ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH           ),
        .AXI_MAX_WRITE_TXNS ( 1  ),
        .RISCV_WORD_WIDTH   ( 64 )
    ) i_axi_riscv_atomics (
        .clk_i(clk),
        .rst_ni ( ndmreset_n               ),
        .slv    ( master[ariane_soc::DRAM] ),
        .mst    ( mx_axi_atomics           )
    );
*/    
    ariane_axi::req_t    mx_axi_s_req;
    ariane_axi::resp_t   mx_axi_s_resp;
    
    axi_slave_connect i_mx_axi_slave_connect (
        .slave      ( master[ariane_soc::DRAM] ),
        .axi_req_o  ( mx_axi_s_req             ),
        .axi_resp_i ( mx_axi_s_resp            )
    );
    
    axim2p #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_USER_WIDTH(AXI_USER_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH)
    ) i_mx_axi_m2p ( 
        
        .axi_ariane_req(mx_axi_s_req),
        .axi_ariane_resp(mx_axi_s_resp),
    
        .m_axi_awid(mx_axi_awid),
        .m_axi_awaddr(mx_axi_awaddr),
        .m_axi_awlen(mx_axi_awlen),
        .m_axi_awsize(mx_axi_awsize),
        .m_axi_awburst(mx_axi_awburst),
        .m_axi_awlock(mx_axi_awlock),
        .m_axi_awcache(mx_axi_awcache),
        .m_axi_awprot(mx_axi_awprot),
        .m_axi_awvalid(mx_axi_awvalid),
        .m_axi_awready(mx_axi_awready),
        .m_axi_wdata(mx_axi_wdata),
        .m_axi_wstrb(mx_axi_wstrb),
        .m_axi_wlast(mx_axi_wlast),
        .m_axi_wvalid(mx_axi_wvalid),
        .m_axi_wready(mx_axi_wready),
        .m_axi_bid(mx_axi_bid),
        .m_axi_bresp(mx_axi_bresp),
        .m_axi_bvalid(mx_axi_bvalid),
        .m_axi_bready(mx_axi_bready),
        .m_axi_arid(mx_axi_arid),
        .m_axi_araddr(mx_axi_araddr),
        .m_axi_arlen(mx_axi_arlen),
        .m_axi_arsize(mx_axi_arsize),
        .m_axi_arburst(mx_axi_arburst),
        .m_axi_arlock(mx_axi_arlock),
        .m_axi_arcache(mx_axi_arcache),
        .m_axi_arprot(mx_axi_arprot),
        .m_axi_arvalid(mx_axi_arvalid),
        .m_axi_arready(mx_axi_arready),
        .m_axi_rid(mx_axi_rid),
        .m_axi_rdata(mx_axi_rdata),
        .m_axi_rresp(mx_axi_rresp),
        .m_axi_rlast(mx_axi_rlast),
        .m_axi_rvalid(mx_axi_rvalid),
        .m_axi_rready(mx_axi_rready)
    );    
    
    ///////////////////////// XBAR /////////////////////////
    
    axi_node_intf_wrap #(
        .NB_SLAVE           ( ariane_soc::NrSlaves       ),
        .NB_MASTER          ( ariane_soc::NB_PERIPHERALS ),
        .NB_REGION          ( ariane_soc::NrRegion       ),
        .AXI_ADDR_WIDTH     ( AXI_ADDR_WIDTH          ),
        .AXI_DATA_WIDTH     ( AXI_DATA_WIDTH             ),
        .AXI_USER_WIDTH     ( AXI_USER_WIDTH             ),
        .AXI_ID_WIDTH       ( ariane_soc::IdWidth        )
        // .MASTER_SLICE_DEPTH ( 0                          ),
        // .SLAVE_SLICE_DEPTH  ( 0                          )
    ) i_axi_xbar (
        .clk          ( clk        ),
        .rst_n        ( ndmreset_n ),
        .test_en_i    ( test_en    ),
        .slave        ( slave      ),
        .master       ( master     ),
        .start_addr_i ({
            ariane_soc::DebugBase,
            ariane_soc::ROMBase,
            ariane_soc::CLINTBase,
            ariane_soc::PLICBase,
            ariane_soc::UARTBase,
            ariane_soc::TimerBase,
            ariane_soc::SPIBase,
            ariane_soc::EthernetBase,
            ariane_soc::GPIOBase,
            ariane_soc::DRAMBase
        }),
        .end_addr_i   ({
            ariane_soc::DebugBase    + ariane_soc::DebugLength - 1,
            ariane_soc::ROMBase      + ariane_soc::ROMLength - 1,
            ariane_soc::CLINTBase    + ariane_soc::CLINTLength - 1,
            ariane_soc::PLICBase     + ariane_soc::PLICLength - 1,
            ariane_soc::UARTBase     + ariane_soc::UARTLength - 1,
            ariane_soc::TimerBase    + ariane_soc::TimerLength - 1,
            ariane_soc::SPIBase      + ariane_soc::SPILength - 1,
            ariane_soc::EthernetBase + ariane_soc::EthernetLength -1,
            ariane_soc::GPIOBase     + ariane_soc::GPIOLength - 1,
            ariane_soc::DRAMBase     + ariane_soc::DRAMLength - 1
        }),
        .valid_rule_i (ariane_soc::ValidRule)
    );


    ///////////////////////// CLINT & Peripherals /////////////////////////

    logic ipi;
    logic timer_irq;

    ariane_axi::req_t    axi_clint_req;
    ariane_axi::resp_t   axi_clint_resp;

    clint #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH        ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH           ),
        .AXI_ID_WIDTH   ( ariane_soc::IdWidthSlave ),
        .NR_CORES       ( 1                        )
    ) i_clint (
        .clk_i       ( clk            ),
        .rst_ni      ( ndmreset_n     ),
        .testmode_i  ( test_en        ),
        .axi_req_i   ( axi_clint_req  ),
        .axi_resp_o  ( axi_clint_resp ),
        .rtc_i       ( rtc_i          ),
        .timer_irq_o ( timer_irq      ),
        .ipi_o       ( ipi            )
    );

    axi_slave_connect i_axi_slave_connect_clint (
        .axi_req_o(axi_clint_req),
        .axi_resp_i(axi_clint_resp),
        .slave(master[ariane_soc::CLINT])
    );



    logic [1:0] irqs;

    ariane_peripherals #(
        .AxiAddrWidth ( AXI_ADDR_WIDTH        ),
        .AxiDataWidth ( AXI_DATA_WIDTH           ),
        .AxiIdWidth   ( ariane_soc::IdWidthSlave ),
        .InclUART     ( 1'b1                     ),
        .InclSPI      ( 1'b0                     ),
        .InclEthernet ( 1'b0                     )
    ) i_ariane_peripherals (
        .clk_i     ( clk                          ),
        .rst_ni    ( ndmreset_n                   ),
        .plic      ( master[ariane_soc::PLIC]     ),
        .uart      ( master[ariane_soc::UART]     ),
        .spi       ( master[ariane_soc::SPI]      ),
        .ethernet  ( master[ariane_soc::Ethernet] ),
        .timer     ( master[ariane_soc::Timer]    ),
        .irq_o     ( irqs                         ),
        .rx_i      ( rx                           ),
        .tx_o      ( tx                           ),
        .eth_txck  ( ),
        .eth_rxck  ( ),
        .eth_rxctl ( ),
        .eth_rxd   ( ),
        .eth_rst_n ( ),
        .eth_tx_en ( ),
        .eth_txd   ( ),
        .phy_mdio  ( ),
        .eth_mdc   ( ),
        .mdio      ( ),
        .mdc       ( ),
        .spi_clk_o ( ),
        .spi_mosi  ( ),
        .spi_miso  ( ),
        .spi_ss    ( )
    );

    ///////////////////////// CORE /////////////////////////
  
    ariane_axi::req_t    axi_ariane_req;
    ariane_axi::resp_t   axi_ariane_resp;

    ariane #(
        .ArianeCfg(ariane_soc::ArianeSocCfg)
    ) i_ariane (
        .clk_i(clk),
        .rst_ni(ndmreset_n),
        .boot_addr_i(boot_addr),
        .hart_id_i(hart_id),
        .irq_i(irqs),
        .ipi_i(ipi),
        .time_irq_i(1'b0),
        .debug_req_i(debug_req_core),
        .axi_req_o(axi_ariane_req),
        .axi_resp_i(axi_ariane_resp)
    );
    
    axi_master_connect i_axi_master_connect_ariane (
        .axi_req_i(axi_ariane_req),
        .axi_resp_o(axi_ariane_resp),
        .master(slave[0])
    );
    

endmodule
    

