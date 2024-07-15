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
	collisions: [dynamic]Collision

	for b1 in bodies {
		for b2 in bodies {
			if b1 == b2 {continue}

			distance := rl.Vector3Distance(b1.position, b2.position)
			if distance < 10 {
				append(&collisions, Collision{b1, b2})
			}
		}

		if b1.position.y <= 5 {
			b1.position.y = 5
			b1.velocity.x -= 0.4 * 9.8 * rl.GetFrameTime() * math.sign(b1.velocity.x)
			b1.velocity.z -= 0.4 * 9.8 * rl.GetFrameTime() * math.sign(b1.velocity.z)
		}
	}

	for c in collisions {
		norm := rl.Vector3Normalize(c.body_a.position - c.body_b.position)
		c.body_a.position += norm
		c.body_b.position -= norm
	}
}
