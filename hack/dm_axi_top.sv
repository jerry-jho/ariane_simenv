module dm_axi_top #(
    localparam AXI_DATA_WIDTH = 64,
    localparam AXI_ADDR_WIDTH = 64,
    localparam AXI_USER_WIDTH = 1,
    localparam AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8),
    localparam AXI_ID_WIDTH   = ariane_soc::IdWidth    
)(
    input                       clk_i,
    input                       rst_ni,
    output                      ndmreset_o,
    output                      debug_req_core,
    
    input                       test_en,
    input                       jtag_TCK,
    input                       jtag_TMS,
    input                       jtag_TDI,
    input                       jtag_TRSTn,
    output                      jtag_TDO_data,
    output                      jtag_TDO_driven,

    input                       slave_req_i,
    input                       slave_we_i,
    input  [AXI_ADDR_WIDTH-1:0] slave_addr_i,
    input  [AXI_STRB_WIDTH-1:0] slave_be_i,
    input  [AXI_DATA_WIDTH-1:0] slave_wdata_i,
    output [AXI_DATA_WIDTH-1:0] slave_rdata_o,

    output ariane_axi::req_t    dm_axi_m_req,
    input  ariane_axi::resp_t   dm_axi_m_resp    
);

    ///////////////////////////////////////////////////////////////////////
    // JTAG
    
    logic        debug_req_valid;
    logic        debug_req_ready;
    logic        debug_resp_valid;
    logic        debug_resp_ready;
    dm::dmi_req_t  debug_req;
    dm::dmi_resp_t debug_resp;
  
  
    dmi_jtag i_dmi_jtag (
        .clk_i            ( clk_i           ),
        .rst_ni           ( rst_ni          ),
        .testmode_i       ( test_en         ),
        .dmi_req_o        ( debug_req       ),
        .dmi_req_valid_o  ( debug_req_valid ),
        .dmi_req_ready_i  ( debug_req_ready ),
        .dmi_resp_i       ( debug_resp      ),
        .dmi_resp_ready_o ( debug_resp_ready),
        .dmi_resp_valid_i ( debug_resp_valid),
        .dmi_rst_no       (                 ), // not connected
        .tck_i            ( jtag_TCK        ),
        .tms_i            ( jtag_TMS        ),
        .trst_ni          ( jtag_TRSTn      ),
        .td_i             ( jtag_TDI        ),
        .td_o             ( jtag_TDO_data   ),
        .tdo_oe_o         ( jtag_TDO_driven )
    );

    // this delay window allows the core to read and execute init code
    // from the bootrom before the first debug request can interrupt
    // core. this is needed in cases where an fsbl is involved that
    // expects a0 and a1 to be initialized with the hart id and a
    // pointer to the dev tree, respectively.
    localparam int unsigned DmiDelCycles = 500;

    logic debug_req_core_ungtd;
    reg [31:0] dmi_del_cnt_d, dmi_del_cnt_q;

    assign dmi_del_cnt_d  = (dmi_del_cnt_q) ? dmi_del_cnt_q - 1 : 0;
    assign debug_req_core = (dmi_del_cnt_q) ? 1'b0 : debug_req_core_ungtd;

    always_ff @(posedge clk_i or negedge rst_ni) begin : p_dmi_del_cnt
        if(!rst_ni) begin
          dmi_del_cnt_q <= DmiDelCycles;
        end else begin
          dmi_del_cnt_q <= dmi_del_cnt_d;
        end
    end



    logic                dm_slave_req;
    logic                dm_slave_we;
    logic [64-1:0]       dm_slave_addr;
    logic [64/8-1:0]     dm_slave_be;
    logic [64-1:0]       dm_slave_wdata;
    logic [64-1:0]       dm_slave_rdata;

    logic                dm_master_req;
    logic [64-1:0]       dm_master_add;
    logic                dm_master_we;
    logic [64-1:0]       dm_master_wdata;
    logic [64/8-1:0]     dm_master_be;
    logic                dm_master_gnt;
    logic                dm_master_r_valid;
    logic [64-1:0]       dm_master_r_rdata;

    // debug module
    dm_top #(
        .NrHarts              ( 1                           ),
        .BusWidth             ( AXI_DATA_WIDTH              ),
        .SelectableHarts      ( 1'b1                        )
    ) i_dm_top (
        .clk_i                ( clk_i                       ),
        .rst_ni               ( rst_ni                      ), // PoR
        .testmode_i           ( test_en                     ),
        .ndmreset_o           ( ndmreset_o                  ),
        .dmactive_o           (                             ), // active debug session
        .debug_req_o          ( debug_req_core_ungtd        ),
        .unavailable_i        ( '0                          ),
        .hartinfo_i           ( {ariane_pkg::DebugHartInfo} ),
        .slave_req_i          ( dm_slave_req                ),
        .slave_we_i           ( dm_slave_we                 ),
        .slave_addr_i         ( dm_slave_addr               ),
        .slave_be_i           ( dm_slave_be                 ),
        .slave_wdata_i        ( dm_slave_wdata              ),
        .slave_rdata_o        ( dm_slave_rdata              ),
        .master_req_o         ( dm_master_req               ),
        .master_add_o         ( dm_master_add               ),
        .master_we_o          ( dm_master_we                ),
        .master_wdata_o       ( dm_master_wdata             ),
        .master_be_o          ( dm_master_be                ),
        .master_gnt_i         ( dm_master_gnt               ),
        .master_r_valid_i     ( dm_master_r_valid           ),
        .master_r_rdata_i     ( dm_master_r_rdata           ),
        .dmi_rst_ni           ( rst_ni                      ),
        .dmi_req_valid_i      ( debug_req_valid             ),
        .dmi_req_ready_o      ( debug_req_ready             ),
        .dmi_req_i            ( debug_req                   ),
        .dmi_resp_valid_o     ( debug_resp_valid            ),
        .dmi_resp_ready_i     ( debug_resp_ready            ),
        .dmi_resp_o           ( debug_resp                  )
    );

    axi_adapter #(
        .DATA_WIDTH            ( AXI_DATA_WIDTH            )
    ) i_dm_axi_master (
        .clk_i                 ( clk_i                     ),
        .rst_ni                ( rst_ni                    ),
        .req_i                 ( dm_master_req             ),
        .type_i                ( ariane_axi::SINGLE_REQ    ),
        .gnt_o                 ( dm_master_gnt             ),
        .gnt_id_o              (                           ),
        .addr_i                ( dm_master_add             ),
        .we_i                  ( dm_master_we              ),
        .wdata_i               ( dm_master_wdata           ),
        .be_i                  ( dm_master_be              ),
        .size_i                ( 2'b11                     ), // always do 64bit here and use byte enables to gate
        .id_i                  ( '0                        ),
        .valid_o               ( dm_master_r_valid         ),
        .rdata_o               ( dm_master_r_rdata         ),
        .id_o                  (                           ),
        .critical_word_o       (                           ),
        .critical_word_valid_o (                           ),
        .axi_req_o             ( dm_axi_m_req              ),
        .axi_resp_i            ( dm_axi_m_resp             )
    );

endmodule