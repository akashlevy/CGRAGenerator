#!/bin/csh -f

set config = $1

# Quick check of goodness in config file
unset bad_config
set c = '[0-9a-fA-F]'
set goodline = "$c$c$c$c$c$c$c$c $c$c$c$c$c$c$c$c"
egrep -v "$goodline" $config > /tmp/tmp$$ && set bad_config
/bin/rm /tmp/tmp$$
if ($?bad_config) then
  echo
  echo "ERROR Config file '$config' looks bad, man. Bad line(s) include:"
  cat /tmp/tmp$$ | sed 's/^/> /'
  exit 13
endif

