module UMAP_Backend
using UMAP: UMAP_
end

module UMAPs # Allographs

export UMAP

using ..UMAP_Backend: UMAP_
const UMAP = UMAP_

end # Allographs.UMAPs
