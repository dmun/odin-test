package main

import "core:fmt"
import "core:math"
import "gui"
import phy "physics"
import rl "vendor:raylib"

Player :: struct {
	orientation: quaternion128,
	camera:      rl.Camera3D,
	using body:  phy.RigidBody,
}

update_player :: proc(using player: ^Player) {
	axis := (camera.target - camera.position)
	movement := rl.Vector3(0)

	if rl.IsKeyDown(.W) {movement += axis}
	if rl.IsKeyDown(.S) {movement += -axis}
	if rl.IsKeyDown(.A) {
		movement += rl.Vector3RotateByAxisAngle(axis, {0, 1, 0}, 90 * rl.DEG2RAD)
	}
	if rl.IsKeyDown(.D) {
		movement += rl.Vector3RotateByAxisAngle(axis, {0, 1, 0}, -90 * rl.DEG2RAD)
	}

	movement.y = 0
	if rl.IsKeyPressed(.SPACE) {
		movement.y = 100
	}
	force += movement * 100

	mouseDelta := rl.GetMouseDelta() * 0.05
	rl.UpdateCameraPro(&camera, 0, {mouseDelta.x, mouseDelta.y, 0}, 0)

	player.orientation = rl.QuaternionFromVector3ToVector3(camera.position, camera.target)

	camera.target = player.position + axis
	camera.position = player.position
}

draw_player :: proc(using player: ^Player) {
	rl.DrawCubeV(position, (20), rl.WHITE)
}

spawn_particle :: proc(
	using camera: ^rl.Camera3D,
	particles: ^[dynamic]^phy.Particle,
	bodies: ^[dynamic]^phy.RigidBody,
) {
	// TODO: Handle-based approach
	p := new(phy.Particle)
	p^ = phy.Particle {
		position = target,
		velocity = target - position,
		force    = target - position,
		radius   = 5,
		mass     = 5,
	}
	append(particles, p)
	append(bodies, &p.body)
}

main :: proc() {
	rl.SetConfigFlags({.MSAA_4X_HINT})
	rl.SetTargetFPS(240)
	rl.InitWindow(1280, 720, "odin-test")

	camera := rl.Camera3D {
		position   = {0, 10, 0},
		target     = {0, 10, 10},
		up         = {0, 1, 0},
		fovy       = 90,
		projection = .PERSPECTIVE,
	}

	free_camera := rl.Camera3D {
		position   = {0, 10, 0},
		target     = {0, 10, 10},
		up         = {0, 1, 0},
		fovy       = 90,
		projection = .PERSPECTIVE,
	}

	crosshair := gui.CrosshairSettings {
		length    = 8,
		gap       = 4,
		thickness = 2,
		color     = rl.GREEN,
	}

	player := Player {
		orientation = rl.QuaternionFromEuler(0, 0, 0),
		camera      = camera,
		position    = {0, 10, 0},
		force       = (0),
		velocity    = (0),
		mass        = 5,
	}

	active_camera := &player.camera
	camera_mode := rl.CameraMode.CUSTOM

	particles: [dynamic]^phy.Particle
	bodies: [dynamic]^phy.RigidBody
	append(&bodies, &player.body)

	timer := f64(0)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.ColorBrightness(rl.BLACK, 0.1))

		defer rl.DrawFPS(0, 0)
		defer gui.draw_crosshair(&crosshair)
		defer rl.DrawText(rl.TextFormat("%d", len(bodies)), 0, 18, 18, rl.WHITE)

		if rl.IsKeyPressed(.LEFT_ALT) {
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

		rl.BeginMode3D(active_camera^)
		defer rl.EndMode3D()
		rl.UpdateCamera(active_camera, camera_mode)

		delta_time := rl.GetFrameTime()
		phy.step(&bodies, delta_time)
		phy.collide(&bodies)

		if rl.IsMouseButtonDown(.LEFT) && rl.GetTime() - timer > 0.1 {
			timer = rl.GetTime()
			spawn_particle(active_camera, &particles, &bodies)
		}

		update_player(&player)
		draw_player(&player)

		for &p in particles {
			rl.DrawSphere(p.position, p.radius, rl.BLUE)
			rl.DrawRay({p.position, p.velocity}, rl.RED)
		}

		rl.DrawGrid(30, 100)

		rl.DisableCursor()
	}
}
