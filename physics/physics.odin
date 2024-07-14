package physics

import rl "vendor:raylib"

GRAVITY :: rl.Vector3{0, -9.82, 0}

RigidBody :: struct {
	position: rl.Vector3,
	velocity: rl.Vector3,
	force:    rl.Vector3,
	mass:     f32,
}

Particle :: struct {
	radius:     f32,
	using body: RigidBody,
}

step :: proc(using body: ^RigidBody, delta_time: f32) {
	force += mass * GRAVITY
	velocity += force / mass * delta_time
	position += velocity * delta_time
}
