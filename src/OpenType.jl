module OpenType

export Vec

using FreeType
using StaticArrays # SVector
using Tokenize # tokenize

const Vec = SVector{2}

function stroke_to_commands(stroke::String)
    T = Tokenize.Tokens
    L = Tokenize.Lexers
    l = tokenize(stroke)
    commands = []
    function next_val(l)
        parse(Int, L.next_token(l).val)
    end
    for (i, n) in enumerate(l)
        if T.kind(n) == T.IDENTIFIER
            typ = first(n.val)
            if typ == 'Z'
                push!(commands, (type=typ,))
            else
                L.next_token(l)
                x1 = next_val(l)
                L.next_token(l)
                y1 = next_val(l)
                if typ == 'Q'
                    L.next_token(l)
                    x2 = next_val(l)
                    L.next_token(l)
                    y2 = next_val(l)
                    push!(commands, (type=typ, x1=x1, y1=y1, x2=x2, y2=y2))
                elseif typ == 'C'
                    L.next_token(l)
                    x2 = next_val(l)
                    L.next_token(l)
                    y2 = next_val(l)
                elseif typ in ('M', 'L')
                    push!(commands, (type=typ, x1=x1, y1=y1))
                end
            end
        end 
    end
    commands
end

end # module Allographs.OpenType
