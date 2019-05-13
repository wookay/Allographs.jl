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

function char_to_glyph(font::Font, ch::Char, char_size::Int)
    char_index = FT_Get_Char_Index(font.face, ch)
    pt = 64char_size # FT_F26Dot6
    dpi = 72         # GetDeviceCaps
    FT_Set_Char_Size(font.face, pt, pt, dpi, dpi) # face char_width char_height horz_resolution vert_resolution
    # FT_Set_Pixel_Sizes(font.face, char_size, char_size) # face pixel_width pixel_height
    FT_Load_Glyph(font.face, char_index, FT_LOAD_NO_BITMAP)
    face = unsafe_load(font.face)
    unsafe_load(face.glyph)
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
    outline_funcs = FT_Outline_Funcs(Base.unsafe_convert.(Ptr{Cvoid}, (move_f, line_f, conic_f, cubic_f))..., Cint(0), C_NULL)
    FT_Outline_Decompose(pointer_from_objref.((Ref(glyph.outline), Ref(outline_funcs)))..., user_f)
    paths 
end

function char_to_commands(path::String, ch::Char, char_size::Int)
    font = open_font(path)
    glyph = char_to_glyph(font, ch, char_size)
    cmds = glyph_to_commands(glyph)
    close_font(font)
    cmds 
end

end # module Allographs.FontEngines.FreeType2
