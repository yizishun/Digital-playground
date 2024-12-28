module system_top (
  // Clock
  input  wire        clk_50M,
  
  // HDMI接口
  output wire        TMDS_clk_n,
  output wire        TMDS_clk_p,
  output wire        TMDS_data_n0,
  output wire        TMDS_data_p0,
  output wire        TMDS_data_n1,
  output wire        TMDS_data_p1,
  output wire        TMDS_data_n2,
  output wire        TMDS_data_p2,
  output wire        HDMI_OEN,
  inout  wire        HDMI_SCL,
  inout  wire        HDMI_SDA,
  input  wire        HDMI_CEC,
  input  wire        HDMI_HPD,
  output wire        HDMI_OUT_EN,
  
  // EEPROM接口
  output wire        EEPROM_I2C_SCL,
  inout  wire        EEPROM_I2C_SDA,
  
  // RTC接口
  output wire        RTC_SCLK,
  output wire        RTC_RESET,
  inout  wire        RTC_DATA,
  
  // 通用IO接口
  inout  wire [36:3] PIN,
  
  // LED和按键
  input  wire [3:0]  KEY,
  output reg  [3:0]  LED
);

  // 内部信号定义
  wire        gcd_input_ready;
  wire        gcd_output_valid;
  wire [31:0] gcd_output_bits;

  // GCD模块例化
  GCD gcd (
    .clock       (clk_50M),
    .reset       (~KEY[0]),           // KEY是低电平有效，所以需要取反
    .input_ready (gcd_input_ready),
    .input_valid (~KEY[1]),           // KEY是低电平有效，所以需要取反
    .input_bits_x({16'b0, PIN[18:11]}), // 使用PIN[18:11]作为x输入
    .input_bits_y({16'b0, PIN[10:3]}),  // 使用PIN[10:3]作为y输入
    .output_valid(gcd_output_valid),
    .output_bits (gcd_output_bits)
  );

  // LED显示逻辑
  always @(posedge clk_50M) begin
    if (~KEY[0]) begin              // 复位状态
      LED <= 4'h0;
    end else begin
      if (gcd_output_valid) begin   // GCD计算完成时更新LED显示
        LED <= gcd_output_bits[3:0]; // 使用结果的低4位显示在LED上
      end
    end
  end

  // 未使用的接口设置为默认值
  assign TMDS_clk_n   = 1'b0;
  assign TMDS_clk_p   = 1'b0;
  assign TMDS_data_n0 = 1'b0;
  assign TMDS_data_p0 = 1'b0;
  assign TMDS_data_n1 = 1'b0;
  assign TMDS_data_p1 = 1'b0;
  assign TMDS_data_n2 = 1'b0;
  assign TMDS_data_p2 = 1'b0;
  assign HDMI_OEN     = 1'b0;
  assign HDMI_OUT_EN  = 1'b0;
  
  assign EEPROM_I2C_SCL = 1'b1;
  
  assign RTC_SCLK  = 1'b0;
  assign RTC_RESET = 1'b1;

endmodule
