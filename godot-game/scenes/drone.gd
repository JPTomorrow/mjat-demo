extends Node3D

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
var is_moving: bool = false

func _ready() -> void:
	explosion = explosionPrefab.instantiate() as Explosion
	get_tree().current_scene.add_child.call_deferred(explosion)
	explosion.position = position
	explosion.position.y += .2
	explosion.explode()
	
	self_destruct.pressed.connect(on_self_destruct)
	go_button.pressed.connect(start_moving)
	stop_button.pressed.connect(stop_moving)
	
func start_moving():
	is_moving = true

func stop_moving():
	is_moving = false

func _physics_process(delta: float):
	if is_moving:
		var forward_vector = Vector3.LEFT
		global_translate(forward_vector * move_speed * delta)

func on_self_destruct() -> void:
	if destroyed: return
	destroyed = true
	stop_moving()
	
	explosion.position = position
	explosion.explode()
	
	play_explosion_sound()
	for c in get_children():
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
