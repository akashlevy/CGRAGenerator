from sets import Set

def tile_str(tile_no):
    return 'T' + str(tile_no)

def add_constant_cmd(tile_no, const_val):
    return tile_str(tile_no) + '_add(wire,const' + str(const_val) + '__0)'

def in_wire_str(tile_no, side_no, track_no):
    return tile_str(tile_no) + '_in_s' + str(side_no) + 't' + str(track_no)

def out_wire_str(tile_no, side_no, track_no):
    return tile_str(tile_no) + '_out_s' + str(side_no) + 't' + str(track_no)

inc_path = []
for i in xrange(21, 37):
    inc_path.append(i)

mem_tiles = Set([24, 28, 32, 36])
for p in inc_path:

    if p in mem_tiles:
        print in_wire_str(p, 2, 0) + ' -> ' + out_wire_str(p, 0, 0)
    else:
        print add_constant_cmd(p, 1)
        print in_wire_str(p, 2, 0) + ' -> ' + tile_str(p) + '_op1'
        print tile_str(p) + '_pe_out -> ' + out_wire_str(p, 0, 0)
