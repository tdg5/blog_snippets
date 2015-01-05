#!/bin/bash

TEST_FILE_SIZE=128M

for BS in 512 1K 2K 4K 8K 16K 32K 64K 128K 256K 512K 1M 2M 4M 8M 16M 32M 64M
do
  TEST_FILE=${1:-dd_bs_testfile}
  result=$(dd if=/dev/zero of=$TEST_FILE iflag=count_bytes bs=$BS count=$TEST_FILE_SIZE 2>&1 1>/dev/null | grep --only-matching -E '[0-9.]+ [MGk]?B/s')
  rm $TEST_FILE
  echo "$BS: $result"
done
