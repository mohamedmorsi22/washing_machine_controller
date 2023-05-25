`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2023 08:36:59 AM
// Design Name: 
// Module Name: washing_machine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module washing_machine
   #(parameter N = 4,
               filling_time = 4,
               washing_time = 9, 
               rinsing_time = 4, 
               spining_time = 7
    )  // considering 50 MHz clock and tick every 10 sec
    (
     input clk,rst,
     input coin_in,
     input double_wash,pause,
     output reg wash_done
    );
    
    
    //state assignment
    localparam [2:0] idle = 3'b000,
                     filling_water = 3'b001,
                     washing = 3'b010,
                     rinsing = 3'b011,
                     spining = 3'b100;
    
    reg filling_start,washing_start,rinsing_start,spining_start;
    reg [2:0] state,next_state;
    reg [N-1:0] q_reg,q_next;
    wire tick;
    reg dw_reg;
    
    
                     
    always @(posedge clk, negedge rst)  
    if (~rst)
    q_reg <= 0;
    else 
    q_reg <= q_next;
    
    
    always @(posedge clk, negedge rst)
    if (~rst)
    state <= idle;
    else
    state <= next_state;
    
    
    
    always @(*)
    begin
    wash_done = 1'b0;
    next_state = state;
    q_next = q_reg;
    case (state)
    
    idle:
    if (coin_in)
    next_state = filling_water;
    else
    next_state = idle;
    
    
    
    filling_water:
    if (q_reg == filling_time-1)
    begin
    next_state = washing;
    q_next = 0;
    end
    else
    begin
    next_state = filling_water;
    q_next = q_reg+1;
    end
    
    
    
    washing:
    if (q_reg != washing_time-1)
    begin
    q_next = q_reg+1;
    next_state = washing;
    end
    else
    begin
    wash_done = 1'b1;
    next_state = rinsing;
    q_next = 0;
    end
    
    
    
    
    rinsing:
    begin
    if (q_reg == rinsing_time)
      
      begin
      if (double_wash)
      dw_reg = 1'b1;
      else
      dw_reg = 1'b0;
    
      if (dw_reg)
      begin
      q_next = 0;
      next_state = washing;
      end
      else
      begin
      q_next = 0;
      next_state = spining;
      end
      end
    
    else
    begin
    next_state = rinsing;
    q_next = q_reg+1;
    end
    end
    
    
    
    
    spining:
    if (pause)
    begin
    next_state = spining;
    q_next = q_reg;
    end
    else
    if (q_reg == spining_time)
    begin
    q_next = 0;
    next_state = idle;
    end
    else
    begin
    next_state = spining;
    q_next = q_reg+1;
    end
        
    default: next_state = state;
    endcase
    end
    
    
    
                    
endmodule
