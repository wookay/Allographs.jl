using Allographs.OpenType # Vec
using Test

@test Vec(1, 2) .+ 1 == Vec(2, 3)

strokes = ["M 350 571 Q 380 593 449 614 Q 465 615 468 623 Q 471 633 458 643 Q 439 656 396 668 Q 381 674 370 672 Q 363 668 363 657 Q 364 621 200 527 Q 196 518 201 516 Q 213 516 290 546 Q 303 550 316 556 L 350 571 Z"]
commands = OpenType.stroke_to_commands(first(strokes))
@test first(commands) == (type = 'M', x1 = 350.0, y1 = 571.0)
@test last(commands) == (type = 'Z',)

d = "M 300 50 a 150 50 0 0 0 250 50"
commands = OpenType.stroke_to_commands(d)
@test last(commands) == (type = 'A', x1 = 150.0, y1 = 50.0, φ = 0.0, arcflag = 0, sweepflag = 0, x2 = 250.0, y2 = 50.0)
