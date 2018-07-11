import os

import magma as m

@m.cache_definition
def define_connect_box(width, num_tracks, has_constant, default_value, feedthrough_outputs):
    class ConnectBox(m.Circuit):
        name = f"connect_box_width_width_{str(width)}_num_tracks_{str(num_tracks)}_has_constant{str(has_constant)}_default_value{str(default_value)}_feedthrough_outputs_{feedthrough_outputs}"
        IO = []

        @classmethod
        def definition(io):
            return

    return ConnectBox


param_width = 16
param_num_tracks = 10
param_feedthrough_outputs = "1111101111"
param_has_constant = 1
param_default_value = 0

cb = define_connect_box(param_width, param_num_tracks, param_has_constant, param_default_value, param_feedthrough_outputs)
m.compile('cb', cb, output='verilog')

os.system('Genesis2.pl -parse -generate -top cb -input cb.vp -parameter cb.width=' + str(param_width) + ' -parameter cb.num_tracks=' + str(param_num_tracks) + ' -parameter cb.has_constant=' + str(param_has_constant) + ' -parameter cb.default_value=' + str(param_default_value) + ' -parameter cb.feedthrough_outputs=' + param_feedthrough_outputs)

os.system('./run_sim.sh')
