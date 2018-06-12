import os

def run_cmd(cmd):
    res = os.system(cmd)
    assert(res == 0)

gen = '~/CGRAGenerator/'
app_path = '{0}bitstream/bsbuilder/testdir/examples/'.format(gen)
app_name = 'pointwise'
app_path = '{0}{1}'.format(app_path, app_name)

gen_dot_cmd = '{0}testdir/graphcompare/json2dot.py < {1}_mapped.json > {2}.dot '.format(gen, app_path, app_name)

print 'Generate dot command =', gen_dot_cmd
run_cmd(gen_dot_cmd)
