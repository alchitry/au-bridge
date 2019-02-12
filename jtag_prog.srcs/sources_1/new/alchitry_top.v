`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2017 09:57:03 AM
// Design Name: 
// Module Name: alchitry_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alchitry_top(
    input clk,
    output reg [7:0] led,
    output cs,
    inout [3:0] sio
    );
    

    wire DRCK_LED;
    wire SEL_LED;
    wire SHIFT_LED;
    wire TDI_LED;
    wire TDO_LED;
    wire clko;
    wire locked;
    
    clk_wiz_0 clk_wiz (
      .clk_in1(clk),
      .clk_out1(clko),
      .locked(locked)
    );
    
    BSCANE2 #(
    .JTAG_CHAIN(4) // Value for USER command
    )
    BSCANE2_LED_inst (
    .CAPTURE(), // 1-bit output: CAPTURE output from TAP controller.
    .DRCK(DRCK_LED), // 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or
    // SHIFT are asserted.
    .RESET(), // 1-bit output: Reset output for TAP controller.
    .RUNTEST(), // 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
    .SEL(SEL_LED), // 1-bit output: USER instruction active output.
    .SHIFT(SHIFT_LED), // 1-bit output: SHIFT output from TAP controller.
    .TCK(), // 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
    .TDI(TDI_LED), // 1-bit output: Test Data Input (TDI) output from TAP controller.
    .TMS(), // 1-bit output: Test Mode Select output. Fabric connection to TAP.
    .UPDATE(), // 1-bit output: UPDATE output from TAP controller
    .TDO(TDO_LED) // 1-bit input: Test Data Output (TDO) input for USER function.
    );
    
    wire sck;
    
    STARTUPE2 startup (
      .CLK(0),
      .GSR(0),
      .GTS(0),
      .KEYCLEARB(1),
      .PACK(1),
      .PREQ(),
      .USRCCLKO(sck),
      .USRCCLKTS(0),
      .USRDONEO(0),
      .USRDONETS(1),
      .CFGCLK(),
      .CFGMCLK(),
      .EOS()
    );
      

    
    reg [7:0] ledr;
    
    assign TDO_LED = ledr[0];
    
    always @(posedge DRCK_LED) begin
        if (SEL_LED && SHIFT_LED) begin
          ledr <= {TDI_LED, ledr[7:1]};
        end
    end
    
    reg [24:0] ctr;
    
    always @(posedge clk) begin
      ctr <= ctr + 1;
      if (!(&ledr))
        led = 8'h55 << ctr[24];
      else
        led = ledr;
    end
    
    sst_flash sst (
      .clk(clk),
      .rst(!locked),
      .sio(sio),
      .cs(cs),
      .sck(sck)
    );
endmodule
