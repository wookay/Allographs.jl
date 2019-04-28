using Tutte.Graphs # Graph → ← IDMap Node @nodes
using LightGraphs.SimpleGraphs: SimpleDiGraph

@nodes A B C D E
graph = Graph(union(A → C → D → E, C → E ← B))
idmap = IDMap(graph)
g = SimpleDiGraph(graph)

using Allographs.GPlot
using GraphPlot: spring_layout
(nodes, texts, edgetexts, lines, arrows) = GPlot.gplot(g, spring_layout(g)...;)

using Poptart.Controls # Canvas
using Poptart.Drawings # Line Polyline stroke
using Colors: RGBA
using Compose: inch

canvas = Canvas()
scale(x) = 200 + 5inch.value * x

textColor = RGBA(0.8, 0.7, 0.8, 0.9)
for (i, prim) in enumerate(nodes.primitives)
    center = (p -> p.value).(prim.center)
    radius = prim.radius.value
    rect = scale.((center[1] - radius, center[2] - radius, center[1] + radius, center[2] + radius))
    node = idmap[i]
    textbox = TextBox(text=String(node.id), rect=rect, color=textColor)
    put!(canvas, textbox)
end

thickness = 6
strokeColor = RGBA(0.1, 0.7, 0.8, 1)
for prim in lines.primitives
    points = (p -> scale.((p[1].value, p[2].value))).(prim.points)
    line = Line(points=points, thickness=thickness, color=strokeColor)
    put!(canvas, stroke(line))
end
for prim in arrows.primitives
    points = (p -> scale.((p[1].value, p[2].value))).(prim.points)
    arrow = Polyline(points=points, thickness=thickness, color=strokeColor)
    put!(canvas, stroke(arrow))
end

using Poptart.Desktop # Application
width, height = 500, 500
window1 = Windows.Window(items=[canvas], title="SimpleDiGraph", frame=(x=10, y=10, width=width-20, height=height-20))
closenotify = Condition()
app = Application(windows=[window1], title="App", frame=(width=width, height=height), closenotify=closenotify)
Base.JLOptions().isinteractive==0 && wait(closenotify)
