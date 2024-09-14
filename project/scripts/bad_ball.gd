extends Node2D


signal kill(body)

@onready var bad_ball_rigid_body_2d: RigidBody2D = %BadBallRigidBody2D
@onready var ball_sound: AudioStreamPlayer2D = %BallSound


func _ready() -> void:
	bad_ball_rigid_body_2d.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group('ball'):
		ball_sound.play()
		kill.emit(body)
