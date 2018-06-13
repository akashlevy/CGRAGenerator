import os

def run_cmd(cmd):
    print 'Running command', cmd
    res = os.system(cmd)
    assert(res == 0)


gen = '~/CGRAGenerator/'
#app_path = '{0}bitstream/bsbuilder/testdir/examples/'.format(gen)
#app_path = '~/CGRAMapper/examples/'.format(gen)
app_path = './'
app_name = 'add_five'
#app_name = 'add_2_input'
app_path = '{0}{1}'.format(app_path, app_name)
bsdir = '{0}/bitstream/bsbuilder/'.format(gen)

serpent_path = '{0}bitstream/bsbuilder/serpent.py'.format(gen)
mapper_path = '~/CGRAMapper/'

# Map the coreir file
map_cmd = '{0}bin/mapper {1}.json {2}_mapped.json'.format(mapper_path, app_path, app_name)
run_cmd(map_cmd)
# print 'Running command', map_cmd
# res = os.system(map_cmd)

#run_cmd(map_cmd)

# Generate .dot file from mapped coreir
gen_dot_cmd = '{0}testdir/graphcompare/json2dot.py < {1}_mapped.json > {1}.dot '.format(gen, app_name)
run_cmd(gen_dot_cmd)

# Place and route the .dot file using serpent and produce .bsb file
serpent_cmd = '{0} -v {1}.dot -o {1}.bsb'.format(serpent_path, app_name)
run_cmd(serpent_cmd)

# Build bitstream .bsa file from .bsb
build_bsa_cmd = '{0}bsbuilder.py {1}.bsb > {1}.bsa'.format(bsdir, app_name)
run_cmd(build_bsa_cmd)

# Reorder bitstream to avoid loops
run_cmd('{0}verilator/generator_z_tb/bin/reorder.csh {1}.bsa > {1}_reordered.bsa'.format(gen, app_name))

# Remove extra lines from bitstream
remove_lines_cmd = './remove_config_blanks.sh {0}_reordered.bsa > {0}_only_config_lines.bsa'.format(app_name)
run_cmd(remove_lines_cmd)

# Compile and run VCS on the new bitstream
# TODO: Add automatic testbench generation
compile_vcs_cmd = 'vcs -assert disable +nbaopt +rad +nospecify +notimingchecks -ld gcc-4.4 +vcs+lic+wait -licqueue +cli -sverilog -full64 +incdir+/hd/cad/synopsys/dc_shell/latest/packages/gtech/src_ver/ +incdir+/hd/cad/synopsys/dc_shell/latest/dw/sim_ver/ -y /hd/cad/synopsys/dc_shell/latest/dw/sim_ver/ -CFLAGS \'-O3 -march=native\' test_pointwise.v ../../hardware/generator_z/top/genesis_verif/*.v ../../hardware/generator_z/top/genesis_verif/*.sv -top test'
run_cmd(compile_vcs_cmd)

run_cmd('./simv')
