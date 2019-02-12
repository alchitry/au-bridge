`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2017 02:35:47 PM
// Design Name: 
// Module Name: sst_flash
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


module sst_flash(
    input clk,
    input rst,
    inout [3:0] sio,
    output reg cs,
    output sck
    );
    
  wire erase_select;
  wire erase_shift;

  wire write_full;
  wire write_din;
  wire write_empty;
  wire [7:0] write_dout;
  reg write_en;
  wire [7:0] wm;
  
  wire read_full;
  reg [7:0] read_din;
  wire [7:0] read_din_mirror;
  reg read_en;
  wire read_dout;
  
  wire tck;
  wire write_sel;
  wire read_sel;
  wire shift;
  wire capture;
  wire reset_tap;
  reg [3:0] tck_d, tck_q;
  reg [1:0] tck_e_d, tck_e_q;
  reg [3:0] write_sel_d, write_sel_q;
  reg [3:0] read_sel_d, read_sel_q;
  reg [3:0] shift_d, shift_q;
  reg [3:0] write_din_d, write_din_q;
  
  reg [1:0] out_ct_d, out_ct_q;

  assign write_dout = {wm[0], wm[1], wm[2], wm[3], wm[4], wm[5], wm[6], wm[7]};
  assign read_din_mirror = {read_din[0], read_din[1], read_din[2], read_din[3], read_din[4], read_din[5], read_din[6], read_din[7]};
  
  // status register
  BSCANE2 #(
    .JTAG_CHAIN(1) // Value for USER command
    )
    BSCANE2_1_inst (
    .CAPTURE(), // 1-bit output: CAPTURE output from TAP controller.
    .DRCK(), // 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or
    // SHIFT are asserted.
    .RESET(reset_tap), // 1-bit output: Reset output for TAP controller.
    .RUNTEST(), // 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
    .SEL(erase_select), // 1-bit output: USER instruction active output.
    .SHIFT(erase_shift), // 1-bit output: SHIFT output from TAP controller.
    .TCK(), // 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
    .TDI(), // 1-bit output: Test Data Input (TDI) output from TAP controller.
    .TMS(), // 1-bit output: Test Mode Select output. Fabric connection to TAP.
    .UPDATE(), // 1-bit output: UPDATE output from TAP controller
    .TDO(0) // 1-bit input: Test Data Output (TDO) input for USER function.
  );
  
  // write register
  BSCANE2 #(
    .JTAG_CHAIN(2) // Value for USER command
    )
    BSCANE2_2_inst (
    .CAPTURE(), // 1-bit output: CAPTURE output from TAP controller.
    .DRCK(), // 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or
    // SHIFT are asserted.
    .RESET(), // 1-bit output: Reset output for TAP controller.
    .RUNTEST(), // 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
    .SEL(write_sel), // 1-bit output: USER instruction active output.
    .SHIFT(shift), // 1-bit output: SHIFT output from TAP controller.
    .TCK(tck), // 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
    .TDI(write_din), // 1-bit output: Test Data Input (TDI) output from TAP controller.
    .TMS(), // 1-bit output: Test Mode Select output. Fabric connection to TAP.
    .UPDATE(), // 1-bit output: UPDATE output from TAP controller
    .TDO(write_full) // 1-bit input: Test Data Output (TDO) input for USER function.
  );

  //read register
  BSCANE2 #(
    .JTAG_CHAIN(3) // Value for USER command
    )
    BSCANE2_3_inst (
    .CAPTURE(), // 1-bit output: CAPTURE output from TAP controller.
    .DRCK(), // 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or
    // SHIFT are asserted.
    .RESET(), // 1-bit output: Reset output for TAP controller.
    .RUNTEST(), // 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
    .SEL(read_sel), // 1-bit output: USER instruction active output.
    .SHIFT(), // 1-bit output: SHIFT output from TAP controller.
    .TCK(), // 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
    .TDI(), // 1-bit output: Test Data Input (TDI) output from TAP controller.
    .TMS(), // 1-bit output: Test Mode Select output. Fabric connection to TAP.
    .UPDATE(), // 1-bit output: UPDATE output from TAP controller
    .TDO(read_dout) // 1-bit input: Test Data Output (TDO) input for USER function.
  );
  
  
  
  localparam INIT = 0;
  localparam EQIO = INIT+1;
  localparam IDLE = EQIO+1;
  localparam WAIT_CS = IDLE+1;
  localparam WAIT_BUSY = WAIT_CS+1;
  localparam WRITE_ENABLE = WAIT_BUSY+1;
  localparam CHIP_ERASE = WRITE_ENABLE+1;
  localparam WRITE_PAGE = CHIP_ERASE+1;
  localparam READ = WRITE_PAGE+1;
  localparam WRITE_CONFIG = READ+1;
  localparam RESET = WRITE_CONFIG+1;
  localparam DEAD = RESET+1;
  localparam GLOBAL_UNLOCK = DEAD+1;
  localparam WRITE_ENABLE_1BIT = GLOBAL_UNLOCK+1;
  
  localparam EQIO_CMD = 8'h38;
  localparam RDSR_CMD = 8'h05;
  localparam WREN_CMD = 8'h06;
  localparam CPER_CMD = 8'hC7;
  localparam PGWR_CMD = 8'h02;
  localparam HSRD_CMD = 8'h0B;
  localparam WWRB_CMD = 8'h42;
  localparam ULBPR_CMD = 8'h98;
  localparam RSTQIO_CMD = 8'hFF;
  localparam WRSR_CMD = 8'h01;
  
  localparam CONFIG_VALUES = 8'h0A;
  
  reg sio_en;
  reg [3:0] sio_val;
  assign sio = sio_en ? sio_val : 4'bzzzz;
  
  reg [3:0] state_d, state_q = INIT;
  reg [3:0] next_state_d, next_state_q;
  reg [3:0] busy_state_d, busy_state_q;
  reg [3:0] write_state_d, write_state_q;
  reg [9:0] bit_ctr_d, bit_ctr_q = 0;
  reg [7:0] data_d, data_q;
  reg sck_d, sck_q = 0;
  reg [7:0] status_d, status_q;
  
  reg [3:0] erase_flag_d, erase_flag_q;
  reg [3:0] reset_flag_d, reset_flag_q;
  
  reg [23:0] byte_count_d, byte_count_q;
  reg [9:0] delay_ctr_d, delay_ctr_q;
  reg cs_d, cs_q;
  reg [2:0] cs_delay_d, cs_delay_q;
  
  reg read_data_d, read_data_q;
  
  reg written_d, written_q = 0;
  
  assign sck = sck_q;
  
    fifo_write write_fifo (
    .srst(state_q == IDLE && !write_sel_q[3]),
    .clk(clk),
    .full(write_full),
    .din(write_din_q[3]),
    .wr_en(tck_e_q == 2'b01 && write_sel_q[3] && shift_q[3]),
    .empty(write_empty),
    .dout(wm),
    .rd_en(write_en)
  );
  
  fifo_read fifo_read (
    .srst(!read_sel_q[3]),
    .clk(clk),
    .full(read_full),
    .din(read_din_mirror),
    .wr_en(read_en),
    .empty(),
    .dout(read_dout),
    .rd_en(read_data_q && (out_ct_q == 2'b11))
  );
  
  always @* begin
    tck_e_d = {tck_e_q[0], &tck_q};
    
    read_data_d = (tck_e_q == 2'b10) && read_sel_q[3] && shift_q[3];
    
    if (!read_sel_q[3])
      out_ct_d = 0;
    else if (read_data_q && (out_ct_q != 2'b11))
      out_ct_d = out_ct_q + 2'd1;
    else
      out_ct_d = out_ct_q;
  
    written_d = written_q;
    write_en = 0;
    read_en = 0;
    read_din = 8'hxx;
    cs = 1;
    sio_val = 4'h0;
    sio_en = 1;
    sck_d = 0;
    bit_ctr_d = bit_ctr_q;
    state_d = state_q;
    next_state_d = next_state_q;
    data_d = data_q;
    status_d = status_q;
    write_state_d = write_state_q;
    busy_state_d = busy_state_q;
    delay_ctr_d = 0;
    cs_d = 0;
    cs_delay_d = cs_delay_q;
    
    byte_count_d = byte_count_q;
    
    reset_flag_d = {reset_flag_q[2:0], reset_tap}; 
    erase_flag_d = {erase_flag_q[2:0], erase_select & erase_shift};
    tck_d = {tck_q[2:0], tck};
    write_sel_d = {write_sel_q[2:0], write_sel};
    read_sel_d = {read_sel_q[2:0], read_sel};
    shift_d = {shift_q[2:0], shift};
    write_din_d = {write_din_q[2:0], write_din};
    
    case (state_q) 
    INIT: begin
      byte_count_d = 0;
      cs_delay_d = 0;
      sck_d = ~sck_q;
      bit_ctr_d = bit_ctr_q + 1;
      if (&bit_ctr_q) begin
        state_d = WAIT_CS;
        next_state_d = WRITE_ENABLE_1BIT;
        write_state_d = WRITE_CONFIG;
        
      end
    end
    
    WRITE_CONFIG: begin
      cs = 0;
      sck_d = ~sck_q;
      bit_ctr_d <= sck_q + bit_ctr_q;
      if (bit_ctr_q < 8)
        sio_val = {3'b111, WRSR_CMD[7-bit_ctr_q[3:0]]};
      else if (bit_ctr_q >= 16)
        sio_val = {3'b111, CONFIG_VALUES[7-bit_ctr_q[3:0]]};
      else
        sio_val = 4'b1110;
      
      if (bit_ctr_q == 23 && sck_q) begin
        next_state_d = EQIO;
        state_d = WAIT_CS;
      end
    end
    
    WRITE_ENABLE_1BIT: begin
        cs = 0;
        sck_d = ~sck_q;
        bit_ctr_d <= sck_q + bit_ctr_q;
        sio_val = {3'b111, WREN_CMD[7-bit_ctr_q[3:0]]};
        next_state_d = write_state_q;
        if (bit_ctr_q == 7 && sck_q == 1) 
          state_d = WAIT_CS;
    end
    
    GLOBAL_UNLOCK: begin
      cs = 0;
      sck_d = ~sck_q;
      bit_ctr_d <= sck_q + bit_ctr_q;
      sio_val = ULBPR_CMD[{~bit_ctr_q[0],2'b11}-:4];

    
      if (bit_ctr_q == 1 && sck_q) begin
        next_state_d = IDLE;
        state_d = WAIT_CS;
      end
    end
    
    EQIO: begin
      sck_d = ~sck_q;
      cs = 0;
      bit_ctr_d <= sck_q + bit_ctr_q;
      sio_val = {3'b111, EQIO_CMD[7-bit_ctr_q[3:0]]};
      if (bit_ctr_q == 8 && sck_q == 0) begin
        sck_d = 0;
        write_state_d = GLOBAL_UNLOCK;
        busy_state_d = WRITE_ENABLE;
        next_state_d = WAIT_BUSY;
        state_d = WAIT_CS;
      end
    end
    
    WAIT_CS: begin
      sio_en = 0;
      bit_ctr_d = 0;
      sck_d = 0;
      cs = cs_q;
      cs_d = 1;
      cs_delay_d = cs_delay_q + 1;
      if (& cs_delay_q) 
        state_d = next_state_q;
    end
    
    IDLE: begin
      bit_ctr_d = 0;
      sck_d = 0;
      
      
      if (erase_flag_q[3:2] == 2'b01) begin // rising edge of erase
        write_state_d = CHIP_ERASE;
        busy_state_d = WRITE_ENABLE;
        state_d = WAIT_BUSY;
      end else if (write_sel_q[3] & shift_q[3]) begin
        write_state_d = WRITE_PAGE;
        busy_state_d = WRITE_ENABLE;
        state_d = WAIT_BUSY;
      end else if (read_sel_q[3]) begin
        busy_state_d = READ;
        state_d = WAIT_BUSY;
      end else if (reset_flag_q[3]) begin
        if (written_q) begin
          busy_state_d = RESET;
          state_d = WAIT_BUSY;
        end
      end

    end
    
    WAIT_BUSY: begin
        cs = 0;
        next_state_d = busy_state_q;
        sck_d = ~sck_q;
        bit_ctr_d <= sck_q + bit_ctr_q;
        if (bit_ctr_q < 2) begin
          sio_val = RDSR_CMD[{~bit_ctr_q[0],2'b11}-:4];
        end else if (bit_ctr_q < 4)  begin
          sio_en = 0;
        end else begin
          sio_en = 0;
          if (sck_q == 1) begin
            data_d = {data_q[3:0], sio};
            if (bit_ctr_q == 5) begin
              bit_ctr_d = 4;
              status_d = {data_q[3:0], sio};
              if (~data_q[3]) // not busy
                state_d = WAIT_CS;
            end
          end
        end
    end
    
    WRITE_ENABLE: begin
        cs = 0;
        sck_d = ~sck_q;
        bit_ctr_d <= sck_q + bit_ctr_q;
        sio_val = WREN_CMD[{~bit_ctr_q[0],2'b11}-:4];
        next_state_d = write_state_q;
        if (bit_ctr_q == 1 && sck_q == 1) 
          state_d = WAIT_CS;
    end
    
    CHIP_ERASE: begin
        byte_count_d = 0;
        cs = 0;
        sck_d = ~sck_q;
        bit_ctr_d <= sck_q + bit_ctr_q;
        sio_val = CPER_CMD[{~bit_ctr_q[0],2'b11}-:4];
        next_state_d = IDLE;
        if (bit_ctr_q == 1 && sck_q == 1) 
          state_d = WAIT_CS;
    end
    
    WRITE_PAGE: begin
      cs = 0;
      written_d = 1;
      
      if (bit_ctr_q < 8) begin
        sck_d = ~sck_q;
        bit_ctr_d <= sck_q + bit_ctr_q;
        if (bit_ctr_q < 2) 
          sio_val = PGWR_CMD[{~bit_ctr_q[0],2'b11}-:4];
        else
          sio_val = byte_count_q[(((5-(bit_ctr_q[2:0]-2))<<2) | 24'b11)-:4];
      end else begin
        if (!write_empty) begin
          sck_d = ~sck_q;
          bit_ctr_d <= sck_q + bit_ctr_q;
          
          sio_val = write_dout[{~bit_ctr_q[0],2'b11}-:4];
          
          if (bit_ctr_q[0] && sck_q) begin
            write_en = 1;
            byte_count_d = byte_count_q + 1;
            if (&byte_count_q[7:0]) begin
              write_state_d = WRITE_PAGE;
              busy_state_d = WRITE_ENABLE;
              next_state_d = WAIT_BUSY;
              state_d = WAIT_CS;
            end
          end
        end else begin
          if (!(write_sel_q[3] & shift_q[3])) begin // nothing more to write
            delay_ctr_d = delay_ctr_q + 1;
            if (&delay_ctr_q) begin
              state_d = WAIT_CS;
              next_state_d = IDLE;
            end
          end
        end
      end
    end
    
    READ: begin
      cs = 0;
      
      if (!read_sel_q[3]) begin
        state_d = WAIT_CS;
        next_state_d = IDLE;
      end
      
      if (bit_ctr_q < 8) begin
        sck_d = ~sck_q;
        bit_ctr_d <= sck_q + bit_ctr_q;
        if (bit_ctr_q < 2) 
          sio_val = HSRD_CMD[{~bit_ctr_q[0],2'b11}-:4];
        else
          sio_val = 0;
      end else if (bit_ctr_q < 10) begin
        sio_en = 0; // dummy bytes
        sck_d = ~sck_q;
        bit_ctr_d <= sck_q + bit_ctr_q;
      end else begin
        sio_en = 0;
        if (!read_full) begin
          sck_d = ~sck_q;
          bit_ctr_d <= sck_q + bit_ctr_q;
          if (sck_q == 1) begin
            data_d = {data_q[3:0], sio};
            
            if (bit_ctr_q[0]) begin
              read_din = {data_q[3:0], sio};
              read_en = 1;
            end
          end
        end
      end
    end
    
    RESET: begin
      cs = 0;
      sck_d = ~sck_q;
      bit_ctr_d <= sck_q + bit_ctr_q;
      sio_val = RSTQIO_CMD[{~bit_ctr_q[0],2'b11}-:4];
      next_state_d = DEAD;
      if (bit_ctr_q == 1 && sck_q == 1) 
        state_d = WAIT_CS;
    end
    
    DEAD: begin
    
    end
    
    endcase
  
  end
  
  always @(posedge clk) begin
    if (rst) begin
      state_q <= INIT;
      written_q <= 0;
    end else begin
      state_q <= state_d;
      written_q <= written_d;
    end
 
    next_state_q <= next_state_d;
    bit_ctr_q <= bit_ctr_d;
    sck_q <= sck_d;
    data_q <= data_d;
    status_q <= status_d;
    write_state_q <= write_state_d;
    busy_state_q <= busy_state_d;
    erase_flag_q <= erase_flag_d;
    tck_q <= tck_d;
    read_sel_q <= read_sel_d;
    write_sel_q <= write_sel_d;
    shift_q <= shift_d;
    write_din_q <= write_din_d;
    byte_count_q <= byte_count_d;
    delay_ctr_q <= delay_ctr_d;
    cs_q <= cs_d;
    out_ct_q <= out_ct_d;
    read_data_q <= read_data_d;
    tck_e_q <= tck_e_d;
    reset_flag_q <= reset_flag_d;
    cs_delay_q <= cs_delay_d;
  end
  


endmodule
