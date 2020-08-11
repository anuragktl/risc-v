`default_nettype none
module mem_32 #(
   parameter DEPTH = 8192,
    parameter MEM0_INIT = "mem.mif",
    parameter MEM1_INIT = "mem.mif",
    parameter MEM2_INIT = "mem.mif",
    parameter MEM3_INIT = "mem.mif"
   )
   (
   input wire clk,
   input wire reset_n,

   input wire imem_read_cmd_valid,
   input wire imem_write_cmd_valid,
   // output wire imem_data_valid,

   
   output reg [31:0] imem_read_data,
   output reg imem_read_data_valid,

   input wire [$clog2(DEPTH) + 2 - 1 : 0] imem_addr, // total memory size is 4*Depth
   input wire [31:0] imem_write_data,
   input wire imem_write_data_valid,
   input wire [3:0] imem_write_data_size // 1 for a byte, 0'b11 for 2 bytes and so on

   // input wire dmem_read_cmd_valid,
   // input wire dmem_write_cmd_valid,

   
   // output reg [31:0] dmem_read_data,
   // output reg dmem_read_data_valid,

   // input wire [$clog2(DEPTH) + 2 - 1 : 0] dmem_addr, // total memory size is 4*Depth
   // input wire [31:0] dmem_write_data,
   // input wire dmem_write_data_valid,
   // input wire [3:0] dmem_write_data_size



   );

   (* ram_style = "block" *) reg [7:0] mem0 [DEPTH];
      (* ram_style = "block" *) reg [7:0] mem1 [DEPTH];
      (* ram_style = "block" *) reg [7:0] mem2 [DEPTH];
      (* ram_style = "block" *) reg [7:0] mem3 [DEPTH];

      initial begin
      $readmemh(MEM0_INIT, mem0);
      $readmemh(MEM1_INIT, mem1);
      $readmemh(MEM2_INIT, mem2);
      $readmemh(MEM3_INIT, mem3);
      end

      logic [$clog2(DEPTH) + 2 - 1 : 2] addr0; // total memory size is 4*Depth
      // logic [$clog2(DEPTH) + 2 - 1 : 2] addr1; // total memory size is 4*Depth

      assign addr0 = imem_addr[$clog2(DEPTH) + 2 - 1 : 2]; // total memory size is 4*Depth
      // assign addr1 = dmem_addr[$clog2(DEPTH) + 2 - 1 : 2]; // total memory size is 4*Depth

      always @ (posedge clk) begin
         if (!reset_n) begin
            // dmem_read_data_valid <= 0;
            imem_read_data_valid <= 0;
         end else begin
            if (imem_write_cmd_valid && imem_write_data_valid) begin // write data according to the data size or byte enables
               if (imem_write_data_size[0]) begin
                  mem0[addr0] <= imem_write_data[7:0];
               end
               if (imem_write_data_size[1]) begin
                  mem1[addr0] <= imem_write_data[15:8];
               end
               if (imem_write_data_size[2]) begin
                  mem2[addr0] <= imem_write_data[23:16];
               end
               if (imem_write_data_size[3]) begin
                  mem3[addr0] <= imem_write_data[31:24];
               end
            end
            imem_read_data_valid <= 0;
            if (imem_read_cmd_valid) begin
               imem_read_data <= {mem3[addr0], mem2[addr0], mem1[addr0], mem0[addr0]};
               imem_read_data_valid <= 1;
            end


            // if (dmem_write_cmd_valid && dmem_write_data_valid) begin // write data according to the data size or byte enables
            //    if (dmem_write_data_size[0]) begin
            //       mem0[addr1] <= dmem_write_data[7:0];
            //    end
            //    if (dmem_write_data_size[1]) begin
            //       mem1[addr1] <= dmem_write_data[15:8];
            //    end
            //    if (dmem_write_data_size[2]) begin
            //       mem2[addr1] <= dmem_write_data[23:16];
            //    end
            //    if (dmem_write_data_size[3]) begin
            //       mem3[addr1] <= dmem_write_data[31:24];
            //    end
            // end
            // dmem_read_data_valid <= 0;
            // if (dmem_read_cmd_valid) begin
            //    dmem_read_data <= {mem3[addr1], mem2[addr1], mem1[addr1], mem0[addr1]};
            //    dmem_read_data_valid <= 1;
            // end
         end
      end

endmodule
