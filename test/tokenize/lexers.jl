module test_tokenize_lexers

using Test
using Tokenize # tokenize

l = tokenize("C10")
n = first(l)
@test "C10" == n.val

end # module test_tokenize_lexers
