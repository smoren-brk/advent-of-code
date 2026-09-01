package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Direction :: enum {
    None,
    Left,
    Right
}

Rotation :: struct {
    direction: Direction,
    clicks: u8,
    full_rotations: u64
}

Parse_Error :: enum {
    None,
    BadDirection,
    BadAmount
}

START_STEP :: 50
RANGE :: 100

parse_rotation :: proc(record: string) -> (Rotation, Parse_Error) {
    direction: Direction

    direction_shorthand := rune(record[0])
    switch direction_shorthand {
        case 'L':
            direction = .Left
        case 'R':
            direction = .Right
        case:
            direction = .None
    }

    if direction == .None {
        return Rotation{}, .BadDirection
    }

    clicks, ok := strconv.parse_uint(record[1:])
    if !ok {
        return Rotation{}, .BadAmount
    }

    full_rotations := u64(clicks / RANGE)
    clicks = clicks % RANGE

    rotation := Rotation {
        direction = direction,
        clicks = u8(clicks),
        full_rotations = full_rotations
    }
    return rotation, .None
}

rotate :: proc(position: u8, rotation: Rotation) -> (u8, bool) {
    rotated_position: u8
    overflow: bool

    #partial switch rotation.direction {
    case .Left:
        overflow = rotation.clicks > position
        rotated_position = (position + RANGE - rotation.clicks % RANGE) % RANGE

    case .Right:
        overflow = (position + rotation.clicks) >= RANGE
        rotated_position = (position + rotation.clicks) % RANGE
    }

    return rotated_position, overflow
}

crack_password :: proc(rotations: []Rotation) -> u64 {
    position: u8 = START_STEP
    zeroes:   u64 = 0
    overflow: bool

    for rotation in rotations {
        position, overflow = rotate(position, rotation)
        if position == 0 || overflow {
            zeroes += 1
        }

        zeroes += rotation.full_rotations
    }

    return zeroes
}

main :: proc() {
    input, _ := os.read_entire_file("input.txt", context.allocator)
    defer delete(input, context.allocator)

    rotations: [dynamic]Rotation
    defer delete(rotations)

    iterator := string(input)
    for line in strings.split_lines_iterator(&iterator) {
        rotation, err := parse_rotation(line)
        if err != .None {
            panic("Malformed input file")
        }

        append(&rotations, rotation)
    }

    password := crack_password(rotations[:])
    fmt.printfln("Password is %d", password)
}

