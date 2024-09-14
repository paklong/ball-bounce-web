extends Node2D

const BALL = preload("res://scenes/ball.tscn")
const BADBALL = preload("res://scenes/badball.tscn")

@onready var ball_label: Label = %BallLabel


@onready var bad_ball_label: RichTextLabel = %BadBallLabel
@onready var stats_label: RichTextLabel = %StatsLabel


@onready var bad_ball_timer: Timer = %BadBallTimer



var number_of_balls := 0
var number_of_badballs := 0
var spwan_positions : Array[Vector2]
var tree : SceneTree 
var stats : Dictionary = {}
var reduced_stats : Dictionary = {}
var total_delta := 0.0
var elapsed_time := 0.0

func _ready() -> void:
	var spwaners : Array[Node] = get_tree().get_nodes_in_group('spawn_position')
	for i:Node in spwaners:
		spwan_positions.append(i.global_position)
	bad_ball_timer.timeout.connect(add_new_badball)
	tree = get_tree()
	add_new_ball()
	add_new_badball()
	await get_tree().process_frame


func _process(_delta: float) -> void:
	if Input.is_action_pressed("reload"):
		tree.reload_current_scene()
	
	get_number_of_bad_balls()
	get_number_of_balls()
	update_bad_ball_label()
	update_ball_label()
	update_stats_label()
	total_delta += _delta
	if total_delta >= 0.5:
		
		total_delta = 0.0
		
	elapsed_time += _delta


func get_number_of_balls():
	if tree:
		number_of_balls = tree.get_node_count_in_group('ball')
	
func get_number_of_bad_balls():
	if tree:
		number_of_badballs = tree.get_node_count_in_group('badball')	

func update_ball_label():
	if elapsed_time > 10:
		ball_label.text = str(clampi(number_of_balls - 1, 0 , 50))
	else:
		ball_label.text = str(clampi(number_of_balls, 0 , 50))

func update_bad_ball_label():
	bad_ball_label.text = "Adding [color=Red]red ball[/color] in: " + str(int(floor(bad_ball_timer.time_left)))

func update_stats_label():
	stats_label.text = '[font_size=12]%67s[/font_size]\n' % ['(Avg. & Total)']
	stats_label.text += '%40s | %-40s\n' % [ '[color=Red]Red balls[/color]', 'White balls']
	stats_label.text += '         ----------------------------------------\n'
	for key in reduced_stats:
		stats_label.text += '[color=Red]%28d[/color] | %.1f, %-28.0f\n' % [key, reduced_stats[key][0], reduced_stats[key][1]]
	
	
func update_stats():
	if tree:
		if number_of_badballs in stats:
			stats[number_of_badballs].append(number_of_balls)
		else:
			stats[number_of_badballs] = [number_of_balls]
		for key in stats:
			if stats[key].size() > 0:
				var reduced_sum : float = stats[key].reduce(sum, 0.0)
				var recuded_count : float = stats[key].size()
				var reduced_avg : float = reduced_sum / recuded_count
				if reduced_avg != NAN:
					reduced_stats[key] = [reduced_avg, recuded_count]
	#print (stats)
func sum(accum, number):
	return accum + number
	
func add_new_ball():
	if number_of_balls < 50:
		var ball = BALL.instantiate()
		var random_position : Vector2 = spwan_positions.pick_random()
		ball.position = random_position
		ball.bounced.connect(_on_bounced)	
		call_deferred("add_child", ball)
		
func add_new_badball():
	if number_of_badballs < 10:
		var badball = BADBALL.instantiate()
		var random_position : Vector2 = spwan_positions.pick_random()
		badball.position = random_position
		badball.kill.connect(_on_kill)
		number_of_badballs += 1
		call_deferred("add_child", badball)
		
func _on_bounced():
	add_new_ball()
	update_stats()
	
func _on_kill(body):
	if not body.is_queued_for_deletion():
		body.get_parent().queue_free()
		await get_tree().process_frame
		update_stats()
