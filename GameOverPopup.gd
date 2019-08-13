extends AcceptDialog

func _ready():
    pass


func alert(msg):
    set_text(msg)
    popup()
