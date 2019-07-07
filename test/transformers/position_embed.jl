function PE(size, pos, i::Int)
    if rem(i, 2) == 0
        sin(pos/1e4^(i/size))
    else
        cos(pos/1e4^((i-1)/size))
    end
end

@info :pe PE(1, 1, 1)
@info :pe PE(1, 1, 2)
