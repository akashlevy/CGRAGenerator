import os
import math
import mantle as mantle

import magma as m

@m.cache_definition
def define_connect_box(width, num_tracks, has_constant, default_value, feedthrough_outputs):
    class ConnectBox(m.Circuit):
        name = f"connect_box_width_width_{str(width)}_num_tracks_{str(num_tracks)}_has_constant{str(has_constant)}_default_value{str(default_value)}_feedthrough_outputs_{feedthrough_outputs}"
        CONFIG_DATA_WIDTH = 32
        CONFIG_ADDR_WIDTH = 32

        IO = ["clk", m.In(m.Clock),
              "reset", m.In(m.Reset),
              "config_en", m.In(m.Bit),
              "config_data", m.In(m.Bits(CONFIG_DATA_WIDTH)),
              "config_addr", m.In(m.Bits(CONFIG_ADDR_WIDTH)),
              "read_data", m.Out(m.Bits(CONFIG_DATA_WIDTH)),
              "out", m.Out(m.Bits(width))]

        for i in range(0, num_tracks):
            if (feedthrough_outputs[i] == '1'):
                IO.append("in_" + str(i))
                IO.append(m.In(m.Bits(width)))
            
        @classmethod
        def definition(io):
            feedthrough_count = num_tracks
            for i in range(0, len(feedthrough_outputs)):
                feedthrough_count -= feedthrough_outputs[i] == '1'

            mux_sel_bit_count = int(math.ceil(math.log(num_tracks - feedthrough_count + has_constant, 2)))

            constant_bit_count = has_constant * width

            config_bit_count = mux_sel_bit_count + constant_bit_count

            config_reg_width = int(math.ceil(config_bit_count / 32.0)*32)

            config_addrs_needed = int(math.ceil(config_bit_count / 32.0))

            reset_val = num_tracks - feedthrough_count + has_constant - 1
            config_reg_reset_bit_vector = []

            CONFIG_DATA_WIDTH = 32
            CONFIG_ADDR_WIDTH = 32

            if (constant_bit_count > 0):
                print('constant_bit_count =', constant_bit_count)

                reset_bits = m.bitutils.int2seq(default_value, constant_bit_count)
                default_bits = m.bitutils.int2seq(reset_val, mux_sel_bit_count)

                print('default val bits =', reset_bits)
                print('reset val bits   =', default_bits)

                # concat before assert
                config_reg_reset_bit_vector += reset_bits
                config_reg_reset_bit_vector += default_bits

                config_reg_reset_bit_vector = m.bitutils.seq2int(config_reg_reset_bit_vector)
                print('reset bit vec as int =', config_reg_reset_bit_vector)
                
                #assert(len(config_reg_reset_bit_vector) == config_reg_width)

            else:
                config_reg_reset_bit_vector = reset_val

            config_cb = mantle.Register(config_reg_width,
                                        init=config_reg_reset_bit_vector,
                                        has_ce=True,
                                        has_reset=True)

            # # create and
            # # wire and to
            # config_and_check = mantle.And(2, 1)
            # wire(config_and_check.I0, m.uint(1, 1))
            # wire(config_and_check.I1, 
            m.wire(1, config_cb.CE)

            
            return

    return ConnectBox


param_width = 16
param_num_tracks = 10
param_feedthrough_outputs = "1111101111"
param_has_constant = 1
param_default_value = 7

cb = define_connect_box(param_width, param_num_tracks, param_has_constant, param_default_value, param_feedthrough_outputs)
m.compile(cb.name, cb, output='coreir')
os.system('coreir -i ' + cb.name + '.json -o ' + cb.name + '.v')

os.system('Genesis2.pl -parse -generate -top cb -input cb.vp -parameter cb.width=' + str(param_width) + ' -parameter cb.num_tracks=' + str(param_num_tracks) + ' -parameter cb.has_constant=' + str(param_has_constant) + ' -parameter cb.default_value=' + str(param_default_value) + ' -parameter cb.feedthrough_outputs=' + param_feedthrough_outputs)

os.system('./run_sim.sh')
