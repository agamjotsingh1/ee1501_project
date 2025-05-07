
`timescale 1s/1ms

module tb_traffic_light_controller;

    reg clk, reset;
    reg Emergency_Left, Emergency_Right;
    wire [1:0] T1, T2;
    wire T1_WALK, T2_WALK, buzzer;

    // Instantiate your module
    traffic_light_controller uut (
        .clk(clk),
        .reset(reset),
        .Emergency_Left(Emergency_Left),
        .Emergency_Right(Emergency_Right),
        .T1(T1),
        .T2(T2),
        .T1_WALK(T1_WALK),
        .T2_WALK(T2_WALK),
        .buzzer(buzzer)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #0.5 clk = ~clk;
    end

    // Light name string variables (for display)
    reg [8*6:1] T1_str, T2_str;

    always @* begin
        case (T1)
            2'b00: T1_str = "GREEN ";
            2'b01: T1_str = "YELLOW";
            2'b10: T1_str = "RED   ";
            default: T1_str = "UNKWN ";
        endcase

        case (T2)
            2'b00: T2_str = "GREEN ";
            2'b01: T2_str = "YELLOW";
            2'b10: T2_str = "RED   ";
            default: T2_str = "UNKWN ";
        endcase
    end

    // Print when anything changes
    initial begin
        $monitor("Time: %0d | T1: %s | T2: %s | T1_WALK = %b | T2_WALK = %b | Buzzer = %b | E_Left = %b | E_Right = %b",
                 $time, T1_str, T2_str, T1_WALK, T2_WALK, buzzer, Emergency_Left, Emergency_Right);
    end

    // Stimulus
    integer i;
    initial begin
        $display("\n=== T-Junction Traffic Light Controller Simulation Started ===\n");

        Emergency_Left = 0;
        Emergency_Right = 0;
        reset = 1;
        #1;
        reset = 0;
        $display("=== Reset at t=%0d ===", $time);

        // Normal operation
        #200

        // Emergency Left
        Emergency_Left = 1;
        #12;
        Emergency_Left = 0;

        // Pause
        #20;

        // Emergency Right
        Emergency_Right = 1;
        #12;
        Emergency_Right = 0;

        // Final normal
        #20;

        $display("\n=== Simulation Complete ===\n");
        $finish;
    end

endmodule

