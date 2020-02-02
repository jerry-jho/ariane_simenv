module axim2p #(
    parameter AXI_DATA_WIDTH = 64,
    parameter AXI_ADDR_WIDTH = 64,
    parameter AXI_USER_WIDTH = 1,
    localparam AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8),
    parameter AXI_ID_WIDTH
)(
    output [AXI_ID_WIDTH-1:0]   m_axi_awid,
    output [AXI_ADDR_WIDTH-1:0] m_axi_awaddr,
    output [7:0]                m_axi_awlen,
    output [2:0]                m_axi_awsize,
    output [1:0]                m_axi_awburst,
    output                      m_axi_awlock,
    output [3:0]                m_axi_awcache,
    output [2:0]                m_axi_awprot,
    output                      m_axi_awvalid,
    input                       m_axi_awready,
    output [AXI_DATA_WIDTH-1:0] m_axi_wdata,
    output [AXI_STRB_WIDTH-1:0] m_axi_wstrb,
    output                      m_axi_wlast,
    output                      m_axi_wvalid,
    input                       m_axi_wready,
    input  [AXI_ID_WIDTH-1:0]   m_axi_bid,
    input  [1:0]                m_axi_bresp,
    input                       m_axi_bvalid,
    output                      m_axi_bready,
    output [AXI_ID_WIDTH-1:0]   m_axi_arid,
    output [AXI_ADDR_WIDTH-1:0] m_axi_araddr,
    output [7:0]                m_axi_arlen,
    output [2:0]                m_axi_arsize,
    output [1:0]                m_axi_arburst,
    output                      m_axi_arlock,
    output [3:0]                m_axi_arcache,
    output [2:0]                m_axi_arprot,
    output                      m_axi_arvalid,
    input                       m_axi_arready,
    input  [AXI_ID_WIDTH-1:0]   m_axi_rid,
    input  [AXI_DATA_WIDTH-1:0] m_axi_rdata,
    input  [1:0]                m_axi_rresp,
    input                       m_axi_rlast,
    input                       m_axi_rvalid,
    output                      m_axi_rready,

    input   ariane_axi::req_t   axi_ariane_req,
    output  ariane_axi::resp_t  axi_ariane_resp
);

    assign m_axi_awid    = axi_ariane_req.aw.id;
    assign m_axi_awaddr  = axi_ariane_req.aw.addr;
    assign m_axi_awlen   = axi_ariane_req.aw.len;
    assign m_axi_awsize  = axi_ariane_req.aw.size;
    assign m_axi_awburst = axi_ariane_req.aw.burst;
    assign m_axi_awlock  = axi_ariane_req.aw.lock;
    assign m_axi_awcache = axi_ariane_req.aw.cache;
    assign m_axi_awprot  = axi_ariane_req.aw.prot;
    assign m_axi_awvalid = axi_ariane_req.aw_valid;

    assign m_axi_wdata   = axi_ariane_req.w.data;
    assign m_axi_wstrb   = axi_ariane_req.w.strb;
    assign m_axi_wlast   = axi_ariane_req.w.last;
    assign m_axi_wvalid  = axi_ariane_req.w_valid;

    assign m_axi_bready  = axi_ariane_req.b_ready;
    assign m_axi_arid    = axi_ariane_req.ar.id;
    assign m_axi_araddr  = axi_ariane_req.ar.addr;
    assign m_axi_arlen   = axi_ariane_req.ar.len;
    assign m_axi_arsize  = axi_ariane_req.ar.size;
    assign m_axi_arburst = axi_ariane_req.ar.burst;
    assign m_axi_arlock  = axi_ariane_req.ar.lock;
    assign m_axi_arcache = axi_ariane_req.ar.cache;
    assign m_axi_arprot  = axi_ariane_req.ar.prot;
    assign m_axi_arvalid = axi_ariane_req.ar_valid;

    assign m_axi_rready  = axi_ariane_req.r_ready;
    
    assign axi_ariane_resp.aw_ready = m_axi_awready;
    assign axi_ariane_resp.ar_ready = m_axi_arready;
    assign axi_ariane_resp.w_ready  = m_axi_wready;
    assign axi_ariane_resp.b_valid  = m_axi_bvalid;
    assign axi_ariane_resp.b.id     = m_axi_bid;
    assign axi_ariane_resp.b.resp   = m_axi_bresp;
    assign axi_ariane_resp.r_valid  = m_axi_rvalid;
    assign axi_ariane_resp.r.id     = m_axi_rid;
    assign axi_ariane_resp.r.data   = m_axi_rdata;
    assign axi_ariane_resp.r.resp   = m_axi_rresp;
    assign axi_ariane_resp.r.last   = m_axi_rlast;
    
endmodule
