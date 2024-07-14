package main

import "core:fmt"
import "core:math"
import "gui"
import "physics"
import rl "vendor:raylib"

Player :: struct {
	orientation: quaternion128,
	camera:      rl.Camera3D,
	using body:  physics.RigidBody,
}

update_player :: proc(using player: ^Player) {
	using rl

	axis := (camera.target - camera.position)

	movement_force := Vector3(0)
	if IsKeyDown(.W) {movement_force += axis}
	if IsKeyDown(.S) {movement_force += -axis}
	if IsKeyDown(.A) {movement_force += Vector3RotateByAxisAngle(axis, {0, 1, 0}, -90 * DEG2RAD)}
	if IsKeyDown(.D) {movement_force += Vector3RotateByAxisAngle(axis, {0, 1, 0}, 90 * DEG2RAD)}
	if IsKeyPressed(.SPACE) {
		movement_force.y = 100
		velocity.y = 100
	}
	force += movement_force

	mouseDelta := GetMouseDelta() * 0.05
	UpdateCameraPro(&camera, 0, {mouseDelta.x, mouseDelta.y, 0}, 0)

	player.orientation = QuaternionFromVector3ToVector3(camera.position, camera.target)

	camera.target = player.position + axis
	camera.position = player.position
}

draw_player :: proc(using player: ^Player) {
	using rl
	DrawCubeV(position, Vector3(20), WHITE)
}

main :: proc() {
	using rl

	SetConfigFlags({.MSAA_4X_HINT})
	SetTargetFPS(240)
	InitWindow(1280, 720, "odin-test")

	camera := Camera3D {
		position   = Vector3{0, 10, 0},
		target     = Vector3{0, 10, 10},
		up         = Vector3{0, 1, 0},
		fovy       = 90,
		projection = .PERSPECTIVE,
	}

	free_camera := Camera3D {
		position   = Vector3{0, 10, 0},
		target     = Vector3{0, 10, 10},
		up         = Vector3{0, 1, 0},
		fovy       = 90,
		projection = .PERSPECTIVE,
	}

	crosshair := gui.CrosshairSettings {
		length    = 8,
		gap       = 4,
		thickness = 2,
		color     = GREEN,
	}

	player := Player {
		orientation = QuaternionFromEuler(0, 0, 0),
		camera      = camera,
		position    = Vector3{0, 10, 0},
		force       = Vector3(0),
		velocity    = Vector3(0),
		mass        = 1,
	}

	active_camera := &player.camera
	camera_mode := CameraMode.CUSTOM

	particles: [dynamic]^physics.Particle
	bodies: [dynamic]^physics.RigidBody
	append(&bodies, &player.body)

	timer := f64(0)

	for !WindowShouldClose() {
		BeginDrawing()
		defer EndDrawing()
		ClearBackground(ColorBrightness(BLACK, 0.1))

		defer DrawFPS(0, 0)
		defer gui.draw_crosshair(&crosshair)
		defer DrawText(TextFormat("%d", len(bodies)), 0, 18, 18, WHITE)

		if IsKeyPressed(.LEFT_ALT) {
			if camera_mode == .FREE {
				camera_mode = .CUSTOM
			} else if camera_mode == .CUSTOM {
				camera_mode = .FREE
			}
		}

		if camera_mode == .CUSTOM {
			active_camera = &player.camera
		} else {
			active_camera = &free_camera
		}

		BeginMode3D(active_camera^)
		defer EndMode3D()
		UpdateCamera(active_camera, camera_mode)

		delta_time := GetFrameTime()
		physics.step(&bodies, delta_time)

		if IsMouseButtonDown(.LEFT) && GetTime() - timer > 0.1 {
			timer = GetTime()

			using active_camera
			// TODO: Handle-based approach
			p := new(physics.Particle)
			p^ = physics.Particle {
				position = target,
				velocity = (target - position) * 10,
				force    = (target - position) * 10,
				radius   = 5,
				mass     = 2,
			}
			append(&particles, p)
			append(&bodies, &p.body)
		}
		update_player(&player)
		draw_player(&player)

		for &body in particles {
			DrawSphere(body.position, body.radius, BLUE)
		}

		DrawGrid(30, 100)

		DisableCursor()
	}
}
