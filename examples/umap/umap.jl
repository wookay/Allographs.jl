using Allographs.UMAPs: UMAP

data = rand(5, 50)
umap = UMAP(data)
@info :umap umap
