import os

def run_cmd(cmd):
    res = os.system(cmd)
    assert(res == 0)

build_bs_cmd = '~/CGRAGenerator/bitstream/bsbuilder/bsbuilder.py add_2_input.bsb > add_2_input_tmp.bsa'
run_cmd(build_bs_cmd)

run_cmd('./remove_config_blanks.sh add_2_input_tmp.bsa > add_2_input.bsa')

run_cmd('./vcs_run_test.sh')
run_cmd('./simv')
