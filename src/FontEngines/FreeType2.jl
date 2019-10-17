module FreeType2 # Allographs.FontEngines

using FreeType: FT_Init_FreeType, FT_New_Face, FT_Get_Char_Index, FT_Set_Char_Size, FT_Load_Glyph, FT_Outline_Funcs, FT_Outline_Decompose, FT_Done_FreeType, FT_Library, FT_Face, FT_Vector, FT_LOAD_NO_BITMAP

struct Font
    path::String
    library::FT_Library
    face::FT_Face
end

function pos(p::Ptr{FT_Vector})
    v = unsafe_load(p)
    (v.x, v.y)
end

function move_to_func(to, user)
    ccall(user, Cvoid, (Any,), (type='M', point=pos(to)))
    Cint(0)
end

function line_to_func(to, user)
    ccall(user, Cvoid, (Any,), (type='L', point=pos(to)))
    Cint(0)
end

function conic_to_func(control, to, user)
    ccall(user, Cvoid, (Any,), (type='C', control=pos(control), endPoint=pos(to)))
    Cint(0)
end

function cubic_to_func(control1, control2, to, user)
    ccall(user, Cvoid, (Any,), (type='Q', control1=pos(control1), control2=pos(control2), endPoint=pos(to)))
    Cint(0)
end

function open_font(path::String)::Font
    reflibrary = Ref{FT_Library}()
    FT_Init_FreeType(reflibrary)
    refface = Ref{FT_Face}()
    FT_New_Face(reflibrary[], path, 0, refface)
    Font(path, reflibrary[], refface[])
end

function close_font(font::Font)
    FT_Done_FreeType(font.library)
end

function char_to_face(font::Font, ch::Char, char_size::Int)
    char_index = FT_Get_Char_Index(font.face, ch)
    pt = 64char_size # FT_F26Dot6
    dpi = 72         # GetDeviceCaps
    FT_Set_Char_Size(font.face, pt, pt, dpi, dpi) # face char_width char_height horz_resolution vert_resolution
    # FT_Set_Pixel_Sizes(font.face, char_size, char_size) # face pixel_width pixel_height
    FT_Load_Glyph(font.face, char_index, FT_LOAD_NO_BITMAP)
    unsafe_load(font.face) # face
end

function char_to_glyph(font::Font, ch::Char, char_size::Int)
    face = char_to_face(font, ch, char_size)
    unsafe_load(face.glyph) # glyph
end

function glyph_to_commands(glyph)
    move_f = @cfunction $move_to_func Cint (Ptr{FT_Vector}, Ptr{Cvoid})
    line_f = @cfunction $line_to_func Cint (Ptr{FT_Vector}, Ptr{Cvoid})
    conic_f = @cfunction $conic_to_func Cint (Ptr{FT_Vector}, Ptr{FT_Vector}, Ptr{Cvoid})
    cubic_f = @cfunction $cubic_to_func Cint (Ptr{FT_Vector}, Ptr{FT_Vector}, Ptr{FT_Vector}, Ptr{Cvoid})
    paths = []
    function user_func(path)
        push!(paths, path)
        nothing
    end
    user_f = @cfunction $user_func Cvoid (Any,)
    outline = Ref(glyph.outline)
    outline_funcs = FT_Outline_Funcs(Base.unsafe_convert.(Ptr{Cvoid}, (move_f, line_f, conic_f, cubic_f))..., Cint(0), C_NULL)
    FT_Outline_Decompose(pointer_from_objref.((outline, Ref(outline_funcs)))..., user_f)
    paths 
end

using FreeType: FT_Render_Glyph, FT_Raster_Params, FT_Span, FT_Bitmap, FT_SpanFunc, FT_Raster_BitTest_Func, FT_Raster_BitSet_Func, FT_BBox, FT_Outline_Get_CBox, FT_Outline_Get_BBox, FT_Outline_Get_Orientation, FT_Outline_Render
using FreeType: FT_RENDER_MODE_NORMAL, FT_GLYPH_FORMAT_BITMAP, FT_RASTER_FLAG_AA, FT_RASTER_FLAG_DIRECT, FT_OUTLINE_EVEN_ODD_FILL

# FT_ORIENTATION_TRUETYPE = 0,
# FT_ORIENTATION_POSTSCRIPT = 1,
# FT_ORIENTATION_FILL_RIGHT = 0,
# FT_ORIENTATION_FILL_LEFT = 1,
# FT_ORIENTATION_NONE = 2,

# FT_OUTLINE_CONTOURS_MAX = SHRT_MAX
# FT_OUTLINE_POINTS_MAX = SHRT_MAX
# FT_OUTLINE_NONE = 0x00
# FT_OUTLINE_OWNER = 0x01
# FT_OUTLINE_EVEN_ODD_FILL = 0x02
# FT_OUTLINE_REVERSE_FILL = 0x04
# FT_OUTLINE_IGNORE_DROPOUTS = 0x08
# FT_OUTLINE_SMART_DROPOUTS = 0x10
# FT_OUTLINE_INCLUDE_STUBS = 0x20
# FT_OUTLINE_HIGH_PRECISION = 0x0100
# FT_OUTLINE_SINGLE_PASS = 0x0200

mutable struct FT_Raster_Params2
    target::Ptr{FT_Bitmap}
    source::Ptr{Cvoid}
    flags::Cint
    gray_spans::FT_SpanFunc
    black_spans::FT_SpanFunc
    bit_test::FT_Raster_BitTest_Func
    bit_set::FT_Raster_BitSet_Func
    user::Ptr{Cvoid}
    clip_box::FT_BBox
end

function outline_render(font::Font, face)
    render_mode = FT_RENDER_MODE_NORMAL
    FT_Render_Glyph(face.glyph, render_mode)

#=
    outline = Ref(glyph.outline)
    function raster_callback(y, count, spans, user)
        println(stdout, :hello)
        nothing
    end
    cbox = Ref{FT_BBox}()
    FT_Outline_Get_CBox(outline, cbox)
    raster_f = @cfunction $raster_callback Cvoid (Cint, Cint, Ptr{FT_Span}, Ptr{Cvoid})
    raster_params = FT_Raster_Params2(C_NULL, C_NULL, Cint(FT_RASTER_FLAG_AA | FT_RASTER_FLAG_DIRECT), pointer_from_objref(Ref(raster_f)), C_NULL, C_NULL, C_NULL, C_NULL, cbox[])
#FT_BBox(Clong(0), Clong(0), Clong(0), Clong(0)))
    n = FT_Outline_Render(font.library, outline, pointer_from_objref(Ref(raster_params)))
=#
end

function get_glyph_info(glyph)
    outline = Ref(glyph.outline)
    bbox = Ref{FT_BBox}()
    FT_Outline_Get_BBox(outline, bbox)
    cbox = Ref{FT_BBox}()
    FT_Outline_Get_CBox(outline, cbox)
    orientation = FT_Outline_Get_Orientation(outline)
    (bbox=bbox[], cbox=cbox[], orientation=orientation, )
end

function char_to_commands(path::String, ch::Char, char_size::Int)
    font = open_font(path)
    glyph = char_to_glyph(font, ch, char_size)
    cmds = glyph_to_commands(glyph)
    close_font(font)
    cmds 
end

end # module Allographs.FontEngines.FreeType2
