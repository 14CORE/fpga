//
// Copyright 2014 Ettus Research LLC
//
`timescale 1ns/1ps

module radio_tb();
  /*********************************************
  ** User variables
  *********************************************/
  localparam CLOCK_FREQ = 200e6;  // MHz
  localparam RESET_TIME = 100;    // ns

  /*********************************************
  ** Helper Tasks
  *********************************************/
  `include "rfnoc_sim_lib.v" 

  /*********************************************
  ** DUT
  *********************************************/
  noc_block_radio_core inst_noc_block_radio_core
    (.bus_clk(clk), .bus_rst(rst),
     .ce_clk(clk), .ce_rst(rst),
     .i_tdata(i_tdata), .i_tlast(i_tlast), .i_tvalid(i_tvalid), .i_tready(i_tready),
     .o_tdata(o_tdata), .o_tlast(o_tlast), .o_tvalid(o_tvalid), .o_tready(o_tready),
     .rx(), .tx(), .db_gpio(), .fp_gpio(),
     .sen(), .sclk(), .mosi(), .miso(),
     .misc_outs(), .leds(),
     .pps(),
     .sync_dacs(),
     .debug());

  integer i,j;
  reg [63:0] payload = 64'd0;

   localparam FFT_SIZE=256;

   localparam SR_RX_BASE = 128+32;
   
  initial begin
    @(negedge rst);
    @(posedge clk);
    
    // Setup
    SendCtrlPacket(12'd0, 32'h0003_0000, {24'd0, SR_FLOW_CTRL_PKTS_PER_ACK_BASE, 32'h8000_0001});               // Command packet to set up flow control
    SendCtrlPacket(12'd0, 32'h0003_0000, {24'd0, SR_FLOW_CTRL_WINDOW_SIZE_BASE, 32'h0000_0FFF});                // Command packet to set up source control window size
    SendCtrlPacket(12'd0, 32'h0003_0000, {24'd0, SR_FLOW_CTRL_WINDOW_EN_BASE, 32'h0000_0001});                  // Command packet to set up source control window enable
    SendCtrlPacket(12'd0, 32'h0003_0000, {24'd0, SR_NEXT_DST_BASE, 32'h0000_0001});                     // Set next destination

    #1000;
    // Commands to receive
    SendCtrlPacket(12'd0, 32'h0003_0000, {24'd0, SR_RX_BASE + 4, 32'h0000_0020});   // Maxlen
    //SendCtrlPacket(12'd0, 32'h0003_0000, {24'd0, SR_RX_BASE + 5, 32'h0000_0001});   // SID -- do we need this?

    SendCtrlPacket(12'd0, 32'h0003_0000, {24'd0, SR_RX_BASE + 0, 32'h8000_0100});   // Command -- immediate, do 256 samples
    SendCtrlPacket(12'd0, 32'h0003_0000, {24'd0, SR_RX_BASE + 1, 32'h0000_0000});   // time[63:32]
    SendCtrlPacket(12'd0, 32'h0003_0000, {24'd0, SR_RX_BASE + 2, 32'h0000_0000});   // time[31:0], execute command

    //SendCtrlPacket(12'd0, 32'h0003_0000, {24'd0, SR_RX_BASE + 3, 32'h0000_0001});   // halt
     
    // Send 1/8th sample rate sine wave
    @(posedge clk);
    forever begin
      SendChdr(CHDR_DATA_PKT_TYPE, 0, j[11:0], FFT_SIZE*SC16_NUM_BYTES, {32'h0000_0001,32'h0001_0003}, 0);
      for (i = 0; i < (FFT_SIZE/RFNOC_CHDR_NUM_SC16_PER_LINE); i = i + 1) begin
        payload[63:48] = 4*i;
        payload[47:32] = 4*i+1;
        payload[31:16] = 4*i+2;
        payload[15: 0] = 4*i+3;
        SendPayload(payload,(i == (FFT_SIZE/RFNOC_CHDR_NUM_SC16_PER_LINE)-1)); // Assert tlast on final word
	 j=j+1;
	 
      end
    end
  end

   initial #1000000 $finish;
   
endmodule