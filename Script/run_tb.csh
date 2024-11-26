
#Author: HoangLM43, PhuocHVD

#!/bin/csh 
echo "test:"
set test1 =( 'test_trans.sv' 'test_baud_rate_no_interrupt.sv' 'test_baud_rate_interrupt.sv' 'test_trans_msb_lsb_no_interrupt.sv' 'test_trans_msb_lsb_interrupt.sv' )
set cr_test = $<
# Path to the custom directory you want to navigate to
set custom_dir = "/home/DN02/SPI_Work/SPI/runDir"

# Path to the file to simulate
set file_path = "/home/DN02/SPI_Work/SPI/test/sim/src_cp/tb_spi.sv"  # Or your RTL or testbench file name

# Check if the directory exists
if (-d $custom_dir) then
    # Navigate to the custom directory
    cd $custom_dir
    echo "Changed to directory: $custom_dir"

    # Check if the file exists in the specified path 
    if (-e $file_path) then
        echo "Running the file with xrun..."
	sed -i "s/test_.*.sv/$test1[$cr_test]/" $file_path
        # Use xrun to simulate the file
        xrun -access +rwc -sv -gui  $file_path
    else
        echo "File not found in $custom_dir: $file_path"
    endif
else
    echo "Directory not found: $custom_dir"
endif

