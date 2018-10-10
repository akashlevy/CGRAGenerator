#!/usr/bin/python
import re
import sys

# I think we'll have to pull this info directly from the verilog...
# E.g.
# grep PE_FLAG $top/genesis_verif/test_pe_unq1.sv 
#     localparam PE_FLAG_EQ = 4'h0;
#     localparam PE_FLAG_NE = 4'h1;
#     localparam PE_FLAG_CS = 4'h2;
#     localparam PE_FLAG_CC = 4'h3;
#     localparam PE_FLAG_MI = 4'h4;
#     localparam PE_FLAG_PL = 4'h5;
#     localparam PE_FLAG_VS = 4'h6;
#     localparam PE_FLAG_VC = 4'h7;
#     localparam PE_FLAG_HI = 4'h8;
#     localparam PE_FLAG_LS = 4'h9;
#     localparam PE_FLAG_GE = 4'hA;
#     localparam PE_FLAG_LT = 4'hB;
#     localparam PE_FLAG_GT = 4'hC;
#     localparam PE_FLAG_LE = 4'hD;
#     localparam PE_FLAG_LUT = 4'hE;
#     localparam PE_FLAG_PE  = 4'hF;
#     PE_FLAG_EQ  : result_flag = Z;
#     PE_FLAG_NE  : result_flag = ~Z;
#     PE_FLAG_CS  : result_flag = C;
#     PE_FLAG_CC  : result_flag = ~C;
#     PE_FLAG_MI  : result_flag = N;
#     PE_FLAG_PL  : result_flag = ~N;
#     PE_FLAG_VS  : result_flag = V;
#     PE_FLAG_VC  : result_flag = ~V;
#     PE_FLAG_HI  : result_flag = C & ~Z;
#     PE_FLAG_LS  : result_flag = ~C | Z;
#     PE_FLAG_GE  : result_flag = (N == V);
#     PE_FLAG_LT  : result_flag = (N != V);
#     PE_FLAG_GT  : result_flag = ~Z & (N == V);
#     PE_FLAG_LE  : result_flag = Z | (N != V);
#     PE_FLAG_LUT : result_flag = res_lut;
#     PE_FLAG_PE  : result_flag = comp_res_p;


import subprocess
cmd = "ls -l"
# return subprocess.check_output(['/bin/sh','-c', cmd])
print subprocess.check_output(['/bin/sh','-c', cmd])


def main(DBG=9):
    # 1. Find genesis_verif
    gendir = find_CGRAGenerator()
    gvdir  = gendir + "/hardware/generator_z/top/genesis_verif/"
    test_pe_file = gvdir + "test_pe_unq1.sv"
    if DBG>2:
        print("I think I found test_pe file here:\n  %s" % test_pe_file)

    foo = my_syscall("ls", DBG=9)
    print foo

    filename = test_pe_file

    # foo = my_syscall("/bin/csh -c 'grep PE_FLAG "+test_pe_file+"'", DBG=9)
    (out,err) = my_syscall("/bin/csh -c 'grep PE_FLAG %s'" % filename, DBG=9)
    # print out
    for line in out.split('\n'):
        sline = line.strip() 
        print sline
        # localparam PE_FLAG_EQ = 4'h0;
        # localparam PE_FLAG_NE = 4'h1;
        # ...
        # PE_FLAG_EQ  : result_flag = Z;
        # PE_FLAG_NE  : result_flag = ~Z;
        # ...
        parse = re.search("localparam\s*PE_FLAG_(\S*).*[']h([0-9a-fA-F])", sline)
        if parse:
            flagname = parse.group(1).lower()
            hexnum =   int(parse.group(2), 16)
            print flagname, hexnum

        parse = re.search("PE_FLAG_([^:\s]*)[^=]*=\s*([^;]*)", sline)
        if parse:
            print parse.group(1),  parse.group(2)

        print ""



def my_syscall(cmd, DBG=9):
    # The subprocess module is the preferred way of running other programs
    # from Python -- much more flexible and nicer to use than os.system.
    # 
    # import subprocess
    # #subprocess.check_output(['ls','-l']) #all that is technically needed...
    # print subprocess.check_output(['ls','-l'])

    # OLD
    #     err = subprocess.Popen(cmd, shell=True).wait()
    #     if err and (action == "FAIL"):
    #         assert False, "\nSubprocess call failed:\n%s" % cmd
    #         # sys.exit(13)
    #     return err


    # Here is how to get stdout and stderr from a program using the subprocess module:
    # 
    # from subprocess import Popen, PIPE, STDOUT
    # 
    # cmd = 'ls /etc/fstab /etc/non-existent-file'
    # p = Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT, close_fds=True)
    # output = p.stdout.read()
    # print output
    

    # This one waits until the process hasa completed...
    # from subprocess import Popen, PIPE
    # cmd = 'blah'
    # p = Popen(cmd, stdout=PIPE, stderr=PIPE)
    # stdout, stderr = p.communicate()

    # E.g.
    # (out,err) = my_syscall("/bin/csh -c 'grep PE_FLAG /tmp/tmp'", DBG=9)
    # (out,err) = my_syscall("/bin/csh -c 'grep PE_FLAG %s'" % filename, DBG=9)


    import subprocess
    from subprocess import Popen, PIPE, STDOUT
    if DBG: print("okay here we go with '%s'" % cmd)
    print("FOO")
    p = subprocess.Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT, close_fds=True)
    p.wait()

    # p = Popen(cmd, stdout=PIPE, stderr=PIPE)
    stdout, stderr = p.communicate()
    # print p.returncode
    # print stdout
    # print stderr


    if p.returncode != 0:
        print stdout
        errmsg \
               = ""\
               + "Subprocess call failed!\n\n" \
               + ("%% %s\n" % cmd) \
               + "%s%s" % (stdout, stderr) \
               + "\n"
        assert False, errmsg
    return stdout, stderr
#     return subprocess.check_output(['/bin/sh','-c', cmd])








def find_CGRAGenerator(DBG=0):
    import os
    mydir = os.path.dirname(os.path.realpath(__file__))
    parse = re.search('^(.*/CGRAGenerator)', mydir)
    if not parse:
        assert False, 'Could not find CGRAGenerator'
    else:
        gendir = parse.group(1)
        if DBG>2:
            print("# I think I found CGRAGenerator here:")
            print(gendir)
        return gendir

main()
