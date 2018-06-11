from sets import Set
import math
import itertools

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

def tile_pair_to_tile_num(tile_pair):
    row = tile_pair[0]
    col = tile_pair[1]

    r_ind = row_ind(row)
    c_ind = col
    if (c_ind != 0) and (row % 2 != 0):
        c_ind -= (int(math.ceil(col / 4.0)) - 1)
    
    return r_ind + c_ind

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
        
snake_height = 2
current = (0, 0)

tiles = []
col = 0
for i in xrange(0, 4):
    print_snake((0, col), 2, 4)

    pe_0 = (0, col + 2)
    pe_num = tile_pair_to_tile_num(pe_0)
    print in_wire_str(pe_num, 2, 0) + ' -> ' + out_wire_str(pe_num, 0, 0)

    mem = (0, col + 3)
    mem_num = tile_pair_to_tile_num(mem)
    print in_wire_str(mem_num, 2, 0) + ' -> ' + out_wire_str(mem_num, 0, 0) + ' # Memory tile'
    
    tiles.append((0, col + 2))
    tiles.append((0, col + 3))
    col += 4
