extends MarginContainer

const DIFFICULTIES = preload('res://constants.gd').DIFFICULTIES
const GAME_OVER_STATES = preload('res://constants.gd').GAME_OVER_STATES

export (DIFFICULTIES) var difficulty = DIFFICULTIES.MEDIUM


var score = 0
var is_game_running = false


func _ready():
    # Initialize randomness
    randomize()
    $Layout/Header.set_difficulty(difficulty)
    setup_new_game()


func _process(delta):
    # TODO
    # set_size(get_viewport().get_size())

    # Update the score as long as the game is running
    if is_game_running:
        score += delta
        update_score()


# If the game is over, stop the game, and alert
func _on_TileBoard_game_over(reason):
    is_game_running = false
    if reason == GAME_OVER_STATES.WIN:
        $Overlay/GameOverPopup.alert('You win!')
    elif reason == GAME_OVER_STATES.LOSE:
        $Overlay/GameOverPopup.alert('Game over!')


# If a tile is clicked when the game is not running, start the game
func _on_TileBoard_tile_clicked():
    if !is_game_running:
        is_game_running = true


# Start a new game when reset button is pressed
func _on_Header_reset_button_pressed():
    setup_new_game()


# Select a new difficulty and start a new game
func _on_Header_difficulty_changed(new_difficulty):
    difficulty = new_difficulty
    setup_new_game()


func setup_new_game():
    is_game_running = false
    score = 0
    update_score()

    if difficulty == DIFFICULTIES.VERY_EASY:
        $Layout/TileBoard.rows = 3
        $Layout/TileBoard.columns = 3
        $Layout/TileBoard.bombs_count = 1

    elif difficulty == DIFFICULTIES.EASY:
        $Layout/TileBoard.rows = 8
        $Layout/TileBoard.columns = 10
        $Layout/TileBoard.bombs_count = 10

    elif difficulty == DIFFICULTIES.MEDIUM:
        $Layout/TileBoard.rows = 14
        $Layout/TileBoard.columns = 18
        $Layout/TileBoard.bombs_count = 40

    elif difficulty == DIFFICULTIES.HARD:
        $Layout/TileBoard.rows = 20
        $Layout/TileBoard.columns = 25
        $Layout/TileBoard.bombs_count = 100

    $Layout/Header.set_mine_value($Layout/TileBoard.bombs_count)
    $Layout/TileBoard.new_game()


func update_score():
    $Layout/Header.set_score(int(round(score)));
