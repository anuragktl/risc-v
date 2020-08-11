`default_nettype none
module riscv
  (
  input wire sys_clk,
  input wire reset_n,
  output wire imem_read_cmd_valid,
  output wire imem_write_cmd_valid,
  // output wire imem_data_valid,

  
  input wire [31:0] imem_read_data,
  // input wire imem_read_data_valid,

  output reg [31 : 0] imem_addr, 
  // output wire [31:0] imem_write_data,
  // output wire imem_write_data_valid,
  // output wire [3:0] imem_write_data_size, // 1 for a byte, 0'b11 for 2 bytes and so on

  output wire dmem_read_cmd_valid,
  output wire dmem_write_cmd_valid,

  
  input wire [31:0] dmem_read_data,
  // input wire dmem_read_data_valid,

  output wire [31 : 0] dmem_addr, 
  output wire [31:0] dmem_write_data,
  output wire dmem_write_data_valid,
  output wire [3:0] dmem_write_data_size,
  
  output wire [31:0] reg_3
   );
  assign dmem_write_data_valid = 1;
  assign imem_read_cmd_valid = 1;
  assign imem_write_cmd_valid = 0;


  localparam OP_NOP       = 7'b0;
  localparam OP_LUI       = 7'b0110111;
  localparam OP_AUIPC     = 7'b0010111;
  localparam OP_JAL       = 7'b1101111;
  localparam OP_JALR      = 7'b1100111;
  localparam OP_BRANCH    = 7'b1100011;
  localparam OP_LOAD      = 7'b0000011;
  localparam OP_STORE     = 7'b0100011;
  localparam OP_R_IMM     = 7'b0010011;
  localparam OP_R_TYPE    = 7'b0110011;
  logic [6:0] id_opcode;

  localparam ADD = 0;
  localparam SLL = 1;
  localparam SLT = 2;
  localparam SLTU = 3;
  localparam XOR = 4;
  localparam SRL = 5;
  localparam OR = 6;
  localparam AND = 7;
  logic [2:0] r_instructions;

  localparam LB = 0;
  localparam LH = 1;
  localparam LW = 2;
  localparam LBW = 3;
  localparam LHU = 4;
  logic [2:0] load_instructions;

  localparam SB = 0;
  localparam SH = 1;
  localparam SW = 2;
  logic [2:0] store_instructions;

  localparam BEQ = 0;
  localparam BNE = 1;
  localparam BLT = 2;
  localparam BGE = 3;
  localparam BLTU = 4;
  localparam BGEU = 5;
  localparam BR_NONE = 6;
  logic [2:0] branch_instructions;

  localparam NONE = 0;
  localparam LUI = 1;
  localparam AUIPC = 2;
  localparam JAL = 3;
  localparam RIMM = 4;
  localparam BRANCH = 5;
  localparam JALR = 6;
  logic [2:0] jump_instructions; 

  // IF stage //
  logic [32:0] if_id_instruction;
  logic [31:0] temp_if_id_instruction;
  logic [31:0] if_id_pc;
  logic if_flush;
  // ID stage //
  logic [31:0] reg_file [31:0];
  // Control signals
  logic id_mem_write;
  logic id_mem_read;
  logic id_reg_write;
  logic id_mem_to_reg;
  logic [3:0] id_alu_control;
  logic id_flush;

  logic id_ex_mem_write;
  logic id_ex_mem_read;
  logic id_ex_reg_write;
  logic id_ex_mem_to_reg;


  // Data signals
  /* verilator lint_off BLKSEQ */
  logic [4:0] id_rs1;
  logic [4:0] id_rs2;
  logic [4:0] id_rd;

  logic [31:0] id_ex_rs1_data;
  logic [31:0] id_ex_rs2_data;
  logic [4:0] id_ex_rd;
  logic [4:0] id_ex_rs1;
  logic [4:0] id_ex_rs2;


  logic [31:0] id_imm_field; // immediate field for each instruction
  logic [31:0] id_ex_imm_field;


  logic [2:0] id_funct3;
  logic [6:0] id_funct7;

  logic [2:0] id_ex_funct3;
  logic [3:0] id_ex_alu_control;

  logic [2:0] id_jump_type_instructions;
  logic [2:0] id_ex_jump_type_instructions;

  logic [31:0] id_ex_pc;


  // EX stage //

  // Control signals
  logic ex_mem_mem_write;
  logic ex_mem_mem_read;
  logic ex_mem_reg_write;
  logic ex_mem_mem_to_reg;
  logic ex_take_branch;
  logic ex_mem_take_branch;
  logic ex_flush;
  logic ex_flush_mem_read;
  logic ex_branch_type;

  logic ex_rs1_mux1;
  logic ex_rs1_mux2;

  logic [31:0] ex_rs1_mux1_output;

  logic ex_rs2_mux1;
  logic ex_rs2_mux2;
  logic ex_rs2_mux3;

  logic [31:0] ex_rs2_mux1_output;
  logic [31:0] ex_rs2_mux2_output;
  // logic [31:0] ex_rs1_mux2_output;

  // Data signals
  logic [31:0] ex_alu_reg1;
  logic [31:0] ex_alu_reg2;
  logic [31:0] ex_alu_result; // For sw/lw, ex_alu_result is always mem_addr. Rs2_data is data for SW
  logic [31:0] ex_mux_rs1_data;
  logic [31:0] ex_mux_rs2_data;
  logic [31:0] ex_mem_rs2_data;
  logic [31:0] ex_mem_alu_result;

  logic [31:0] ex_target_address;
  logic [31:0] ex_mem_target_address;
  
  logic [2:0] ex_mem_funct3;
  logic [4:0] ex_mem_rd;

  logic [2:0] ex_mem_jump_type_instructions;

  logic [31:0] ex_source1;
  logic [31:0] ex_source2;
  logic [31:0] ex_sum_calculate;

  // Mem stage //
  // Control signals

  logic mem_wb_reg_write;
  logic mem_wb_mem_to_reg;

  // Data signals
  logic [31:0] mem_read_data;
  logic [31:0] mem_wb_mem_read_data;
  logic [31:0] mem_wb_alu_result;
  logic [4:0] mem_wb_rd;

  logic mem_wb_mem_read;
  logic [2:0] mem_wb_funct3;

  // Write back stage //

  // Data Signals
  logic [31:0] wb_rd_data;
  // logic insert_nop;

  // logic [31:0] temp;
  // logic [31:0] const_temp;

  logic hdu_stall;

  logic [31:0] ex_sw_data;

  // alu alu (
  //   .alu_reg1   (ex_alu_reg1),
  //   .alu_reg2   (ex_alu_reg2),
  //   .alu_control(id_ex_alu_control),
  //   .alu_result (ex_alu_result));

  // assign dmem_addr = ex_mem_alu_result; // for lw/sw
  // assign dmem_write_data = ex_mem_rs2_data; // for sw
  // assign dmem_read_cmd_valid    = ex_mem_mem_read;
  // assign dmem_write_cmd_valid   = ex_mem_mem_write;

  // assign store_instructions = (ex_mem_mem_write) ? ex_mem_funct3 : 3'bx;

  assign dmem_addr = ex_sum_calculate; // for lw/sw
  assign dmem_write_data = ex_sw_data; // for sw
  assign dmem_read_cmd_valid    = id_ex_mem_read;
  assign dmem_write_cmd_valid   = id_ex_mem_write;

  assign store_instructions = (id_ex_mem_write) ? id_ex_funct3 : 3'bx;

  assign dmem_write_data_size = (store_instructions == SB) ? 1 : (store_instructions == SH) ? 3 : 4'b1111;

  assign reg_3 = reg_file[3];

  logic if_flush_reg;
  logic hdu_stall_reg;

  always @ (*) begin
    // Write back stage

      wb_rd_data = (mem_wb_mem_to_reg) ? mem_wb_mem_read_data : mem_wb_alu_result;

      if_id_instruction = (hdu_stall_reg) ? {1'b0, temp_if_id_instruction} : {if_flush_reg, imem_read_data}; // Inserting NOP

      id_rs1 = if_id_instruction[19:15];
      id_rs2 = if_id_instruction[24:20]; 
      id_rd = if_id_instruction[11:7]; 

      
      if ((ex_mem_jump_type_instructions == JAL) || (ex_mem_jump_type_instructions == JALR)|| ((ex_mem_jump_type_instructions == BRANCH) && ex_mem_take_branch)) begin // branch taken
        if_flush = 1;
        id_flush = 1;
        ex_flush = 1;
        
        // imem_addr <= ex_mem_pc + ex_mem_imm_field;
      end else begin
        if_flush = 0;
        id_flush = 0;
        ex_flush = 0;
        // imem_addr <= imem_addr + 4;
      end

      ex_flush_mem_read = !ex_flush && id_ex_mem_read;

      if (ex_flush_mem_read && ((id_rs1 == id_ex_rd) || (id_rs2 == id_ex_rd)))  begin
        hdu_stall = 1;
      end else begin
        hdu_stall = 0;
      end

      id_funct3 = if_id_instruction[14:12];
      id_funct7 = if_id_instruction[31:25]; // for r type instructions

      id_mem_read = 1'b0;
      id_mem_write = 1'b0;
      id_mem_to_reg = 1'b0;
      id_reg_write = 0;

      id_opcode = if_id_instruction[6:0]; 
      // id_opcode = (insert_nop) ? 7'b0 : if_id_instruction[6:0]; // Inserting nop
      id_jump_type_instructions = 0;
      id_alu_control = 4'bx;
      id_imm_field = 32'bx;
      branch_instructions = 3'b110;
      r_instructions = 3'bx;
      case (id_opcode) // Instruction decode
        OP_LUI: begin
          id_imm_field = {if_id_instruction[31:12], {12{1'b0}}}; 
          id_reg_write = 1'b1;
          id_alu_control = 10;
          id_jump_type_instructions = LUI;
        end

        OP_AUIPC: begin
          id_imm_field = {if_id_instruction[31:12], {12{1'b0}}}; 
          id_reg_write = 1'b1;
          id_alu_control = 10;
          id_jump_type_instructions = AUIPC;
        end

        OP_JAL: begin
          id_imm_field = {{11{if_id_instruction[31]}}, {if_id_instruction[31], if_id_instruction[19:12], if_id_instruction[20], if_id_instruction[30:21]}, {1'b0}};
          id_reg_write = 1'b1;
          id_alu_control = 10;
          id_jump_type_instructions = JAL;
        end

        OP_JALR: begin
          id_imm_field = {{20{if_id_instruction[31]}}, if_id_instruction[31:20]}; // TO DO: first add to id_rs1 data, then replace LSB with '0'
          id_reg_write = 1'b1;
          id_alu_control = 10;
          id_jump_type_instructions = JALR;
        end

        OP_BRANCH: begin
          id_imm_field = {{19{if_id_instruction[31]}}, {if_id_instruction[31], if_id_instruction[7], if_id_instruction[30:25], if_id_instruction[11:8]}, {1'b0}};
          id_jump_type_instructions = BRANCH;
          id_alu_control = 4'bx;
          branch_instructions = id_funct3;
        end

        OP_LOAD: begin
          id_imm_field = {{20{if_id_instruction[31]}}, if_id_instruction[31:20]};
          id_mem_read = 1'b1;
          id_mem_to_reg = 1'b1;
          id_reg_write = 1'b1;
          id_alu_control = 4'bx;
          id_jump_type_instructions = RIMM;
        end

        OP_STORE: begin
          id_imm_field = {{20{if_id_instruction[31]}}, {if_id_instruction[31:25], if_id_instruction[11:7]}};
          id_alu_control = 4'bx;
          id_mem_write = 1'b1;
          id_jump_type_instructions = RIMM;
        end

        OP_R_IMM: begin
          id_imm_field = {{20{if_id_instruction[31]}}, if_id_instruction[31:20]};
          id_reg_write = 1;
          r_instructions = id_funct3;
          id_jump_type_instructions = RIMM;
          case (r_instructions) 
            ADD: begin // ADDI
              id_alu_control = 0;
            end
            SLL: begin // SLLI
              id_alu_control = 2;
            end

            SLT: begin // SLTI
              id_alu_control = 3;
            end
            SLTU: begin // SLTIU
              id_alu_control = 4;
            end
            XOR: begin // XORI
              id_alu_control = 5;
            end
            SRL: begin 
              if (if_id_instruction[31:25] == 0) begin // SRLI
                id_alu_control = 6;
              end else begin // SRAI
                id_alu_control = 7;
              end
            end

            OR: begin // ORI
              id_alu_control = 8;
            end
            AND: begin // ANDI
              id_alu_control = 9;
            end
          endcase
        end

        OP_R_TYPE: begin
          id_reg_write = 1;
          r_instructions = id_funct3;
          case (r_instructions)
            ADD: begin
              if (id_funct7 == 0) begin
                id_alu_control = 0;
              end else begin
                id_alu_control = 1;
              end
            end

            SLL: begin
              id_alu_control = 2;
            end

            SLT: begin
              id_alu_control = 3;
            end

            SLTU: begin
              id_alu_control = 4;
            end

            XOR: begin
              id_alu_control = 5;
            end

            SRL: begin
              if (id_funct7 == 0) begin
                id_alu_control = 6;
              end else begin
                id_alu_control = 7;
              end
            end

            OR: begin
              id_alu_control = 8;
            end

            AND: begin
              id_alu_control = 9;
            end
          endcase // id_funct3
        end
        default: begin
          id_mem_read = 1'b0;
          id_mem_write = 1'b0;
          id_mem_to_reg = 1'b0;
          id_reg_write = 0;
        end 
      endcase // if_id_instruction

      // Ex stage //
      jump_instructions = id_ex_jump_type_instructions;
      // Forwarding unit
      ex_rs1_mux1 = (id_ex_rs1 == mem_wb_rd) && mem_wb_reg_write;
      ex_rs1_mux2 = (id_ex_rs1 == ex_mem_rd) && ex_mem_reg_write;

      ex_rs1_mux1_output = (ex_rs1_mux1) ? wb_rd_data : id_ex_rs1_data; // data dependency from S2
      ex_mux_rs1_data = (ex_rs1_mux2) ? ex_mem_alu_result : ex_rs1_mux1_output; // data dependency from S1

      ex_rs2_mux1 = (id_ex_rs2 == mem_wb_rd) && mem_wb_reg_write;
      ex_rs2_mux2 = (id_ex_rs2 == ex_mem_rd) && ex_mem_reg_write;
      ex_rs2_mux3 = jump_instructions == RIMM;

      ex_rs2_mux1_output = (ex_rs2_mux1) ? wb_rd_data : id_ex_rs2_data;
      ex_rs2_mux2_output = (ex_rs2_mux2) ? ex_mem_alu_result : ex_rs2_mux1_output;
      ex_mux_rs2_data = (ex_rs2_mux3) ? id_ex_imm_field : ex_rs2_mux2_output;

      ex_sw_data = ex_rs2_mux2_output;

      
      case(jump_instructions)
        LUI: begin
          ex_alu_reg1 = id_ex_imm_field;
          ex_alu_reg2 = 0;
        end

        AUIPC: begin
          ex_alu_reg1 = id_ex_imm_field;
          ex_alu_reg2 = id_ex_pc;
        end

        JAL: begin
          ex_alu_reg1 = 4;
          ex_alu_reg2 = id_ex_pc;
        end

        JALR: begin
          ex_alu_reg1 = 4;
          ex_alu_reg2 = id_ex_pc;
        end

        default: begin
          ex_alu_reg1 = ex_mux_rs1_data;
          ex_alu_reg2 = ex_mux_rs2_data;
        end
      endcase // jump_instructions

      // adder for lw, sw, and jump and branch address calculation //
      ex_branch_type = (jump_instructions == JAL) || (jump_instructions == BRANCH);
      if (ex_branch_type) begin
        ex_source1 = id_ex_pc;
        ex_source2 = id_ex_imm_field;
      end else if (jump_instructions == JALR) begin
        ex_source1 = ex_mux_rs1_data;
        ex_source2 = id_ex_imm_field;
      end else if (id_ex_mem_write || id_ex_mem_read) begin // Load Store instructions
        ex_source1 = ex_mux_rs1_data;
        ex_source2 = ex_mux_rs2_data;
      end else begin
        ex_source1 = 32'bx;
        ex_source2 = 32'bx;
      end

      ex_sum_calculate = ex_source1 + ex_source2;

      if (ex_branch_type) begin
        ex_target_address = ex_sum_calculate;
      end else if (jump_instructions == JALR) begin
        ex_target_address = {ex_sum_calculate[31:1],{1'b0}};
      end else  begin
        ex_target_address = 32'bx;
      end


      /*
      --------------------------
      |id_alu_control  | function |
      --------------------------
      | 000         |add       |
      | 001         |sub       |
      | 010         |SLL       |
      | 011         |SLT       |
      | 100         |SLTU      |
      | 101         |XOR       |
      | 110         |SRL       |
      | 111         |SRA       |
      |1000         |OR        |
      |1001         |AND       |
      |1010         |Unsign ADD|
      |1011         |COMPARE   |
      --------------------------
      */


      case(id_ex_alu_control)

        4'h0: begin // Add
          ex_alu_result = $signed(ex_alu_reg1) + $signed(ex_alu_reg2);
        end

        4'h1: begin // Sub
          ex_alu_result = $signed(ex_alu_reg2) - $signed(ex_alu_reg1);
        end

        4'h2: begin // SLL
          ex_alu_result = ex_alu_reg1 << ex_alu_reg2[4:0];
        end

        4'h3: begin //SLT
          ex_alu_result = $signed(ex_alu_reg1) < $signed(ex_alu_reg2);
        end

        4'h4: begin //SLTU
          ex_alu_result = ex_alu_reg1 < ex_alu_reg2;
        end

        4'h5: begin // XOR
          ex_alu_result = ex_alu_reg1 ^ ex_alu_reg2;
        end

        4'h6: begin // SRL
          ex_alu_result = ex_alu_reg1 >> ex_alu_reg2[4:0];
        end

        4'h7: begin // SRA
          ex_alu_result = ex_alu_reg1 >>> ex_alu_reg2[4:0];
        end

        4'h8: begin // OR
          ex_alu_result = ex_alu_reg1 | ex_alu_reg2;
        end

        4'h9: begin // AND
          ex_alu_result = ex_alu_reg1 & ex_alu_reg2;
        end

        4'ha: begin //ADDU
          ex_alu_result = ex_alu_reg1 + ex_alu_reg2;
        end

        default: begin
          ex_alu_result = 32'b0;
        end
      endcase

      

      

      case (id_ex_funct3)
        BEQ: begin
          ex_take_branch = ex_alu_reg1 == ex_alu_reg2;
          // ex_take_branch = ex_alu_result[0];
        end

        BNE: begin
          ex_take_branch = ex_alu_reg1 != ex_alu_reg2;
        end

        BLT: begin
          // id_alu_control = 3;
          // ex_take_branch = ex_alu_result[0];
          ex_take_branch = $signed(ex_alu_reg1) < $signed(ex_alu_reg2);
        end

        BGE: begin
          // ex_take_branch = !ex_alu_result[0];
          ex_take_branch = $signed(ex_alu_reg1) >= $signed(ex_alu_reg2);
        end

        BLTU: begin
          // id_alu_control = 4;
          // ex_take_branch = ex_alu_result[0];
          ex_take_branch = ex_alu_reg1 < ex_alu_reg2;
        end

        BGEU: begin
          // ex_take_branch = !ex_alu_result[0];
          ex_take_branch = ex_alu_reg1 >= ex_alu_reg2;;
        end
        default:
          ex_take_branch = 0;
      endcase // branch_instructions

      // Mem Stage
      if (ex_mem_mem_read) begin // LW instruction
        load_instructions = ex_mem_funct3;
        case (load_instructions)
          LB: begin
            mem_read_data = {{24{dmem_read_data[7]}}, {dmem_read_data[7:0]}};
          end

          LH: begin
            mem_read_data = {{16{dmem_read_data[15]}}, {dmem_read_data[15:0]}};
          end

          LW: begin
            mem_read_data = dmem_read_data;
          end

          LBW: begin
            mem_read_data = {{24{1'b0}}, {dmem_read_data[7:0]}};
          end

          LHU: begin
            mem_read_data = {{16{1'b0}}, {dmem_read_data[15:0]}};
          end
          default:
            mem_read_data = 32'bx;
        endcase // load_instructions
      end else begin
        load_instructions = 3'bx;
        mem_read_data = 32'bx;
      end


  end

  always @ (posedge sys_clk) begin

    if (!reset_n) begin
      // imem_read_cmd_valid <= 0;
      // imem_write_cmd_valid <= 0;
      imem_addr <= 0;
      
      // IF stage //
      // if_id_instruction <= {1'b0,32'bx};
      if_id_pc <= 32'bx;
      temp_if_id_instruction <= 32'bx;
      if_flush_reg <= 0;
      hdu_stall_reg <= 0;


      id_ex_mem_write <= 0;
      id_ex_mem_read <= 0;
      id_ex_reg_write <= 0;
      id_ex_mem_to_reg <= 0;


  // Data signals
  /* verilator lint_off BLKSEQ */


      id_ex_rs1_data <= 32'bx;
      id_ex_rs2_data <= 32'bx;
      id_ex_rd <= 5'bx;
      id_ex_rs1 <= 5'bx;
      id_ex_rs2 <= 5'bx;


      id_ex_imm_field <= 32'bx;


      // id_funct3 = 3'bx;
      // id_funct7 = 7'bx;

      id_ex_funct3 <= 3'bx;
      id_ex_alu_control <= 4'bx;

      // id_jump_type_instructions = 3'bx;
      id_ex_jump_type_instructions <= 0;

      id_ex_pc <= 32'bx;


  // EX stage //

  // Control signals
      ex_mem_mem_write <= 0;
      ex_mem_mem_read <= 0;
      ex_mem_reg_write <= 0;
      ex_mem_mem_to_reg <= 0;
      ex_take_branch = 1'bx;
      ex_mem_take_branch <= 0;
      // ex_flush = 1'bx;

  // Data signals

      ex_mem_rs2_data <= 32'bx;
      ex_mem_alu_result <= 32'bx;

      // ex_target_address = 32'bx;
      ex_mem_target_address <= 32'bx;
  
      ex_mem_funct3 <= 3'bx;
      ex_mem_rd <= 5'bx;

      ex_mem_jump_type_instructions <= 0;

  // Mem stage //
  // Control signals

      mem_wb_reg_write <= 0;
      mem_wb_mem_to_reg <= 0;

  // Data signals
      // mem_read_data = 32'bx;
      // mem_wb_mem_read_data <= 32'bx;
      mem_wb_alu_result <= 32'bx;
      mem_wb_rd <= 5'bx;

      mem_wb_mem_read <= 0;
      mem_wb_funct3 <= 0;

    end else begin
      
      
      
      // IF stage

      
      temp_if_id_instruction <= imem_read_data; 

      if_flush_reg <= if_flush;

      
      hdu_stall_reg <= hdu_stall;

      if (if_flush) begin
        imem_addr <= ex_mem_target_address;
      end else if (!hdu_stall) begin
        imem_addr <= imem_addr + 4;
        if_id_pc <= imem_addr;
      end


      // ID stage //
      

      id_ex_rs1_data    <= (mem_wb_reg_write && (id_rs1 == mem_wb_rd)) ? wb_rd_data : reg_file[id_rs1];
      id_ex_rs2_data    <= (mem_wb_reg_write && (id_rs2 == mem_wb_rd)) ? wb_rd_data : reg_file[id_rs2];
      id_ex_rs1         <= id_rs1;
      id_ex_rs2         <= id_rs2;
      id_ex_rd          <= id_rd;
      id_ex_funct3      <= id_funct3;
      id_ex_imm_field   <= id_imm_field;

      id_ex_mem_write   <= id_mem_write;
      id_ex_mem_read    <= id_mem_read;
      id_ex_reg_write   <= id_reg_write;
      id_ex_mem_to_reg  <= id_mem_to_reg;
      id_ex_alu_control <= id_alu_control;
      id_ex_pc          <= if_id_pc;
      id_ex_jump_type_instructions <= id_jump_type_instructions;

      // Hazard Detection Unit // if lw instruction is S1, then stall the pipeline for one cycle
       //id_rd = if_id_instruction[11:7]; 
      if (hdu_stall || id_flush || if_id_instruction[32])  begin
        id_ex_mem_write <= 0;
        id_ex_mem_read <= 0;
        id_ex_reg_write <= 0;
        id_ex_jump_type_instructions <= 0;

      end 

      

      
      
      ex_mem_mem_write    <= (ex_flush) ? 0 : id_ex_mem_write;
      ex_mem_mem_read     <= ex_flush_mem_read;
      ex_mem_reg_write    <= (ex_flush) ? 0 : id_ex_reg_write;
      ex_mem_mem_to_reg   <= id_ex_mem_to_reg;
      ex_mem_alu_result   <= ex_alu_result;
      ex_mem_rs2_data     <= ex_sw_data;
      ex_mem_rd           <= id_ex_rd;
      ex_mem_funct3       <= id_ex_funct3;
      ex_mem_take_branch  <= (ex_flush) ? 0 : ex_take_branch;
      ex_mem_target_address <= ex_target_address;
      ex_mem_jump_type_instructions <= (ex_flush) ? 0 : id_ex_jump_type_instructions;

      // Mem stage

      mem_wb_mem_read_data <= mem_read_data;
      mem_wb_alu_result    <= ex_mem_alu_result;
      mem_wb_reg_write     <= ex_mem_reg_write;
      mem_wb_mem_to_reg    <= ex_mem_mem_to_reg;
      mem_wb_rd            <= ex_mem_rd;

      // Write back stage //

      if (mem_wb_reg_write) begin
        reg_file[mem_wb_rd] <= wb_rd_data;
      end
      reg_file[0] <= 0;
    end
  end
endmodule : riscv

  


