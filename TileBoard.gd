extends GridContainer

var GAME_OVER_STATES = preload('res://constants.gd').GAME_OVER_STATES

# Signals
signal tile_clicked
signal game_over(reason)

# So we can make instances of tiles
export (PackedScene) var Tile

# Settings
export var rows = 8
export var bombs_count = 10
export var min_tiles_to_reveal_per_second = 1
export var max_tiles_to_reveal_per_second = 100

# Tiles waiting to be revealed
var tiles_to_reveal = []

# Is game in progress?
var is_game_in_progress = false

# Set up a new game on ready
func _ready():
    new_game()


func _process(delta):
    # Resize container to equal the viewport's size
    # set_size(get_viewport().get_size())

    # Reveal tiles from the tiles waiting to be revealed queue
    var tiles_to_reveal_now = round(max_tiles_to_reveal_per_second * delta)

    if tiles_to_reveal_now < min_tiles_to_reveal_per_second:
        tiles_to_reveal_now = min_tiles_to_reveal_per_second

    if tiles_to_reveal.size() > 0:
        print(
            ' Current FPS: ', round(1 / delta),
            ' Revealing this many tiles: ', tiles_to_reveal_now,
            ' Tiles left to reveal: ', tiles_to_reveal.size()
        )

    for i in range(tiles_to_reveal_now):
        if tiles_to_reveal.size() > 0:
            tiles_to_reveal.pop_front().reveal()
        else:
            break


func _on_Tile_tile_revealed(revealed_tile):
    emit_signal('tile_clicked')

    # If player clicked on a bomb...
    if revealed_tile.is_bomb:
        emit_signal('game_over', GAME_OVER_STATES.LOSE)

    # else if the board is in a winning state
    elif is_winning_board():
        emit_signal('game_over', GAME_OVER_STATES.WIN)

    # else if player clicked on a blank tile, register adjacent tiles for reavealing
    elif revealed_tile.proximity == 0:
        var adjacent_tiles = revealed_tile.adjacent_tiles
        for adjacent_tile in adjacent_tiles:
            tiles_to_reveal.append(adjacent_tile)


# Check all tiles on the board and report if the board is in a winning state
func is_winning_board():
    for tile in get_children():
        if !tile.is_bomb && !tile.is_revealed:
            return false
    return true


# Set up a new game board
func new_game():
    is_game_in_progress = false

    # Delete all existing tiles
    for tile in get_children():
        remove_child(tile)
        tile.queue_free()

    var tiles_to_spawn = rows * columns

    # Generate bomb locations
    var bomb_locations = range(tiles_to_spawn)
    bomb_locations.shuffle()
    while bomb_locations.size() > bombs_count:
        bomb_locations.pop_front()

    print('Bomb locations: ', str(bomb_locations))

    # Spawn new tiles, attach to adjacent tiles
    for tile_id in range(tiles_to_spawn):

        # Spawn new tiles, add them to the board, connect up the 'revealed'
        # signal and callback
        var new_tile = Tile.instance()
        new_tile.connect("tile_revealed", self, "_on_Tile_tile_revealed")
        add_child(new_tile)

        # Add a bomb if this location is a bomb
        if tile_id in bomb_locations:
            new_tile.is_bomb = true

        # Link up adjacent tiles as they're laid out
        link_adjacent_tiles(new_tile, tile_id)


 # Link adjacent tiles
func link_adjacent_tiles(new_tile, tile_id):
    # Index of adjacent tiles. We only need these directions because tiles are
    # laid out left to right, and other tiles don't yet exist
    var adjacent_tile_directions = {
        # North
        'N': tile_id - columns,
        # Northeast
        'NE': tile_id - columns + 1,
        # West
        'W': tile_id - 1,
        # Northwest
        'NW': tile_id - columns - 1
    }

    # Detect border tiles
    var current_column = tile_id % columns
    var is_on_western_border = current_column == 0;
    var is_on_eastern_border = current_column == columns - 1;

    # On the western border, there's nothing to the west
    if is_on_western_border:
        link_adjacent_tile(new_tile, tile_id, [
            adjacent_tile_directions['N'],
            adjacent_tile_directions['NE']
        ])

    # On the eastern border, there's nothing to the east
    elif is_on_eastern_border:
        link_adjacent_tile(new_tile, tile_id, [
            adjacent_tile_directions['N'],
            adjacent_tile_directions['W'],
            adjacent_tile_directions['NW']
        ])

    # All other tiles
    else:
        link_adjacent_tile(new_tile, tile_id, adjacent_tile_directions.values())


# Link a tile to its neighbor and back
func link_adjacent_tile(new_tile, tile_id, adjacent_tile_ids):
    for adjacent_tile_id in adjacent_tile_ids:
        if adjacent_tile_id >= 0 && adjacent_tile_id <= tile_id:
            var adjacent_tile = get_child(adjacent_tile_id)
            new_tile.adjacent_tiles.append(adjacent_tile)
            adjacent_tile.adjacent_tiles.append(new_tile)
