extends RigidBody2D



func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:

	
	if randi_range(0, 10) == 0:
		state.add_constant_force(
			Vector2(
				randf_range(-100, 100),
				0
			)
		)
