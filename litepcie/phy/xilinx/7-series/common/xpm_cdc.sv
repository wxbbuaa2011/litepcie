//------------------------------------------------------------------------------
//  (c) Copyright 2015 Xilinx, Inc. All rights reserved.
//
//  This file contains confidential and proprietary information
//  of Xilinx, Inc. and is protected under U.S. and
//  international copyright and other intellectual property
//  laws.
//
//  DISCLAIMER
//  This disclaimer is not a license and does not grant any
//  rights to the materials distributed herewith. Except as
//  otherwise provided in a valid license issued to you by
//  Xilinx, and to the maximum extent permitted by applicable
//  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//  (2) Xilinx shall not be liable (whether in contract or tort,
//  including negligence, or under any other theory of
//  liability) for any loss or damage of any kind or nature
//  related to, arising under or in connection with these
//  materials, including for any direct, or any indirect,
//  special, incidental, or consequential loss or damage
//  (including loss of data, profits, goodwill, or any type of
//  loss or damage suffered as a result of any action brought
//  by a third party) even if such damage or loss was
//  reasonably foreseeable or Xilinx had been advised of the
//  possibility of the same.
//
//  CRITICAL APPLICATIONS
//  Xilinx products are not designed or intended to be fail-
//  safe, or for use in any application requiring fail-safe
//  performance, such as life-support or safety devices or
//  systems, Class III medical devices, nuclear facilities,
//  applications related to the deployment of airbags, or any
//  other applications that could lead to death, personal
//  injury, or severe property or environmental damage
//  (individually and collectively, "Critical
//  Applications"). Customer assumes the sole risk and
//  liability of any use of Xilinx products in Critical
//  Applications, subject only to applicable laws and
//  regulations governing limitations on product liability.
//
//  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//  PART OF THIS FILE AT ALL TIMES.
//------------------------------------------------------------------------------

// ***************************
// * DO NOT MODIFY THIS FILE *
// ***************************

`timescale 1ps/1ps

`default_nettype none

// -------------------------------------------------------------------------------------------------------------------
// Macro definitions.  Only to be used by xpm_cdc_* modules.
// -------------------------------------------------------------------------------------------------------------------

// Define Xilinx Synchronous Register.  Only to be used by xpm_cdc_* modules.
`define XPM_XSRREG(clk, reset_p, q, d, rstval)   \
  always @(posedge clk) begin                    \
    if (reset_p == 1'b1)                         \
      q <= rstval;                               \
    else                                         \
      q <= d;                                    \
  end

// Define Xilinx Synchronous Register with Enable.  Only to be used by xpm_cdc_* modules.
`define XPM_XSRREGEN(clk, reset_p, q, d, en, rstval)   \
  always @(posedge clk) begin                          \
    if (reset_p == 1'b1)                               \
      q <= rstval;                                     \
    else                                               \
      if (en == 1'b1)                                  \
        q <= d;                                        \
  end

// Define Xilinx Asynchronous Register. Only to be used by xpm_cdc_* modules.
`define XPM_XARREG(clk, reset_p, q, d, rstval)   \
  always @(posedge clk or posedge reset_p)       \
  begin                                          \
    if (reset_p == 1'b1)                         \
      q <= rstval;                               \
    else                                         \
      q <= d;                                    \
  end

//==================================================================================================================

  // Define Xilinx Synchronous Register.  Only to be used by xpm_cdc_* modules.
`define XPM_XSRREG_INIT(clk, reset_p, q, d, rstval, gsr_asserted, gsr_init_val) \
  always @(gsr_asserted) begin                                                  \
    if (gsr_asserted)                                                           \
      force q = gsr_init_val;                                                   \
    else                                                                        \
      release q;                                                                \
  end                                                                           \
                                                                                \
  always @(posedge clk) begin                                                   \
    if (reset_p == 1'b1)                                                        \
      q <= rstval;                                                              \
    else                                                                        \
      q <= d;                                                                   \
  end

// Define Xilinx Synchronous Register with Enable.  Only to be used by xpm_cdc_* modules.
`define XPM_XSRREGEN_INIT(clk, reset_p, q, d, en, rstval, gsr_asserted, gsr_init_val) \
  always @(gsr_asserted) begin                                                        \
    if (gsr_asserted)                                                                 \
      force q = gsr_init_val;                                                         \
    else                                                                              \
      release q;                                                                      \
  end                                                                                 \
                                                                                      \
  always @(posedge clk) begin                                                         \
    if (reset_p == 1'b1)                                                              \
      q <= rstval;                                                                    \
    else                                                                              \
      if (en == 1'b1)                                                                 \
        q <= d;                                                                       \
  end

// Define Xilinx Asynchronous Register. Only to be used by xpm_cdc_* modules.
`define XPM_XARREG_INIT(clk, reset_p, q, d, rstval, gsr_asserted, gsr_init_val) \
  always @(gsr_asserted or reset_p)                                             \
    if (gsr_asserted)                                                           \
      force q = gsr_init_val;                                                   \
    else if (reset_p === 1'b1)                                                  \
      force q = ~gsr_init_val;                                                  \
    else if (reset_p === 1'bx)                                                  \
      force q = 1'bx;                                                           \
    else                                                                        \
      release q;                                                                \
                                                                                \
  always @(posedge clk or posedge reset_p)                                      \
  begin                                                                         \
    if (reset_p == 1'b1)                                                        \
      q <= rstval;                                                              \
    else                                                                        \
      q <= d;                                                                   \
  end

//********************************************************************************************************************
//********************************************************************************************************************
//********************************************************************************************************************

// -------------------------------------------------------------------------------------------------------------------
// Single-bit Synchronizer
// -------------------------------------------------------------------------------------------------------------------
(* XPM_MODULE = "TRUE", XPM_CDC = "SINGLE", KEEP_HIERARCHY = "TRUE" *)
module xpm_cdc_single #(
  // Module parameters
  parameter integer DEST_SYNC_FF    = 4,
  parameter integer INIT_SYNC_FF    = 0,
  parameter integer SIM_ASSERT_CHK  = 0,
  parameter integer SRC_INPUT_REG   = 1,
  parameter integer VERSION         = 0
) (
  // Module ports
  input  wire         src_clk,
  input  wire         src_in,
  input  wire         dest_clk,
  output wire         dest_out
);

  // -------------------------------------------------------------------------------------------------------------------
  // Configuration DRCs
  // -------------------------------------------------------------------------------------------------------------------
  initial begin : config_drc_single
    reg drc_err_flag;
    drc_err_flag = 0;

    if ((DEST_SYNC_FF < 2) || (DEST_SYNC_FF > 10)) begin
       $error("[%s %0d-%0d] DEST_SYNC_FF (%0d) value is outside of valid range of 2-10. %m", "XPM_CDC", 1, 2, DEST_SYNC_FF);
      drc_err_flag = 1;
    end

    if (!(INIT_SYNC_FF==0) && !(INIT_SYNC_FF==1)) begin
       $error("[%s %0d-%0d] INIT_SYNC_FF (%0d) is outside of valid range. %m", "XPM_CDC", 1, 5, INIT_SYNC_FF);
      drc_err_flag = 1;
    end

    if (!(SRC_INPUT_REG == 0) && !(SRC_INPUT_REG == 1)) begin
       $error("[%s %0d-%0d] SRC_INPUT_REG (%0d) value is outside of valid range. %m", "XPM_CDC", 1, 3, SRC_INPUT_REG);
      drc_err_flag = 1;
    end

    if (!(SIM_ASSERT_CHK==0) && !(SIM_ASSERT_CHK==1)) begin
       $error("[%s %0d-%0d] SIM_ASSERT_CHK (%0d) value is outside of valid range. %m", "XPM_CDC", 1, 4, SIM_ASSERT_CHK);
      drc_err_flag = 1;
    end

    if (!(VERSION == 0)) begin
      $error("[%s %0d-%0d] VERSION (%0d) value is outside of valid range. %m", "XPM_CDC", 1, 1, VERSION);
      drc_err_flag = 1;
    end

    if (drc_err_flag == 1)
      #1 $finish;
  end : config_drc_single

  // Set Asynchronous Register property on synchronizers
  (* XPM_CDC = "SINGLE", ASYNC_REG = "TRUE" *) reg [DEST_SYNC_FF-1:0] syncstages_ff;

  // -------------------------------------------------------------------------------------------------------------------
  // Simulation only variable and signal assignment
  // -------------------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  `ifdef VCS
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef INCA
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef MODEL_TECH
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef XILINX_SIMULATOR
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef _VCP
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  // synthesis translate_on

  reg  src_ff;
  wire src_inqual;
  wire async_path_bit;

  assign dest_out       = syncstages_ff[DEST_SYNC_FF-1];
  assign async_path_bit = src_inqual;

  // Virtual mux:  Register at input optional.
  generate
  if (SRC_INPUT_REG) begin : extra_inreg
    assign src_inqual = src_ff;
  end : extra_inreg
  else begin : no_extra_inreg
    assign src_inqual = src_in;
  end : no_extra_inreg
  endgenerate

  // Instantiate Xilinx Synchronous Register
  `ifdef XPM_CDC_BHVSIM_ONLY
    if(INIT_SYNC_FF) begin
      `XPM_XSRREG_INIT(src_clk , 1'b0,  src_ff,        src_in,         1'b0, glblGSR_xpmcdc, 1'b0)
      `XPM_XSRREG_INIT(dest_clk, 1'b0,  syncstages_ff, { syncstages_ff[DEST_SYNC_FF-2:0], async_path_bit} , {DEST_SYNC_FF{1'b0}}, glblGSR_xpmcdc, 1'b0)
    end else begin
      `XPM_XSRREG(src_clk , 1'b0,  src_ff,        src_in,         1'b0)
      `XPM_XSRREG(dest_clk, 1'b0,  syncstages_ff, { syncstages_ff[DEST_SYNC_FF-2:0], async_path_bit} , {DEST_SYNC_FF{1'b0}})
    end
  `else
    `XPM_XSRREG(src_clk , 1'b0,  src_ff,        src_in,         1'b0)
    `XPM_XSRREG(dest_clk, 1'b0,  syncstages_ff, { syncstages_ff[DEST_SYNC_FF-2:0], async_path_bit} , {DEST_SYNC_FF{1'b0}})
  `endif

  // -------------------------------------------------------------------------------------------------------------------
  // Simulation constructs
  // -------------------------------------------------------------------------------------------------------------------
  // synthesis translate_off

  initial begin : sim_check
    #1;
    if (SIM_ASSERT_CHK == 1) begin : sim_xil_check
      `ifdef XILINX_SIMULATOR
        $warning("Vivado Simulator does not currently support the SystemVerilog Assertion syntax used within XPM_CDC.  \
Messages related to potential misuse will not be reported.");
      `endif
    end : sim_xil_check
  end : sim_check

  `ifndef XILINX_SIMULATOR
  //S_A1: To guarantee data is transfered into destination clock domain (asynchronous to source clock domain), input data
  //must be sampled at the minimum by 2 destination clock edges.
  if (SIM_ASSERT_CHK == 1) begin : min_sampling
    assume property (@(posedge dest_clk)
      !( $stable(src_in) ) |-> ##1 $stable(src_in) [*2])
    else
      $warning("[%s %s-%0d] Input data at %0t is not stable long enough to be sampled twice by the destination clock. \
Data in source domain may not transfer to destination clock domain.", "XPM_CDC_SINGLE", "S", 1, $time);
  end : min_sampling
  `endif

  // synthesis translate_on

endmodule : xpm_cdc_single


// -------------------------------------------------------------------------------------------------------------------
// Binary Bus Synchronizer
// -------------------------------------------------------------------------------------------------------------------
(* XPM_MODULE = "TRUE", XPM_CDC = "GRAY", KEEP_HIERARCHY = "TRUE" *)
module xpm_cdc_gray #(
  // Module parameters
  parameter integer DEST_SYNC_FF          = 4,
  parameter integer INIT_SYNC_FF          = 0,
  parameter integer REG_OUTPUT            = 0,
  parameter integer SIM_ASSERT_CHK        = 0,
  parameter integer SIM_LOSSLESS_GRAY_CHK = 0,
  parameter integer VERSION               = 0,
  parameter integer WIDTH                 = 2
) (
  // Module ports
  input  wire             src_clk,
  input  wire [WIDTH-1:0] src_in_bin,
  input  wire             dest_clk,
  output wire [WIDTH-1:0] dest_out_bin
);

  // -------------------------------------------------------------------------------------------------------------------
  // Configuration DRCs
  // -------------------------------------------------------------------------------------------------------------------
  initial begin : config_drc_gray
    reg drc_err_flag;
    drc_err_flag = 0;

    if ((DEST_SYNC_FF < 2) || (DEST_SYNC_FF > 10)) begin
       $error("[%s %0d-%0d] DEST_SYNC_FF (%0d) is outside of valid range of 2-10. %m", "XPM_CDC", 2, 2, DEST_SYNC_FF);
      drc_err_flag = 1;
    end

    if (!(INIT_SYNC_FF==0) && !(INIT_SYNC_FF==1)) begin
       $error("[%s %0d-%0d] INIT_SYNC_FF (%0d) is outside of valid range. %m", "XPM_CDC", 2, 7, INIT_SYNC_FF);
      drc_err_flag = 1;
    end

    if (!(REG_OUTPUT==0) && !(REG_OUTPUT==1)) begin
       $error("[%s %0d-%0d] REG_OUTPUT (%0d) is outside of valid range. %m", "XPM_CDC", 2, 6, REG_OUTPUT);
      drc_err_flag = 1;
    end

    if (!(SIM_ASSERT_CHK == 0) && !(SIM_ASSERT_CHK == 1)) begin
       $error("[%s %0d-%0d] SIM_ASSERT_CHK (%0d) is outside of valid range. %m", "XPM_CDC", 2, 4, SIM_ASSERT_CHK);
      drc_err_flag = 1;
    end

    if (SIM_LOSSLESS_GRAY_CHK>1) begin
       $error("[%s %0d-%0d] SIM_LOSSLESS_GRAY_CHK (%0d) is outside of valid range. %m", "XPM_CDC", 2, 5, SIM_LOSSLESS_GRAY_CHK);
      drc_err_flag = 1;
    end

    if (!(VERSION == 0)) begin
      $error("[%s %0d-%0d] VERSION (%0d) value is outside of valid range. %m", "XPM_CDC", 2, 1, VERSION);
      drc_err_flag = 1;
    end

    if ((WIDTH < 2) || (WIDTH > 32)) begin
       $error("[%s %0d-%0d] WIDTH (%0d) is outside of valid range of 2-32. %m", "XPM_CDC", 2, 3, WIDTH);
      drc_err_flag = 1;
    end

    if (drc_err_flag == 1)
      #1 $finish;
  end : config_drc_gray

  // -------------------------------------------------------------------------------------------------------------------
  // Simulation only variable and signal assignment
  // -------------------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  `ifdef VCS
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef INCA
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef MODEL_TECH
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef XILINX_SIMULATOR
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef _VCP
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  // synthesis translate_on

  // Set Asynchronous Register property on synchronizers
  (* XPM_CDC = "GRAY", ASYNC_REG = "TRUE" *) reg [WIDTH-1:0] dest_graysync_ff [DEST_SYNC_FF-1:0];

  `ifdef XPM_CDC_BHVSIM_ONLY
    if (INIT_SYNC_FF == 1) begin
      always @(glblGSR_xpmcdc)
        if (glblGSR_xpmcdc)
          force dest_graysync_ff = '{default:(0)};
        else
          release dest_graysync_ff;
    end
  `endif

  wire [WIDTH-1:0] gray_enc;
  reg  [WIDTH-1:0] binval;

  reg  [WIDTH-1:0] src_gray_ff;
  wire [WIDTH-1:0] synco_gray;
  wire [WIDTH-1:0] async_path;
  reg  [WIDTH-1:0] dest_out_bin_ff;

  always @(posedge dest_clk) begin
    dest_graysync_ff[0] <= async_path;

    for (int syncstage = 1; syncstage < DEST_SYNC_FF ;syncstage = syncstage + 1)
      dest_graysync_ff[syncstage] <= dest_graysync_ff [syncstage-1];
  end

  assign async_path = src_gray_ff;

  assign synco_gray = dest_graysync_ff[DEST_SYNC_FF-1];
  assign gray_enc = src_in_bin ^ {1'b0, src_in_bin[WIDTH-1:1]};

  // Convert gray code back to binary
  always_comb begin
    binval[WIDTH-1] = synco_gray[WIDTH-1];
    for (int j = WIDTH - 2; j >= 0; j = j - 1)
        binval[j] = binval[j+1] ^ synco_gray[j];
  end

  generate
  if(REG_OUTPUT) begin : reg_out
    assign dest_out_bin     = dest_out_bin_ff;
  end : reg_out
  else begin : comb_out
    assign dest_out_bin     = binval;
  end : comb_out
  endgenerate

  // Instantiate Xilinx Synchronous Register
  `ifdef XPM_CDC_BHVSIM_ONLY
    if(INIT_SYNC_FF) begin
      `XPM_XSRREG_INIT(src_clk, 1'b0,  src_gray_ff, gray_enc, {WIDTH{1'b0}}, glblGSR_xpmcdc, 1'b0)
      `XPM_XSRREG_INIT(dest_clk, 1'b0,  dest_out_bin_ff, binval, {WIDTH{1'b0}}, glblGSR_xpmcdc, 1'b0)
    end else begin
      `XPM_XSRREG(src_clk, 1'b0,  src_gray_ff, gray_enc, {WIDTH{1'b0}})
      `XPM_XSRREG(dest_clk, 1'b0,  dest_out_bin_ff, binval, {WIDTH{1'b0}})
    end
  `else
    `XPM_XSRREG(src_clk, 1'b0,  src_gray_ff, gray_enc, {WIDTH{1'b0}})
    `XPM_XSRREG(dest_clk, 1'b0,  dest_out_bin_ff, binval, {WIDTH{1'b0}})
  `endif

  // -------------------------------------------------------------------------------------------------------------------
  // Simulation constructs
  // -------------------------------------------------------------------------------------------------------------------
  // synthesis translate_off

  initial begin : sim_check
    #1;
    if (SIM_ASSERT_CHK == 1) begin : sim_xil_check
      `ifdef XILINX_SIMULATOR
        $warning("Vivado Simulator does not currently support the SystemVerilog Assertion syntax used within XPM_CDC.  \
Messages related to potential misuse will not be reported.");
      `endif
    end : sim_xil_check
  end : sim_check

  `ifndef XILINX_SIMULATOR
  localparam logic [WIDTH-1:0] VALONE = {WIDTH{1'b0}}+1;
  //To guarantee data is transfered into destination clock domain (asynchronous to source clock domain), input data
  //must be sampled at the minimum by 2 destination clock edges.
  if (SIM_ASSERT_CHK == 1) begin : min_sampling
    assume property (@(posedge dest_clk)
     !$stable(src_in_bin) |-> ##1 $stable(src_in_bin) [*2])
   else
     $warning("[%s %s-%0d] Input data at %0t is not stable long enough to be sampled twice by the destination clock. \
Data in source domain may not transfer to destination clock domain.", "XPM_CDC_GRAY", "S", 1, $time);
  end : min_sampling

  //Check that input only increments or decrements by one each time to avoid any loss of counter value being synchronized.
  if ((SIM_ASSERT_CHK == 1)||(SIM_LOSSLESS_GRAY_CHK == 1)) begin : chk_input_incdec
    assume property (@(posedge src_clk)
    (!$stable(src_in_bin) && !$isunknown($past(src_in_bin))) |->
     ( (src_in_bin == ($past(src_in_bin)+VALONE) ) || (src_in_bin == ($past(src_in_bin)-VALONE)) ) )
    else
      $error("[%s %s-%0d] Input data may be lost and may not be correctly synchronized.  src_in_bin at %0t is not \
incrementing or decrementing by one.  This violates the usage guidance for this module.  Please refer to the XPM_CDC \
documentation in the libraries guide.", "XPM_CDC_GRAY", "S", 2, $time);
  end : chk_input_incdec
  `endif

  // synthesis translate_on

endmodule : xpm_cdc_gray


// -------------------------------------------------------------------------------------------------------------------
// Pulse Transfer
// -------------------------------------------------------------------------------------------------------------------
// This is a module that takes a pulse from the source domain and converts it
// to a level to cross into the other domain, and then converting it back to a pulse
// in destination domain.
(* XPM_MODULE = "TRUE", XPM_CDC = "PULSE", KEEP_HIERARCHY = "TRUE" *)
module xpm_cdc_pulse #(
  parameter integer DEST_SYNC_FF    = 4,
  parameter integer INIT_SYNC_FF    = 0,
  parameter integer REG_OUTPUT      = 0,
  parameter integer RST_USED        = 1,
  parameter integer SIM_ASSERT_CHK  = 0,
  parameter integer VERSION         = 0
) (
  input  wire       src_clk,
  input  wire       src_pulse,
  input  wire       dest_clk,
  input  wire       src_rst,
  input  wire       dest_rst,
  output wire       dest_pulse
);

  // -------------------------------------------------------------------------------------------------------------------
  // Configuration DRCs
  // -------------------------------------------------------------------------------------------------------------------
  initial begin : config_drc_pulse
    reg drc_err_flag;
    drc_err_flag = 0;

    if ((DEST_SYNC_FF < 2) || (DEST_SYNC_FF > 10)) begin
       $error("[%s %0d-%0d] DEST_SYNC_FF (%0d) is outside of valid range of 2-10. %m", "XPM_CDC", 4, 2, DEST_SYNC_FF);
      drc_err_flag = 1;
    end

    if (!(INIT_SYNC_FF==0) && !(INIT_SYNC_FF==1)) begin
       $error("[%s %0d-%0d] INIT_SYNC_FF (%0d) is outside of valid range. %m", "XPM_CDC", 4, 6, INIT_SYNC_FF);
      drc_err_flag = 1;
    end

    if (!(REG_OUTPUT == 0) && !(REG_OUTPUT == 1)) begin
       $error("[%s %0d-%0d] REG_OUTPUT (%0d) value is outside of valid range. %m", "XPM_CDC", 4, 5, REG_OUTPUT);
      drc_err_flag = 1;
    end

    if (!(RST_USED == 0) && !(RST_USED == 1)) begin
       $error("[%s %0d-%0d] RST_USED (%0d) value is outside of valid range. %m", "XPM_CDC", 4, 3, RST_USED);
      drc_err_flag = 1;
    end

    if (!(SIM_ASSERT_CHK==0) && !(SIM_ASSERT_CHK==1)) begin
       $error("[%s %0d-%0d] SIM_ASSERT_CHK (%0d) is outside of valid range. %m", "XPM_CDC", 4, 4, SIM_ASSERT_CHK);
      drc_err_flag = 1;
    end

    if (!(VERSION == 0)) begin
      $error("[%s %0d-%0d] VERSION (%0d) value is outside of valid range. %m", "XPM_CDC", 4, 1, VERSION);
      drc_err_flag = 1;
    end

    if (drc_err_flag == 1)
      #1 $finish;
  end : config_drc_pulse

  // -------------------------------------------------------------------------------------------------------------------
  // Simulation only variable and signal assignment
  // -------------------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  `ifdef VCS
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef INCA
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef MODEL_TECH
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef XILINX_SIMULATOR
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef _VCP
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  // synthesis translate_on

  // If toggle flop is not initialized,then it can be un-known forever.
  // It is assumed that there is no loss of coverage either way.
  // For edge detect, we would want the logic to be more controlled.
  reg  src_level_ff = 1'b0;

  reg  src_in_ff;
  wire src_level_nxt;
  wire src_edge_det;
  wire src_sync_in;

  wire dest_sync_out;
  wire dest_event_nxt;
  reg  dest_event_ff;
  wire dest_sync_qual;

  wire src_rst_qual;
  wire dest_rst_qual;

  wire dest_pulse_int;
  reg  dest_pulse_ff;

  //Assignments
  assign src_edge_det   = src_pulse & ~src_in_ff;
  assign src_level_nxt  = src_level_ff ^ src_edge_det;
  assign src_sync_in    = src_level_ff;
  assign dest_event_nxt = dest_sync_qual;
  assign dest_pulse_int = dest_sync_qual ^ dest_event_ff;
  assign dest_sync_qual = dest_sync_out & ~dest_rst_qual;

  generate
  if(RST_USED) begin : use_rst
    assign src_rst_qual = src_rst;
    assign dest_rst_qual = dest_rst;
  end : use_rst
  else begin : no_rst
    assign src_rst_qual = 1'b0;
    assign dest_rst_qual = 1'b0;
  end : no_rst
  endgenerate

  generate
  if(REG_OUTPUT) begin : reg_out
    assign dest_pulse     = dest_pulse_ff;
  end : reg_out
  else begin : comb_out
    assign dest_pulse     = dest_pulse_int;
  end : comb_out
  endgenerate

  xpm_cdc_single # (
    .DEST_SYNC_FF   (DEST_SYNC_FF ),
    .INIT_SYNC_FF   (INIT_SYNC_FF ),
    .SRC_INPUT_REG  (0            ),
    .VERSION        (VERSION      )
  ) xpm_cdc_single_inst (
    .src_clk       (src_clk       ),
    .dest_clk      (dest_clk      ),
    .src_in        (src_sync_in   ),
    .dest_out      (dest_sync_out )
  );

  // Instantiate Xilinx Synchronous Register
  `ifdef XPM_CDC_BHVSIM_ONLY
    if(INIT_SYNC_FF) begin
      `XPM_XSRREG_INIT(src_clk,  src_rst_qual,   src_in_ff,     src_pulse,      1'b0, glblGSR_xpmcdc, 1'b0)
      `XPM_XSRREG_INIT(src_clk,  src_rst_qual,   src_level_ff,  src_level_nxt,  1'b0, glblGSR_xpmcdc, 1'b0)
      `XPM_XSRREG_INIT(dest_clk, dest_rst_qual,  dest_event_ff, dest_event_nxt, 1'b0, glblGSR_xpmcdc, 1'b0)
      `XPM_XSRREG_INIT(dest_clk, dest_rst_qual,  dest_pulse_ff, dest_pulse_int, 1'b0, glblGSR_xpmcdc, 1'b0)
    end else begin
      `XPM_XSRREG(src_clk,  src_rst_qual,   src_in_ff,     src_pulse,      1'b0)
      `XPM_XSRREG(src_clk,  src_rst_qual,   src_level_ff,  src_level_nxt,  1'b0)
      `XPM_XSRREG(dest_clk, dest_rst_qual,  dest_event_ff, dest_event_nxt, 1'b0)
      `XPM_XSRREG(dest_clk, dest_rst_qual,  dest_pulse_ff, dest_pulse_int, 1'b0)
    end
  `else
      `XPM_XSRREG(src_clk,  src_rst_qual,   src_in_ff,     src_pulse,      1'b0)
      `XPM_XSRREG(src_clk,  src_rst_qual,   src_level_ff,  src_level_nxt,  1'b0)
      `XPM_XSRREG(dest_clk, dest_rst_qual,  dest_event_ff, dest_event_nxt, 1'b0)
      `XPM_XSRREG(dest_clk, dest_rst_qual,  dest_pulse_ff, dest_pulse_int, 1'b0)
  `endif

  // -------------------------------------------------------------------------------------------------------------------
  // Simulation constructs
  // -------------------------------------------------------------------------------------------------------------------
  // synthesis translate_off

  initial begin : sim_check
    #1;
    if (SIM_ASSERT_CHK == 1) begin : sim_xil_check
      `ifdef XILINX_SIMULATOR
        $warning("Vivado Simulator does not currently support the SystemVerilog Assertion syntax used within XPM_CDC.  \
Messages related to potential misuse will not be reported.");
      `endif
    end : sim_xil_check
  end : sim_check

  `ifndef XILINX_SIMULATOR
  if (SIM_ASSERT_CHK == 1 && RST_USED == 1) begin : chk_rst
    //Verify that src_pulse doesn't change during source or dest reset
    assume property ( @(posedge src_clk)
      (($past(src_pulse) == 0) && (src_pulse==1)) |-> !src_rst )
    else
      $warning("[%s %s-%0d] Input should not change when src_rst is asserted.  Pulse transfer initiated at time %0t \
may fail.", "XPM_CDC_PULSE", "S", 1, $time);

    assume property ( @(posedge dest_clk)
      (($past(src_pulse) == 0) && (src_pulse==1)) |-> !dest_rst  )
    else
      $warning("[%s %s-%0d] Input should not change when dest_rst is asserted.  Pulse transfer initiated at time %0t \
may fail.", "XPM_CDC_PULSE", "S", 1, $time);
  end : chk_rst
  `endif

  // synthesis translate_on

endmodule : xpm_cdc_pulse

// -------------------------------------------------------------------------------------------------------------------
// Synchronous Reset Synchronizer
// -------------------------------------------------------------------------------------------------------------------
(* XPM_MODULE = "TRUE", XPM_CDC = "SYNC_RST", KEEP_HIERARCHY = "TRUE" *)
module xpm_cdc_sync_rst # (
  parameter integer DEST_SYNC_FF    = 4,
  parameter integer INIT            = 1,
  parameter integer INIT_SYNC_FF    = 0,
  parameter integer SIM_ASSERT_CHK  = 0,
  parameter integer VERSION         = 0
  ) (
  input  wire       src_rst,
  input  wire       dest_clk,
  output wire       dest_rst
);

  // -------------------------------------------------------------------------------------------------------------------
  // Configuration DRCs
  // -------------------------------------------------------------------------------------------------------------------
  initial begin : config_drc
    reg drc_err_flag;
    drc_err_flag = 0;

    if ((DEST_SYNC_FF < 2) || (DEST_SYNC_FF > 10)) begin
       $error("[%s %0d-%0d] DEST_SYNC_FF (%0d) is outside of valid range of 2-10. %m", "XPM_CDC", 6, 2, DEST_SYNC_FF);
      drc_err_flag = 1;
    end

    if (!(INIT == 0) && !(INIT == 1)) begin
       $error("[%s %0d-%0d] INIT (%0d) value is outside of valid range. %m", "XPM_CDC", 6, 3, INIT);
      drc_err_flag = 1;
    end

    if (!(INIT_SYNC_FF==0) && !(INIT_SYNC_FF==1)) begin
       $error("[%s %0d-%0d] INIT_SYNC_FF (%0d) is outside of valid range. %m", "XPM_CDC", 6, 5, INIT_SYNC_FF);
      drc_err_flag = 1;
    end

    if (!(SIM_ASSERT_CHK==0) && !(SIM_ASSERT_CHK==1)) begin
       $error("[%s %0d-%0d] SIM_ASSERT_CHK (%0d) is outside of valid range. %m", "XPM_CDC", 6, 4, SIM_ASSERT_CHK);
      drc_err_flag = 1;
    end

    if (!(VERSION == 0)) begin
      $error("[%s %0d-%0d] VERSION (%0d) value is outside of valid range. %m", "XPM_CDC", 6, 1, VERSION);
      drc_err_flag = 1;
    end

    if (drc_err_flag == 1)
      #1 $finish;
  end : config_drc

  // Define local parameter for settings
  localparam DEF_VAL        = (INIT == 1) ? 1'b1 : 1'b0;

  // Set asynchronous register property on synchronizers and initialize register with INIT value
  (* XPM_CDC = "SYNC_RST", ASYNC_REG = "TRUE" *) reg [DEST_SYNC_FF-1:0] syncstages_ff = {DEST_SYNC_FF{DEF_VAL}};

  // -------------------------------------------------------------------------------------------------------------------
  // Simulation only variable and signal assignment
  // -------------------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  `ifdef VCS
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc  = glbl.GSR;
  `endif
  `ifdef INCA
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc  = glbl.GSR;
  `endif
  `ifdef MODEL_TECH
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc  = glbl.GSR;
  `endif
  `ifdef XILINX_SIMULATOR
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc  = glbl.GSR;
  `endif
  `ifdef _VCP
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  // synthesis translate_on

  wire async_path_bit;

  assign dest_rst = syncstages_ff[DEST_SYNC_FF-1];
  assign async_path_bit = src_rst;

  // Instantiate Xilinx Synchronous Register
  `ifdef XPM_CDC_BHVSIM_ONLY
    if(INIT_SYNC_FF) begin
      `XPM_XSRREG_INIT(dest_clk, 1'b0,  syncstages_ff, { syncstages_ff[DEST_SYNC_FF-2:0], async_path_bit}, {DEST_SYNC_FF{1'b0}}, glblGSR_xpmcdc, {DEST_SYNC_FF{DEF_VAL}})
    end else begin
      `XPM_XSRREG(dest_clk, 1'b0,  syncstages_ff, { syncstages_ff[DEST_SYNC_FF-2:0], async_path_bit}, {DEST_SYNC_FF{1'b0}})
    end
  `else
      `XPM_XSRREG(dest_clk, 1'b0,  syncstages_ff, { syncstages_ff[DEST_SYNC_FF-2:0], async_path_bit}, {DEST_SYNC_FF{1'b0}})
  `endif

  // -------------------------------------------------------------------------------------------------------------------
  // Simulation constructs
  // -------------------------------------------------------------------------------------------------------------------
  // synthesis translate_off

  initial begin : sim_check
    #1;
    if (SIM_ASSERT_CHK == 1) begin : sim_xil_check
      `ifdef XILINX_SIMULATOR
        $warning("Vivado Simulator does not currently support the SystemVerilog Assertion syntax used within XPM_CDC.  \
Messages related to potential misuse will not be reported.");
      `endif
    end : sim_xil_check
  end : sim_check

  `ifndef XILINX_SIMULATOR
  //To guarantee data is transfered into destination clock domain (asynchronous to source clock domain), input data
  //must be sampled at the minimum by 2 destination clock edges.
  if (SIM_ASSERT_CHK == 1) begin : min_sampling
    assume property (@(posedge dest_clk)
    ! $stable(src_rst) |-> ##1 $stable(src_rst) [*2])
    else
      $warning("[%s %s-%0d] Input data at %0t is not stable long enough to be sampled twice by the destination clock. \
Reset from source domain may not transfer to destination clock domain.", "XPM_CDC_SYNC_RST", "S", 1, $time);
  end : min_sampling

  `endif

  // synthesis translate_on

endmodule : xpm_cdc_sync_rst

// -------------------------------------------------------------------------------------------------------------------
// Asynchronous Reset Synchronizer
// -------------------------------------------------------------------------------------------------------------------
(* XPM_MODULE = "TRUE", XPM_CDC = "ASYNC_RST", KEEP_HIERARCHY = "TRUE" *)
module xpm_cdc_async_rst # (
  parameter integer DEST_SYNC_FF    = 4,
  parameter integer INIT_SYNC_FF    = 0,
  parameter integer RST_ACTIVE_HIGH = 0,
  parameter integer VERSION         = 0
  ) (
  input  wire       src_arst,
  input  wire       dest_clk,
  output wire       dest_arst
);

  // -------------------------------------------------------------------------------------------------------------------
  // Configuration DRCs
  // -------------------------------------------------------------------------------------------------------------------
  initial begin : config_drc_async_rst
    reg drc_err_flag;
    drc_err_flag = 0;

    if ((DEST_SYNC_FF < 2) || (DEST_SYNC_FF > 10)) begin
       $error("[%s %0d-%0d] DEST_SYNC_FF (%0d) is outside of valid range of 2-10. %m", "XPM_CDC", 7, 2, DEST_SYNC_FF);
      drc_err_flag = 1;
    end

    if (!(INIT_SYNC_FF==0) && !(INIT_SYNC_FF==1)) begin
       $error("[%s %0d-%0d] INIT_SYNC_FF (%0d) is outside of valid range. %m", "XPM_CDC", 7, 4, INIT_SYNC_FF);
      drc_err_flag = 1;
    end

    if (!(RST_ACTIVE_HIGH == 0) && !(RST_ACTIVE_HIGH == 1)) begin
       $error("[%s %0d-%0d] RST_ACTIVE_HIGH (%0d) value is outside of valid range. %m", "XPM_CDC", 7, 3, RST_ACTIVE_HIGH);
      drc_err_flag = 1;
    end

    if (!(VERSION == 0)) begin
      $error("[%s %0d-%0d] VERSION (%0d) value is outside of valid range. %m", "XPM_CDC", 7, 1, VERSION);
      drc_err_flag = 1;
    end

    if (drc_err_flag == 1)
      #1 $finish;
  end : config_drc_async_rst

  // -------------------------------------------------------------------------------------------------------------------
  // Local parameter definitions
  // -------------------------------------------------------------------------------------------------------------------

  // Define local parameter for settings
  localparam DEF_VAL        = (RST_ACTIVE_HIGH == 1) ? 1'b0 : 1'b1;
  localparam INV_DEF_VAL    = (RST_ACTIVE_HIGH == 0) ? 1'b0 : 1'b1;

  // Set asynchronous register property on synchronizers and initialize register with default value
  (* XPM_CDC = "ASYNC_RST", ASYNC_REG = "TRUE" *) reg [DEST_SYNC_FF-1:0] arststages_ff = {DEST_SYNC_FF{DEF_VAL}};

  // -------------------------------------------------------------------------------------------------------------------
  // Simulation only variable and signal assignment
  // -------------------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  `ifdef VCS
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef INCA
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef MODEL_TECH
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef XILINX_SIMULATOR
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  `ifdef _VCP
    `define XPM_CDC_BHVSIM_ONLY
    tri0 glblGSR_xpmcdc = glbl.GSR;
  `endif
  // synthesis translate_on

  wire                    async_path_bit;
  wire                    reset_pol;
  wire                    reset_polo;

  assign reset_polo = arststages_ff[DEST_SYNC_FF-1];
  assign async_path_bit = (RST_ACTIVE_HIGH == 1) ? 1'b0 : 1'b1;
  assign reset_pol = src_arst ^ ~RST_ACTIVE_HIGH;
  assign dest_arst = reset_polo;

  // Instantiate Xilinx Asynchronous Clear Register
  `ifdef XPM_CDC_BHVSIM_ONLY
    if(INIT_SYNC_FF) begin
      `XPM_XARREG_INIT(dest_clk, reset_pol,  arststages_ff, { arststages_ff[DEST_SYNC_FF-2:0], async_path_bit}, {DEST_SYNC_FF{INV_DEF_VAL}}, glblGSR_xpmcdc, {DEST_SYNC_FF{DEF_VAL}})
      end else begin
      `XPM_XARREG(dest_clk, reset_pol,  arststages_ff, { arststages_ff[DEST_SYNC_FF-2:0], async_path_bit}, {DEST_SYNC_FF{INV_DEF_VAL}})
    end
  `else
      `XPM_XARREG(dest_clk, reset_pol,  arststages_ff, { arststages_ff[DEST_SYNC_FF-2:0], async_path_bit}, {DEST_SYNC_FF{INV_DEF_VAL}})
  `endif

endmodule : xpm_cdc_async_rst

`default_nettype wire

`undef XPM_XSRREG
`undef XPM_XSRREGEN
`undef XPM_XARREG
`undef XPM_XSRREG_INIT
`undef XPM_XSRREGEN_INIT
`undef XPM_XARREG_INIT
