`include "/home/DN03/SPI_Work/SPI/test/sim/src_cp/transaction.sv"
`define DRIV_ITF i_spi.DRIVER.driver_cb

class driver;
  int no_transaction;
  virtual itf_spi_env i_spi;
  mailbox gen2driv;
  reg SCK_reg;
  reg [11:0] clock_counter;
  reg [11:0] cal;  // Clock division factor for controlling frequenc

  function new(virtual itf_spi_env i_spi, mailbox gen2driv);
    this.i_spi = i_spi;
    this.gen2driv = gen2driv;
    clock_counter = 12'b0;
    cal = 12'b0;
    SCK_reg = 0;
  endfunction

  // Reset task
  task reset;
    wait (i_spi.rst);
    `DRIV_ITF.i_data_p  <= 8'b0;
    `DRIV_ITF.io_miso_s <= 8'b0;
    `DRIV_ITF.trans_en  <= 1'b0;
    `DRIV_ITF.io_mosi_s <= 1'b0;
    `DRIV_ITF.SS        <= 1'b1;  // Deactivate slave select
  endtask

  // Main driver task
  task driver;
    transaction trans;
    gen2driv.get(trans);

    @(posedge i_spi.DRIVER.clk);
    `DRIV_ITF.data_config <= trans.data_config;

    if (trans.data_config[28] == 1) begin
      // SPI Master mode transaction
      repeat (10) @(posedge i_spi.DRIVER.clk);
      `DRIV_ITF.i_data_p <= trans.i_data_p;
      `DRIV_ITF.trans_en <= 1'b1;

      for (int i = 0; i < 8; i++) begin
        @(negedge i_spi.SCK);
        `DRIV_ITF.io_miso_s <= trans.io_miso_s[7-i];
      end

      trans.interupt_request = `DRIV_ITF.interupt_request;
      repeat (10) @(posedge i_spi.DRIVER.clk);
      `DRIV_ITF.trans_en <= 1'b0;
      no_transaction++;
    end else begin
      // SPI Slave mode transaction with SCK generation
      repeat (10) @(posedge i_spi.DRIVER.clk);
      `DRIV_ITF.i_data_p <= trans.i_data_p;
      `DRIV_ITF.SS <= 1'b0;  // Activate slave select
      `DRIV_ITF.SCK <= 0;  // Initial state of SCK

      // SCK Generation (generate SCK based on clock counter)
      clock_counter <= 12'b0;

      // Generate SCK until SS is high
      while (!`DRIV_ITF.SS) begin
        @(posedge i_spi.DRIVER.clk);  // Synchronize with the driver's clock
        if (clock_counter < cal) begin
          clock_counter <= clock_counter + 1'b1;
        end else begin
          clock_counter <= 12'b0;
          SCK_reg <= ~SCK_reg;  // Toggle SCK
          `DRIV_ITF.SCK <= SCK_reg;  // Output SCK signal
        end
      end
      // Keep SCK low when SS is high
      `DRIV_ITF.SCK <= 1'b0;

      // Transmit data on MOSI synchronized with SCK
      for (int i = 0; i < 8; i++) begin
        @(posedge `DRIV_ITF.SCK);  // Synchronize with the rising edge of SCK
        #1;  // Small delay for signal stability
        `DRIV_ITF.io_mosi_s <= trans.io_mosi_s[7-i];  // Transmit data on MOSI
      end

      // Pull SS high after transmitting 8 bits
      @(posedge i_spi.DRIVER.clk);
      `DRIV_ITF.SS <= 1'b1;  // End the SPI transaction
      trans.interupt_request = `DRIV_ITF.interupt_request;
      repeat (10) @(posedge i_spi.DRIVER.clk);
      no_transaction++;
    end
  endtask

  // Main task
  task main;
    fork
      begin
        wait (i_spi.rst);
        reset();
      end
      begin
        forever driver();
      end
    join_any
  endtask
endclass
