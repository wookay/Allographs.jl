module test_allographs_umaps

using Test
using Allographs.UMAPs: UMAP

data = rand(5, 50)
umap = UMAP(data)
@test size(umap.graph) == (50, 50)
@test size(umap.embedding) == (2, 50)
@test umap isa UMAP{Float64}

end # module test_allographs_umaps
