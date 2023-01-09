extends Camera2D

export var shake_factor = 1


func shake():
	for _i in range(8):
		position += Vector2(
			rand_range(-shake_factor, shake_factor), rand_range(-shake_factor, shake_factor)
		)
		yield(get_tree().create_timer(0.01), "timeout")
	position = Vector2.ZERO
