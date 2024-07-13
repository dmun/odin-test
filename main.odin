package main

import "core:fmt"
import "core:math"
import "gui"
import "physics"
import "vendor:raylib"

main :: proc() {
	using raylib

	SetConfigFlags({.MSAA_4X_HINT})
	SetTargetFPS(240)
	InitWindow(1280, 720, "odin-test")

	p := physics.Particle{Vector3(0), Vector3(0), Vector3(0), 10, 10}

	camera := Camera3D {
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

	for !WindowShouldClose() {
		BeginDrawing()
		defer EndDrawing()

		defer DrawFPS(0, 0)
		defer gui.draw_crosshair(&crosshair)

		BeginMode3D(camera)
		defer EndMode3D()

		physics.step(&p, GetFrameTime())

		UpdateCamera(&camera, .FIRST_PERSON)
		DisableCursor()

		DrawSphere(p.position, p.radius, BLUE)
		DrawGrid(30, 100)

		ClearBackground(ColorBrightness(BLACK, 0.1))
	}
}
