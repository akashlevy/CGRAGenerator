import os

def run_cmd(cmd):
    res = os.system(cmd)
    assert(res == 0)

gen = '~/CGRAGenerator/'
app_path = '{0}bitstream/bsbuilder/testdir/examples/'.format(gen)
app_name = 'pointwise'
app_path = '{0}{1}'.format(app_path, app_name)

serpent_path = '{0}bitstream/bsbuilder/serpent.py'.format(gen)

gen_dot_cmd = '{0}testdir/graphcompare/json2dot.py < {1}_mapped.json > {2}.dot '.format(gen, app_path, app_name)
print 'Generate dot command =', gen_dot_cmd
run_cmd(gen_dot_cmd)

serpent_cmd = '{0} -v {1}.dot -o {1}.bsb'.format(serpent_path, app_name)
print 'Serpent command =', gen_dot_cmd
run_cmd(serpent_cmd)
