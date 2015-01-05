#!/bin/bash

TEST_FILE=${1:-dd_obs_testfile}
TEST_FILE_SIZE=128M

for block_size in 512 1K 2K 4K 8K 16K 32K 64K 128K 256K 512K 1M 2M 4M 8M 16M 32M 64M
do
  # Create a test file with the specified block size
  dd_result=$(dd if=/dev/zero of=$TEST_FILE iflag=count_bytes bs=$block_size count=$TEST_FILE_SIZE 2>&1 1>/dev/null)

  # Extract the transfer rate from dd's STDERR output
  transfer_rate=$(echo $dd_result | \grep --only-matching -E '[0-9.]+ [MGk]?B/s')

  # Clean up the test file and output result
  rm $TEST_FILE
  echo "$block_size: $transfer_rate"
done
