module test_allographs_gplot

using Test
using Allographs.GPlot: curve_lines

lines_cord = [
    Any[:M, -0.925522, -0.897966, :Q, -1.0034, -0.527442, -0.675083, -0.338873],
    Any[:M, 0.90314, 0.94416, :Q, 0.366411, 1.00092, 0.146571, 0.508001],
    Any[:M, -0.68843, -0.141903, :Q, -0.667218, 0.152805, -0.940947, 0.26405],
    Any[:M, -0.550895, -0.157211, :Q, -0.482275, 0.297334, -0.0287718, 0.372534],
    Any[:M, -0.888634, 0.368871, :Q, -0.501811, 0.705991, -0.0616553, 0.442276],
]
lines = curve_lines(lines_cord)
@test lines[1] == (startPoint=(-0.925522, -0.897966), control=(-1.0034, -0.527442), endPoint=(-0.675083, -0.338873))

end # module test_allographs_gplot
