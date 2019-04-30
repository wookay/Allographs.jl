module GPlot # Allographs

using GraphPlot: spring_layout, graphline, graphcurve
using Compose: Compose, hcenter, vcenter
using LightGraphs.SimpleGraphs: SimpleGraph, SimpleDiGraph, edges, src, dst
using LightGraphs: AbstractGraph
using LightGraphs.SimpleGraphs: nv, ne, is_directed
using Colors: @colorant_str

function curve_lines(lines_cord)::Vector{NamedTuple{(:startPoint, :control, :endPoint)}}
    points = []
    for cord in lines_cord
        startPoint = (cord[2:3]...,)
        control = (cord[5:6]...,)
        endPoint =  (cord[7:8]...,)
        push!(points, (startPoint=startPoint, control=control, endPoint=endPoint))
    end
    points
end

function gplot(g::AbstractGraph{T}; kwargs...) where {T <:Integer}
    gplot(g, spring_layout(g)...; kwargs...)
end

# take from https://github.com/JuliaGraphs/GraphPlot.jl/blob/master/src/plot.jl
function gplot(g::AbstractGraph{T},
    locs_x_in::Vector{R}, locs_y_in::Vector{R};
    nodelabel = nothing,
    nodelabelc = colorant"black",
    nodelabelsize = 1.0,
    NODELABELSIZE = 4.0,
    nodelabeldist = 0.0,
    nodelabelangleoffset = π / 4.0,
    edgelabel = [],
    edgelabelc = colorant"black",
    edgelabelsize = 1.0,
    EDGELABELSIZE = 4.0,
    edgestrokec = colorant"lightgray",
    edgelinewidth = 1.0,
    EDGELINEWIDTH = 3.0 / sqrt(nv(g)),
    edgelabeldistx = 0.0,
    edgelabeldisty = 0.0,
    nodesize = 1.0,
    NODESIZE = 0.25 / sqrt(nv(g)),
    nodefillc = colorant"turquoise",
    nodestrokec = nothing,
    nodestrokelw = 0.0,
    arrowlengthfrac = is_directed(g) ? 0.1 : 0.0,
    arrowangleoffset = π / 9.0,
    linetype = "straight",
    outangle = pi/5) where {T <:Integer, R <: Real}

    length(locs_x_in) != length(locs_y_in) && error("Vectors must be same length")
    N = nv(g)
    NE = ne(g)
    if nodelabel != nothing && length(nodelabel) != N
        error("Must have one label per node (or none)")
    end
    if !isempty(edgelabel) && length(edgelabel) != NE
        error("Must have one label per edge (or none)")
    end

    locs_x = Float64.(locs_x_in)
    locs_y = Float64.(locs_y_in)

    # Scale to unit square
    min_x, max_x = extrema(locs_x)
    min_y, max_y = extrema(locs_y)
    function scaler(z, a, b)
        2.0 * ((z - a) / (b - a)) - 1.0
    end
    map!(z -> scaler(z, min_x, max_x), locs_x, locs_x)
    map!(z -> scaler(z, min_y, max_y), locs_y, locs_y)

    # Determine sizes
    #NODESIZE    = 0.25/sqrt(N)
    #LINEWIDTH   = 3.0/sqrt(N)

    max_nodesize = NODESIZE / maximum(nodesize)
    nodesize *= max_nodesize
    max_edgelinewidth = EDGELINEWIDTH / maximum(edgelinewidth)
    edgelinewidth *= max_edgelinewidth
    max_edgelabelsize = EDGELABELSIZE / maximum(edgelabelsize)
    edgelabelsize *= max_edgelabelsize
    max_nodelabelsize = NODELABELSIZE / maximum(nodelabelsize)
    nodelabelsize *= max_nodelabelsize
    max_nodestrokelw = maximum(nodestrokelw)
    if max_nodestrokelw > 0.0
        max_nodestrokelw = EDGELINEWIDTH / max_nodestrokelw
        nodestrokelw *= max_nodestrokelw
    end

    # Create nodes
    nodecircle = fill(0.4Compose.w, length(locs_x))
    nodes = []
    for i = 1:length(locs_x)
        if isa(nodesize, Real)
            nodecircle[i] *= nodesize
        else
            nodecircle[i] *= nodesize[i]
        end
        push!(nodes, (center=(locs_x[i], locs_y[i]), radius=nodecircle[i].value))
    end

    # Create node labels if provided
    texts = nothing
    if nodelabel != nothing
        text_locs_x = deepcopy(locs_x)
        text_locs_y = deepcopy(locs_y)
        texts = text(text_locs_x .+ nodesize .* (nodelabeldist * cos(nodelabelangleoffset)),
                     text_locs_y .- nodesize .* (nodelabeldist * sin(nodelabelangleoffset)),
                     map(string, nodelabel), [hcenter], [vcenter])
    end
    # Create edge labels if provided
    edgetexts = nothing
    if !isempty(edgelabel)
        edge_locs_x = zeros(R, NE)
        edge_locs_y = zeros(R, NE)
        for (e_idx, e) in enumerate(edges(g))
            i = src(e)
            j = dst(e)
            mid_x = (locs_x[i]+locs_x[j]) / 2.0
            mid_y = (locs_y[i]+locs_y[j]) / 2.0
            edge_locs_x[e_idx] = (is_directed(g) ? (mid_x+locs_x[j]) / 2.0 : mid_x) + edgelabeldistx * NODESIZE
            edge_locs_y[e_idx] = (is_directed(g) ? (mid_y+locs_y[j]) / 2.0 : mid_y) + edgelabeldisty * NODESIZE

        end
        edgetexts = text(edge_locs_x, edge_locs_y, map(string, edgelabel), [hcenter], [vcenter])
    end

    # Create lines and arrow heads
    lines, arrows = nothing, nothing
    if linetype == "curve"
        if arrowlengthfrac > 0.0
            lines_cord, arrows_cord = graphcurve(g, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset, outangle)
            lines = curve_lines(lines_cord)
            arrows = arrows_cord
        else
            lines_cord = graphcurve(g, locs_x, locs_y, nodesize, outangle)
            lines = curve_lines(lines_cord)
        end
    else
        if arrowlengthfrac > 0.0
            lines_cord, arrows_cord = graphline(g, locs_x, locs_y, nodesize, arrowlengthfrac, arrowangleoffset)
            lines = lines_cord
            arrows = arrows_cord
        else
            lines_cord = graphline(g, locs_x, locs_y, nodesize)
            lines = lines_cord
        end
    end
    (nodes, texts, edgetexts, lines, arrows)
end

end # module Allographs.GPlot
