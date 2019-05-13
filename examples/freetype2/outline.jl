using Allographs.FontEngines.FreeType2
using Poptart.Desktop # Application
using Poptart.Controls # Canvas
using Poptart.Drawings # Line Curve stroke translate scale
using Colors # RGBA

function put_glyph(transform, canvas, commands)
    thickness = 2
    strokeColor = RGBA(0.1, 0.7, 0.8, 0.9)
    lastPoint = (0, 0)
    for cmd in commands
        if cmd.type == 'M'
           lastPoint = cmd.point
        elseif cmd.type == 'L'
           line = Line(points=[lastPoint, cmd.point], thickness=thickness, color=strokeColor)
           put!(canvas, (stroke ∘ transform)(line))
           lastPoint = cmd.point
        elseif cmd.type == 'Q'
           curve = Curve(startPoint=lastPoint, control1=cmd.control1, control2=cmd.control2, endPoint=cmd.endPoint, thickness=thickness, color=strokeColor)
           put!(canvas, (stroke ∘ transform)(curve))
           lastPoint = cmd.endPoint
        elseif cmd.type == 'C'
           curve = Curve(startPoint=lastPoint, control1=cmd.control, control2=cmd.endPoint, endPoint=cmd.endPoint, thickness=thickness, color=strokeColor)
           put!(canvas, (stroke ∘ transform)(curve))
           lastPoint = cmd.endPoint
        end
    end
end

canvas = Canvas()
width, height = 500, 500

font_path = normpath(@__DIR__, "IropkeBatangM.ttf")
commands = FreeType2.char_to_commands(font_path, '헐', 72)
put_glyph(canvas, commands) do element
    translate(scale(element, (1/7, -1/7)), (10, 150))
end
window1 = Windows.Window(items=[canvas], title="freetype2", frame=(x=10, y=10, width=width-20, height=height-20))
closenotify = Condition()
app = Application(windows=[window1], title="App", frame=(width=width, height=height), closenotify=closenotify)
Base.JLOptions().isinteractive==0 && wait(closenotify)
