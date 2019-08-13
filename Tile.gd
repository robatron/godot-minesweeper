extends MarginContainer

signal tile_revealed(this_tile)

export var is_revealed = false
export var is_bomb = false
export var is_flagged = false
export var proximity = 0

# This tile's neighbor tiles
var adjacent_tiles = [];

# Called when the node enters the scene tree for the first time.
func _ready():
    pass


func _process(delta):
    if is_revealed:
        $Button.hide()
    else:
        $Button.show()
        if is_flagged:
            $Flag.show()
        else:
            $Flag.hide()

    if is_bomb:
        $Bomb.show()
        $ProxLabel.hide()
    else:
        $Bomb.hide()

        if proximity == 0:
            $ProxLabel.hide()
        else:
            $ProxLabel.text = str(proximity)
            $ProxLabel.show()


func _on_Button_left_click():
    reveal()


func _on_Button_right_click(event):
    if event is InputEventMouseButton:
        if event.get_button_index() == 2 && !event.is_pressed():
            is_flagged = !is_flagged

# Reveal a tile: If not already revealed, set its proximity number, and show tile
func reveal():
    if !is_revealed:
        is_revealed = true
        set_proximity()
        emit_signal("tile_revealed", self)


# Set proximity number based on how many adjacent tiles have bombs
func set_proximity():
    proximity = 0
    for adjacent_tile in adjacent_tiles:
        if adjacent_tile.is_bomb:
            proximity += 1
