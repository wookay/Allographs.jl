using FreeType
using FreeType: FT_Vector

font_path = normpath(@__DIR__, "IropkeBatangM.ttf")

library = Ref{FT_Library}()
error = FT_Init_FreeType(library)

refface = Ref{FT_Face}()
FT_New_Face(library[], font_path, 0, refface) == 0

glyph_index = FT_Get_Char_Index(refface[], '헐')
FT_Set_Char_Size(refface[], 0, 72, 3, 3) == 0
FT_Load_Glyph(refface[], glyph_index, FT_LOAD_NO_SCALE | FT_LOAD_NO_BITMAP) == 0

function pos(p::Ptr{FT_Vector})
    v = unsafe_load(p)
    (v.x, v.y)
end

paths = []
function move_to_func(to, user)
    push!(paths, (type='M', point=pos(to)))
    Cint(0)
end
function line_to_func(to, user)
    push!(paths, (type='L', point=pos(to)))
    Cint(0)
end
function conic_to_func(control, to, user)
    c, endPoint = pos.((control, to))
    push!(paths, (type='C', control=c, endPoint=endPoint))
    Cint(0)
end
function cubic_to_func(control1, control2, to, user)
    c1, c2, endPoint = pos.((control1, control2, to))
    push!(paths, (type='Q', control1=c1, control2=c2, endPoint=endPoint))
    Cint(0)
end

move_f = @cfunction $move_to_func Cint (Ptr{FT_Vector}, Ptr{Cvoid})
line_f = @cfunction $line_to_func Cint (Ptr{FT_Vector}, Ptr{Cvoid})
conic_f = @cfunction $conic_to_func Cint (Ptr{FT_Vector}, Ptr{FT_Vector}, Ptr{Cvoid})
cubic_f = @cfunction $cubic_to_func Cint (Ptr{FT_Vector}, Ptr{FT_Vector}, Ptr{FT_Vector}, Ptr{Cvoid})

GC.@preserve move_f line_f conic_f cubic_f begin
face = unsafe_load(refface[])
glyph = unsafe_load(face.glyph)
outline_funcs = FreeType.FT_Outline_Funcs(Base.unsafe_convert.(Ptr{Cvoid}, (move_f, line_f, conic_f, cubic_f))..., 0, 0)
FT_Outline_Decompose(pointer_from_objref.((Ref(glyph.outline), Ref(outline_funcs)))..., C_NULL)
end

FT_Done_FreeType(library[]) == 0


using Allographs.OpenType
using Poptart.Desktop # Application
using Poptart.Controls # Canvas
using Poptart.Drawings # Line Curve stroke
using Colors # RGBA

function put_glyph(f, canvas, commands)
    thickness = 2
    strokeColor = RGBA(0.1, 0.7, 0.8, 0.9)
    lastPoint = (0, 0)
    for cmd in commands
        if cmd.type == 'M'
           lastPoint = cmd.point
        elseif cmd.type == 'L'
           line = Line(points=f.([lastPoint, cmd.point]), thickness=thickness, color=strokeColor)
           put!(canvas, stroke(line))
           lastPoint = cmd.point
        elseif cmd.type == 'Q'
           curve = Curve(startPoint=f(lastPoint), control1=f(cmd.control1), control2=f(cmd.control2), endPoint=f(cmd.endPoint), thickness=thickness, color=strokeColor)
           put!(canvas, stroke(curve))
           lastPoint = cmd.endPoint
        elseif cmd.type == 'C'
           curve = Curve(startPoint=f(lastPoint), control1=f(cmd.control), control2=f(cmd.endPoint), endPoint=f(cmd.endPoint), thickness=thickness, color=strokeColor)
           put!(canvas, stroke(curve))
           lastPoint = cmd.endPoint
        end
    end
end

canvas = Canvas()
width, height = 500, 500
put_glyph(canvas, paths) do point
    x, y = point
    (x, height-y) ./ 7 .+ (20, 110)
end
window1 = Windows.Window(items=[canvas], title="freetype", frame=(x=10, y=10, width=width-20, height=height-20))
closenotify = Condition()
app = Application(windows=[window1], title="App", frame=(width=width, height=height), closenotify=closenotify)
Base.JLOptions().isinteractive==0 && wait(closenotify)
