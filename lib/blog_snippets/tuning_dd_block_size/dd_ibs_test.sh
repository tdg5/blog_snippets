#!/bin/bash

TEST_FILE=${1:-dd_ibs_testfile}
TEST_FILE_SIZE=128M

# Exit if file exists
[ -e $TEST_FILE ] && exit 1

# Create test file
dd if=/dev/urandom of=$TEST_FILE iflag=count_bytes bs=64K count=$TEST_FILE_SIZE > /dev/null 2>&1

for block_size in 512 1K 2K 4K 8K 16K 32K 64K 128K 256K 512K 1M 2M 4M 8M 16M 32M 64M
do
  # Read test file out to /dev/null with specified block size
  dd_result=$(dd if=$TEST_FILE of=/dev/null iflag=count_bytes bs=$block_size count=$TEST_FILE_SIZE 2>&1 1>/dev/null)

  # Extract transfer rate
  transfer_rate=$(echo $dd_result | \grep --only-matching -E '[0-9.]+ [MGk]?B/s')

  echo "$block_size: $transfer_rate"
done

# Clean up
rm $TEST_FILE
