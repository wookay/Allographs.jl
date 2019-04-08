module OpenType

export Vec

using FreeType
using StaticArrays # SVector
using Tokenize # tokenize

const Vec = SVector{2}

function stroke_to_commands(stroke::String)::Vector
    T = Tokenize.Tokens
    L = Tokenize.Lexers
    function next_val(l; valtype=Float64)
        parse(valtype, L.next_token(l).val)
    end
    commands = []
    l = tokenize(stroke)
    for (i, n) in enumerate(l)
        if T.kind(n) == T.IDENTIFIER
            typ = uppercase(first(n.val))
            if typ == 'Z'
                push!(commands, (type=typ,))
            else
                L.next_token(l)
                x1 = next_val(l)
                L.next_token(l)
                y1 = next_val(l)
                if typ in ('Q', 'C') # quadratic bézier, curve to
                    L.next_token(l)
                    x2 = next_val(l)
                    L.next_token(l)
                    y2 = next_val(l)
                    push!(commands, (type=typ, x1=x1, y1=y1, x2=x2, y2=y2))
                elseif typ == 'A' # elliptical arc
                    L.next_token(l)
                    φ  = next_val(l)
                    L.next_token(l)
                    arcflag = next_val(l, valtype=Int)
                    L.next_token(l)
                    sweepflag = next_val(l, valtype=Int)
                    L.next_token(l)
                    x2 = next_val(l)
                    L.next_token(l)
                    y2 = next_val(l)
                    push!(commands, (type=typ, x1=x1, y1=y1, φ=φ, arcflag=arcflag, sweepflag=sweepflag, x2=x2, y2=y2))
                elseif typ in ('M', 'L')
                    push!(commands, (type=typ, x1=x1, y1=y1))
                end
            end
        end 
    end
    commands
end

end # module Allographs.OpenType
