module system_top (
  input  wire        clk,
  input  wire [32:1] sw,
  input  wire [6:1]  swb,
  input  wire        enable,
  output reg  [32:1] led,
  output reg  [7:0]  seg,
  output reg  [2:0]  which
);

  // 内部信号定义
  wire        gcd_input_ready;
  wire        gcd_output_valid;
  wire [31:0] gcd_output_bits;
  reg  [31:0] display_value;

  // GCD模块例化
  GCD gcd (
    .clock       (clk),
    .reset       (swb[1]),              // 使用swb[1]作为复位信号
    .input_ready (gcd_input_ready),
    .input_valid (swb[2]),              // 使用swb[2]作为输入有效信号
    .input_bits_x({sw[32:17]}),         // 使用高16位开关作为x输入
    .input_bits_y({sw[16:1]}),          // 使用低16位开关作为y输入
    .output_valid(gcd_output_valid),
    .output_bits (gcd_output_bits)
  );

  // LED显示逻辑
  always @(posedge clk) begin
    if (swb[1]) begin                   // 复位状态
      led <= 32'h0;
    end else begin
      if (gcd_output_valid) begin       // GCD计算完成时更新LED显示
        led[16:1]  <= gcd_output_bits[15:0];    // 低16位LED显示结果的低16���
        led[32:17] <= gcd_output_bits[31:16];   // 高16位LED显示结果的高16位
      end
    end
  end

  // 数码管扫描计数器
  reg [15:0] scan_cnt;
  always @(posedge clk) begin
    if (swb[1])
      scan_cnt <= 16'h0;
    else
      scan_cnt <= scan_cnt + 1'b1;
  end

  // 数码管位选逻辑
  always @(posedge clk) begin
    if (swb[1]) begin
      which <= 3'b0;
    end else begin
      case (scan_cnt[15:14])
        2'b00: which <= 3'b110;  // 显示个位
        2'b01: which <= 3'b101;  // 显示十位
        2'b10: which <= 3'b011;  // 显示百位
        2'b11: which <= 3'b111;  // 全部关闭
      endcase
    end
  end

  // 数码管段选逻辑
  reg [3:0] digit_to_display;
  always @(*) begin
    case (scan_cnt[15:14])
      2'b00: digit_to_display = gcd_output_bits[3:0];    // 个位
      2'b01: digit_to_display = gcd_output_bits[7:4];    // 十位
      2'b10: digit_to_display = gcd_output_bits[11:8];   // 百位
      default: digit_to_display = 4'h0;
    endcase
  end

  // 7段数码管译码器
  always @(*) begin
    case (digit_to_display)
      4'h0: seg = 8'b11111100;  // 0
      4'h1: seg = 8'b01100000;  // 1
      4'h2: seg = 8'b11011010;  // 2
      4'h3: seg = 8'b11110010;  // 3
      4'h4: seg = 8'b01100110;  // 4
      4'h5: seg = 8'b10110110;  // 5
      4'h6: seg = 8'b10111110;  // 6
      4'h7: seg = 8'b11100000;  // 7
      4'h8: seg = 8'b11111110;  // 8
      4'h9: seg = 8'b11110110;  // 9
      4'ha: seg = 8'b11101110;  // A
      4'hb: seg = 8'b00111110;  // b
      4'hc: seg = 8'b10011100;  // C
      4'hd: seg = 8'b01111010;  // d
      4'he: seg = 8'b10011110;  // E
      4'hf: seg = 8'b10001110;  // F
      default: seg = 8'b00000000;
    endcase
  end

endmodule
