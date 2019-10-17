module test_transformers_position_embed

using Test

function PE(size, pos, i::Int)
    if rem(i, 2) == 0
        sin(pos/1e4^(i/size))
    else
        cos(pos/1e4^((i-1)/size))
    end
end

@test PE(1, 1, 1) ≈ 0.5403023058681398
@test PE(1, 1, 2) == 1.0e-8

end # module test_transformers_position_embed
