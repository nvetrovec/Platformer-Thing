extends RigidBody2D

signal play_animation(name)
const STATE_IDLE = "idle"
const STATE_RUN = "run"
const STATE_JUMP_START = "jump_start"
const STATE_AIRBORNE = "airborne"
const DIR_LEFT = "left"
const DIR_RIGHT = "right"
const MIN_AIRBORNE_TIME = 0.166666667
export(float) var run_speed = 128.0 # px/s
export(float) var air_speed = 96.0 # px/s
export(float) var jump_speed = 384.0 # px/s
var _state = STATE_IDLE # use _set_state to properly handle this stuff
var _just_pressed_jump = false
var _ground_index = -1
var _airborne_time = 0.0

func _integrate_forces(body_state):
	# find the ground, that is, a contact with an upwards-facing collision normal
	_ground_index = -1
	for contact_id in range(body_state.get_contact_count()):
		var collision_normal = body_state.get_contact_local_normal(contact_id)
		if (collision_normal.dot(Vector2(0, -1)) > 0.6):
			_ground_index = contact_id
			break
	# call the appropriate state function
	_set_state(call("_state_" + _state, body_state), body_state)
	# update the amount of time that the player was airborne
	if (_ground_index < 0):
		_airborne_time += body_state.get_step()
	else:
		_airborne_time = 0.0
	# apply the power of physics for every state
	var linear_velocity = body_state.get_linear_velocity()
	linear_velocity += body_state.get_total_gravity() * body_state.get_step()
	body_state.set_linear_velocity(linear_velocity)

# handles all the enter/exit actions of a state
func _set_state(new_state, body_state):
	# can't necessarily change state if changing to the same state
	if (_state != new_state):
		# do any cleanup that the current state requires
		var exit_func = "_exit_state_" + _state
		if (has_method(exit_func)):
			call(exit_func, body_state)
		# do any setup that the new state requires
		var enter_func = "_enter_state_" + new_state
		if (has_method(enter_func)):
			call(enter_func, body_state)
		# finally, switch to the new state
		_state = new_state

# sets the direction that the player is facing
func _set_direction(dir):
	if (dir == DIR_LEFT):
		get_node("torso").set_scale(Vector2(-1, 1))
	elif (dir == DIR_RIGHT):
		get_node("torso").set_scale(Vector2(1, 1))

# get the direction that the player is facing, -1=left 1=right
func _get_direction():
	return get_node("torso").get_scale().x

# handles left/right movement controls
func _move_left_right():
	var move_left = Input.is_action_pressed("ui_left")
	var move_right = Input.is_action_pressed("ui_right")
	if (move_left and not move_right):
		_set_direction(DIR_LEFT)
		return STATE_RUN
	elif (not move_left and move_right):
		_set_direction(DIR_RIGHT)
		return STATE_RUN
	return STATE_IDLE

# returns true if the jump key was just pressed, and updates that key's state
func _check_jump():
	if (Input.is_action_pressed("player_jump")):
		if (_just_pressed_jump):
			_just_pressed_jump = false
			return true
	else:
		_just_pressed_jump = true
	return false

# returns true if the player is on the ground
func _is_on_ground(body_state):
	return body_state.get_linear_velocity().y >= 0 and _ground_index >= 0

func _enter_state_idle(body_state):
	emit_signal("play_animation", "idle")

func _state_idle(body_state):
	var linear_velocity = body_state.get_linear_velocity()
	linear_velocity.x = 0
	body_state.set_linear_velocity(linear_velocity)
	if (not _is_on_ground(body_state) and _airborne_time >= MIN_AIRBORNE_TIME):
		return STATE_AIRBORNE
	if (_check_jump()):
		return STATE_JUMP_START
	return _move_left_right()

func _enter_state_run(body_state):
	emit_signal("play_animation", "run")

func _state_run(body_state):
	var linear_velocity = body_state.get_linear_velocity()
	linear_velocity.x = run_speed * _get_direction()
	body_state.set_linear_velocity(linear_velocity)
	if (not _is_on_ground(body_state) and _airborne_time >= MIN_AIRBORNE_TIME):
		return STATE_AIRBORNE
	if (_check_jump()):
		return STATE_JUMP_START
	return _move_left_right()

func _state_jump_start(body_state):
	return STATE_AIRBORNE

func _exit_state_jump_start(body_state):
	var linear_velocity = body_state.get_linear_velocity()
	linear_velocity.y = -jump_speed
	body_state.set_linear_velocity(linear_velocity)

func _enter_state_airborne(body_state):
	emit_signal("play_animation", "airborne")

func _state_airborne(body_state):
	var state = _move_left_right()
	var linear_velocity = body_state.get_linear_velocity()
	if (state == STATE_RUN):
		linear_velocity.x = air_speed * _get_direction()
	elif (state == STATE_IDLE):
		linear_velocity.x = 0
	body_state.set_linear_velocity(linear_velocity)
	if (not _is_on_ground(body_state)):
		return STATE_AIRBORNE
	return state
