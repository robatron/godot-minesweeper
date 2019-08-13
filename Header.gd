extends HBoxContainer

const DIFFICULTIES = preload('res://constants.gd').DIFFICULTIES

signal difficulty_changed(difficulty)
signal reset_button_pressed


func _ready():
    # Set up difficulty dropdown
    $DifficultyControl/DifficultyOptions.add_item('Very easy', DIFFICULTIES.VERY_EASY)
    $DifficultyControl/DifficultyOptions.add_item('Easy', DIFFICULTIES.EASY)
    $DifficultyControl/DifficultyOptions.add_item('Medium', DIFFICULTIES.MEDIUM)
    $DifficultyControl/DifficultyOptions.add_item('Hard', DIFFICULTIES.HARD)


# When the difficulty options change, emit signal to the parent
func _on_DifficultyOptions_item_selected(ID):
    emit_signal('difficulty_changed', ID)


func _on_ResetGameButton_pressed():
    emit_signal('reset_button_pressed')


func set_difficulty(new_difficulty):
    $DifficultyControl/DifficultyOptions.select(new_difficulty)


func set_mine_value(value):
    $GameInfo/MineInfo/MineValue.set_text(str(value))


func set_score(value):
    $GameInfo/ScoreInfo/ScoreValue.set_text(str(value))
