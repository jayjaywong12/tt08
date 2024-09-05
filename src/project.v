/*
 * Copyright (c) 2024 Jayjay Wong
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_jayjaywong12 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All units in words, or 4 bits
  localparam WORD_SIZE_BITS = 4;
  localparam INSTRUCT_SIZE = 1;
  localparam MAX_VECTOR_SIZE = 16;
  localparam NUM_VECTORS = 2;
  localparam OUTPUT_SIZE = 2;

  // Does not reset with rst_n
  reg [WORD_SIZE_BITS * (INSTRUCT_SIZE + (NUM_VECTORS * MAX_VECTOR_SIZE) + OUTPUT_SIZE) - 1:0] mem;
  
  localparam INSTRUCT_OFFSET = 0;
  localparam VECTOR_OFFSET = INSTRUCT_OFFSET + INSTRUCT_SIZE;
  localparam OUTPUT_OFFSET = VECTOR_OFFSET + NUM_VECTORS * MAX_VECTOR_SIZE;

  localparam [1:0] OPCODE_READ = 2'h0;
  localparam [1:0] OPCODE_WRITE = 2'h1;
  localparam [1:0] OPCODE_RUN = 2'h2;

  localparam [1:0] STATE_RESET = 2'h0;
  localparam [1:0] STATE_RUNNING = 2'h1;
  localparam [1:0] STATE_DONE = 2'h2;

  reg [1:0] state;
  wire [1:0] op = ui_in[7:6];
  wire [5:0] addr = ui_in[5:0];

  always @(posedge clk) begin
    if (rst_n) begin
      if (state == STATE_RESET && op == OPCODE_RUN) begin
        state <= STATE_RUNNING;
      end else if (op == OPCODE_READ) begin
        state <= STATE_RESET;
      end else if (op == OPCODE_WRITE) begin
        state <= STATE_RESET;
      end
    end else begin
      state <= STATE_RESET;
    end
  end

  assign uo_out[7:0] = mem[OUTPUT_OFFSET * OUTPUT_SIZE * WORD_SIZE_BITS - 1: OUTPUT_OFFSET];

  // State is always output
  assign uio_out[5:4] = state[1:0];
  assign uio_oe[5:4] = 2'b11;

  assign uio_oe[7:6] = 2'b0; // Unused, set input
  assign uio_out[7:6] = 2'b0; // Be a good citizen

  wire read_operation = op == OPCODE_READ;
  // Read operation, use bidir pins as outputs
  assign uio_oe[3:0] = read_operation;
  wire [7:0] word_addr = {addr, 2'b00};
  assign uio_out[3:0] = mem[word_addr+:8];
  wire write_operation = op == OPCODE_WRITE;

  always @(posedge clk) begin
    if (write_operation) begin
      mem[word_addr+:8] = uio_in[3:0];
    end
  end


endmodule
