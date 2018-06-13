import os

def run_cmd(cmd):
    res = os.system(cmd)
    assert(res == 0)


gen = '~/CGRAGenerator/'
app_path = '{0}bitstream/bsbuilder/testdir/examples/'.format(gen)
app_name = 'pointwise'
app_path = '{0}{1}'.format(app_path, app_name)
bsdir = '{0}/bitstream/bsbuilder/'.format(gen)

serpent_path = '{0}bitstream/bsbuilder/serpent.py'.format(gen)

# Generate .dot file from mapped coreir
gen_dot_cmd = '{0}testdir/graphcompare/json2dot.py < {1}_mapped.json > {2}.dot '.format(gen, app_path, app_name)
print 'Generate dot command =', gen_dot_cmd
run_cmd(gen_dot_cmd)

# Place and route the .dot file using serpent and produce .bsb file
serpent_cmd = '{0} -v {1}.dot -o {1}.bsb'.format(serpent_path, app_name)
print 'Serpent command =', gen_dot_cmd
run_cmd(serpent_cmd)

# Build bitstream .bsa file from .bsb
build_bsa_cmd = '{0}bsbuilder.py {1}.bsb > {1}.bsa'.format(bsdir, app_name)
print 'Build .bsa command = ', build_bsa_cmd
run_cmd(build_bsa_cmd)

# Remove extra lines from bitstream
remove_lines_cmd = './remove_config_blanks.sh {0}.bsa > {0}_only_config_lines.bsa'.format(app_name)
print 'Remove lines command', remove_lines_cmd
run_cmd(remove_lines_cmd)

# TODO: Add FlatCircuit-like automatic testbench generation
compile_vcs_cmd = 'vcs -assert disable +nbaopt +rad +nospecify +notimingchecks -ld gcc-4.4 +vcs+lic+wait -licqueue +cli -sverilog -full64 +incdir+/hd/cad/synopsys/dc_shell/latest/packages/gtech/src_ver/ +incdir+/hd/cad/synopsys/dc_shell/latest/dw/sim_ver/ -y /hd/cad/synopsys/dc_shell/latest/dw/sim_ver/ -CFLAGS \'-O3 -march=native\' test_pointwise.v ../../hardware/generator_z/top/genesis_verif/*.v ../../hardware/generator_z/top/genesis_verif/*.sv -top test'
print 'Compile vcs command =', compile_vcs_cmd
run_cmd(compile_vcs_cmd)

run_cmd('./simv')
