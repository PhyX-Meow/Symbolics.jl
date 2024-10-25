using Symbolics
using Symbolics: symbolic_to_float, var_from_nested_derivative

@testset "get_variables" begin
    @variables t x y z(t)

    ex1 = x + y + sin(z)
    vars1 = Symbolics.get_variables(ex1)
    @test length(vars1) == 3
    @test allunique(vars1)

    sorted_vars1 = Symbolics.get_variables(ex1; sort = true)
    @test isequal(sorted_vars1, [x, y, z])

    ex2 = x - y
    vars2 = Symbolics.get_variables(ex2)
    @test length(vars2) == 2
    @test allunique(vars2)

    sorted_vars2 = Symbolics.get_variables(ex2; sort = true)
    @test isequal(sorted_vars2, [x, y])
end

@testset "symbolic_to_float" begin
    @variables x
    @test symbolic_to_float((1//2 * x)/x) isa Rational{Int}
    @test symbolic_to_float((1/2 * x)/x) isa Float64
    @test symbolic_to_float((1//2)*√(279//4)) isa Float64
    @test symbolic_to_float((big(1)//2)*√(279//4)) isa BigFloat
    @test symbolic_to_float((-1//2)*√(279//4)) isa Float64
end

@testset "var_from_nested_derivative" begin
    @variables t x(t) p(..)
    D = Differential(t)
    @test var_from_nested_derivative(x) == (x, 0)
    @test var_from_nested_derivative(D(x)) == (x, 1)
    @test var_from_nested_derivative(p) == (p, 0)
    @test var_from_nested_derivative(D(p(x))) == (p(x), 1)
end

@testset "fixpoint_sub maxiters" begin
    @variables x y
    expr = Symbolics.fixpoint_sub(x, Dict(x => y, y => x))
    @test isequal(expr, x)
    expr = Symbolics.fixpoint_sub(x, Dict(x => y, y => x); maxiters = 9)
    @test isequal(expr, y)
end
