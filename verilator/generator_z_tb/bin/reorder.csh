#!/bin/csh -f

unset HELP
if ("$1" == "--help") set HELP
if ($#argv == 0) set HELP
# if ("$1" == "--help") then
if ($?HELP) then
  echo "Example:"
  echo "  $0 r5_after/onebit_bool.bsa > r5_after/onebit_bool_reordered.bsa"
  exit
endif

grep -v '#' $1 | egrep . > tmp$$
cat tmp$$ | egrep -v '^..00' > tmp$$.1
cat tmp$$ | egrep    '^..00' > tmp$$.2
cat tmp$$.1 tmp$$.2

