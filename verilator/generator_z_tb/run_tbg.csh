#!/bin/csh -f

# This is tbg.csh. It replaces run.csh (eventually maybe)

# Can't believe I have to do this...
set path = (. $path)

# Local flow (test):
# - run.csh calls build_cgra.sh to do the initial generate
# - run.csh uses pre-built io, map files in bitstream/example3 to build config file
# - builds small parrot
# 
# Travis flow (CGRAFlow/.travis.yml)
# - travis script calls "build_cgra.sh" to do the initial generate
# - travis script calls PNR to build map, io info from generated cgra_info.txt
# - builds the full parrot
# 
# Travis flow (CGRAGenerator/.travis.yml)
# - travis script calls "build_cgra.sh" to do the initial generate
# - travis script calls run.csh using pre-built bitstream w/embedded io info
# - builds small parrot

########################################################################
# Sometimes may need to know what branch we are in (currently unused)
set branch = `git rev-parse --abbrev-ref HEAD`
echo "${0:t}: I think we are in branch '$branch'"

# DEFAULTS
set GENERATE  = "-gen"     # Generate CGRA from scratch
set BUILD                  # (re)build simulator from scratch
set DELAY = '0,0'

set hwtop = ../../hardware/generator_z/top

########################################################################
# Also see $hwtop/bin/show_cgra_info.csh
# FIND MEMTILE HEIGHT; top.v will have e.g.
# 
# // Parameter mem_tile_height 	= 1
# // mem_tile_height (_GENESIS2_EXTERNAL_XML_PRIORITY_) = 1
# 
# Assumes height must be either 1 or 2
set memtile_height = 1
echo ""
echo "top.v:"
grep mem_tile_height $hwtop/genesis_verif/top.v
grep mem_tile_height $hwtop/genesis_verif/top.v \
  | tail -n 1 \
  | egrep 'mem_tile_height[^0-9]*2$' \
  && set memtile_height = 2

########################################################################
# Default configuration bitstream: 16x16 pointwise mul-by-two
# 
set b = ../../bitstream/examples

if ($memtile_height == 1) set config = $b/pw2_16x16_shortmem.bsa
if ($memtile_height == 2) set config = $b/pw2_16x16.bsa


if ($memtile_height == 1) set config = $b/pw_padring_shortmem.bsa
if ($memtile_height == 2) then
  set config = sorry_no_tallmem_config_exists_yet
  echo ""
  echo WARNING "There is no default config file for tallmem (yet)"
  echo WARNING "There is no default config file for tallmem (yet)"
  echo WARNING "There is no default config file for tallmem (yet)"
  echo ""
endif

echo "run.csh: Looks like memtile_height is $memtile_height"
echo ""

# Note pointwise w/'conv_bw' should take ~4000 cycles to complete
set input     = io/conv_bw_in.png

# Build a tmp space for intermediate files
set tmpdir = `mktemp -d /tmp/run.csh.XXX`

set nclocks = "1M"
set outpad  = 's1t0'
set output  = $tmpdir/output.raw
set out1    = $tmpdir/onebit.raw
set tracefile = ""

if ($#argv == 1) then
  if ("$argv[1]" == '--help') then
    echo "Usage:"
    echo "    $0 <textbench.cpp> -q [-gen | -nogen] [-nobuild]"
    echo "        -usemem -allreg"
    echo "        -config <config_filename.bs>"
    echo "        -input   <input_filename.png>"
    echo "        -output <output_filename.raw>"
    echo "        -out1 s1t0 <1bitout_filename>",
    echo "        -delay <ncy_delay_in>,<ncy_delay_out>"
    echo "       [-trace   <trace_filename.vcd>]"
    echo "        -nclocks <max_ncycles e.g. '100K' or '5M' or '3576602'>"
    echo "        -build  # (overrides SKIP_RUNCSH_BUILD)"
    echo "        -nobuild # no genesis, no verilator build"
    echo "        -nogen   # no genesis"
    echo "        -gen     # genesis"
    echo
    echo "Defaults:"
    echo "    $0 top_tb.cpp \"
    echo "       $GENERATE         \"
    echo "       -config  $config \"
    echo "       -input   $input  \"
    echo "       -output  $output \"
    echo "       -out1    $outpad $out1 \"
    echo "       -delay   $DELAY \"
    if ("$tracefile" != "") then
      echo "       -trace $tracefile \"
    endif
    echo "       -nclocks $nclocks"
    echo
    exit 0
  endif
endif

# NO don't cleanup might want this later (for -nobuild)...
# # CLEANUP
# foreach f (obj_dir counter.cvd tile_config.dat)
#   if (-e $f) rm -rf $f
# end

set VERBOSE
set VERILATOR_DEBUG = ""
while ($#argv)
  # echo "Found switch '$1'"
  switch ("$1")

    case 'top_tb.cpp':
      echo "${0:t} WARNING deprecated switch '$1', don't need that no more"; breaksw

    ##############################
    # switches: VERBOSITY
    case '-q':
      unset VERBOSE; breaksw;
    case '-v':
      set VERBOSE; breaksw;

    ##############################
    # switches: GEN/NOGEN BUILD/NOBUILD
    case '-gen':
      set GENERATE = '-gen'; breaksw;

    case '-nobuild':
      set GENERATE = '-nogen'; unset BUILD; breaksw;

    case '-nogen':
      set GENERATE = '-nogen'; breaksw;

    case '-build':
    case '-rebuild':
        echo WARNING You asked for it with -build
        echo WARNING Will rebuild Vtop from scratch...
        echo "rm build/*"
        if (-d build) rm build/*
        unsetenv SKIP_RUNCSH_BUILD; breaksw

    ########################################
    # Switches: programming the CGRA
    case '-config':
      set config = "$2"; shift; breaksw

    # "bitstream" is an alias for "config"
    case '-bitstream':
      set config = "$2"; shift; breaksw

    case -delay:
      set DELAY = "$2"; shift; breaksw

    ########################################
    # Switches: I/O
    case '-config':
      set config = "$2"; shift; breaksw

    case -input:
      set input = "$2"; shift; breaksw

    case -output:
      set output = "$2"; shift; breaksw

    case -out1:
      set outpad = $2; shift;
      set out1   = $2; shift;
      breaksw;

    ########################################
    # Switches: Debugging

    case -trace:
      set tracefile = "$2"; shift; breaksw

    case --verilator_debug:
      set VERILATOR_DEBUG = "--debug"; breaksw

    ########################################
    # Switches: Misc

    case -nclocks:
      # will accept e.g. "1,000,031" or "41K" or "3M"
      set nclocks = $2;
      shift; breaksw

    default:
        echo ""
        echo "ERROR: Unknown switch '$1'"
        echo ""
        exec $0 --help
        set EXIT13; goto DIE
  endsw
  shift;
end

# VERBOSE or no
if   ($?VERBOSE) set VSWITCH = '-v'
if (! $?VERBOSE) set VSWITCH = '-q'

unset ONEBIT
if (${config:t:r} == 'onebit_bool') set ONEBIT

# Need this on more than one path...
set io_config = `pwd`/io/2in2out.json
echo ""
echo "${0:t}: Using standard io file '$io_config:t'"

if ($?ONEBIT) then
  set io_config = `pwd`/io/s2in_s1t0out.io.json
  echo -n "$0:t aha it's the onebit thing - "
  echo    "i will try using $io_config instead"
endif

# This is the default now...
# if ($?TWO_IN_TWO_OUT) then
#   set io_config = `pwd`/io/2in2out.io.json
#   echo -n "$0:t oh wait it's 2in2out okay..."
#   echo    "i will use '$io_config' for io config"
# endif

# Note I think the new default works for cascade as well, but it's not yet been tested...
# From Lenny, for cascade
unset CASCADE
# if (${config:t:r} == 'cascade') set CASCADE
# works for e.g. "cascade" or "cascade_keyi"
if `expr "${config:t:r}" : 'cascade'` set CASCADE
if ($?CASCADE) then
  set io_config = `pwd`/io/cascade_fixed.bsb.json
  echo -n "$0:t oh wait it's cascade"
  echo    "i will use '$io_config' for io config"
endif

# if ($?VERBOSE) then
if (1) then
  # Backslashes line up better when printed...
  echo ''
  echo "Running with the following switches:"
  echo "$0 $VSWITCH \"
  echo "   $GENERATE \"
  if (! $?BUILD) echo "   -nobuild \"
  echo "   -config $config \"
  echo "   -input  $input \"
  echo "   -output $output \"
  echo "   -out1   $outpad $out1 \"
  echo "   -delay  $DELAY \"
  if ("$tracefile" != "") then
    echo "   -trace   $tracefile \"
  endif
  echo "   -nclocks $nclocks"
endif

if (! -e $config) then
  echo "${0:t}: ERROR Cannot find config file '$config'"
  exit 13
endif

########################################################################
# Detect if running from within travis
unset TRAVIS
if ($?TRAVIS_BUILD_DIR) then
  echo "${0:t}: I think we are running from travis"
  set TRAVIS

  # Use this to extend time on travis
  ./my_travis_wait.csh 15 &
endif

# Turn nclocks into an integer e.g. "6K" => "6000"
set nclocks = `echo $nclocks | sed 's/,//g' | sed 's/K/000/' | sed 's/M/000000/'`
set nclocks = "-nclocks $nclocks"

# Process config file here, then only have to do it ONCE

  # Clean up config file for verilator use
  grep -v '#' $config | grep . > $tmpdir/${config:t:r}.bs
  set config = $tmpdir/${config:t:r}.bs

  # Here's some terrible hackiness
  # if ($?ONEBIT) then
  if (1) then
    echo ''
    echo 'HACK WARNING found onebit_bool config'
    echo 'HACK WARNING found onebit_bool config'
    echo 'HACK WARNING found onebit_bool config'
    echo "bin/reorder.csh $config > $tmpdir/${config:t:r}_reordered.bs"
    echo ""
    bin/reorder.csh $config > $tmpdir/${config:t:r}_reordered.bs
    set config = $tmpdir/${config:t:r}_reordered.bs
  endif

  # Quick check of goodness in config file (again)
  # Early out before waste time simulating
  ./verify_bitstream_goodness.csh $config || exit 13

  # Filenames must be absolute, not relative
  if (! `expr "$config" : /`) set config = "`pwd`/$config"
  if (! `expr "$input"  : /`) set input  = "`pwd`/$input"
  if (! `expr "$output" : /`) set output = "`pwd`/$output"

if (! $?BUILD) then
  echo ""
  echo "Skipping generate and build b/c you asked me to..."
  goto RUN_SIM
endif


GENERATE:
  # How about skip generator if
  # running on travis AND already built cgra_info.txt
  #
  set gbuild = ../../hardware/generator_z/top
  if ($?TRAVIS) then
    if (-e $gbuild/cgra_info.txt) then
      echo '#####################################################################'
      echo  ${0:t}: I am in a travis script AND I found an existing cgra_info.txt
      echo  Therefore skipping generator step
      echo '#####################################################################'
      goto AFTER_GENERATE
    endif
  endif

  echo
  if ("$GENERATE" == "-nogen") then
    echo "${0:t}: No generate!"
    echo "${0:t}: Not building CGRA because you set '-nogen'..."
  else
    # echo "${0:t}: Building CGRA because you asked for it with '-gen'..."
    echo "${0:t}: Building CGRA because it's the default..."


    if ($?VERBOSE) echo "${0:t}: $gbuild/build_cgra.sh"
    pushd $gbuild >& /dev/null; ./build_cgra.sh || set EXIT13; popd >& /dev/null
    if ($?VERBOSE) $gbuild/bin/show_cgra_info.csh
    if ($?EXIT13) goto DIE
  endif

AFTER_GENERATE:
  ########################################################################
  # Build or not build?

  if ($?SKIP_RUNCSH_BUILD) then
    echo "WARNING: IGNORING ENV VAR 'SKIP_RUNCSH_BUILD'"
    echo "WARNING: IGNORING ENV VAR 'SKIP_RUNCSH_BUILD'"
    echo "WARNING: IGNORING ENV VAR 'SKIP_RUNCSH_BUILD'"
    unset SKIP_RUNCSH_BUILD

#     echo "WARNING SKIPPING SIMULATOR BUILD B/C FOUND ENV VAR 'SKIP_RUNCSH_BUILD'"
#     echo "WARNING SKIPPING SIMULATOR BUILD B/C FOUND ENV VAR 'SKIP_RUNCSH_BUILD'"
#     echo "WARNING SKIPPING SIMULATOR BUILD B/C FOUND ENV VAR 'SKIP_RUNCSH_BUILD'"
#     goto RUN_SIM
  endif

  # Oops no this does not fly w/tbg; must recompile when bitstream changes
  if ("${0:t}" == run_tbg.csh) goto BUILD_SIM

  # How about skip verilator build if
  # running on travis AND already built obj_dir/Vtop
  #
  if ($?TRAVIS) then
    if (-e obj_dir/Vtop) then
      echo '##################################'
      echo  I am in a travis script AND
      echo  I found an existing obj_dir/Vtop
      echo  Therefore skipping verilator build
      echo '##################################'
      goto RUN_SIM
    endif
  endif


BUILD_SIM:
  echo ''
  echo '------------------------------------------------------------------------'
  echo "${0:t}: Building the verilator simulator executable..."

  # Builds verilator simulator obj_dir/Vtop
  echo  "build_simulator_tbg.csh $VSWITCH \"
  echo  "  $config:t $io_config:t \"
  echo  "  $input:t $output:t \"
  echo  "  $tracefile:t"
  ./bin/build_simulator_tbg.csh $VSWITCH $config $io_config $input $output $tracefile || exit 13


RUN_SIM:
  echo '------------------------------------------------------------------------'
  echo "${0:t}: Run the simulator..."
  echo ''

  if ($?VERBOSE) echo '  First prepare input and output files...'

  # Prepare an input file
  #   if input file has extension ".png" => convert to raw
  #   if input file has extension ".raw" => use input file as is

  set t = `io/process_input.csh $VSWITCH $input $tmpdir | tail -1`
  set input = $t

  # If no trace requested, simulator will not create a waveform file.
  set trace = ''
  if ("$tracefile" != "") then
    set trace = "-trace $tracefile"
  endif










  # For 'quiet' execution, use these two filters to limit output;
  # Otherwise just cat everything to stdout
  if (! $?VERBOSE) then
    set quietfilter = (egrep -v "Cycle: [1-9]00")
    set qf2 = (grep -v "^000[23456789].*Two times")
  else
    set quietfilter = (cat)
    set qf2         = (cat)
  endif

  ########################################################################
  if ($?VERBOSE) then
    echo
    echo "BITSTREAM '$config':"
    cat $config
  endif

# # If no output requested, simulator will not create an output file.
# set out = ''
# if ($?output) then
#     set out = "-output $output"
# endif

  echo ''
  echo "${0:t}: TIME NOW: `date`"
# echo "${0:t}: Vtop -output $output:t -out1 $outpad $out1:t"

set TestBenchGenerator = `cd ../../../TestBenchGenerator; pwd`
pushd build >& /dev/null
  # What does this do?  Turn png into raw maybe?
  # Hm looks like it adds zeroes to end of input file according to DELAY value
  echo python3 $TestBenchGenerator/process_input.py $io_config $input $DELAY

  python3 $TestBenchGenerator/process_input.py $io_config $input $DELAY

#   echo ""
#   echo od -t u1 io16in_in_arg_1_0_0.raw
#   od -t u1 io16in_in_arg_1_0_0.raw
#   echo ""

  # Cut down 10x on "Cycle" output thingies
  ./Vtop |  egrep -v '([^0]0$|[^0]00$)' \
      | tee $tmpdir/run.log.$$

  # Hm appears to do funny hacks in case of conv_1_2 or conv_bw
  echo python3 $TestBenchGenerator/process_output.py $io_config $output bw $DELAY
  python3 $TestBenchGenerator/process_output.py $io_config $output bw $DELAY


  if ($?ONEBIT) then
    set echo
    ls -lt *.raw | head
    cp io16in_in_arg_1_0_0.raw $output 
    cp io1_out_0_0.raw $out1
    unset echo
  endif


popd >& /dev/null

  if ($?VERBOSE) then
    echo ""
    echo "ub.  so i guess i built this maybe:"
    ls -l $output
    echo ""
  endif

  echo -n " TIME NOW: "; date

  unset FAIL
  # Hm I think this ALWAYS fails if test is not pointwise!!?
  # grep FAIL   $tmpdir/run.log.$$ && set FAIL
  grep %Error $tmpdir/run.log.$$ && set FAIL

  if ($?FAIL) then
    echo ${0:t} 676 oops looks like something bad must have happened
    cat $tmpdir/run.log.$$
    # set EXIT13
    # goto DIE
  endif

  echo ""
  echo "# ${0:t}: Reminder config was $config:t:r"
  echo "# Show output vs. input; output should be 2x input for most common testbench"

  if (! $?input) echo "what?  how?"
  if (1) then
    echo ''
#     ls -l $input
#     ls -l $output

    if ("$output:t" == "conv_1_2_CGRA_out.raw") then
      # echo; set cmd = "od -t u1 $output"; echo $cmd; $cmd | head

      echo; echo "FOUND conv_1_2 output; converting to 9x9..."
      ./bin/conv_1_2_convert < $output > $tmpdir/tmp.raw
      mv $tmpdir/tmp.raw $output
      ls -l $output

      # echo; set cmd = "od -t u1 $output"; echo $cmd; $cmd | head

    endif

    if ("$output:t" == "conv_bw_CGRA_out.raw") then
      echo; echo "FOUND conv_bw output; converting to 62x62..."
      ./bin/crop31 < $output > $tmpdir/tmp.raw
      mv $tmpdir/tmp.raw $output
      ls -l $output
    endif

    echo
    set cmd = "od -t u1 $input"
    echo "INPUT  $cmd"; $cmd | head; echo ...; $cmd | tail -n 3

    if ($?ONEBIT) then
      echo ''
      echo ONEBIT OUTPUT
      echo out1 = $out1:t
      echo output = $output:t
      (cd $output:h; ls -l $output:t $out1:t || echo oop)
      
#       echo ''
#       # TBG produced $output (I think) but tb will compare to $out1 (I think)
#       echo cp $output $out1
#       cp $output $out1
#       (cd $output:h; ls -l $output:t $out1:t || echo oop)

    endif

    echo ''
    set cmd = "od -t u1 $output"
    echo "OUTPUT $cmd"; $cmd | head; echo ...; $cmd | tail -n 3
    echo ''
  endif

  if ($?FAIL) then
    echo ${0:t} 720 oops looks like something bad must have happened
    set EXIT13
    goto DIE
  endif

# Tell how to clean up (not necessary for travis VM of course)
# if (`hostname` == "kiwi") then
set pwd = `pwd`
if (! `expr $pwd : /home/travis`) then
  set gbuild = ../../hardware/generator_z/top
  cat << eof

  ********************************************************************
  NOTE: If you want to clean up after yourself you'll want to do this:
  
    ./${0:t} -clean
    pushd $gbuild; ./genesis_clean.cmd; popd
  
  ********************************************************************
eof
endif

# Need this to kill background job(s)
DIE:
  if ($?TRAVIS) then
    echo Time...to die.
    jobs >& /tmp/joblist-$$
    if ( "`cat /tmp/joblist-$$`" != '' ) then
      echo "killing 'my_travis' background job(s)"
      cat /tmp/joblist-$$
      # Wait for stdout to settle I guess
      sleep 10
      kill -9 %1 || echo "Nothing to kill maybe; that's okay."
      sleep 10
      jobs
    endif
  endif
  if ($?EXIT13) then
    echo oops 768 looks like something bad must have happened
    exit 13
  endif
