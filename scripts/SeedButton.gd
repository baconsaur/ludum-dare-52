extends TextureButton

var seed_type

func setup(seed_name, icon):
	seed_type = seed_name
	set_normal_texture(load(icon))
