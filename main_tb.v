`timescale 1s/1ms

module digital_clock_tb;
    // Clock and reset signals
    reg clk;
    reg reset;

    // Clock time control signals
    reg set_time;
    reg [7:0] input_sec;
    reg [7:0] input_min;
    reg [7:0] input_hour;
    reg hour_format;

    // Date control signals
    reg set_date;
    reg [7:0] input_day;
    reg [7:0] input_month;
    reg [15:0] input_year;

    // Timer control signals
    reg set_timer;
    reg start_timer;
    reg stop_timer;
    reg [7:0] timer_input_min;
    reg [7:0] timer_input_sec;

    // Alarm control signals
    reg set_alarm;
    reg snooze_alarm;
    reg stop_alarm;
    reg [7:0] alarm_time_sec;
    reg [7:0] alarm_time_min;
    reg [7:0] alarm_time_hour;

    // Clock time outputs
    wire [7:0] current_24_sec;
    wire [7:0] current_24_min;
    wire [7:0] current_24_hour;
    wire [7:0] display_sec;
    wire [7:0] display_min;
    wire [7:0] display_hour;
    wire is_pm;

    // Date outputs
    wire [7:0] current_day;
    wire [7:0] current_month;
    wire [15:0] current_year;

    // Timer outputs
    wire [7:0] timer_min;
    wire [7:0] timer_sec;
    wire timer_running;
    wire timer_buzzer;

    // Alarm outputs
    wire alarm_buzzer;

    // Display variables for monitoring
    reg [7:0] display_seconds;
    reg [7:0] display_minutes;
    reg [7:0] display_hours;

    // Indicator to display am or pm on the screen
    reg [15:0] am_pm_indicator;

    // Instantiating the main driver for the clock
    main_driver dut (
        .clk(clk),
        .reset(reset),
        .hour_format(hour_format),
        .set_time(set_time),
        .set_date(set_date),
        .set_alarm(set_alarm),
        .snooze_alarm(snooze_alarm),
        .stop_alarm(stop_alarm),
        .set_timer(set_timer),
        .start_timer(start_timer),
        .stop_timer(stop_timer),
        .input_sec(input_sec),
        .input_min(input_min),
        .input_hour(input_hour),
        .input_day(input_day),
        .input_month(input_month),
        .input_year(input_year),
        .timer_input_min(timer_input_min),
        .timer_input_sec(timer_input_sec),
        .alarm_time_sec(alarm_time_sec),
        .alarm_time_min(alarm_time_min),
        .alarm_time_hour(alarm_time_hour),
        .current_24_sec(current_24_sec),
        .current_24_min(current_24_min),
        .current_24_hour(current_24_hour),
        .display_sec(display_sec),
        .display_min(display_min),
        .display_hour(display_hour),
        .current_day(current_day),
        .current_month(current_month),
        .current_year(current_year),
        .timer_min(timer_min),
        .timer_sec(timer_sec),
        .timer_running(timer_running),
        .timer_buzzer(timer_buzzer),
        .alarm_buzzer(alarm_buzzer)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #0.5 clk = ~clk;
    end

    // Display logic - show timer when running, otherwise show clock
    always @(*) begin
        if (timer_running) begin
            display_seconds = timer_sec;
            display_minutes = timer_min;
            display_hours = 8'd0; // Timer doesn't use hours
        end else begin
            display_seconds = display_sec;
            display_minutes = display_min;
            display_hours = display_hour;
        end

        if (hour_format) begin
            if (is_pm)
                am_pm_indicator = {"P", "M"};  // 'P' = 8'h50, 'M' = 8'h4D
            else
                am_pm_indicator = {"A", "M"};  // 'A' = 8'h41, 'M' = 8'h4D
        end else begin
            am_pm_indicator = "  ";  // Two spaces if 24-hour
        end
    end

    // Test sequence
    initial begin
        // Initialize all inputs
        reset = 1;
        set_time = 0;
        input_sec = 0;
        input_min = 0;
        input_hour = 0;
        hour_format = 0;
        set_date = 0;
        input_day = 1;
        input_month = 1;
        input_year = 2020;
        set_alarm = 0;
        set_timer = 0;
        start_timer = 0;
        stop_timer = 0;
        timer_input_min = 0;
        timer_input_sec = 0;
        alarm_time_sec = 0;
        alarm_time_min = 0;
        alarm_time_hour = 0;
        snooze_alarm = 0;
        stop_alarm = 0;

        // Apply reset for 20ns
        #20 reset = 0;

        // Test 1: Set the time to 23:59:50
        #10;
        set_time = 1;
        input_sec = 50;
        input_min = 59;
        input_hour = 23;
        #10;
        set_time = 0;

        // Test 2: Set the date to December 31, 2025
        #10;
        set_date = 1;
        input_day = 31;
        input_month = 12;
        input_year = 2025;
        #10; set_date = 0;

        // Test 3: Set an alarm for 00:01:00
        set_alarm = 1;
        alarm_time_sec = 0;
        alarm_time_min = 1;
        alarm_time_hour = 0;
        #10;
        set_alarm = 0;

        // Test 4: Set and start a 10-second timer
        #10;
        set_timer = 1;
        timer_input_min = 0;
        timer_input_sec = 10;
        #10;
        set_timer = 0;
        #10;
        start_timer = 1;
        #10;
        start_timer = 0;

        // Wait for the timer to run for a bit
        #200;

        // Test 5: Stop the timer
        stop_timer = 1;
        #10;
        stop_timer = 0;

        // Test 6: Wait for the clock to roll over to the next day
        // We'll speed up time by setting it closer to midnight
        #10;
        set_time = 1;
        input_sec = 58;
        input_min = 59;
        input_hour = 23;
        #10;
        set_time = 0;

        // Wait for date to change (about 30 seconds in simulation time)
        #300;

        // Test 7: Switch to 12-hour format
        hour_format = 1;
        #100;

        // Test 8: Set a new timer and let it complete
        #10;
        set_timer = 1;
        timer_input_min = 0;
        timer_input_sec = 5; // 5-second timer
        #10;
        set_timer = 0;
        #10;
        start_timer = 1;
        #10;
        start_timer = 0;

        // Wait for the timer to finish
        #600;

        // End simulation
        #100 $finish;
    end

   // Monitor outputs
   initial begin
       $monitor("DISPLAY: %02d:%02d:%02d %c%c | DATE: %02d/%02d/%4d\nTime: %3ds | Clock: %02d:%02d:%02d\nTimer: %02d:%02d (Running: %b, Done: %b)\nAlarm Buzzer: %0d | Alarm: sec=%d, min=%d, hour=%d\nControls: set_time=%b | set_date=%b | set_timer=%b | start=%b | stop=%b | hour_format=%b | reset=%b\nInputs: sec=%d, min=%d, hour=%d, day=%d, month=%d, year=%d\nTimer Inputs: min=%d, sec=%d\nAlarm Inputs: snooze=%d, stop=%d\n",
           display_hours, display_minutes, display_seconds,
           am_pm_indicator[15:8], am_pm_indicator[7:0],
           current_day, current_month, current_year,
           $time,
           current_24_hour, current_24_min, current_24_sec,
           timer_min, timer_sec, timer_running, timer_buzzer,
           alarm_buzzer, alarm_time_sec, alarm_time_min, alarm_time_hour,
           set_time, set_date, set_timer, start_timer, stop_timer, hour_format, reset,
           input_sec, input_min, input_hour, input_day, input_month, input_year,
           timer_input_min, timer_input_sec,
           snooze_alarm, stop_alarm);
   end

   initial begin
       $dumpfile("wave.vcd");
       $dumpvars(0, digital_clock_tb);
   end

endmodule
