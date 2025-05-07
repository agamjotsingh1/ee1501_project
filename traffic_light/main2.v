module traffic_light_controller(
    input clk,
    input reset,
    input Emergency_Left,
    input Emergency_Right,
    output reg [1:0] T1,        // 00:G, 01:Y, 10:R
    output reg [1:0] T2,        // 00:G, 01:Y, 10:R
    output reg T1_WALK,
    output reg T2_WALK,
    output reg buzzer
);

    // State definitions
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;
    parameter S5 = 3'b101;
    parameter S6 = 3'b110;
    parameter S7 = 3'b111;

    reg [2:0] current_state, next_state;
    reg [6:0] timer;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S1;
            timer <= 0;
        end else begin
            if (Emergency_Left) begin
                // Emergency left handling
                T1 <= 2'b10; // Red
                T2 <= 2'b00; // Green
                T1_WALK <= 0;
                T2_WALK <= 0;
                buzzer <= 0;
                if (timer >= 10) begin
                    timer <= 0;
                    current_state <= next_state;
                end else begin
                    timer <= timer + 1;
                end

            end else if (Emergency_Right) begin
                // Emergency right handling
                T1 <= 2'b10; // Red
                T2 <= 2'b10; // Red
                T1_WALK <= 0;
                T2_WALK <= 0;
                buzzer <= 0;
                if (timer >= 10) begin
                    timer <= 0;
                    current_state <= next_state;
                end else begin
                    timer <= timer + 1;
                end

            end else begin
                case (current_state)
                    S1: begin
                        T1 <= 2'b00; // Green
                        T2 <= 2'b10; // Red
                        T1_WALK <= 0;
                        T2_WALK <= 0;
                        buzzer <= 0;
                        if (timer >= 30) begin
                            timer <= 0;
                            current_state <= S2;
                        end else begin
                            timer <= timer + 1;
                        end
                    end

                    S2: begin
                        T1 <= 2'b01; // Yellow
                        T2 <= 2'b10; // Red
                        T1_WALK <= 0;
                        T2_WALK <= 0;
                        buzzer <= 0;
                        if (timer >= 5) begin
                            timer <= 0;
                            current_state <= S3;
                        end else begin
                            timer <= timer + 1;
                        end
                    end

                    S3: begin
                        T1 <= 2'b10; // Red
                        T2 <= 2'b10; // Red
                        T1_WALK <= 1;
                        T2_WALK <= 1;

                        if (timer >= 55) begin
                            timer <= 0;
                            current_state <= S4;
                        end else begin
                            timer <= timer + 1;
                        end
                    end

                    S4: begin
                        T1 <= 2'b10; // Red
                        T2 <= 2'b10; // Red
                        T1_WALK <= 1;
                        T2_WALK <= 1;

                        if (timer >= 4) begin
                            timer <= 0;
                            current_state <= S5;
                            buzzer <= 0;
                        end else begin
                            timer <= timer + 1;
                            buzzer <= 1;
                        end
                    end

                    S5: begin
                        T1 <= 2'b10; // Red
                        T2 <= 2'b00; // Green
                        T1_WALK <= 0;
                        T2_WALK <= 0;
                        buzzer <= 0;
                        if (timer >= 30) begin
                            timer <= 0;
                            current_state <= S6;
                        end else begin
                            timer <= timer + 1;
                        end
                    end

                    S6: begin
                        T1 <= 2'b10; // Red
                        T2 <= 2'b01; // Yellow
                        T1_WALK <= 0;
                        T2_WALK <= 0;
                        buzzer <= 0;
                        if (timer >= 5) begin
                            timer <= 0;
                            current_state <= S7;
                        end else begin
                            timer <= timer + 1;
                        end
                    end

                    S7: begin
                        T1 <= 2'b00; // Green
                        T2 <= 2'b10; // Red
                        T1_WALK <= 0;
                        T2_WALK <= 0;
                        buzzer <= 0;
                        if (timer >= 30) begin
                            timer <= 0;
                            current_state <= S1;
                        end else begin
                            timer <= timer + 1;
                        end
                    end

                    default: current_state <= S1;
                endcase
            end
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            S1: next_state = S2;
            S2: next_state = S3;
            S3: next_state = S4;
            S4: next_state = S5;
            S5: next_state = S6;
            S6: next_state = S7;
            S7: next_state = S1;
            default: next_state = S1;
        endcase
    end

endmodule
