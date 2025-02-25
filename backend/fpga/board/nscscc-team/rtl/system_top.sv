module system_top (
    // 时钟与复位
    input  wire        clk,
    input  wire        resetn,
    
    // LED接口
    output reg  [15:0] led,
    output reg  [1:0]  led_rg0,
    output reg  [1:0]  led_rg1,
    
    // 数码管接口
    output reg  [7:0]  num_csn,
    output reg  [6:0]  num_a_g,
    
    // 拨码开关
    input  wire [7:0]  switch,
    
    // 按键
    input  wire [3:0]  btn_key_row,
    input  wire [3:0]  btn_key_col,
    input  wire [1:0]  btn_step,
    
    // UART接口
    input  wire        UART_RX,
    output wire        UART_TX
);

    // 内部信号定义
    wire        gcd_input_ready;
    wire        gcd_output_valid;
    wire [31:0] gcd_output_bits;
    
    // GCD模块例化
    GCD gcd (
        .clock       (clk),
        .reset       (~resetn),           // resetn是低电平有效
        .input_ready (gcd_input_ready),
        .input_valid (btn_step[0]),       // 使用btn_step[0]作为输入有效信号
        .input_bits_x({24'b0, switch}),   // 使用switch作为x输入
        .input_bits_y({24'b0, btn_key_row, btn_key_col}), // 使用按键矩阵作为y输入
        .output_valid(gcd_output_valid),
        .output_bits (gcd_output_bits)
    );

    // LED显示逻辑
    always @(posedge clk) begin
        if (~resetn) begin
            led <= 16'h0;
            led_rg0 <= 2'b00;
            led_rg1 <= 2'b00;
        end else begin
            if (gcd_output_valid) begin
                led <= gcd_output_bits[15:0];  // 使用结果显示在LED上
                led_rg0[0] <= gcd_input_ready; // 显示输入就绪状态
                led_rg0[1] <= gcd_output_valid; // 显示输出有效状态
                led_rg1 <= switch[1:0];        // 显示部分开关状态
            end
        end
    end

    // 数码管显示逻辑
    always @(posedge clk) begin
        if (~resetn) begin
            num_csn <= 8'hff;  // 所有数码管关闭
            num_a_g <= 7'h7f;  // 所有段关闭
        end else begin
            // 简单的数码管扫描显示逻辑
            num_csn <= 8'b11111110;  // 只使能最右边的数码管
            num_a_g <= ~gcd_output_bits[6:0];  // 显示GCD结果的低7位
        end
    end

    // UART接口默认设置
    assign UART_TX = UART_RX;  // 简单环回测试

endmodule
