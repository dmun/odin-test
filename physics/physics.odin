package physics

import rl "vendor:raylib"

GRAVITY :: rl.Vector3{0, -9.82, 0}

Particle :: struct {
	position: rl.Vector3,
	velocity: rl.Vector3,
	force:    rl.Vector3,
	mass:     f32,
	radius:   f32,
}

step :: proc(using particle: ^Particle, delta_time: f32) {
	force += mass * GRAVITY
	velocity += force / mass * delta_time
	position += velocity * delta_time
}
