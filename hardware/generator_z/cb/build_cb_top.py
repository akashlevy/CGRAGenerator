import os

param_width = 16
param_num_tracks = 10
param_feedthrough_outputs = "1111101111"
param_has_constant = 1
param_default_value = 0

os.system('Genesis2.pl -parse -generate -top cb -input cb.vp -parameter cb.width=' + str(param_width) + ' -parameter cb.num_tracks=' + str(param_num_tracks) + ' -parameter cb.has_constant=' + str(param_has_constant) + ' -parameter cb.default_value=' + str(param_default_value) + ' -parameter cb.feedthrough_outputs=' + param_feedthrough_outputs)

os.system('./run_sim.sh')
