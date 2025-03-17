/*
 * axi_datamover_s2mm_ctrl
 */

`timescale 1ns/100ps

module axi_datamover_s2mm_ctrl #(
    parameter DEFAULT_ADDR   = 32'h0000_0000,
    parameter DEFAULT_SIZE   = 32'h0000_8000,
    parameter DEFAULT_BURST  = 32'h0000_1000
) (
    // axi interface
    input           s_axi_aclk,
    input           s_axi_aresetn,
    input           s_axi_awvalid,
    input   [15:0]  s_axi_awaddr,
    input   [ 2:0]  s_axi_awprot,
    output          s_axi_awready,
    input           s_axi_wvalid,
    input   [31:0]  s_axi_wdata,
    input   [ 3:0]  s_axi_wstrb,
    output          s_axi_wready,
    output          s_axi_bvalid,
    output  [ 1:0]  s_axi_bresp,
    input           s_axi_bready,
    input           s_axi_arvalid,
    input   [15:0]  s_axi_araddr,
    input   [ 2:0]  s_axi_arprot,
    output          s_axi_arready,
    output          s_axi_rvalid,
    output  [31:0]  s_axi_rdata,
    output  [ 1:0]  s_axi_rresp,
    input           s_axi_rready,
    // datamover command interface
    output [103:0]  m_axis_s2mm_cmd_tdata,
    input           m_axis_s2mm_cmd_tready,
    output          m_axis_s2mm_cmd_tvalid,
    // datamover status interface
    input  [ 7:0]   s_axis_s2mm_sts_tdata,
    input           s_axis_s2mm_sts_tkeep,
    input           s_axis_s2mm_sts_tlast,
    output          s_axis_s2mm_sts_tready,
    input           s_axis_s2mm_sts_tvalid,
    // datamover error
    input           s2mm_error
);

// internal clocks and resets

wire            up_clk;
wire            up_rstn;


// internal signals

wire            up_wreq_s;
wire    [13:0]  up_waddr_s;
wire    [31:0]  up_wdata_s;
wire            up_rreq_s;
wire    [13:0]  up_raddr_s;
wire            up_wack_ctrl_s;
wire            up_rack_ctrl_s;
wire    [31:0]  up_rdata_ctrl_s;

reg             up_wack;
reg             up_rack;
reg     [31:0]  up_rdata;

// signal name changes

assign up_clk = s_axi_aclk;
assign up_rstn = s_axi_aresetn;

// processor read interface

always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
        up_wack <= 'd0;
        up_rack <= 'd0;
        up_rdata <= 'd0;
    end else begin
        up_wack <= up_wack_ctrl_s;
        up_rack <= up_rack_ctrl_s;
        up_rdata <= up_rdata_ctrl_s;
    end
end

// axi interface

up_axi i_up_axi (
    .up_rstn        (up_rstn),
    .up_clk         (up_clk),
    .up_axi_awvalid (s_axi_awvalid),
    .up_axi_awaddr  (s_axi_awaddr),
    .up_axi_awready (s_axi_awready),
    .up_axi_wvalid  (s_axi_wvalid),
    .up_axi_wdata   (s_axi_wdata),
    .up_axi_wstrb   (s_axi_wstrb),
    .up_axi_wready  (s_axi_wready),
    .up_axi_bvalid  (s_axi_bvalid),
    .up_axi_bresp   (s_axi_bresp),
    .up_axi_bready  (s_axi_bready),
    .up_axi_arvalid (s_axi_arvalid),
    .up_axi_araddr  (s_axi_araddr),
    .up_axi_arready (s_axi_arready),
    .up_axi_rvalid  (s_axi_rvalid),
    .up_axi_rresp   (s_axi_rresp),
    .up_axi_rdata   (s_axi_rdata),
    .up_axi_rready  (s_axi_rready),
    .up_wreq        (up_wreq_s),
    .up_waddr       (up_waddr_s),
    .up_wdata       (up_wdata_s),
    .up_wack        (up_wack),
    .up_rreq        (up_rreq_s),
    .up_raddr       (up_raddr_s),
    .up_rdata       (up_rdata),
    .up_rack        (up_rack)
);

// datamover control

datamover_ctrl #(
    .DEFAULT_ADDR  (DEFAULT_ADDR),
    .DEFAULT_SIZE  (DEFAULT_SIZE),
    .DEFAULT_BURST (DEFAULT_BURST)
) ctrl (
    .up_clk            (up_clk),
    .up_rstn           (up_rstn),
    .up_wreq           (up_wreq_s),
    .up_waddr          (up_waddr_s),
    .up_wdata          (up_wdata_s),
    .up_wack           (up_wack_ctrl_s),
    .up_rreq           (up_rreq_s),
    .up_raddr          (up_raddr_s),
    .up_rdata          (up_rdata_ctrl_s),
    .up_rack           (up_rack_ctrl_s),
    .m_axis_cmd_tdata  (m_axis_s2mm_cmd_tdata),
    .m_axis_cmd_tready (m_axis_s2mm_cmd_tready),
    .m_axis_cmd_tvalid (m_axis_s2mm_cmd_tvalid),
    .s_axis_sts_tdata  (s_axis_s2mm_sts_tdata),
    .s_axis_sts_tkeep  (s_axis_s2mm_sts_tkeep),
    .s_axis_sts_tlast  (s_axis_s2mm_sts_tlast),
    .s_axis_sts_tready (s_axis_s2mm_sts_tready),
    .s_axis_sts_tvalid (s_axis_s2mm_sts_tvalid),
    .error             (s2mm_error)
);

endmodule
