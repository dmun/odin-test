package physics

import rl "vendor:raylib"
import "core:math"

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

Collision :: struct {
	body_a: ^RigidBody,
	body_b: ^RigidBody,
}

step :: proc(bodies: ^[dynamic]^RigidBody, delta_time: f32) {
	for &body in bodies {
		using body
		force += mass * GRAVITY
		velocity += force / mass * delta_time
		position += velocity * delta_time
		force *= 0
	}
}

collide :: proc(bodies: ^[dynamic]^RigidBody) {
	using rl
	collisions: [dynamic]Collision

	for b1 in bodies {
		for b2 in bodies {
			if b1 == b2 {continue}

			distance := Vector3Distance(b1.position, b2.position)
			if distance < 10 {
				append(&collisions, Collision{b1, b2})
			}
		}

		if b1.position.y <= 5 {
			b1.position.y = 5
			b1.velocity.x -= 0.4 * 9.8 * GetFrameTime() * math.sign(b1.velocity.x)
			b1.velocity.z -= 0.4 * 9.8 * GetFrameTime() * math.sign(b1.velocity.z)
		}
	}

	for c in collisions {
		using c
		norm := Vector3Normalize(body_a.position - body_b.position)
		body_a.position += norm
		body_b.position -= norm
	}
}
