# Simulating a 1D wave equation using PINNs

using NeuralPDE, Lux, Optimization, OptimizationOptimJL, LineSearches, Plots
using DomainSets: Interval
import DomainSets: infimum, supremum

# independent variables
@parameters x t

# unknown function
@variables u(..)

# differentials
Dxx = Differential(x)^2
Dtt = Differential(t)^2
Dt = Differential(t)

# 1D wave equation
eqs = [
    Dtt(u(x,t)) ~ Dxx(u(x,t))
]

@derivatives Dt'~t

# boundary conditions
bcs = [
    u(0.0,t) ~ 0.0,
    u(1.0,t) ~ 0.0,
    u(x,0.0) ~ x * (1.0 - x),
    Dt(u(x, 0.0)) ~ 0.0
]

# Space and time domains
domain = [x ∈ Interval(0.0, 1.0), t ∈ Interval(0.0, 1.0)]

# defining NN layers 
dim = 2                 # 2 dimensions: x and t
chain = Lux.Chain(
    Dense(dim, 16, tanh),
    Dense(16, 16, tanh),
    Dense(16, 1)
)

# PINN discretization
discretization = PhysicsInformedNN(chain, QuadratureTraining(; batch = 100))

# PDE system
@named pinn_sys = PDESystem(eqs, bcs, domain, [x, t], [u(x, t)])

# convert to optimization problem
prob = discretize(pinn_sys, discretization)

# Train
opt = OptimizationOptimJL.BFGS()
res = Optimization.solve(prob, opt; maxiters = 1000)

# prediction function
φ = discretization.phi

# create grid for evaluation
xs = 0:0.1:1
ts = 0:0.1:1

# Evaluate PINN and true solution
u_pred = [φ([x, t], res.u)[1] for x in xs, t in ts]
u_true = [sum([
    (8 / (n^3 * π^3)) * sin(n * π * x) * cos(n * π * t)
    for n in 1:2:19
]) for x in xs, t in ts]

# reshape for plotting
u_pred_mat = reshape(u_pred, length(xs), length(ts))
u_true_mat = reshape(u_true, length(xs), length(ts))
error_mat = abs.(u_pred_mat .- u_true_mat)

# plots
p1 = heatmap(xs, ts, u_true_mat', xlabel="x", ylabel="t", title="True Solution")
p2 = heatmap(xs, ts, u_pred_mat', xlabel="x", ylabel="t", title="PINN Solution")
p3 = heatmap(xs, ts, error_mat', xlabel="x", ylabel="t", title="Absolute Error")

# display and save 
plot(p1, p2, p3, layout=(1, 3), size=(1200, 400))
savefig("wave_eq_pinn_results.png")
