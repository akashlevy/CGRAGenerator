import os

gen = '~/CGRAGenerator/'

def run_cmd(cmd):
    res = os.system(cmd)
    assert(res == 0)

run_cmd('python make_snake_bsb.py > add_2_input.bsb')

build_bs_cmd = '~/CGRAGenerator/bitstream/bsbuilder/bsbuilder.py add_2_input.bsb > add_2_input_tmp.bsa'
run_cmd(build_bs_cmd)

app_name = 'add_2_input_tmp'
run_cmd('{0}verilator/generator_z_tb/bin/reorder.csh {1}.bsa > {1}_reordered.bsa'.format(gen, app_name))
run_cmd('./remove_config_blanks.sh add_2_input_tmp_reordered.bsa > add_2_input.bsa')

run_cmd('./vcs_run_test.sh')
run_cmd('./simv')
