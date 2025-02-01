extends Node3D

class_name Explosion

@export var sparks: GPUParticles3D
@export var flash: GPUParticles3D

func explode() -> void:
	sparks.emitting = true
	flash.emitting = true
