module OpenType # Allographs.FontEngines

function feed!(l, commands)
    if isempty(l)
        commands
    else
        function next_val(l; valtype=Float64)
            val = popfirst!(l)
            parse(valtype, val)
        end
        typ = uppercase(first(popfirst!(l)))
        if typ == 'Z'
            push!(commands, (type=typ,))
        else
            x1 = next_val(l)
            y1 = next_val(l)
            if typ == 'Q' # quadratic bézier
                x = next_val(l)
                y = next_val(l)
                push!(commands, (type=typ, control=(x1, y1), endPoint=(x, y)))
            elseif typ == 'C' # curve to
                x2 = next_val(l)
                y2 = next_val(l)
                x = next_val(l)
                y = next_val(l)
                push!(commands, (type=typ, control1=(x1, y1), control2=(x2, y2), endPoint=(x, y)))
            elseif typ == 'A' # elliptical arc
                φ  = next_val(l)
                arcflag = next_val(l, valtype=Int)
                sweepflag = next_val(l, valtype=Int)
                x2 = next_val(l)
                y2 = next_val(l)
                push!(commands, (type=typ, control=(x1, y1), φ=φ, arcflag=arcflag, sweepflag=sweepflag, endPoint=(x2, y2)))
           elseif typ in ('M', 'L') # move to, line to
                push!(commands, (type=typ, point=(x1, y1)))
            end
        end
        feed!(l, commands)
    end
end

function stroke_to_commands(stroke::String)::Vector
    l = split(stroke, ' ')
    feed!(l, [])
end

end # module Allographs.FontEngines.OpenType
