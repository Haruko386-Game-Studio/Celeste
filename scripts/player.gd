extends CharacterBody2D

@export var speed: float = 260.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_velocity: float = -430.0
@export var gravity: float = 1200.0
@export var fall_gravity_multiplier: float = 1.35
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.12

@export var dash_speed: float = 620.0
@export var dash_time: float = 0.14

var spawn_position: Vector2
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var dash_timer: float = 0.0
var can_dash: bool = true
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.RIGHT
var facing: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    spawn_position = global_position

func _physics_process(delta: float) -> void:
    if global_position.y > 900.0:
        respawn()

    var input_x := Input.get_axis("move_left", "move_right")
    if input_x != 0.0:
        facing = sign(input_x)

    if is_on_floor():
        coyote_timer = coyote_time
        can_dash = true
    else:
        coyote_timer = max(coyote_timer - delta, 0.0)

    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = jump_buffer_time
    else:
        jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

    if is_dashing:
        dash_timer -= delta
        velocity = dash_direction * dash_speed
        if dash_timer <= 0.0:
            is_dashing = false
        move_and_slide()
        return

    if Input.is_action_just_pressed("dash") and can_dash:
        start_dash(input_x)
        move_and_slide()
        return

    # Horizontal movement
    if input_x != 0.0:
        velocity.x = move_toward(velocity.x, input_x * speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, friction * delta)

    # Gravity
    var g := gravity
    if velocity.y > 0.0:
        g *= fall_gravity_multiplier
    velocity.y += g * delta

    # Jump buffer + coyote time
    if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
        velocity.y = jump_velocity
        jump_buffer_timer = 0.0
        coyote_timer = 0.0

    # Variable jump height: release jump to cut upward speed.
    if Input.is_action_just_released("jump") and velocity.y < 0.0:
        velocity.y *= 0.45

    move_and_slide()
    update_visual()

func start_dash(input_x: float) -> void:
    can_dash = false
    is_dashing = true
    dash_timer = dash_time

    var dir := Vector2.ZERO
    dir.x = Input.get_axis("move_left", "move_right")
    dir.y = Input.get_axis("ui_up", "ui_down")

    if dir == Vector2.ZERO:
        dir = Vector2(facing, 0.0)

    dash_direction = dir.normalized()
    velocity = dash_direction * dash_speed

func respawn() -> void:
    global_position = spawn_position
    velocity = Vector2.ZERO
    is_dashing = false
    can_dash = true

func update_visual() -> void:
    sprite.flip_h = facing < 0
