extends Node3D

class_name Drone

@export var ui_layer: CanvasLayer
@export var go_button: Button
@export var stop_button: Button
@export var self_destruct: Button
@export var offline_text: RichTextLabel
@export var move_speed: float = 3.0

var explosionPrefab: PackedScene = preload("res://scenes/explosion.tscn")
var explosionSound: AudioStreamWAV = preload("res://sfx/drone_explode.wav")
var explosion: Explosion

var fade_duration: float = 1.0
var start_alpha: float = 0.0
var end_alpha: float = 1.0

var destroyed: bool = false

func _ready() -> void:
	if not is_multiplayer_authority():
		ui_layer.visible = false
		
	explosion = explosionPrefab.instantiate() as Explosion
	get_tree().current_scene.add_child.call_deferred(explosion)
	explosion.position = position
	explosion.position.y += .2
	explosion.explode()
	
	self_destruct.pressed.connect(on_self_destruct)
	go_button.pressed.connect(start_moving)
	stop_button.pressed.connect(stop_moving)


var is_moving: bool = false

func start_moving():
	_start_moving.rpc()
	
@rpc("any_peer","call_local","reliable")
func _start_moving():
	is_moving = true

func stop_moving():
	_stop_moving.rpc()

@rpc("any_peer","call_local","reliable")
func _stop_moving():
	is_moving = false
	

func _physics_process(delta: float):
	move_forward.rpc(delta)

@rpc("any_peer","call_local", "unreliable")
func move_forward(delta):
	if is_moving:
		var forward_vector = Vector3.LEFT
		global_translate(forward_vector * move_speed * delta)


func on_self_destruct() -> void:
		_explode_drone.rpc()

@rpc("any_peer","call_local","reliable")
func _explode_drone():
	if destroyed: return
	destroyed = true
	stop_moving()
	
	explosion.position = position
	explosion.explode()
	
	play_explosion_sound()
	for c in get_children():
		if c.name == "cam" or c.name == "target" or c.name == "ui": continue
		c.queue_free()
	var t = get_tree().create_timer(.5)
	await t.timeout
	await show_offline_text()

func show_offline_text():
	offline_text.visible = true
	offline_text.modulate.a = start_alpha
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(offline_text, "modulate:a", end_alpha, fade_duration)
	await tween.finished

func play_explosion_sound():
	if explosionSound is AudioStreamWAV:
		var player = AudioStreamPlayer.new()
		player.stream = explosionSound
		player.finished.connect(player.queue_free)
		get_tree().current_scene.add_child(player)
		player.play()
