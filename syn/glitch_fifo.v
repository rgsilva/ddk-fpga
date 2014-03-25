`timescale 1 ns/100 ps
// Version: v11.0 11.0.0.23


module glitch_fifo(
       DATA,
       Q,
       WE,
       RE,
       WCLOCK,
       RCLOCK,
       FULL,
       EMPTY,
       RESET,
       AEMPTY,
       AFULL
    );
input  [47:0] DATA;
output [47:0] Q;
input  WE;
input  RE;
input  WCLOCK;
input  RCLOCK;
output FULL;
output EMPTY;
input  RESET;
output AEMPTY;
output AFULL;

    wire WEBP, RESETP, CLKAP, WRITE_FSTOP_ENABLE, WRITE_ENABLE_I, 
        READ_ESTOP_ENABLE, READ_ENABLE_I, \FULLX_I[0] , \EMPTYX_I[0] , 
        \AFULLX_I[0] , \AEMPTYX_I[0] , \FULLX_I[1] , \EMPTYX_I[1] , 
        \AFULLX_I[1] , \AEMPTYX_I[1] , \FULLX_I[2] , \EMPTYX_I[2] , 
        \AFULLX_I[2] , \AEMPTYX_I[2] , OR2_1_Y, OR2_2_Y, OR2_0_Y, 
        OR2_3_Y, VCC, GND;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    
    OR2 OR2_EMPTY (.A(OR2_2_Y), .B(\EMPTYX_I[2] ), .Y(EMPTY));
    INV RCLKBUBBLE (.A(RCLOCK), .Y(CLKAP));
    NAND2A WRITE_AND (.A(WEBP), .B(WRITE_FSTOP_ENABLE), .Y(
        WRITE_ENABLE_I));
    OR2 OR2_FULL (.A(OR2_3_Y), .B(\FULLX_I[2] ), .Y(FULL));
    OR2 OR2_3 (.A(\FULLX_I[0] ), .B(\FULLX_I[1] ), .Y(OR2_3_Y));
    OR2 OR2_AEMPTY (.A(OR2_0_Y), .B(\AEMPTYX_I[2] ), .Y(AEMPTY));
    FIFO4K18 \FIFOBLOCK[2]  (.AEVAL11(GND), .AEVAL10(GND), .AEVAL9(GND)
        , .AEVAL8(GND), .AEVAL7(GND), .AEVAL6(GND), .AEVAL5(GND), 
        .AEVAL4(VCC), .AEVAL3(GND), .AEVAL2(GND), .AEVAL1(GND), 
        .AEVAL0(GND), .AFVAL11(VCC), .AFVAL10(VCC), .AFVAL9(VCC), 
        .AFVAL8(VCC), .AFVAL7(VCC), .AFVAL6(VCC), .AFVAL5(VCC), 
        .AFVAL4(VCC), .AFVAL3(GND), .AFVAL2(GND), .AFVAL1(GND), 
        .AFVAL0(GND), .WD17(GND), .WD16(GND), .WD15(GND), .WD14(GND), 
        .WD13(GND), .WD12(GND), .WD11(DATA[47]), .WD10(DATA[46]), .WD9(
        DATA[45]), .WD8(DATA[44]), .WD7(DATA[43]), .WD6(DATA[42]), 
        .WD5(DATA[41]), .WD4(DATA[40]), .WD3(DATA[39]), .WD2(DATA[38]), 
        .WD1(DATA[37]), .WD0(DATA[36]), .WW0(GND), .WW1(GND), .WW2(VCC)
        , .RW0(GND), .RW1(GND), .RW2(VCC), .RPIPE(GND), .WEN(
        WRITE_ENABLE_I), .REN(READ_ENABLE_I), .WBLK(GND), .RBLK(GND), 
        .WCLK(WCLOCK), .RCLK(CLKAP), .RESET(RESETP), .ESTOP(VCC), 
        .FSTOP(VCC), .RD17(), .RD16(), .RD15(), .RD14(), .RD13(), 
        .RD12(), .RD11(Q[47]), .RD10(Q[46]), .RD9(Q[45]), .RD8(Q[44]), 
        .RD7(Q[43]), .RD6(Q[42]), .RD5(Q[41]), .RD4(Q[40]), .RD3(Q[39])
        , .RD2(Q[38]), .RD1(Q[37]), .RD0(Q[36]), .FULL(\FULLX_I[2] ), 
        .AFULL(\AFULLX_I[2] ), .EMPTY(\EMPTYX_I[2] ), .AEMPTY(
        \AEMPTYX_I[2] ));
    NAND2 READ_ESTOP_GATE (.A(EMPTY), .B(VCC), .Y(READ_ESTOP_ENABLE));
    OR2 OR2_AFULL (.A(OR2_1_Y), .B(\AFULLX_I[2] ), .Y(AFULL));
    INV RESETBUBBLEA (.A(RESET), .Y(RESETP));
    NAND2 WRITE_FSTOP_GATE (.A(FULL), .B(VCC), .Y(WRITE_FSTOP_ENABLE));
    OR2 OR2_1 (.A(\AFULLX_I[0] ), .B(\AFULLX_I[1] ), .Y(OR2_1_Y));
    AND2 READ_AND (.A(RE), .B(READ_ESTOP_ENABLE), .Y(READ_ENABLE_I));
    OR2 OR2_2 (.A(\EMPTYX_I[0] ), .B(\EMPTYX_I[1] ), .Y(OR2_2_Y));
    FIFO4K18 \FIFOBLOCK[0]  (.AEVAL11(GND), .AEVAL10(GND), .AEVAL9(GND)
        , .AEVAL8(GND), .AEVAL7(GND), .AEVAL6(GND), .AEVAL5(GND), 
        .AEVAL4(VCC), .AEVAL3(GND), .AEVAL2(GND), .AEVAL1(GND), 
        .AEVAL0(GND), .AFVAL11(VCC), .AFVAL10(VCC), .AFVAL9(VCC), 
        .AFVAL8(VCC), .AFVAL7(VCC), .AFVAL6(VCC), .AFVAL5(VCC), 
        .AFVAL4(VCC), .AFVAL3(GND), .AFVAL2(GND), .AFVAL1(GND), 
        .AFVAL0(GND), .WD17(DATA[17]), .WD16(DATA[16]), .WD15(DATA[15])
        , .WD14(DATA[14]), .WD13(DATA[13]), .WD12(DATA[12]), .WD11(
        DATA[11]), .WD10(DATA[10]), .WD9(DATA[9]), .WD8(DATA[8]), .WD7(
        DATA[7]), .WD6(DATA[6]), .WD5(DATA[5]), .WD4(DATA[4]), .WD3(
        DATA[3]), .WD2(DATA[2]), .WD1(DATA[1]), .WD0(DATA[0]), .WW0(
        GND), .WW1(GND), .WW2(VCC), .RW0(GND), .RW1(GND), .RW2(VCC), 
        .RPIPE(GND), .WEN(WRITE_ENABLE_I), .REN(READ_ENABLE_I), .WBLK(
        GND), .RBLK(GND), .WCLK(WCLOCK), .RCLK(CLKAP), .RESET(RESETP), 
        .ESTOP(VCC), .FSTOP(VCC), .RD17(Q[17]), .RD16(Q[16]), .RD15(
        Q[15]), .RD14(Q[14]), .RD13(Q[13]), .RD12(Q[12]), .RD11(Q[11]), 
        .RD10(Q[10]), .RD9(Q[9]), .RD8(Q[8]), .RD7(Q[7]), .RD6(Q[6]), 
        .RD5(Q[5]), .RD4(Q[4]), .RD3(Q[3]), .RD2(Q[2]), .RD1(Q[1]), 
        .RD0(Q[0]), .FULL(\FULLX_I[0] ), .AFULL(\AFULLX_I[0] ), .EMPTY(
        \EMPTYX_I[0] ), .AEMPTY(\AEMPTYX_I[0] ));
    FIFO4K18 \FIFOBLOCK[1]  (.AEVAL11(GND), .AEVAL10(GND), .AEVAL9(GND)
        , .AEVAL8(GND), .AEVAL7(GND), .AEVAL6(GND), .AEVAL5(GND), 
        .AEVAL4(VCC), .AEVAL3(GND), .AEVAL2(GND), .AEVAL1(GND), 
        .AEVAL0(GND), .AFVAL11(VCC), .AFVAL10(VCC), .AFVAL9(VCC), 
        .AFVAL8(VCC), .AFVAL7(VCC), .AFVAL6(VCC), .AFVAL5(VCC), 
        .AFVAL4(VCC), .AFVAL3(GND), .AFVAL2(GND), .AFVAL1(GND), 
        .AFVAL0(GND), .WD17(DATA[35]), .WD16(DATA[34]), .WD15(DATA[33])
        , .WD14(DATA[32]), .WD13(DATA[31]), .WD12(DATA[30]), .WD11(
        DATA[29]), .WD10(DATA[28]), .WD9(DATA[27]), .WD8(DATA[26]), 
        .WD7(DATA[25]), .WD6(DATA[24]), .WD5(DATA[23]), .WD4(DATA[22]), 
        .WD3(DATA[21]), .WD2(DATA[20]), .WD1(DATA[19]), .WD0(DATA[18]), 
        .WW0(GND), .WW1(GND), .WW2(VCC), .RW0(GND), .RW1(GND), .RW2(
        VCC), .RPIPE(GND), .WEN(WRITE_ENABLE_I), .REN(READ_ENABLE_I), 
        .WBLK(GND), .RBLK(GND), .WCLK(WCLOCK), .RCLK(CLKAP), .RESET(
        RESETP), .ESTOP(VCC), .FSTOP(VCC), .RD17(Q[35]), .RD16(Q[34]), 
        .RD15(Q[33]), .RD14(Q[32]), .RD13(Q[31]), .RD12(Q[30]), .RD11(
        Q[29]), .RD10(Q[28]), .RD9(Q[27]), .RD8(Q[26]), .RD7(Q[25]), 
        .RD6(Q[24]), .RD5(Q[23]), .RD4(Q[22]), .RD3(Q[21]), .RD2(Q[20])
        , .RD1(Q[19]), .RD0(Q[18]), .FULL(\FULLX_I[1] ), .AFULL(
        \AFULLX_I[1] ), .EMPTY(\EMPTYX_I[1] ), .AEMPTY(\AEMPTYX_I[1] ));
    OR2 OR2_0 (.A(\AEMPTYX_I[0] ), .B(\AEMPTYX_I[1] ), .Y(OR2_0_Y));
    INV WEBUBBLEA (.A(WE), .Y(WEBP));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule

// _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


// _GEN_File_Contents_

// Version:11.0.0.23
// ACTGENU_CALL:1
// BATCH:T
// FAM:ProASIC3
// OUTFORMAT:VERILOG
// LPMTYPE:LPM_FIFO
// LPM_HINT:NONE
// INSERT_PAD:NO
// INSERT_IOREG:NO
// GEN_BHV_VHDL_VAL:F
// GEN_BHV_VERILOG_VAL:F
// MGNTIMER:F
// MGNCMPL:F
// DESDIR:D:/ddk-fpga/syn/ddk_smartgen\glitch_fifo
// GEN_BEHV_MODULE:F
// SMARTGEN_DIE:UM4X2M1N
// SMARTGEN_PACKAGE:vq100
// AGENIII_IS_SUBPROJECT_LIBERO:F
// WWIDTH:48
// RWIDTH:48
// WDEPTH:256
// RDEPTH:256
// WE_POLARITY:1
// RE_POLARITY:1
// RCLK_EDGE:FALL
// WCLK_EDGE:RISE
// PMODE1:0
// FLAGS:STATIC
// AFVAL:255
// AEVAL:1
// ESTOP:NO
// FSTOP:NO
// AFVAL:255
// AEVAL:1
// AFFLAG_UNITS:WW
// AEFLAG_UNITS:RW
// DATA_IN_PN:DATA
// DATA_OUT_PN:Q
// WE_PN:WE
// RE_PN:RE
// WCLOCK_PN:WCLOCK
// RCLOCK_PN:RCLOCK
// ACLR_PN:RESET
// FF_PN:FULL
// EF_PN:EMPTY
// AF_PN:AFULL
// AE_PN:AEMPTY
// AF_PORT_PN:AFVAL
// AE_PORT_PN:AEVAL
// RESET_POLARITY:1

// _End_Comments_

