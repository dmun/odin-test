package gui

import rl "vendor:raylib"

CrosshairSettings :: struct {
    length: i32,
    thickness: i32,
    gap: i32,
    color: rl.Color,
}

draw_crosshair :: proc(using settings: ^CrosshairSettings) {
    mid_x := rl.GetScreenWidth() / 2
    mid_y := rl.GetScreenHeight() / 2

    rl.DrawRectangle(mid_x - thickness / 2, mid_y + gap, thickness, length, color)
    rl.DrawRectangle(mid_x - thickness / 2, mid_y - gap - length, thickness, length, color)
    rl.DrawRectangle(mid_x + gap, mid_y - thickness / 2, length, thickness, color)
    rl.DrawRectangle(mid_x - gap - length, mid_y - thickness / 2, length, thickness, color)
}
