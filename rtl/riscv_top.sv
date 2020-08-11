`default_nettype none
module riscv_top
  (input wire clk, 
   input wire rstf,
   output reg reg_3_or
   );
    
   localparam DEPTH = 4096;
   
   
   //  wire        iBus_cmd_valid;
   //  wire        iBus_cmd_ready;
   //  wire [31:0] iBus_cmd_payload_pc;
   //  wire        iBus_rsp_ready;
   //  wire        iBus_rsp_err;
   //  wire [31:0] iBus_rsp_instr;
   // /* Data Bus */
   //  wire        dBus_cmd_valid;
   //  wire        dBus_cmd_ready;
   //  wire [31:0] dBus_cmd_payload_addr;
   //  wire [31:0] dBus_cmd_payload_data;
   //  wire [3:0]  dBus_cmd_payload_size;
   //  wire        dBus_cmd_payload_wr; //1 - write, 0 - read
   //  wire [31:0] dBus_rsp_data;
   //  wire        dBus_rsp_valid;
   //  wire        dBus_rsp_error;

  wire imem_read_cmd_valid;
  wire imem_write_cmd_valid;
  // output wire imem_data_valid;

  
  wire [31:0] imem_read_data;
  wire imem_read_data_valid;

  wire [31 : 0] imem_addr;
  wire [31:0] imem_write_data;
  wire imem_write_data_valid;
  wire [3:0] imem_write_data_size; // 1 for a byte; 0'b11 for 2 bytes and so on

  wire dmem_read_cmd_valid;
  wire dmem_write_cmd_valid;

  
  wire [31:0] dmem_read_data;
  wire dmem_read_data_valid;

  wire [31 : 0] dmem_addr; 
  wire [31:0] dmem_write_data;
  wire dmem_write_data_valid;
  wire [3:0] dmem_write_data_size;

    logic locked;
    logic sys_clk;


   
   localparam MEM0_INIT = "Z:/riscv-sv/c/counter/build/counter_mem0.bin";
   localparam MEM1_INIT = "Z:/riscv-sv/c/counter/build/counter_mem1.bin";
   localparam MEM2_INIT = "Z:/riscv-sv/c/counter/build/counter_mem2.bin";
   localparam MEM3_INIT = "Z:/riscv-sv/c/counter/build/counter_mem3.bin";

   (* mark_debug = "true" *) logic [31:0] reg_3;
   
   always @ (posedge sys_clk) begin
    if (!locked) begin
      reg_3_or <= 0;
    end else begin
      reg_3_or <= |reg_3;
    end
  end
   riscv riscv_0p
                (.sys_clk            (sys_clk),
                 .reset_n            (locked),
                 .imem_read_cmd_valid (imem_read_cmd_valid),
                 .imem_write_cmd_valid (imem_write_cmd_valid),
                 .imem_read_data (imem_read_data),
                 .imem_addr (imem_addr),
                 .dmem_read_cmd_valid (dmem_read_cmd_valid),
                 .dmem_write_cmd_valid (dmem_write_cmd_valid),
                 .dmem_read_data (dmem_read_data),
                 .dmem_addr (dmem_addr),
                 .dmem_write_data (dmem_write_data),
                 .dmem_write_data_valid (dmem_write_data_valid),
                 .dmem_write_data_size (dmem_write_data_size),
                 .reg_3           (reg_3)

                 );

   // dpram_32_ba 
   //   #(.DEPTH(DEPTH),
   //     .MEM0_INIT(MEM0_INIT),
   //     .MEM1_INIT(MEM1_INIT),
   //     .MEM2_INIT(MEM2_INIT),
   //     .MEM3_INIT(MEM3_INIT)
   //     ) imem_dmem
   //     (.t_p0_valid(iBus_cmd_valid),
   //      .t_p0_ready(iBus_cmd_ready),
   //      .t_p0_we(1'b0),
   //      .t_p0_addr(iBus_cmd_payload_pc[$clog2(DEPTH)+2-1:0]),
   //      .t_p0_data(32'b0),
   //      .t_p0_mask(4'h0),

   //      .i_p0_valid(iBus_rsp_ready),
   //      .i_p0_ready(1'b1),
   //      .i_p0_data(iBus_rsp_instr),

   //      .t_p1_valid(dBus_cmd_valid),
   //      .t_p1_ready(dBus_cmd_ready),
   //      .t_p1_we(dBus_cmd_payload_wr),
   //      .t_p1_addr(dBus_cmd_payload_addr[$clog2(DEPTH)+2-1:0]),
   //      .t_p1_data(dBus_cmd_payload_data),
   //      .t_p1_mask(dBus_cmd_payload_size),

   //      .i_p1_valid(dBus_rsp_valid),
   //      .i_p1_ready(1'b1),
   //      .i_p1_data(dBus_rsp_data),
   //      .clk(sys_clk),
   //      .rstf(locked)
   //      );
   mem_32 #(
      .DEPTH(DEPTH),
      .MEM0_INIT(MEM0_INIT),
      .MEM1_INIT(MEM1_INIT),
      .MEM2_INIT(MEM2_INIT),
      .MEM3_INIT(MEM3_INIT)
      ) instruction_memory (
      .clk (sys_clk),
      .reset_n(locked),
      .imem_read_cmd_valid (imem_read_cmd_valid),
      .imem_write_cmd_valid (imem_write_cmd_valid),
      .imem_read_data (imem_read_data),
      .imem_read_data_valid (imem_read_data_valid),
      .imem_addr (imem_addr),
      .imem_write_data (imem_write_data),
      .imem_write_data_valid (imem_write_data_valid),
      .imem_write_data_size (imem_write_data_size)
      // .dmem_read_cmd_valid (dmem_read_cmd_valid),
      // .dmem_write_cmd_valid (dmem_write_cmd_valid),
      // .dmem_read_data (dmem_read_data),
      // .dmem_read_data_valid (dmem_read_data_valid),
      // .dmem_addr (dmem_addr),
      // .dmem_write_data (dmem_write_data),
      // .dmem_write_data_valid (dmem_write_data_valid),
      // .dmem_write_data_size (dmem_write_data_size)
      );

  mem_32 #(
      .DEPTH(DEPTH),
      .MEM0_INIT(MEM0_INIT),
      .MEM1_INIT(MEM1_INIT),
      .MEM2_INIT(MEM2_INIT),
      .MEM3_INIT(MEM3_INIT)
      ) data_memory (
      .clk (sys_clk),
      .reset_n(locked),
      // .imem_read_cmd_valid (imem_read_cmd_valid),
      // .imem_write_cmd_valid (imem_write_cmd_valid),
      // .imem_read_data (imem_read_data),
      // .imem_read_data_valid (imem_read_data_valid),
      // .imem_addr (imem_addr),
      // .imem_write_data (imem_write_data),
      // .imem_write_data_valid (imem_write_data_valid),
      // .imem_write_data_size (imem_write_data_size),
      .imem_read_cmd_valid (dmem_read_cmd_valid),
      .imem_write_cmd_valid (dmem_write_cmd_valid),
      .imem_read_data (dmem_read_data),
      .imem_read_data_valid (dmem_read_data_valid),
      .imem_addr (dmem_addr),
      .imem_write_data (dmem_write_data),
      .imem_write_data_valid (dmem_write_data_valid),
      .imem_write_data_size (dmem_write_data_size)
      );

  clk_wiz_0 clock_wiz (
      .clk_in1 (clk),
      .reset   (rstf),
      .clk_out1(sys_clk),
      .locked  (locked)
    );

   

   
endmodule