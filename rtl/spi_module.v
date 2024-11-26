module spi_module (
    input clk,
    input rst_n,
    input [31:0] data_config,
    input trans_en,
    input [7:0] i_data,
    output reg [7:0] o_data,
    output interupt_request,
    inout SCK,
    inout MOSI,
    inout MISO,
    inout SS
);

  //=====================================================================
  // 		REGISTER CONFIG MASTER - SLAVE 
  //=====================================================================
  reg [7:0] R_SPI_CONTROL_1;
  reg [7:0] R_SPI_CONTROL_2;
  reg [7:0] R_SPI_STATUS;
  reg [7:0] R_SPI_BAUD_RATE;
  reg [7:0] R_SPI_DATA_SHIFT;
  reg [7:0] R_SPI_DATA;


  reg [3:0] counter_i;
  //DIV FREQUENCE CLOCK WITH 
  reg [11:0] R_counter_div;
  reg [11:0] cal;
  reg M_SCK;
  reg M_SS;
  always @(posedge clk) begin
    cal = (R_SPI_BAUD_RATE[6:4] + 1) * (2 ** R_SPI_BAUD_RATE[2:0]) - 1;
    if (!rst_n) begin
      R_counter_div <= 12'b0;
      cal <= 12'b0;
      M_SCK = R_SPI_CONTROL_1[3];
    end  //    cal = (R_SPI_BAUD_RATE[6:4]+1)*(2**R_SPI_BAUD_RATE[2:0])-1;
    else if ((R_SPI_CONTROL_1[4]) && (R_SPI_CONTROL_1[6] == 1) && (R_SPI_CONTROL_2[1] == 0)) begin
      //MASTER - ENABLE SYS - INTERUP EN - CHECK INTERUP - CONDITION COUNTER
      if (!M_SS) begin
        if (R_counter_div < cal) begin
          R_counter_div = R_counter_div + 1'b1;

        end else begin
          R_counter_div = 0;
          M_SCK = !M_SCK;
        end
      end else M_SCK = R_SPI_CONTROL_1[3];
    end
  end
  assign SCK = (R_SPI_CONTROL_1[4]) ? M_SCK : 1'bZ;




  //=========================================================================
  //		CONFIG MODE MASTER OR SLAVE FOR MODULE
  //=========================================================================
  parameter IDLE = 2'b00;
  parameter MASTER = 2'b01;
  parameter SLAVE = 2'b10;

  reg [1:0] STATUS;

  always @(posedge clk) begin
    if (!rst_n) begin
      R_SPI_CONTROL_1 <= 8'b0000100;
      R_SPI_CONTROL_2 <= 8'b0;
      R_SPI_STATUS <= 8'b0010000;
      R_SPI_BAUD_RATE <= 8'b0;
      R_SPI_DATA_SHIFT <= 8'b0;
      R_SPI_DATA <= 8'b0;
      STATUS <= IDLE;
      o_data <= 8'b0;
    end else if (STATUS == IDLE) begin
      R_SPI_CONTROL_1 = data_config[31:24];
      R_SPI_CONTROL_2 = data_config[23:16];
      R_SPI_STATUS = data_config[15:8];
      R_SPI_BAUD_RATE = data_config[7:0];
      if (R_SPI_CONTROL_1[4]) begin
        STATUS = MASTER;
      end
      if (!R_SPI_CONTROL_1[4]) begin
        STATUS = SLAVE;
      end
    end


  end
  //reg [31:0]reg_data_config;



  //==========================================================
  //	INTERUPT REQUEST IF CONFIG CHANGE AND INTERUPT EN
  //==========================================================
  always @(posedge clk) begin
    if (STATUS != IDLE) begin
      if((R_SPI_CONTROL_1 != data_config[31:24]) || (R_SPI_CONTROL_2 != data_config[23:16]) || (R_SPI_BAUD_RATE != data_config[7:0])) begin

        if (R_SPI_CONTROL_1[7] == 0) STATUS <= IDLE;
        else begin
          R_SPI_STATUS[4] = 1'b1;
          R_SPI_CONTROL_1[6] = 1'b0;
        end
      end
    end
  end



  //==========================================================
  //			 MASTER MODE
  // =========================================================
  reg M_MOSI;

  always @(posedge clk) begin
    if (!rst_n) begin
      counter_i <= 4'b0;
      M_MOSI <= 1'b0;
      M_SS <= 1'b1;
    end
  end
  always @(posedge trans_en) begin
    if (STATUS == MASTER) begin
      counter_i = 4'b0;
      //        R_SPI_DATA = i_data;
      //        R_SPI_DATA_SHIFT = R_SPI_DATA;
      //        R_SPI_STATUS[7] = 1'b0;
      M_SS = 1'b0;
    end
  end


  // DETECTED MODE - DON'T RUN
  // always @(posedge SCK) begin
  //     if((R_SPI_CONTROL_1[6])&&(STATUS == MASTER)) begin
  //         if(R_SPI_CONTROL_2[4]&&(!R_SPI_CONTROL_1[1]))begin //check master detecting erro master
  //             R_SPI_CONTROL_1[4] <= 1'b0;
  //             STATUS <= SLAVE;
  //             R_SPI_STATUS[4] <= 1'b1;
  //         end
  //     end

  // end

  assign SS = ((STATUS == MASTER) && (R_SPI_CONTROL_1[1])) ? M_SS : 1'bz;

  //MASTER TRANS
  always @(negedge SS) begin
    if (STATUS == MASTER) begin
      R_SPI_DATA = i_data;
      R_SPI_DATA_SHIFT = R_SPI_DATA;
      R_SPI_STATUS[7] = 1'b0;
    end
  end
  always @(posedge SS) begin
    if (STATUS == MASTER) begin
      o_data = R_SPI_DATA_SHIFT;
      R_SPI_STATUS[7] = 1'b1;
    end
  end
  always @(posedge M_SCK) begin
    if ((!R_SPI_CONTROL_2[0]) && (STATUS == MASTER) && (R_SPI_CONTROL_1[6])) begin  //checl SPC0
      if ((R_SPI_CONTROL_1[2])) begin  // CPHA
        if (R_SPI_CONTROL_1[0] == 1'b1) begin
          M_MOSI = R_SPI_DATA_SHIFT[7];
        end else begin
          M_MOSI = R_SPI_DATA_SHIFT[0];
        end
      end
    end
  end
  always @(negedge M_SCK) begin
    if ((!R_SPI_CONTROL_2[0]) && (STATUS == MASTER) && (R_SPI_CONTROL_1[6])) begin  //checl SPC0
      if ((R_SPI_CONTROL_1[2]) && (!R_SPI_STATUS[7])) begin  // CPHA
        if (R_SPI_CONTROL_1[0] == 1'b1) begin
          R_SPI_DATA_SHIFT = {R_SPI_DATA_SHIFT[6:0], MISO};
          counter_i = counter_i + 1;
        end else begin
          R_SPI_DATA_SHIFT = {MISO, R_SPI_DATA_SHIFT[7:1]};
          counter_i = counter_i + 1;
        end
        if (counter_i == 8) M_SS = 1'b1;
      end
    end
  end

  assign interupt_request = (R_SPI_CONTROL_1[7] && R_SPI_STATUS[4]) ? 1'b1 : 1'b0;
  assign MOSI = ((!R_SPI_STATUS[7]) && (STATUS == MASTER)) ? M_MOSI : 1'bz;


  //==========================================================
  // 		SLAVE MODE
  //==========================================================
  wire S_CLK;
  assign S_CLK = SCK;
  reg S_MISO;
  always @(negedge SS) begin
    if (STATUS == SLAVE) begin
      R_SPI_DATA = i_data;
      R_SPI_DATA_SHIFT = R_SPI_DATA;
      R_SPI_STATUS[7] = 1'b0;
    end
  end
  always @(posedge SS) begin
    if (STATUS == SLAVE) begin
      o_data = R_SPI_DATA_SHIFT;
      R_SPI_STATUS[7] = 1'b1;
    end
  end


  always @(posedge clk) begin
    if (!rst_n) begin
      S_MISO <= 1'b0;
    end
  end
  // SLAVE TRANS
  always @(posedge SCK) begin

    if ((!R_SPI_CONTROL_2[0]) && (STATUS == SLAVE) && (R_SPI_CONTROL_1[6])) begin  //check SPC0
      if ((R_SPI_CONTROL_1[2]) && (!R_SPI_STATUS[7]) && (!SS)) begin  // CPHA
        if (R_SPI_CONTROL_1[0] == 1'b1) S_MISO = R_SPI_DATA_SHIFT[7];
        else S_MISO = R_SPI_DATA_SHIFT[0];
      end
    end
  end
  always @(negedge SCK) begin
    if ((!R_SPI_CONTROL_2[0]) && (STATUS == SLAVE) && (R_SPI_CONTROL_1[6])) begin  //checl SPC0
      if ((R_SPI_CONTROL_1[2]) && (!R_SPI_STATUS[7]) && (!SS)) begin  // CPHA
        if (R_SPI_CONTROL_1[0] == 1'b1) R_SPI_DATA_SHIFT = {R_SPI_DATA_SHIFT[6:0], MOSI};
        else R_SPI_DATA_SHIFT = {MOSI, R_SPI_DATA_SHIFT[7:1]};
      end
    end
  end

  assign MISO = ((STATUS == SLAVE) && (!R_SPI_STATUS[7])) ? S_MISO : 1'bz;

endmodule
