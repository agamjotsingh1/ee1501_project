module clock_time_handle (
    input clk,
    input AM_PM,
    input set_time,
    input [7:0] input_sec,
    input [7:0] input_min,
    input [7:0] input_hour,
    output reg [7:0] current_24_sec,
    output reg [7:0] current_24_min,
    output reg [7:0] current_24_hour,
    output reg [7:0] display_sec,
    output reg [7:0] display_min,
    output reg [7:0] display_hour
);

  // synchronous time set
  always @(posedge clk) begin
    if (set_time == 1'd1) begin
      current_24_sec  <= input_sec;
      current_24_min  <= input_min;
      current_24_hour <= input_hour;
    end else begin
      if (current_24_sec == 8'd59) begin
        current_24_sec <= 8'd0;
        if (current_24_min == 8'd59) begin
          current_24_min <= 8'd0;
          if (current_24_hour == 8'd23) begin
            current_24_hour <= 8'd0;
          end else begin
            current_24_hour <= current_24_hour + 1;
          end
        end else begin
          current_24_min <= current_24_min + 1;
        end
      end else begin
        current_24_sec <= current_24_sec + 1;
      end
    end
  end

  // Display time in 12-hour or 24-hour format
  always @(*) begin
    display_sec <= current_24_sec;
    display_min <= current_24_min;

    if (AM_PM == 1'b1) begin  // 12-hour format
      if (current_24_hour == 0) begin
        display_hour <= 8'd12;  // 12 AM (midnight)
      end else if (current_24_hour == 12) begin
        display_hour <= 8'd12;  // 12 PM (noon)
      end else if (current_24_hour > 12) begin
        display_hour <= current_24_hour - 12;  // PM hours
      end else begin
        display_hour <= current_24_hour;  // AM hours
      end
    end else begin  // 24-hour format
      display_hour <= current_24_hour;
    end
  end
endmodule
module date_handler (
    input clk,
    input reset,
    input set_date,
    input [7:0] input_day,
    input [7:0] input_month,
    input [15:0] input_year,

    // Clock time inputs to detect day changes
    input [7:0] current_24_hour,
    input [7:0] current_24_min,
    input [7:0] current_24_sec,

    // Date outputs
    output reg [ 7:0] current_day,
    output reg [ 7:0] current_month,
    output reg [15:0] current_year
);

  // Internal signals
  reg [7:0] days_in_current_month;

  // Date handling logic
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset to default date
      current_day   <= 8'd1;
      current_month <= 8'd1;
      current_year  <= 16'd2025;
    end else if (set_date) begin
      // Set date manually when set_date is active
      current_day   <= input_day;
      current_month <= input_month;
      current_year  <= input_year;

    end else if (current_24_hour == 8'd23 && current_24_min == 8'd59 && current_24_sec == 8'd59) begin
      // Day changes at midnight (23:59:59)

      // First determine days in current month without using a function
      case (current_month)
        8'd1, 8'd3, 8'd5, 8'd7, 8'd8, 8'd10, 8'd12:
        days_in_current_month = 8'd31;  // Jan, Mar, May, Jul, Aug, Oct, Dec

        8'd4, 8'd6, 8'd9, 8'd11: days_in_current_month = 8'd30;  // Apr, Jun, Sep, Nov

        8'd2: begin  // February
          // Check leap year without using a function
          if (((current_year % 4 == 0) && (current_year % 100 != 0)) || (current_year % 400 == 0))
            days_in_current_month = 8'd29;  // Leap year
          else days_in_current_month = 8'd28;  // Non-leap year
        end

        default: days_in_current_month = 8'd30;  // Default case
      endcase

      // Update date
      if (current_day == days_in_current_month) begin
        current_day <= 8'd1;  // Reset day to 1

        if (current_month == 8'd12) begin
          current_month <= 8'd1;  // Reset month to January
          current_year  <= current_year + 16'd1;  // Increment year
        end else begin
          current_month <= current_month + 8'd1;  // Increment month
        end
      end else begin
        current_day <= current_day + 8'd1;  // Increment day
      end

    end
  end

endmodule


module alarm_handler (
    input clk,

    input [7:0] input_sec,
    input [7:0] input_min,
    input [7:0] input_hour,

    input [7:0] alarm_time_sec,
    input [7:0] alarm_time_min,
    input [7:0] alarm_time_hour,

    output reg alarm_sound
);

  always @(posedge clk) begin
    if (input_sec == alarm_time_sec && input_min == alarm_time_min && input_hour == alarm_time_hour) begin
      alarm_sound <= 1;
    end else begin
      alarm_sound <= 0;
    end
  end

endmodule


module timer_handler (
    input clk,
    input reset,
    input start_timer,
    input stop_timer,
    input set_timer,
    input [7:0] input_min,
    input [7:0] input_sec,

    output reg [7:0] timer_min,
    output reg [7:0] timer_sec,
    output reg timer_running,
    output reg timer_done
);


  reg [7:0] max_min = 8'd10;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      timer_min <= 8'd0;
      timer_sec <= 8'd0;
      timer_running <= 1'b0;
      timer_done <= 1'b0;
    end else if (set_timer) begin
      if (input_min > max_min) begin
        // Limit to maximum 10 minutes
        timer_min <= max_min;
        timer_sec <= input_sec;
      end else begin
        timer_min <= input_min;
        timer_sec <= input_sec;
      end
      timer_running <= 1'b0;
      timer_done <= 1'b0;
    end else if (start_timer) begin
      timer_running <= 1'b1;
      timer_done <= 1'b0;
    end else if (stop_timer) begin
      // Stop the timer
      timer_running <= 1'b0;
    end else if (timer_running) begin
      // Timer is running, decrement
      if (timer_sec == 8'd0) begin
        if (timer_min == 8'd0) begin
          // Timer has reached zero
          timer_running <= 1'b0;
          timer_done <= 1'b1;
        end else begin
          // Decrement minute, reset seconds to 59
          timer_min <= timer_min - 8'd1;
          timer_sec <= 8'd59;
        end
      end else begin
        // Decrement seconds
        timer_sec <= timer_sec - 8'd1;
      end
    end
  end
endmodule
