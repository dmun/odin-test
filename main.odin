package main

import "core:fmt"
import "core:math"
import "physics"
import "vendor:raylib"

main :: proc() {
	using raylib
	screenWidth: i32 = 1280
	screenHeight: i32 = 720

	SetConfigFlags({.MSAA_4X_HINT})
	SetTargetFPS(240)
	InitWindow(screenWidth, screenHeight, "odin-test")

	p := physics.Particle{Vector3(0), Vector3(0), Vector3(0), 10, 10}

	camera := Camera3D {
		position   = Vector3{0, 10, 0},
		target     = Vector3{0, 10, 10},
		up         = Vector3{0, 1, 0},
		fovy       = 90,
		projection = .PERSPECTIVE,
	}

	for !WindowShouldClose() {
		BeginDrawing()
		defer EndDrawing()

		ClearBackground(BLACK)
		defer DrawFPS(0, 0)

		BeginMode3D(camera)
		defer EndMode3D()

		physics.step(&p, GetFrameTime())

		UpdateCamera(&camera, .FIRST_PERSON)
		DisableCursor()

		DrawSphere(p.position, p.radius, BLUE)
		DrawGrid(30, 100)
	}
}
