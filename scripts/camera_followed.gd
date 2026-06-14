extends Camera2D

@export var target_path: NodePath
@export var follow_speed: float = 8.0

@onready var target: Node2D = get_node(target_path)

func _process(delta: float) -> void:
    if target:
        global_position = global_position.lerp(target.global_position, follow_speed * delta)
