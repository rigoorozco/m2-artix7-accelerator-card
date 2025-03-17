/*
 * datamover_ctrl_tb
 */

`timescale 1ns/100ps

module datamover_ctrl_tb;

reg             up_clk;
reg             up_rstn;

reg            up_wreq;
reg    [13:0]  up_waddr;
reg    [31:0]  up_wdata;
reg            up_rreq;
reg    [13:0]  up_raddr;

wire           up_wack;
wire           up_rack;
wire   [31:0]  up_rdata;

wire    [103:0] m_axis_cmd_tdata;
reg             m_axis_cmd_tready;
wire            m_axis_cmd_tvalid;

reg    [ 7:0]  s_axis_sts_tdata;
reg            s_axis_sts_tkeep;
reg            s_axis_sts_tlast;
wire           s_axis_sts_tready;
reg            s_axis_sts_tvalid;
reg            error;

localparam ADDR_USR_ENABLE      = 8'h00;
localparam ADDR_USR_BUFFER      = 8'h03;
localparam ADDR_USR_LENTH       = 8'h04;
localparam ADDR_USR_BURST       = 8'h05;

// Generate clock
always begin
    #50 up_clk = ~up_clk;
end

initial begin
    up_clk <= 0;
    up_rstn <= 0;

    up_wreq <= 0;
    up_waddr <= 0;
    up_wdata <= 0;
    up_rreq <= 0;
    up_raddr <= 0;

    m_axis_cmd_tready <= 1;
    s_axis_sts_tdata <= 0;
    s_axis_sts_tkeep <= 0;
    s_axis_sts_tlast <= 0;
    s_axis_sts_tvalid <= 1;
    error <= 0;

    @(posedge up_clk);
    @(posedge up_clk);

    up_rstn <= 1;
    @(posedge up_clk);

    up_wreq <= 1;
    up_waddr <= ADDR_USR_BUFFER;
    up_wdata <= 32'h00400_0000;
    @(posedge up_clk);
    up_wreq <= 0;
    @(posedge up_clk);

    up_wreq <= 1;
    up_waddr <= ADDR_USR_LENTH;
    up_wdata <= 32'h00200_0000;
    @(posedge up_clk);
    up_wreq <= 0;
    @(posedge up_clk);

    up_wreq <= 1;
    up_waddr <= ADDR_USR_BURST;
    up_wdata <= 32'h00000_1000;
    @(posedge up_clk);
    up_wreq <= 0;
    @(posedge up_clk);

    up_wreq <= 1;
    up_waddr <= ADDR_USR_ENABLE;
    up_wdata <= 32'h00000_0001;
    @(posedge up_clk);
    up_wreq <= 0;
    @(posedge up_clk);
end

// datamover control

datamover_ctrl #(
    .DEFAULT_ADDR  (32'h0000_0000),
    .DEFAULT_SIZE  (32'h0000_8000),
    .DEFAULT_BURST (32'h0000_1000)
) dut (
    .up_clk            (up_clk),
    .up_rstn           (up_rstn),
    .up_wreq           (up_wreq),
    .up_waddr          (up_waddr),
    .up_wdata          (up_wdata),
    .up_wack           (up_wack),
    .up_rreq           (up_rreq),
    .up_raddr          (up_raddr),
    .up_rdata          (up_rdata),
    .up_rack           (up_rack),
    .m_axis_cmd_tdata  (m_axis_cmd_tdata),
    .m_axis_cmd_tready (m_axis_cmd_tready),
    .m_axis_cmd_tvalid (m_axis_cmd_tvalid),
    .s_axis_sts_tdata  (s_axis_sts_tdata),
    .s_axis_sts_tkeep  (s_axis_sts_tkeep),
    .s_axis_sts_tlast  (s_axis_sts_tlast),
    .s_axis_sts_tready (s_axis_sts_tready),
    .s_axis_sts_tvalid (s_axis_sts_tvalid),
    .error             (error)
);

endmodule
