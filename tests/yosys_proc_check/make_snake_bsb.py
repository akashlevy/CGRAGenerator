from sets import Set
import math
import itertools
import sys

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

def tile_below(tile_pair):
    return (tile_pair[0] + 1, tile_pair[1])

def tile_above(tile_pair):
    return (tile_pair[0] - 1, tile_pair[1])

def tile_left(tile_pair):
    return (tile_pair[0], tile_pair[1] - 1)

def tile_right(tile_pair):
    return (tile_pair[0], tile_pair[1] + 1)

base = 21
row_stride = 19
def row_ind(r):
    assert(r >= 0)

    if (r == 0):
        return base
    elif r == 1:
        return base + 19
    else:
        return row_ind(r - 1) + (14 if (r % 2) == 0 else 18)

def append_blank(row, ind):
    row.append(0)
    return ind

def append_tile(row, ind):
    row.append(ind)
    return ind + 1

tile_layout = []
tile_no = 2

def append_no_mem_row(row, ind):
    tn = ind
    for i in xrange(0, 16):
        if (i % 4) == 3:
            tn = append_blank(row, tn)
        else:
            tn = append_tile(row, tn)

    return tn

def append_full_row(row, ind):
    tn = ind
    for i in xrange(0, 16):
        tn = append_tile(row, tn)
    return tn

# one bit row
row = []
tile_no = append_blank(row, tile_no)
tile_no = append_blank(row, tile_no)
for i in xrange(0, 16):
    tile_no = append_tile(row, tile_no)
tile_no = append_blank(row, tile_no)
tile_no = append_blank(row, tile_no)

#print row
tile_layout.append(row)

# 16 bit pad row
row = []
tile_no = append_blank(row, tile_no)
tile_no = append_blank(row, tile_no)

tile_no = append_tile(row, tile_no)
for i in xrange(0, 16 + 1):
    tile_no = append_blank(row, tile_no)

tile_layout.append(row)

# full 16 bit pad rows
row = []

tile_no = append_tile(row, tile_no)
tile_no = append_tile(row, tile_no)

tile_no = append_full_row(row, tile_no)

tile_no = append_tile(row, tile_no)
tile_no = append_tile(row, tile_no)

tile_layout.append(row)
    
# normal rows 15?
for i in range(1, 16):
    row = []
    # IO tile
    tile_no = append_tile(row, tile_no)
    # blank
    tile_no = append_blank(row, tile_no)
    if (i % 2) == 0:
        tile_no = append_full_row(row, tile_no)
    else:
        tile_no = append_no_mem_row(row, tile_no)
    # for i in xrange(0, 16):
    #     tile_no = append_tile(row, tile_no)

    tile_no = append_tile(row, tile_no)
    tile_no = append_blank(row, tile_no)

    tile_layout.append(row)
# another 16 bit pad row
row = []
tile_no = append_blank(row, tile_no)
tile_no = append_blank(row, tile_no)

tile_no = append_tile(row, tile_no)
for i in xrange(0, 16 + 1):
    tile_no = append_blank(row, tile_no)

tile_layout.append(row)

# another 1 bit pad row
row = []
tile_no = append_blank(row, tile_no)
tile_no = append_blank(row, tile_no)
for i in xrange(0, 16):
    tile_no = append_tile(row, tile_no)
tile_no = append_blank(row, tile_no)
tile_no = append_blank(row, tile_no)

for r in tile_layout:
    # for elem in r:
    #     sys.stdout.write("0x%-6x" % elem)
    # sys.stdout.write("\n")

    assert(len(r) == 20)

def tile_pair_to_tile_num(tile_pair):
    target_row = tile_layout[tile_pair[0]]
    #print 'row', tile_pair[0], '=', target_row
    return target_row[tile_pair[1]]
    # row = tile_pair[0]
    # col = tile_pair[1]

    # r_ind = row_ind(row)
    # c_ind = col
    # if (c_ind != 0) and (row % 2 != 0):
    #     c_ind -= (int(math.ceil(col / 4.0)) - 1)
    
    # return r_ind + c_ind

def is_memory_tile(tile_pair):
    return ((tile_pair[1] + 1) % 4) == 0

def make_snake(snake_start, snake_width, snake_height):
    current = snake_start
    snake_list = []
    for col in xrange(0, snake_width):
        snake_list.append(current)

        if col % 2 == 0:
            for inc in xrange(0, snake_height - 1):
                current = tile_below(current)
                snake_list.append(current)
        else:
            for inc in xrange(snake_height - 1, 0, -1):
                current = tile_above(current)
                snake_list.append(current)

        current = tile_right(current)

    return snake_list

def reverse_side(side):
    if (side == 0):
        return 2
    elif (side == 2):
        return 0
    elif (side == 3):
        return 0
    elif (side == 1):
        return 3
    else:
        print 'Error; Unsupported side = ', side
        assert(False)

def print_block(tile_pair, in_side, in_track, out_side, out_track):
    print in_wire_str(tile_pair_to_tile_num(tile_pair), in_side, in_track) + ' -> ' + out_wire_str(tile_pair_to_tile_num(tile_pair), out_side, out_track)

def print_downward_chain(snake_start, snake_height, in_track, out_track):
    current = snake_start
    input_side = 2
    exit_side = 0
    steady_in_side = 3
    steady_out_side = 1

    steady_track = 0

    # Start of chain
    print_block(current, input_side, in_track, steady_out_side, steady_track)

    for i in xrange(0, snake_height - 2):
        current = tile_below(current)
        print_block(current, steady_in_side, steady_track, steady_out_side, steady_track)

    current = tile_below(current)
    print_block(current, steady_in_side, steady_track, exit_side, out_track)

    current = tile_right(current)
    return current

def print_upward_chain(snake_start, snake_height, in_track, out_track):
    current = snake_start
    input_side = 2
    exit_side = 0
    steady_in_side = 1
    steady_out_side = 3

    steady_track = 0

    # Start of chain
    print_block(current, input_side, in_track, steady_out_side, steady_track)

    for i in xrange(0, snake_height - 2):
        current = tile_above(current)
        print_block(current, steady_in_side, steady_track, steady_out_side, steady_track)

    current = tile_above(current)
    print_block(current, steady_in_side, steady_track, exit_side, out_track)

    current = tile_right(current)
    return current

def print_snake(snake_start, snake_width, snake_height):
    current = snake_start
    input_side = 2
    output_side = 1
    in_track = 0
    out_track = 0

    for col in xrange(0, snake_width):
        if col % 2 == 0:
            out_track = 0
            current = print_downward_chain(current, snake_height, in_track, out_track)
        else:
            out_track = 0
            current = print_upward_chain(current, snake_height, in_track, out_track)
        
snake_height = 1
current = (2, 2)

col = 2
for i in xrange(0, 4):
    print_snake((2, col), 2, snake_height)

    pe_0 = (2, col + 2)
    pe_num = tile_pair_to_tile_num(pe_0)
    print in_wire_str(pe_num, 2, 0) + ' -> ' + out_wire_str(pe_num, 0, 0)

    mem = (2, col + 3)
    mem_num = tile_pair_to_tile_num(mem)
    print in_wire_str(mem_num, 2, 0) + ' -> ' + out_wire_str(mem_num, 0, 0) + ' # Memory tile'
    
    col += 4
