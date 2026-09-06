package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Range :: struct {
    start: int,
    end: int
}

parse_ranges :: proc(input: string) -> [dynamic]Range {
    ranges: [dynamic]Range

    for range_string in strings.split(input, ",") {
        range := strings.split(range_string, "-")

        start, _ := strconv.parse_int(range[0])
        end, _ := strconv.parse_int(range[1])

        append(&ranges, Range { start, end })
    }

    return ranges
}

halve :: proc(number: string) -> int {
    half_digits := len(number) / 2
    half := strings.cut(number, 0, half_digits)

    og, _ := strconv.parse_int(half)

    return og
}

self_similar :: proc(number: string) -> int {
    og := halve(number)
    magnitude := (len(number) / 2) * 10 + 1

    imitation := og * magnitude
    integral, _ := strconv.parse_int(number)

    if imitation != integral do return 0

    return integral
}

accumulate_self_similar :: proc(range: Range) -> int {
    selfs: int

    for number in range.start..=range.end {
        stringified_integral := fmt.aprintf("%v", number)
        even_digit_number := (len(stringified_integral)  % 2) == 0

        if !even_digit_number do continue

        selfs += self_similar(stringified_integral)
    }

    return selfs
}

main :: proc() {
    input, _ := os.read_entire_file("input.txt", context.allocator)
    defer delete(input, context.allocator)

    content := string(input)
    ranges := parse_ranges(content)
    defer delete(ranges)

    accumulation: int
    for range in ranges {
        accumulatee := accumulate_self_similar(range)
        fmt.println(range)
        fmt.println(accumulatee)

        accumulation += accumulatee
    }

    fmt.println(accumulation)
}

