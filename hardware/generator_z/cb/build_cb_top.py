import os

os.system('Genesis2.pl -parse -generate -top cb -input cb.vp')
os.system('iverilog -o test_cb_10_16_const test_cb_10_16_const.v ./genesis_verif/cb.v')
os.system('./test_cb_10_16_const')

