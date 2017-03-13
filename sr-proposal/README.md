For a quick example of how Steve's proposal works, you can do this
(assumes github repository is mapped to CGRA/ and that the "make" and
"Genesis2.pl" commands are both working and available in your path):

<pre>
  % cd CGRA/sr-proposal

  % ls */test_pe.svp
    tst/test_pe.svp

  % make gen GENESIS_TOP=test_pe

  % ls */test_pe.sv
    genesis_verif/test_pe.sv

  % ./genesis_clean.cmd
</pre>

What did this do?  Well, if everything worked correctly...
* the "make" command used the information in CGRA/Makefile to find and
  process the Genesis file tst/test_pe.svp, producing the verilog file
  genesis_verif/test_pe.sv
* the "genesis_clean.cmd" cleaned everything up and put it back the
  way it was before you started the example.

