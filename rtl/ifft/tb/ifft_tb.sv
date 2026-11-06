`timescale 1ns/1ps

module ifft_tb;

    // ---------------------------------------------------------
    // Configuration
    // ---------------------------------------------------------
    localparam integer N = 64;

    localparam [63:0] SRC_BASE  = 64'h0000_0000_0000_1000;
    localparam [63:0] DEST_BASE = 64'h0000_0000_0000_2000;

    localparam [4:0] CTRL_ADDR  = 5'h00;
    localparam [4:0] COUNT_ADDR = 5'h10;
    localparam [4:0] INV_ADDR   = 5'h18;

    localparam [5:0] SRC_LO_ADDR  = 6'h10;
    localparam [5:0] SRC_HI_ADDR  = 6'h14;
    localparam [5:0] DEST_LO_ADDR = 6'h1C;
    localparam [5:0] DEST_HI_ADDR = 6'h20;

    reg ap_clk;
    reg ap_rst_n;

    initial begin
        ap_clk = 0;
        forever #5 ap_clk = ~ap_clk;
    end

    // ---------------------------------------------------------
    // AXI-Lite: s_axi_control (main control registers)
    // ---------------------------------------------------------
    reg         s_axi_control_AWVALID;
    wire        s_axi_control_AWREADY;
    reg  [4:0]  s_axi_control_AWADDR;

    reg         s_axi_control_WVALID;
    wire        s_axi_control_WREADY;
    reg  [31:0] s_axi_control_WDATA;
    reg  [3:0]  s_axi_control_WSTRB;

    wire        s_axi_control_BVALID;
    reg         s_axi_control_BREADY;
    wire [1:0]  s_axi_control_BRESP;

    reg         s_axi_control_ARVALID;
    wire        s_axi_control_ARREADY;
    reg  [4:0]  s_axi_control_ARADDR;

    wire        s_axi_control_RVALID;
    reg         s_axi_control_RREADY;
    wire [31:0] s_axi_control_RDATA;
    wire [1:0]  s_axi_control_RRESP;

    // ---------------------------------------------------------
    // AXI-Lite: s_axi_control_r (pointer registers)
    // ---------------------------------------------------------
    reg         s_axi_control_r_AWVALID;
    wire        s_axi_control_r_AWREADY;
    reg  [5:0]  s_axi_control_r_AWADDR;

    reg         s_axi_control_r_WVALID;
    wire        s_axi_control_r_WREADY;
    reg  [31:0] s_axi_control_r_WDATA;
    reg  [3:0]  s_axi_control_r_WSTRB;

    wire        s_axi_control_r_BVALID;
    reg         s_axi_control_r_BREADY;
    wire [1:0]  s_axi_control_r_BRESP;

    reg         s_axi_control_r_ARVALID;
    wire        s_axi_control_r_ARREADY;
    reg  [5:0]  s_axi_control_r_ARADDR;

    wire        s_axi_control_r_RVALID;
    reg         s_axi_control_r_RREADY;
    wire [31:0] s_axi_control_r_RDATA;
    wire [1:0]  s_axi_control_r_RRESP;

    // ---------------------------------------------------------
    // GMEM0: AXI read interface
    // ---------------------------------------------------------
    wire        m_axi_gmem0_ARVALID;
    reg         m_axi_gmem0_ARREADY;
    wire [63:0] m_axi_gmem0_ARADDR;
    wire [0:0]  m_axi_gmem0_ARID;
    wire [7:0]  m_axi_gmem0_ARLEN;
    wire [2:0]  m_axi_gmem0_ARSIZE;
    wire [1:0]  m_axi_gmem0_ARBURST;
    wire [1:0]  m_axi_gmem0_ARLOCK;
    wire [3:0]  m_axi_gmem0_ARCACHE;
    wire [2:0]  m_axi_gmem0_ARPROT;
    wire [3:0]  m_axi_gmem0_ARQOS;
    wire [3:0]  m_axi_gmem0_ARREGION;
    wire [0:0]  m_axi_gmem0_ARUSER;

    reg         m_axi_gmem0_RVALID;
    wire        m_axi_gmem0_RREADY;
    reg  [63:0] m_axi_gmem0_RDATA;
    reg         m_axi_gmem0_RLAST;
    reg  [0:0]  m_axi_gmem0_RID;
    reg  [0:0]  m_axi_gmem0_RUSER;
    reg  [1:0]  m_axi_gmem0_RRESP;

    // ---------------------------------------------------------
    // GMEM1: AXI write interface
    // ---------------------------------------------------------
    wire        m_axi_gmem1_AWVALID;
    reg         m_axi_gmem1_AWREADY;
    wire [63:0] m_axi_gmem1_AWADDR;
    wire [0:0]  m_axi_gmem1_AWID;
    wire [7:0]  m_axi_gmem1_AWLEN;
    wire [2:0]  m_axi_gmem1_AWSIZE;
    wire [1:0]  m_axi_gmem1_AWBURST;
    wire [1:0]  m_axi_gmem1_AWLOCK;
    wire [3:0]  m_axi_gmem1_AWCACHE;
    wire [2:0]  m_axi_gmem1_AWPROT;
    wire [3:0]  m_axi_gmem1_AWQOS;
    wire [3:0]  m_axi_gmem1_AWREGION;
    wire [0:0]  m_axi_gmem1_AWUSER;

    wire        m_axi_gmem1_WVALID;
    reg         m_axi_gmem1_WREADY;
    wire [63:0] m_axi_gmem1_WDATA;
    wire [7:0]  m_axi_gmem1_WSTRB;
    wire        m_axi_gmem1_WLAST;
    wire [0:0]  m_axi_gmem1_WID;
    wire [0:0]  m_axi_gmem1_WUSER;

    reg         m_axi_gmem1_BVALID;
    wire        m_axi_gmem1_BREADY;
    reg  [1:0]  m_axi_gmem1_BRESP;
    reg  [0:0]  m_axi_gmem1_BID;
    reg  [0:0]  m_axi_gmem1_BUSER;

    // ---------------------------------------------------------
    // Memory model
    // 4096 x 64-bit words
    // ---------------------------------------------------------
    reg [63:0] mem [0:4095];

    integer i;
    integer output_file;

    initial begin
        for (i = 0; i < 4096; i = i + 1)
            mem[i] = 64'd0;

        // 0x1000 / 8 = word index 512
        $readmemh("ifft_input_vectors.mem", mem, 512, 575);
    end

    // ---------------------------------------------------------
    // DUT
    // ---------------------------------------------------------
    fft1d dut (
        .ap_clk(ap_clk),
        .ap_rst_n(ap_rst_n),

        // GMEM0 unused write channels
        .m_axi_gmem0_AWREADY(1'b0),
        .m_axi_gmem0_WREADY(1'b0),
        .m_axi_gmem0_BVALID(1'b0),
        .m_axi_gmem0_BRESP(2'b00),
        .m_axi_gmem0_BID(1'b0),
        .m_axi_gmem0_BUSER(1'b0),

        // GMEM0 read channels
        .m_axi_gmem0_ARVALID(m_axi_gmem0_ARVALID),
        .m_axi_gmem0_ARREADY(m_axi_gmem0_ARREADY),
        .m_axi_gmem0_ARADDR(m_axi_gmem0_ARADDR),
        .m_axi_gmem0_ARID(m_axi_gmem0_ARID),
        .m_axi_gmem0_ARLEN(m_axi_gmem0_ARLEN),
        .m_axi_gmem0_ARSIZE(m_axi_gmem0_ARSIZE),
        .m_axi_gmem0_ARBURST(m_axi_gmem0_ARBURST),
        .m_axi_gmem0_ARLOCK(m_axi_gmem0_ARLOCK),
        .m_axi_gmem0_ARCACHE(m_axi_gmem0_ARCACHE),
        .m_axi_gmem0_ARPROT(m_axi_gmem0_ARPROT),
        .m_axi_gmem0_ARQOS(m_axi_gmem0_ARQOS),
        .m_axi_gmem0_ARREGION(m_axi_gmem0_ARREGION),
        .m_axi_gmem0_ARUSER(m_axi_gmem0_ARUSER),

        .m_axi_gmem0_RVALID(m_axi_gmem0_RVALID),
        .m_axi_gmem0_RREADY(m_axi_gmem0_RREADY),
        .m_axi_gmem0_RDATA(m_axi_gmem0_RDATA),
        .m_axi_gmem0_RLAST(m_axi_gmem0_RLAST),
        .m_axi_gmem0_RID(m_axi_gmem0_RID),
        .m_axi_gmem0_RUSER(m_axi_gmem0_RUSER),
        .m_axi_gmem0_RRESP(m_axi_gmem0_RRESP),

        // GMEM1 unused read channels
        .m_axi_gmem1_ARREADY(1'b0),
        .m_axi_gmem1_RVALID(1'b0),
        .m_axi_gmem1_RDATA(64'd0),
        .m_axi_gmem1_RLAST(1'b0),
        .m_axi_gmem1_RID(1'b0),
        .m_axi_gmem1_RUSER(1'b0),
        .m_axi_gmem1_RRESP(2'b00),

        // GMEM1 write channels
        .m_axi_gmem1_AWVALID(m_axi_gmem1_AWVALID),
        .m_axi_gmem1_AWREADY(m_axi_gmem1_AWREADY),
        .m_axi_gmem1_AWADDR(m_axi_gmem1_AWADDR),
        .m_axi_gmem1_AWID(m_axi_gmem1_AWID),
        .m_axi_gmem1_AWLEN(m_axi_gmem1_AWLEN),
        .m_axi_gmem1_AWSIZE(m_axi_gmem1_AWSIZE),
        .m_axi_gmem1_AWBURST(m_axi_gmem1_AWBURST),
        .m_axi_gmem1_AWLOCK(m_axi_gmem1_AWLOCK),
        .m_axi_gmem1_AWCACHE(m_axi_gmem1_AWCACHE),
        .m_axi_gmem1_AWPROT(m_axi_gmem1_AWPROT),
        .m_axi_gmem1_AWQOS(m_axi_gmem1_AWQOS),
        .m_axi_gmem1_AWREGION(m_axi_gmem1_AWREGION),
        .m_axi_gmem1_AWUSER(m_axi_gmem1_AWUSER),

        .m_axi_gmem1_WVALID(m_axi_gmem1_WVALID),
        .m_axi_gmem1_WREADY(m_axi_gmem1_WREADY),
        .m_axi_gmem1_WDATA(m_axi_gmem1_WDATA),
        .m_axi_gmem1_WSTRB(m_axi_gmem1_WSTRB),
        .m_axi_gmem1_WLAST(m_axi_gmem1_WLAST),
        .m_axi_gmem1_WID(m_axi_gmem1_WID),
        .m_axi_gmem1_WUSER(m_axi_gmem1_WUSER),

        .m_axi_gmem1_BVALID(m_axi_gmem1_BVALID),
        .m_axi_gmem1_BREADY(m_axi_gmem1_BREADY),
        .m_axi_gmem1_BRESP(m_axi_gmem1_BRESP),
        .m_axi_gmem1_BID(m_axi_gmem1_BID),
        .m_axi_gmem1_BUSER(m_axi_gmem1_BUSER),

        // Main control AXI-Lite
        .s_axi_control_AWVALID(s_axi_control_AWVALID),
        .s_axi_control_AWREADY(s_axi_control_AWREADY),
        .s_axi_control_AWADDR(s_axi_control_AWADDR),
        .s_axi_control_WVALID(s_axi_control_WVALID),
        .s_axi_control_WREADY(s_axi_control_WREADY),
        .s_axi_control_WDATA(s_axi_control_WDATA),
        .s_axi_control_WSTRB(s_axi_control_WSTRB),
        .s_axi_control_ARVALID(s_axi_control_ARVALID),
        .s_axi_control_ARREADY(s_axi_control_ARREADY),
        .s_axi_control_ARADDR(s_axi_control_ARADDR),
        .s_axi_control_RVALID(s_axi_control_RVALID),
        .s_axi_control_RREADY(s_axi_control_RREADY),
        .s_axi_control_RDATA(s_axi_control_RDATA),
        .s_axi_control_RRESP(s_axi_control_RRESP),
        .s_axi_control_BVALID(s_axi_control_BVALID),
        .s_axi_control_BREADY(s_axi_control_BREADY),
        .s_axi_control_BRESP(s_axi_control_BRESP),

        // Pointer AXI-Lite
        .s_axi_control_r_AWVALID(s_axi_control_r_AWVALID),
        .s_axi_control_r_AWREADY(s_axi_control_r_AWREADY),
        .s_axi_control_r_AWADDR(s_axi_control_r_AWADDR),
        .s_axi_control_r_WVALID(s_axi_control_r_WVALID),
        .s_axi_control_r_WREADY(s_axi_control_r_WREADY),
        .s_axi_control_r_WDATA(s_axi_control_r_WDATA),
        .s_axi_control_r_WSTRB(s_axi_control_r_WSTRB),
        .s_axi_control_r_ARVALID(s_axi_control_r_ARVALID),
        .s_axi_control_r_ARREADY(s_axi_control_r_ARREADY),
        .s_axi_control_r_ARADDR(s_axi_control_r_ARADDR),
        .s_axi_control_r_RVALID(s_axi_control_r_RVALID),
        .s_axi_control_r_RREADY(s_axi_control_r_RREADY),
        .s_axi_control_r_RDATA(s_axi_control_r_RDATA),
        .s_axi_control_r_RRESP(s_axi_control_r_RRESP),
        .s_axi_control_r_BVALID(s_axi_control_r_BVALID),
        .s_axi_control_r_BREADY(s_axi_control_r_BREADY),
        .s_axi_control_r_BRESP(s_axi_control_r_BRESP)
    );

    // ---------------------------------------------------------
    // AXI-Lite write task: main control
    // ---------------------------------------------------------
    task automatic axi_write_main(
        input [4:0] addr,
        input [31:0] data
    );
    begin
        @(negedge ap_clk);
        s_axi_control_AWADDR  = addr;
        s_axi_control_AWVALID = 1'b1;

        do @(posedge ap_clk);
        while (!s_axi_control_AWREADY);

        @(negedge ap_clk);
        s_axi_control_AWVALID = 1'b0;
        s_axi_control_WDATA   = data;
        s_axi_control_WSTRB   = 4'hF;
        s_axi_control_WVALID  = 1'b1;

        do @(posedge ap_clk);
        while (!s_axi_control_WREADY);

        @(negedge ap_clk);
        s_axi_control_WVALID  = 1'b0;
        s_axi_control_BREADY  = 1'b1;

        do @(posedge ap_clk);
        while (!s_axi_control_BVALID);

        @(negedge ap_clk);
        s_axi_control_BREADY = 1'b0;
    end
    endtask

    // ---------------------------------------------------------
    // AXI-Lite write task: pointer registers
    // ---------------------------------------------------------
    task automatic axi_write_ptr(
        input [5:0] addr,
        input [31:0] data
    );
    begin
        @(negedge ap_clk);
        s_axi_control_r_AWADDR  = addr;
        s_axi_control_r_AWVALID = 1'b1;

        do @(posedge ap_clk);
        while (!s_axi_control_r_AWREADY);

        @(negedge ap_clk);
        s_axi_control_r_AWVALID = 1'b0;
        s_axi_control_r_WDATA   = data;
        s_axi_control_r_WSTRB   = 4'hF;
        s_axi_control_r_WVALID  = 1'b1;

        do @(posedge ap_clk);
        while (!s_axi_control_r_WREADY);

        @(negedge ap_clk);
        s_axi_control_r_WVALID = 1'b0;
        s_axi_control_r_BREADY = 1'b1;

        do @(posedge ap_clk);
        while (!s_axi_control_r_BVALID);

        @(negedge ap_clk);
        s_axi_control_r_BREADY = 1'b0;
    end
    endtask

    // ---------------------------------------------------------
    // GMEM0 read memory model
    // One outstanding burst, 64-bit data
    // ---------------------------------------------------------
    reg        rd_active;
    reg [63:0] rd_addr;
    reg [7:0]  rd_len;
    reg [7:0]  rd_beat;

    always @(posedge ap_clk) begin
        if (!ap_rst_n) begin
            m_axi_gmem0_ARREADY <= 1'b0;
            m_axi_gmem0_RVALID  <= 1'b0;
            m_axi_gmem0_RDATA   <= 64'd0;
            m_axi_gmem0_RLAST   <= 1'b0;
            m_axi_gmem0_RID     <= 1'b0;
            m_axi_gmem0_RUSER   <= 1'b0;
            m_axi_gmem0_RRESP   <= 2'b00;

            rd_active <= 1'b0;
            rd_addr   <= 64'd0;
            rd_len    <= 8'd0;
            rd_beat   <= 8'd0;
        end else begin
            // Accept a read address only when no burst is active
            m_axi_gmem0_ARREADY <= !rd_active && !m_axi_gmem0_RVALID;

            if (m_axi_gmem0_ARVALID &&
                m_axi_gmem0_ARREADY) begin

                rd_active <= 1'b1;
                rd_addr   <= m_axi_gmem0_ARADDR;
                rd_len    <= m_axi_gmem0_ARLEN;
                rd_beat   <= 8'd0;

                m_axi_gmem0_RVALID <= 1'b1;
                m_axi_gmem0_RDATA  <= mem[m_axi_gmem0_ARADDR[15:3]];
                m_axi_gmem0_RLAST  <= (m_axi_gmem0_ARLEN == 0);
                m_axi_gmem0_RID    <= m_axi_gmem0_ARID;
                m_axi_gmem0_RRESP  <= 2'b00;
            end
            else if (m_axi_gmem0_RVALID &&
                     m_axi_gmem0_RREADY) begin

                if (rd_beat == rd_len) begin
                    m_axi_gmem0_RVALID <= 1'b0;
                    m_axi_gmem0_RLAST  <= 1'b0;
                    rd_active          <= 1'b0;
                end else begin
                    rd_beat <= rd_beat + 1'b1;

                    m_axi_gmem0_RDATA <=
                        mem[(rd_addr[15:3]) + rd_beat + 1];

                    m_axi_gmem0_RLAST <=
                        ((rd_beat + 1'b1) == rd_len);
                end
            end
        end
    end

    // ---------------------------------------------------------
    // GMEM1 write memory model
    // One outstanding burst, 64-bit data
    // ---------------------------------------------------------
    reg        wr_active;
    reg [63:0] wr_addr;
    reg [7:0]  wr_len;
    reg [7:0]  wr_beat;

    integer byte_index;
    integer mem_index;

    always @(posedge ap_clk) begin
        if (!ap_rst_n) begin
            m_axi_gmem1_AWREADY <= 1'b0;
            m_axi_gmem1_WREADY  <= 1'b0;
            m_axi_gmem1_BVALID  <= 1'b0;
            m_axi_gmem1_BRESP   <= 2'b00;
            m_axi_gmem1_BID     <= 1'b0;
            m_axi_gmem1_BUSER   <= 1'b0;

            wr_active <= 1'b0;
            wr_addr   <= 64'd0;
            wr_len    <= 8'd0;
            wr_beat   <= 8'd0;
        end else begin
            m_axi_gmem1_AWREADY <= !wr_active && !m_axi_gmem1_BVALID;
            m_axi_gmem1_WREADY  <= wr_active && !m_axi_gmem1_BVALID;

            if (m_axi_gmem1_AWVALID &&
                m_axi_gmem1_AWREADY) begin

                wr_active <= 1'b1;
                wr_addr   <= m_axi_gmem1_AWADDR;
                wr_len    <= m_axi_gmem1_AWLEN;
                wr_beat   <= 8'd0;
                m_axi_gmem1_BID <= m_axi_gmem1_AWID;
            end

            if (m_axi_gmem1_WVALID &&
                m_axi_gmem1_WREADY) begin

                mem_index = (wr_addr[15:3]) + wr_beat;

                for (byte_index = 0; byte_index < 8;
                     byte_index = byte_index + 1) begin

                    if (m_axi_gmem1_WSTRB[byte_index])
                        mem[mem_index][byte_index*8 +: 8]
                            <= m_axi_gmem1_WDATA[byte_index*8 +: 8];
                end

                if (m_axi_gmem1_WLAST ||
                    (wr_beat == wr_len)) begin

                    wr_active <= 1'b0;
                    m_axi_gmem1_BVALID <= 1'b1;
                    m_axi_gmem1_BRESP  <= 2'b00;
                end else begin
                    wr_beat <= wr_beat + 1'b1;
                end
            end

            if (m_axi_gmem1_BVALID &&
                m_axi_gmem1_BREADY) begin
                m_axi_gmem1_BVALID <= 1'b0;
            end
        end
    end

    // ---------------------------------------------------------
    // Main test sequence
    // ---------------------------------------------------------
    initial begin
        ap_rst_n = 1'b0;

        // Initialize AXI-Lite controls
        s_axi_control_AWVALID = 0;
        s_axi_control_WVALID  = 0;
        s_axi_control_WDATA   = 0;
        s_axi_control_WSTRB   = 4'hF;
        s_axi_control_BREADY  = 0;
        s_axi_control_ARVALID = 0;
        s_axi_control_ARADDR  = 0;
        s_axi_control_RREADY  = 0;

        s_axi_control_r_AWVALID = 0;
        s_axi_control_r_WVALID  = 0;
        s_axi_control_r_WDATA   = 0;
        s_axi_control_r_WSTRB   = 4'hF;
        s_axi_control_r_BREADY  = 0;
        s_axi_control_r_ARVALID = 0;
        s_axi_control_r_ARADDR  = 0;
        s_axi_control_r_RREADY  = 0;

        // Initialize memory-side signals
        m_axi_gmem0_ARREADY = 0;
        m_axi_gmem0_RVALID  = 0;
        m_axi_gmem0_RDATA   = 0;
        m_axi_gmem0_RLAST   = 0;
        m_axi_gmem0_RID     = 0;
        m_axi_gmem0_RUSER   = 0;
        m_axi_gmem0_RRESP   = 0;

        m_axi_gmem1_AWREADY = 0;
        m_axi_gmem1_WREADY  = 0;
        m_axi_gmem1_BVALID  = 0;
        m_axi_gmem1_BRESP   = 0;
        m_axi_gmem1_BID     = 0;
        m_axi_gmem1_BUSER   = 0;

        repeat (10) @(posedge ap_clk);
        @(negedge ap_clk);
        ap_rst_n = 1'b1;

        repeat (5) @(posedge ap_clk);

        // Program source pointer: 0x1000
        axi_write_ptr(SRC_LO_ADDR, SRC_BASE[31:0]);
        axi_write_ptr(SRC_HI_ADDR, SRC_BASE[63:32]);

        // Program destination pointer: 0x2000
        axi_write_ptr(DEST_LO_ADDR, DEST_BASE[31:0]);
        axi_write_ptr(DEST_HI_ADDR, DEST_BASE[63:32]);

        // One FFT frame
        axi_write_main(COUNT_ADDR, 32'd1);

        // inverse = 1
        axi_write_main(INV_ADDR, 32'd1);

        // Start
        axi_write_main(CTRL_ADDR, 32'h0000_0001);

        $display("[%0t] FFT started", $time);

        // Wait for ap_done (control register bit 1)
        axi_write_main(CTRL_ADDR, 32'h0000_0000);

        // Poll the control register using AXI-Lite read
        // (read task is provided below)
        wait_done();

        $display("[%0t] FFT completed", $time);

        output_file = $fopen(
    "D:/CRIP-system/ifft/results/ifft_output_vectors.txt", "w"
);

	if (output_file == 0)
    $fatal(1, "ERROR: Could not open output file");

	$display("[%0t] Writing IFFT output...", $time);

	for (i = 0; i < N; i = i + 1) begin
   	 $fdisplay(output_file, "%08h %08h",
              mem[1024+i][31:0],   // Real: low 32 bits
              mem[1024+i][63:32]); // Imaginary: high 32 bits
	end

	$fclose(output_file);

	$display("[%0t] Output file successfully written.", $time);
	$finish;
    end

    // ---------------------------------------------------------
    // Poll ap_done using main AXI-Lite read
    // ---------------------------------------------------------
    task automatic wait_done;
        reg done;
    begin
        done = 1'b0;

        while (!done) begin
            @(negedge ap_clk);
            s_axi_control_ARADDR  = CTRL_ADDR;
            s_axi_control_ARVALID = 1'b1;
            s_axi_control_RREADY  = 1'b1;

            do @(posedge ap_clk);
            while (!s_axi_control_ARREADY);

            @(negedge ap_clk);
            s_axi_control_ARVALID = 1'b0;

            do @(posedge ap_clk);
            while (!s_axi_control_RVALID);

            done = s_axi_control_RDATA[1];

            @(negedge ap_clk);
            s_axi_control_RREADY = 1'b0;

            repeat (2) @(posedge ap_clk);
        end
    end
    endtask

    // ---------------------------------------------------------
    // Timeout protection
    // ---------------------------------------------------------
    initial begin
        #5000000;
        $fatal(1, "TIMEOUT: FFT did not complete");
    end

endmodule