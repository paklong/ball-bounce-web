extends Node2D

signal bounced

@onready var ball_rigid_body_2d: RigidBody2D = %BallRigidBody2D
@onready var boundary_sound: AudioStreamPlayer2D = %BoundarySound


func _ready() -> void:
	ball_rigid_body_2d.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	#print (body)
	if body.is_in_group('wall'):
		boundary_sound.play(0.04)
		bounced.emit()
