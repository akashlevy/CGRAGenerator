KNOWN BUGS IN THE TAPED_OUT CHIP

UNDER CONSTRUCTION as of 1/2019, still need to add 1-bit bug etc.

For more information see Issue 22
- https://github.com/StanfordAHA/CGRAGenerator/issues/122

and/or markdown file in hw top (not yet in master as of 1/2019...)
- https://github.com/StanfordAHA/CGRAGenerator/blob/dev/hardware/generator_z/top/Bugs.md

and/or wiki page
- https://github.com/StanfordAHA/CGRAGenerator/wiki/Bugs


FIXME/HELPME These notes need to be cleaned up!

= Arithmetic right-shift ASHR =

The taped-out chip has no working arithmetic right-shift (MAYBE see
question below). The original verilog used unsigned inputs with a
$signed() conversion where needed. Later it was found that ncsim did
not honor this convention, so Alex fixed it in commit
cafa5a5791fa9d76f922f4f48a60d5b47200ae93 on Aug 28 2018 (after
tapeout):

ORIGINAL CODE:
-  input        [DataWidth-1:0] a,
-  input        [B_MSB:0]       b,
-
-  assign shift_res = (is_signed & !dir_left) ? 
-                     $signed(shift_inp) >>> b[B_MSB:0] : 
-                     (shift_inp >> b[B_MSB:0]);

"FIXED" CODE:
+  input signed [DataWidth-1:0] a,
+  input signed [B_MSB:0]       b,
+
+  assign shift_res = (is_signed & !dir_left) ? 
+                     (shift_inp >>> b[B_MSB:0]) : 
+                     (shift_inp  >> b[B_MSB:0]) ;

QUESTION: Was this an actual bug in the taped-out chip, or is it just
a problem with ncsim???

ANSWER: Keyi and Teguh (et al.?) tried this on the actual chip; it
doesn't work.

WORKAROUND: I don't think we have an official workaround yet?

Note Harris is the first (and so far only) app to actually
use ashr, which is why it took so long to find the bug.



<!-------------------------------------------------------------------->
= No XOR in PE spec =

?? I think the original PE spec neglected to list XOR as a valid
operation...but that spec has been replaced by this updated one
(below) I think??

https://github.com/StanfordAHA/CGRAGenerator/wiki/PE-Spec#pe_instruction_decode_31_16



<!-------------------------------------------------------------------->
= Odd register default for one-bit bus in memory tiles =

By default, all wires and buses are unregistered as they pass through
the various switchboxes. EXCEPT for one-bit (BUS1) track 0 coming into
side 0 (east side) of any memory tile (BUS1_S0T0).  The switchbox
reset value is set to b0001000..., where the 1 sets reg mode for this
track ONLY.

==== WHY ====

This perl code generates the default vectors in our tapeout branch
"tapeout1":

  //; my $mask = sprintf("%016X", 2**$nonreg_bits - 1);
  config_sb <= `$config_reg_width`'h`$mask`;

16-bit switchboxes and PE-tile one-bit switchboxes have 40 nonregister
bits in the config vector, while one-bit mem tile switchboxes have 60
(see below). Unfortunately, in perl, although 2**40-1 is indeed
0xFF,FFFF,FFFF, 2**60-1 is equal to 0x1000,0000,0000,0000, as
confirmed by the values calculated for the two PE switchboxes and the
single mem switchbox:

  sb_unq1.v:      config_sb <= 64'h000000FFFFFFFFFF;
  sb_unq2.v:      config_sb <= 64'h000000FFFFFFFFFF;
  sb_unq3.v:      config_sb <= 96'h1000000000000000;

==== WORKAROUND ====

The safest thing, if you want to do any one-bit routing, is to
explicitly set all config registers to zero in the defective
switchboxes as the first set of commands in any bitstream:

<pre>
    # MEM_CONFIG_HACK
    # Override buggy mem config default: set bits 32-63 in every memtile to all zeroes
    01000018 00000000
    0100001C 00000000
    01000020 00000000
    ...

    For all memory tiles:
      0018 001C 0020 0024 002B 002F 0033 0037
      003D 0041 0045 0049 004F 0053 0057 005B
      0061 0065 0069 006D 0073 0077 007B 007F
      0085 0089 008D 0091 0097 009B 009F 00A3
      00A9 00AD 00B1 00B5 00BB 00BF 00C3 00C7
      00CD 00D1 00D5 00D9 00DF 00E3 00E7 00EB
      00F1 00F5 00F9 00FD 0103 0107 010B 010F
      0115 0119 011D 0121 0127 012B 012F 0133
</pre>




==============================================================================
NOTES
<pre>

------------------------------------------------------------------------
+   //;# 12/2017 Nikhil changed default to pe_output to avoid loops (note the tilde)
+   //;# config_sb <= ~(`$config_reg_width`'d0);
+   //;#
+   //;# 12/2017 SR changed default so that pe_output is selected AND registers are off
+   //;# Want regs initialized to zero, everything else to 1 e.g. 64'h0000,00FF,FFFF,FFFF
+   //;#   my $mask = sprintf("%016X", 2**$nonreg_bits - 1);
+   //;#   config_sb <= `$config_reg_width`'h`$mask`;
+   //;#
+   //;# SR 5/2018
+   //;# Note perl has insufficient precision to calculate 2**n when n is large!
+   //;# It does not err, just silently gives the wrong answer :(
+   //;# Better: in verilog e.g. {16{1'b1}} = 0xFFFF

tapeout1 branch:


PE tiles have 40 nonregister bits in the config vector, mem tiles have
60 (see below). Unfortunately, in perl, although 2**40-1 is indeed
0xFFFFFFFFFF, 2**60-1 is equal to 0x1000000000000000, as confirmed by
the values calculated in the two PE switchboxes and the single mem switchbox:

  sb_unq1.v:      config_sb <= 64'h000000FFFFFFFFFF;
  sb_unq2.v:      config_sb <= 64'h000000FFFFFFFFFF;
  sb_unq3.v:      config_sb <= 96'h1000000000000000;


For all PE tile buses and mem tile BUS16 only:
  2bits * 5 tracks * 4 sides = 40 bits for routing
  1bit  * 5 tracks * 4 sides = 20 bits for registers

For mem tile BUS1 has 3 bits for routing b/c 7 mux inputs instead of 4:
  3bits * 5 tracks * 4 sides = 60 bits for routing
  1bit  * 5 tracks * 4 sides = 20 bits for registers

...as confirmed in cgra_info.txt for tapeout1:
  <mux snk='out_0_BUS1_S3_T4' reg='1' configh='59' configl='57' configr='79'>
    <src sel='0'>in_0_BUS1_S0_T4</src>
    <src sel='1'>in_0_BUS1_S1_T4</src>
    <src sel='2'>in_0_BUS1_S2_T4</src>
    <src sel='3'>valid</src>
    <src sel='4'>almost_full</src>
    <src sel='5'>almost_empty</src>
  </mux>


==============================================================================


include missing XOR in list of bugs

- DOCUMENT the BUGS! (see below)
- add to wiki: known bugs in taped-out chip

Taped-out chip ISSUES (1809)
- no reset signal / no 1bit input
- ??something to do with ashr??



==============================================================================
NOTES

On Aug 28, 2018, at 3:32 PM, Keyi Zhang <keyi@cs.stanford.edu> wrote:
This is really bad. ashr is not implemented properly on hardware,
which also includes the chip we taped out. Alex and I looked into the
implementation and the wire (LOGIC) is not declared as `signed`, so
`>>>` never works.

I will work with Jeff to see if we can create a design without using
ashr and without using too many PE tiles (we only have 12 PE tiles
left for harris).

Keyi

------------------------------------------------------------------------
Found another hardware bug this afternoon. Any 1-bit track passing
through the MEM, S0T0 to be exact, will use register mode. It's
because the reset value is set to b0001000..., where the 1 set the reg
mode. It was fixed by you some time late in May last year. Taeyoung
said you commented that perl doesn't handle large exponential very
well. Unfortunately it was fixed after the chip taped out. As a
result, we never encountered this bug in the following test cases,
e.g. cascade and harris, which use some 1-bit routing. Alex came up
with a work around: put 0 as config data in that memory tile to reset
that 1 bit.
------------------------------------------------------------------------


# MEM_CONFIG_HACK
# Override buggy mem config default: set bits 32-63 in every memtile to all zeroes
01000018 00000000
0100001C 00000000
01000020 00000000
..
01000133 00000000

For all memory tiles:
  0018 001C 0020 0024 002B 002F 0033 0037
  003D 0041 0045 0049 004F 0053 0057 005B
  0061 0065 0069 006D 0073 0077 007B 007F
  0085 0089 008D 0091 0097 009B 009F 00A3
  00A9 00AD 00B1 00B5 00BB 00BF 00C3 00C7
  00CD 00D1 00D5 00D9 00DF 00E3 00E7 00EB
  00F1 00F5 00F9 00FD 0103 0107 010B 010F
  0115 0119 011D 0121 0127 012B 012F 0133



# MEM_CONFIG_HACK
# Override buggy mem config default: set bits 32-63 in every memtile to all zeroes
01000018 00000000
0100001C 00000000
01000020 00000000
01000024 00000000
0100002B 00000000
0100002F 00000000
01000033 00000000
01000037 00000000
0100003D 00000000
01000041 00000000
01000045 00000000
01000049 00000000
0100004F 00000000
01000053 00000000
01000057 00000000
0100005B 00000000
01000061 00000000
01000065 00000000
01000069 00000000
0100006D 00000000
01000073 00000000
01000077 00000000
0100007B 00000000
0100007F 00000000
01000085 00000000
01000089 00000000
0100008D 00000000
01000091 00000000
01000097 00000000
0100009B 00000000
0100009F 00000000
010000A3 00000000
010000A9 00000000
010000AD 00000000
010000B1 00000000
010000B5 00000000
010000BB 00000000
010000BF 00000000
010000C3 00000000
010000C7 00000000
010000CD 00000000
010000D1 00000000
010000D5 00000000
010000D9 00000000
010000DF 00000000
010000E3 00000000
010000E7 00000000
010000EB 00000000
010000F1 00000000
010000F5 00000000
010000F9 00000000
010000FD 00000000
01000103 00000000
01000107 00000000
0100010B 00000000
0100010F 00000000
01000115 00000000
01000119 00000000
0100011D 00000000
01000121 00000000
01000127 00000000
0100012B 00000000
0100012F 00000000
01000133 00000000

# MEM_CONFIG_HACK
# Override buggy mem config default: set bits 32-63 in every memtile to all zeroes
0018 001C 0020 0024 002B 002F 0033 0037
003D 0041 0045 0049 004F 0053 0057 005B
0061 0065 0069 006D 0073 0077 007B 007F
0085 0089 008D 0091 0097 009B 009F 00A3
00A9 00AD 00B1 00B5 00BB 00BF 00C3 00C7
00CD 00D1 00D5 00D9 00DF 00E3 00E7 00EB
00F1 00F5 00F9 00FD 0103 0107 010B 010F
0115 0119 011D 0121 0127 012B 012F 0133
</pre>
