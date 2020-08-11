`default_nettype none
module axi_lcd (
	input wire clk,
	input wire reset,
	inout wire scl,
	inout wire sda,
	output wire led0
	);

logic sys_clk;
logic locked;

logic sda_o;
logic sda_i;
logic sda_t;

logic scl_o;
logic scl_i;
logic scl_t;
// Assuming active high
// assign scl = (!scl_t) ? scl_o : 1'bz;
// assign scl_i = scl;
// assign sda = (!sda_t) ? sda_o : 1'bz;
// assign sda_i = sda;

logic [31:0] wr_data;
logic [6:0] wr_addr;
logic wr_en;

IOBUF i2c_scl_iobuf
       (.I(scl_o),
        .IO(scl),
        .O(scl_i),
        .T(scl_t)
        );
  IOBUF i2c_sda_iobuf
       (.I(sda_o),
        .IO(sda),
        .O(sda_i),
        .T(sda_t)
        );


clk_wiz_0 clock_wizard
   (
    // Clock out ports
    .clk_out1(sys_clk),     // output clk_out1
    // Status and control signals
    .reset(reset), // input reset
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(clk));      // input clk_in1


axi_iic_driver axi_i2c(
	.clk (sys_clk),
	.reset_n(locked),
	.wr_data(wr_data),
	.wr_addr(wr_addr),
	.wr_en (wr_en),
	.sda_i (sda_i),
	.sda_o  (sda_o),
	.sda_t  (sda_t),
	.scl_i  (scl_i),
	.scl_o  (scl_o),
	.scl_t  (scl_t),
	.led0 (led0)
		);


endmodule : axi_lcd

module axi_iic_driver (
	input wire clk,
	input wire reset_n,
	input wire [31:0] wr_data,
	input wire [6:0] wr_addr,
	input wire wr_en,
	input wire sda_i,
	output wire sda_o,
	output wire sda_t,
	input wire scl_i,
	output wire scl_o,
	output wire scl_t,
	output wire led0
	);
	
	(* mark_debug = "true" *) logic [8:0] s_axi_awaddr;
logic 		s_axi_awvalid;
logic 		s_axi_awready;

logic [31:0] s_axi_wdata;
logic [3:0] s_axi_wstrb;
logic 		s_axi_wvalid;
logic 		s_axi_wready;

logic [1:0] s_axi_bresp;
logic 		s_axi_bvalid;
logic 		s_axi_bready;

(* mark_debug = "true" *) logic [8:0] s_axi_araddr;
(* mark_debug = "true" *) logic 		s_axi_arvalid;
(* mark_debug = "true" *) logic 		s_axi_arready;

(* mark_debug = "true" *)logic [31:0] s_axi_rdata;
logic [1:0] s_axi_rresp;
(* mark_debug = "true" *)logic 		s_axi_rvalid;
(* mark_debug = "true" *)logic 		s_axi_rready;

assign s_axi_bready = 1;

axi_iic_0 axi_iic (
  .s_axi_aclk(clk),        // input wire s_axi_aclk
  .s_axi_aresetn(reset_n),  // input wire s_axi_aresetn
  .iic2intc_irpt(led0),  // output wire iic2intc_irpt
  .s_axi_awaddr(s_axi_awaddr),    // input wire [8 : 0] s_axi_awaddr
  .s_axi_awvalid(s_axi_awvalid),  // input wire s_axi_awvalid
  .s_axi_awready(s_axi_awready),  // output wire s_axi_awready
  .s_axi_wdata(s_axi_wdata),      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb(s_axi_wstrb),      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid(s_axi_wvalid),    // input wire s_axi_wvalid
  .s_axi_wready(s_axi_wready),    // output wire s_axi_wready
  .s_axi_bresp(s_axi_bresp),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid(s_axi_bvalid),    // output wire s_axi_bvalid
  .s_axi_bready(s_axi_bready),    // input wire s_axi_bready
  .s_axi_araddr(s_axi_araddr),    // input wire [8 : 0] s_axi_araddr
  .s_axi_arvalid(s_axi_arvalid),  // input wire s_axi_arvalid
  .s_axi_arready(s_axi_arready),  // output wire s_axi_arready
  .s_axi_rdata(s_axi_rdata),      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp(s_axi_rresp),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid(s_axi_rvalid),    // output wire s_axi_rvalid
  .s_axi_rready(s_axi_rready),    // input wire s_axi_rready
  .sda_i(sda_i),                  // input wire sda_i
  .sda_o(sda_o),                  // output wire sda_o
  .sda_t(sda_t),                  // output wire sda_t
  .scl_i(scl_i),                  // input wire scl_i
  .scl_o(scl_o),                  // output wire scl_o
  .scl_t(scl_t),                  // output wire scl_t
  .gpo()                      // output wire [0 : 0] gpo
);

logic [31:0] STATE;

localparam TX_FIFO_EMPTY = 0;
localparam TX_FIFO_RESET = 1;
localparam CONTINUE = 2;
localparam INIT_STATE = 3;
localparam LCD_INITIAL_3 = 4;
localparam LAST_BYTE = 5;
localparam DONE = 6;
localparam RGB_INIT = 7;

logic [7:0] init_mem[64];

(* mark_debug = "true" *) logic [5:0] mem_addr;
always @ (posedge clk) begin
	if (!reset_n) begin
		s_axi_awvalid <= 0;
		s_axi_wvalid <= 0;
		s_axi_arvalid <= 0;
		s_axi_rready <= 0;
		STATE <= TX_FIFO_EMPTY;
		mem_addr <= 0;
	end else begin
		s_axi_awvalid <= 0;
		s_axi_wvalid <= 0;
		s_axi_arvalid <= 0;
		s_axi_rready <= 0;
		s_axi_wstrb <= 4'hf;
		s_axi_wdata <= 0;

		// init_mem[0] <= 8'hd8; // slave address for simulation
		// init_mem[1] <= 8'h11; // Function set
		// init_mem[2] <= 8'h12; // Display on/off // working
		// init_mem[3] <= 8'hef; // Display clear
		// init_mem[4] <= 8'hd8; // Entry mode set
		// init_mem[5] <= 8'hc0; // slave DDR address
		// init_mem[6] <= 8'h48; // slave DDR address
		init_mem[0] <= 8'h7c; // slave address
		init_mem[1] <= 8'h38; // Function set
		init_mem[2] <= 8'hf; // Display on/off // working
		init_mem[3] <= 8'h1; // Display clear
		// init_mem[3] <= 8'he; // Display clear
		init_mem[4] <= 8'h6; // Entry mode set
		init_mem[5] <= 8'h40; // slave DDR address
		init_mem[6] <= "I"; // H
		// init_mem[6] <= 8'h48; // H
		init_mem[7] <= " "; // command
		init_mem[8] <= "L"; // E
		// init_mem[8] <= 8'h45; // E
		init_mem[9] <= "o"; // command // https://www.mouser.com/pdfdocs/DFR0464Datasheet.pdf
		init_mem[10] <="v"; // L 
		// init_mem[10] <=8'h4C; // L 
		init_mem[11] <= "e"; // command
		init_mem[12] <= " "; // L
		init_mem[13] <= "Y"; // command
		init_mem[14] <= "o"; // O
		init_mem[15] <= "u"; // command
		init_mem[16] <= " "; // space
		init_mem[17] <= "A"; // command
		init_mem[18] <= "p"; // W
		init_mem[19] <= "o"; // command
		init_mem[20] <= "o"; // O
		init_mem[21] <= "r"; // command
		init_mem[22] <= "v"; // R
		init_mem[23] <= "i"; // command
		init_mem[24] <= " "; // L
		init_mem[25] <= ":"; // command
		init_mem[26] <= ")"; // D

		init_mem[27] <= 8'hc4; // rgb address
		init_mem[28] <= 0;
		init_mem[29] <= 0;
		init_mem[30] <= 8'h08;
		init_mem[31] <= 8'hff;
		init_mem[32] <= 8'h1;
		init_mem[33] <= 8'h20;
		init_mem[34] <= 8'h4;
		init_mem[35] <= 8'hff;
		init_mem[36] <= 8'h3;
		init_mem[37] <= 8'hff;
		init_mem[38] <= 8'h2;
		init_mem[39] <= 8'hff;




		case(STATE)
			TX_FIFO_EMPTY: begin // again device address
				// s_axi_araddr <= 9'h20;
				s_axi_araddr <= 9'h104;
				s_axi_arvalid <= 1;
				s_axi_rready <= 1;
				// if (s_axi_rvalid && s_axi_rdata[2]) begin // tx fifo is empty
				if (s_axi_rvalid && s_axi_rdata[7] && !s_axi_rdata[2]) begin // tx fifo is empty
					STATE <= TX_FIFO_RESET;
					s_axi_rready <= 0;
					s_axi_arvalid <= 0;
					s_axi_rready <= 0;
				end
			end

			TX_FIFO_RESET: begin
				// if (s_axi_arready) begin
				s_axi_awaddr <= 9'h100;
				s_axi_wdata <= 8'h3; //  TX fifo reset = 1 and enable
				// s_axi_wstrb <= 4'b1;
				s_axi_wvalid <= 1'b1;
				s_axi_awvalid <= 1'b1;
				
				if (s_axi_awready && s_axi_wready) begin
					// mem_addr <= mem_addr + 1;
					STATE <= CONTINUE;
					s_axi_wvalid <= 1'b0;
					s_axi_awvalid <= 1'b0;
				end
			end

			CONTINUE: begin
				s_axi_awaddr <= 9'h100;
				s_axi_wdata <= 8'h1; // remove tx fifo reset
				// s_axi_wstrb <= 4'b1;
				s_axi_wvalid <= 1'b1;
				s_axi_awvalid <= 1'b1;
				
				if (s_axi_awready && s_axi_wready) begin
					if (mem_addr >= 26) begin
						STATE <= RGB_INIT;
					end else begin
						STATE <= INIT_STATE;
					end
					s_axi_wvalid <= 1'b0;
					s_axi_awvalid <= 1'b0;
				end
			end


			INIT_STATE: begin // write I2C device address. 
				s_axi_awaddr <= 9'h108;
				s_axi_wdata <= {1'b0, 1'b1,init_mem[0]};
				
				s_axi_wvalid <= 1'b1;
				s_axi_awvalid <= 1'b1;
				if (s_axi_awready && s_axi_wready) begin
					mem_addr <= mem_addr + 1;
					STATE <= LCD_INITIAL_3;
					s_axi_wvalid <= 1'b0;
					s_axi_awvalid <= 1'b0;
					
				end
			end

			LCD_INITIAL_3: begin
				s_axi_awaddr <= 9'h108;
				if ((mem_addr > 5) && (mem_addr <27)) begin
					s_axi_wdata <= {2'b0,8'h40};
				end else begin
					s_axi_wdata <= {2'b0,init_mem[mem_addr]};
				end
				s_axi_wvalid <= 1'b1;
				s_axi_awvalid <= 1'b1;
				if (s_axi_awready && s_axi_wready) begin
					if (!((mem_addr > 5) && (mem_addr <27))) begin
						mem_addr <= mem_addr + 1;
					end
					STATE <= LAST_BYTE;
					s_axi_wvalid <= 1'b0;
					s_axi_awvalid <= 1'b0;
				end
			end

			LAST_BYTE: begin
					s_axi_awaddr <= 9'h108;
					s_axi_wdata <= {1'b1,1'b0,init_mem[mem_addr]};
					s_axi_wvalid <= 1'b1;
					s_axi_awvalid <= 1'b1;
				if (s_axi_awready && s_axi_wready) begin
					if (mem_addr == 39) begin
						STATE <= DONE;
					end else begin
						STATE <= TX_FIFO_EMPTY;
					end
					s_axi_wvalid <= 1'b0;
					s_axi_awvalid <= 1'b0;
				end
			end

			RGB_INIT: begin
				s_axi_awaddr <= 9'h108;
				s_axi_wdata <= {1'b0, 1'b1,init_mem[27]};
				
				s_axi_wvalid <= 1'b1;
				s_axi_awvalid <= 1'b1;
				if (s_axi_awready && s_axi_wready) begin
					mem_addr <= (mem_addr == 26) ? (mem_addr + 2) : (mem_addr + 1);
					STATE <= LCD_INITIAL_3;
					s_axi_wvalid <= 1'b0;
					s_axi_awvalid <= 1'b0;
					
				end
			end

			DONE: begin
				s_axi_awvalid <= 0;
				s_axi_wvalid <= 0;
				s_axi_arvalid <= 0;
				s_axi_rready <= 0;
			end


		endcase // STATE
	end
end

endmodule : axi_iic_driver

