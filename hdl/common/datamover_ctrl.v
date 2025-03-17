/*
 * datamover_ctrl
 */

module datamover_ctrl #(
    parameter DEFAULT_ADDR   = 32'h0000_0000,
    parameter DEFAULT_SIZE   = 32'h0000_8000,
    parameter DEFAULT_BURST  = 9'h000
) (
    // bus interface
    input               up_rstn,
    input               up_clk,
    input               up_wreq,
    input       [13:0]  up_waddr,
    input       [31:0]  up_wdata,
    output reg          up_wack,
    input               up_rreq,
    input       [13:0]  up_raddr,
    output reg  [31:0]  up_rdata,
    output reg          up_rack,
    // datamover command interface
    output     [103:0]  m_axis_cmd_tdata,
    input               m_axis_cmd_tready,
    output              m_axis_cmd_tvalid,
    // datamover status interface
    input      [ 7:0]   s_axis_sts_tdata,
    input               s_axis_sts_tkeep,
    input               s_axis_sts_tlast,
    output              s_axis_sts_tready,
    input               s_axis_sts_tvalid,
    // datamover error
    input               error
);

// parameters

localparam STATE_IDLE      = 4'd0;
localparam STATE_START_CMD = 4'd1;
localparam STATE_WR_CMD    = 4'd2;
localparam STATE_RD_STS    = 4'd3;
localparam STATE_INCR_CMD  = 4'd4;
localparam STATE_NEXT_CMD  = 4'd5;

localparam ADDR_USR_ENABLE      = 8'h00;
localparam ADDR_USR_AUTO_ENABLE = 8'h01;
localparam ADDR_USR_SCRATCH     = 8'h02;
localparam ADDR_USR_BUFFER      = 8'h03;
localparam ADDR_USR_LENTH       = 8'h04;
localparam ADDR_USR_BURST       = 8'h05;
localparam ADDR_CMD_TAG         = 8'h06;
localparam ADDR_CMD_DDR         = 8'h07;
localparam ADDR_CMD_DSA         = 8'h08;
localparam ADDR_CMD_TYPE        = 8'h09;
localparam ADDR_STS_WORD        = 8'h0A;
localparam ADDR_DBG_STATE       = 8'h0B;
localparam ADDR_DBG_SADDR       = 8'h0C;
localparam ADDR_DBG_BTT         = 8'h0D;
localparam ADDR_DBG_LENGTH      = 8'h0E;

// internal signals

reg          usr_enable, _usr_enable;
reg          usr_auto_enable;
reg   [31:0] usr_scratch;
reg   [31:0] usr_buffer;
reg   [31:0] usr_length;
reg   [31:0] usr_burst;

wire  [ 3:0] cmd_reserved;
reg   [ 3:0] cmd_tag;
reg   [63:0] cmd_saddr, _cmd_saddr;
reg          cmd_ddr;
reg          cmd_eof, _cmd_eof;
reg   [ 5:0] cmd_dsa;
reg          cmd_type;
reg   [22:0] cmd_btt, _cmd_btt;

reg   [ 7:0] sts_word;
reg   [ 7:0] _sts_word;

reg   [ 3:0] state, _state;
reg          ctrl_write_cmd, _ctrl_write_cmd;
reg          ctrl_sts_ready, _ctrl_sts_ready;
reg   [31:0] ctrl_length, _ctrl_length;

always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
        up_wack         <= 1'h0;
        up_rack         <= 1'h0;
        up_rdata        <= 'h0;

        usr_enable      <= 0;
        usr_auto_enable <= 0;
        usr_scratch     <= 32'hBEEFCAFE;
        usr_buffer      <= DEFAULT_ADDR;
        usr_length      <= DEFAULT_SIZE;
        usr_burst       <= DEFAULT_BURST;

        cmd_tag         <= 'h0;
        cmd_saddr       <= 'h0;
        cmd_ddr         <= 0;
        cmd_eof         <= 0;
        cmd_dsa         <= 'h0;
        cmd_type        <= 1;
        cmd_btt         <= 'h0;

        sts_word        <= 'h0;

        state           <= STATE_IDLE;
        ctrl_write_cmd  <= 0;
        ctrl_sts_ready  <= 0;
        ctrl_length     <= 'h0;
    end else begin
        up_wack         <= up_wreq;
        up_rack         <= up_rreq;
        up_rdata        <= up_rdata;

        usr_enable      <= _usr_enable;
        usr_auto_enable <= usr_auto_enable;
        usr_scratch     <= usr_scratch;
        usr_buffer      <= usr_buffer;
        usr_length      <= usr_length;
        usr_burst       <= usr_burst;

        cmd_tag         <= cmd_tag;
        cmd_saddr       <= _cmd_saddr;
        cmd_ddr         <= cmd_ddr;
        cmd_eof         <= _cmd_eof;
        cmd_dsa         <= cmd_dsa;
        cmd_type        <= cmd_type;
        cmd_btt         <= _cmd_btt;

        sts_word        <= _sts_word;

        state           <= _state;
        ctrl_write_cmd  <= _ctrl_write_cmd;
        ctrl_sts_ready  <= _ctrl_sts_ready;
        ctrl_length     <= _ctrl_length;

        // Handle writes
        if (up_wreq) begin
            case(up_waddr[7:0])
                ADDR_USR_ENABLE:      usr_enable       <= up_wdata[0];
                ADDR_USR_AUTO_ENABLE: usr_auto_enable  <= up_wdata[0];
                ADDR_USR_SCRATCH:     usr_scratch      <= up_wdata;
                ADDR_USR_BUFFER:      usr_buffer       <= up_wdata;
                ADDR_USR_LENTH:       usr_length       <= up_wdata;
                ADDR_USR_BURST:       usr_burst        <= up_wdata;
                ADDR_CMD_TAG:         cmd_tag          <= up_wdata[3:0];
                ADDR_CMD_DDR:         cmd_ddr          <= up_wdata[0];
                ADDR_CMD_DSA:         cmd_dsa          <= up_wdata[5:0];
                ADDR_CMD_TYPE:        cmd_type         <= up_wdata[0];
                ADDR_STS_WORD:        sts_word         <= sts_word; // READ-ONLY
            endcase
        end

        // Handle reads
        if (up_rreq) begin
            case(up_raddr[7:0])
                ADDR_USR_ENABLE:      up_rdata   <= {31'd0, usr_enable};
                ADDR_USR_AUTO_ENABLE: up_rdata   <= {31'd0, usr_auto_enable};
                ADDR_USR_SCRATCH:     up_rdata   <= usr_scratch;
                ADDR_USR_BUFFER:      up_rdata   <= usr_buffer;
                ADDR_USR_LENTH:       up_rdata   <= usr_length;
                ADDR_USR_BURST:       up_rdata   <= usr_burst;
                ADDR_CMD_TAG:         up_rdata   <= {18'd0, cmd_tag};
                ADDR_CMD_DDR:         up_rdata   <= {31'd0, cmd_ddr};
                ADDR_CMD_DSA:         up_rdata   <= {26'd0, cmd_dsa};
                ADDR_CMD_TYPE:        up_rdata   <= {31'd0, cmd_type};
                ADDR_STS_WORD:        up_rdata   <= {24'd0, sts_word};
                ADDR_DBG_STATE:       up_rdata   <= {28'd0, state};
                ADDR_DBG_SADDR:       up_rdata   <= cmd_saddr[31:0];
                ADDR_DBG_BTT:         up_rdata   <= {9'd0, cmd_btt};
                ADDR_DBG_LENGTH:      up_rdata   <= ctrl_length;
                default:              up_rdata   <= 32'h0;
            endcase
        end
    end
end

always @(*) begin
    _state          = state;
    _ctrl_write_cmd = 0;
    _ctrl_sts_ready = 0;
    _ctrl_length    = ctrl_length;
    _usr_enable     = usr_enable;
    _sts_word       = sts_word;
    _cmd_saddr      = cmd_saddr;
    _cmd_eof        = cmd_eof;
    _cmd_btt        = cmd_btt;

    case(state)
        STATE_IDLE: begin
            // Wait for enable
            if (usr_enable) begin
                // Load initial command configurations
                _cmd_saddr = usr_buffer;
                _cmd_btt = usr_burst;

                // Load initial length
                _ctrl_length = usr_length;

                // Go to start command state
                _state = STATE_START_CMD;
            end
        end
        STATE_START_CMD: begin
            if (ctrl_length > cmd_btt) begin
                // More than one burst needed, leave BTT the same
                _cmd_eof = 0;
            end else begin
                // Last burst, make BTT equal what is left
                _cmd_eof = 1;
                _cmd_btt = ctrl_length;
            end

            // Go to write command state
            _state = STATE_WR_CMD;
        end
        STATE_WR_CMD: begin
            // Wait for command interface to be ready
            if (m_axis_cmd_tready) begin
                // Write to command interface
                _ctrl_write_cmd = 1;

                // Got to read status state
                _state = STATE_RD_STS;
            end
        end
        STATE_RD_STS: begin
            // Wait for valid status
            _ctrl_sts_ready = 1;

            if (s_axis_sts_tvalid) begin
                // Load status word
                _sts_word = s_axis_sts_tdata;

                // Go to increment/decrement state
                _state = STATE_INCR_CMD;
            end
        end
        STATE_INCR_CMD: begin
            // Decrement bytes left
            _ctrl_length = ctrl_length - cmd_btt;

            // Incremet start address
            _cmd_saddr = cmd_saddr + cmd_btt;

            // Go to read status state
            _state = STATE_NEXT_CMD;
        end
        STATE_NEXT_CMD: begin
            if (ctrl_length > 0) begin
                // Not done yet
                _state = STATE_START_CMD;
            end else begin
                // Decide whether to remain enabled
                _usr_enable = usr_auto_enable;

                // Done go to idle state
                _state = STATE_IDLE;
            end
        end
        default: _state = 'h0;
    endcase
end

assign cmd_reserved = 4'h00;
assign m_axis_cmd_tdata = {
    cmd_reserved, // 4-bit
    cmd_tag,      // 4-bit
    cmd_saddr,    // 64-bit <- depends on address width
    cmd_ddr,      // 1-bit
    cmd_eof,      // 1-bit
    cmd_dsa,      // 6-bit
    cmd_type,     // 1-bit
    cmd_btt       // 23-bit
};

assign m_axis_cmd_tvalid = ctrl_write_cmd;
assign s_axis_sts_tready = ctrl_sts_ready;

endmodule
