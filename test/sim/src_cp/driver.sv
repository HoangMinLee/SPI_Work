`include "/home/DN03/SPI_Work/SPI/test/sim/src_cp/transaction.sv"
`define DRIV_ITF i_spi.DRIVER.driver_cb

class driver;
  int no_transaction;
  virtual itf_spi_env i_spi;
  mailbox gen2driv;
  reg [11:0] clock_counter;  // Counter for clock generation
  reg [11:0] cal;  // Clock cycle value for controlling the clock frequency
  reg SCK_reg;  // Register to store the current SCK value

  function new(virtual itf_spi_env i_spi, mailbox gen2driv);
    this.i_spi = i_spi;
    this.gen2driv = gen2driv;
    clock_counter = 12'b0;  // Initialize the clock counter
    cal = 12'd1;  // Set the clock cycle (can be adjusted)
    SCK_reg = 0;  // Initialize the SCK signal
  endfunction

  // Reset task
  task reset;
    wait (i_spi.rst);
    `DRIV_ITF.i_data_p  <= 8'b0;
    `DRIV_ITF.io_miso_s <= 8'b0;
    `DRIV_ITF.trans_en  <= 1'b0;
    `DRIV_ITF.io_mosi_s <= 1'b0;
    `DRIV_ITF.SS        <= 1'b1;  // Deactivate slave select
    wait (!i_spi.rst);
  endtask

  // Main driver task
  task driver;
    transaction trans;
    gen2driv.get(trans);

    // Output setup
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
    `DRIV_ITF.SCK <= 1'b0;

    // Initialize clock cycle generation
    clock_counter <= 12'b0;

    // Always block for SCK generation
    always @(posedge i_spi.DRIVER.clk) begin
      if (!`DRIV_ITF.SS) begin  // Only run when SS is low
        if (clock_counter < cal) begin
          clock_counter <= clock_counter + 1'b1;
        end else begin
          clock_counter <= 12'b0;
          SCK_reg <= ~SCK_reg;  // Toggle SCK
          `DRIV_ITF.SCK <= SCK_reg;
        end
      end else begin
        // When SS goes high, stop clock toggling and set SCK low
        `DRIV_ITF.SCK <= 1'b0;
      end
    end

    // Always block for MOSI transmission
    always @(negedge `DRIV_ITF.SCK) begin
      for (int i = 0; i < 8; i++) begin
        #1;  // Small delay to stabilize signals
        `DRIV_ITF.io_mosi_s <= trans.io_mosi_s[7-i];  // Transfer MOSI data
      end

      // After completing data transfer, set SS to high
      @(posedge i_spi.DRIVER.clk);
      `DRIV_ITF.SS <= 1'b1;  // Deactivate slave select
      trans.interupt_request = `DRIV_ITF.interupt_request;
      repeat (10) @(posedge i_spi.DRIVER.clk);
      no_transaction++;
    end

    end
    
  endtask

  // Main task to run the driver continuously
  task main;
    fork
      begin
        wait (i_spi.rst);
        reset();  // Reset the driver on reset signal
      end
      begin
        forever driver();  // Continuously run the driver task
      end
    join_any
  endtask
endclass
