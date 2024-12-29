extends CharacterBody2D

@export var dead:bool = false
@export var degree:float = 0
@export var velox:int = 200
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _unhandled_key_input(event):
	velocity.y = JUMP_VELOCITY

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and not dead:
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		
	if is_on_floor() or is_on_ceiling() or is_on_wall():
		dead = true
	
	if not dead:
		degree = clampf(velocity.y / JUMP_VELOCITY * 30 * -1, -30, 30)
		rotation_degrees = degree
	else:
		rotation_degrees = 30
	# Handle Jump.
	#if is_processing_unhandled_input():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if not dead:
		velocity.x = velox
	else:
		velocity.x = 0
		var Ani:AnimatedSprite2D = $AnimatedSprite2D
		Ani.stop()

	move_and_slide()
