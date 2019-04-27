module test_compose_inch

using Test
using Compose: inch, mm

@test 8inch == 203.2mm
@test 8inch.value == 203.2

end # module test_compose_inch
