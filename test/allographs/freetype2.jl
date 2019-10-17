using Jive
@useinside module test_allographs_freetype2

using Test
using Allographs.FontEngines.FreeType2
using FreeType: FT_Outline_Get_Orientation

ch = '헐'
char_size = 16
path = normpath(@__DIR__, "../../examples/freetype2/", "IropkeBatangM.ttf")
font = FreeType2.open_font(path)
glyph = FreeType2.char_to_glyph(font, ch, char_size)

outline = pointer_from_objref(Ref(glyph.outline))
orientation = FT_Outline_Get_Orientation(outline)
@test orientation == 0

FreeType2.close_font(font)

end # module test_allographs_freetype2
