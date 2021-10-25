extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const KNOCKBACK_MAG = 150

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 500
export var WANDER_TARGET_EPSILON = 1

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = CHASE

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var wanderController = $WanderController

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
				
			accelerate_towards(wanderController.target_position, delta)

			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_EPSILON:
				update_wander()
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards(player.global_position, delta)
			else:
				state = IDLE
	
	sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)
	
func accelerate_towards(target, delta):
	var direction = global_position.direction_to(target)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCKBACK_MAG
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
