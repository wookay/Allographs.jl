module test_geometricflux_graphconv

using Test
using GeometricFlux: GraphConv
using SimpleWeightedGraphs: SimpleWeightedGraph, add_edge!

const in_channel = 3
const out_channel = 5
const N = 6
const adj = [0. 1. 1. 0. 0. 0.;
             1. 0. 1. 0. 1. 0.;
             1. 1. 0. 1. 0. 1.;
             0. 0. 1. 0. 0. 0.;
             0. 1. 0. 0. 0. 0.;
             0. 0. 1. 0. 0. 0.]

ug = SimpleWeightedGraph(6)
add_edge!(ug, 1, 2, 2); add_edge!(ug, 1, 3, 2); add_edge!(ug, 2, 3, 1)
add_edge!(ug, 3, 4, 5); add_edge!(ug, 2, 5, 2); add_edge!(ug, 3, 6, 2)

gc = GraphConv(ug, in_channel=>out_channel)
@test gc.adjlist == [[2, 3], [1, 3, 5], [1, 2, 4, 6], [3], [2], [3]]
@test gc.aggr === :add
@test size(gc.weight1) == size(gc.weight2) == (out_channel, in_channel)
@test size(gc.bias) == (out_channel, N)

end # module test_geometricflux_graphconv
