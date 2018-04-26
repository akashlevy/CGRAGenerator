#!/bin/bash
CGRA_INFO_PATH='..'
grep -Po "(?<=<tile type='io1bit' tile_addr='0x).*(?=' r)" $CGRA_INFO_PATH/cgra_info.txt > io1bit_IDs.txt
grep -Po "(?<=<tile type='io16bit' tile_addr='0x).*(?=' r)" $CGRA_INFO_PATH/cgra_info.txt > io16bit_IDs.txt
grep -Po "(?<=<tile type='pe_tile_new' tile_addr='0x).*(?=' r)" $CGRA_INFO_PATH/cgra_info.txt > pe_IDs.txt
grep -Po "(?<=<tile type='memory_tile' tile_addr='0x).*(?=' r)" $CGRA_INFO_PATH/cgra_info.txt > memory_IDs.txt

