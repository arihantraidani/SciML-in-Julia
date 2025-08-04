# Solving a 1D heat equation

using ModelingToolkit, MethodOfLines, OrdinaryDiffEq, DomainSets, Plots

@parameters t x 
@variables u(..)

Dt = Differential(t)
Dxx = Differential(x)^2

eqs = [Dt(u(t, x)) ~ Dxx(u(t, x))]

initial_conditions = [u(0, x) ~ Symbolics.sin(Symbolics.pi * x)]
boundary_conditions = [u(t, 0) ~ Num(0.0), u(t, 1) ~ Num(0.0)]

domain = [t ∈ Interval(0.0, 1.0), x ∈ Interval(0.0, 1.0)]

@named wavesys = PDESystem(eqs, vcat(initial_conditions, boundary_conditions), domain, [t,x], [u(t,x)])

dis = MOLFiniteDifference([x => 100], t)

prob = discretize(wavesys, dis)

sol = solve(prob, Tsit5(), saveat = 0.01 )

#plot
x_vals = sol[x]
final_u = sol[u(t, x)][end, :]
p = plot(x_vals, final_u, xlabel="x", ylabel="u(t,x)", title="Solution at t = 1")

savefig(p, "heat_wave.png")