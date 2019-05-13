module test_allographs_fontengines_opentype

using Allographs.FontEngines.OpenType
using Test

strokes = ["M 350 571 Q 380 593 449 614 Q 465 615 468 623 Q 471 633 458 643 Q 439 656 396 668 Q 381 674 370 672 Q 363 668 363 657 Q 364 621 200 527 Q 196 518 201 516 Q 213 516 290 546 Q 303 550 316 556 L 350 571 Z"]
commands = OpenType.stroke_to_commands(first(strokes))
@test first(commands) == (type = 'M', point = (350.0, 571.0))
@test last(commands) == (type = 'Z',)

d = "M 300 50 a 150 50 0 0 0 250 50"
commands = OpenType.stroke_to_commands(d)
@test last(commands) == (type = 'A', control = (150.0, 50.0), φ = 0.0, arcflag = 0, sweepflag = 0, endPoint=(250.0, 50.0))

end # module test_allographs_fontengines_opentype
