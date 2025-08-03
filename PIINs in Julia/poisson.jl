# Solving a Poisson equation using PIINs

using NeuralPDE, Lux, Optimization, OptimizationOptimJL, LineSearches, Plots
using DomainSets: Interval
import DomainSets: infimum, supremum


#defining independent variables
@parameters x y 

#defining unknown function
@variables u(..)

#defining differential operators
Dxx = Differential(x)^2
Dyy = Differential(y)^2

# Poisson Equation - 2D PDE
eqs = [
    Dxx(u(x,y)) + Dyy(u(x,y)) ~ -sin(pi * x) * sin(pi * y)
]

#boundary conditions
bcs = [
    u(0,y) ~ 0, u(1,y) ~ 0,
    u(x,0) ~ 0, u(x,1) ~ 0
]

# definig the space domains
domain = [x ∈ Interval(0.0, 1.0), y ∈ Interval(0.0, 1.0)]

#Neural Network
dim = 2     #number of dimensions
chain = Lux.Chain(
    Dense(dim, 16, tanh),
    Dense(16, 16, tanh),
    Dense(16, 1)
)

# Discretization
discretization = PhysicsInformedNN(
    chain, QuadratureTraining(; batch = 200, abstol = 1e-6, reltol = 1e-6))

# Creating the PDE system
@named pde_system = PDESystem(eqs, bcs, domain, [x, y], [u(x, y)])
prob = discretize(pde_system, discretization)

#Callback function
callback = function (p, l)
    println("Current loss is: $l")
    return false
end

# Optimizer
opt = LBFGS(linesearch = BackTracking())
res = solve(prob, opt, maxiters = 1000)
phi = discretization.phi

dx = 0.05
xs, ys = [infimum(d.domain):(dx / 10):supremum(d.domain) for d in domains]
analytic_sol_func(x, y) = (sin(pi * x) * sin(pi * y)) / (2pi^2)

u_predict = reshape([first(phi([x, y], res.u)) for x in xs for y in ys],
    (length(xs), length(ys)))
u_real = reshape([analytic_sol_func(x, y) for x in xs for y in ys],
    (length(xs), length(ys)))
diff_u = abs.(u_predict .- u_real)


#plotting
p1 = plot(xs, ys, u_real, st=:contourf, title="Analytic")
p2 = plot(xs, ys, u_predict, st=:contourf, title="Predicted")
p3 = plot(xs, ys, diff_u, st=:contourf, title="Error")

final_plot = plot(p1, p2, p3, layout = (1, 3), size=(1200, 400))  # Optional layout and size
savefig(final_plot, "poisson_pinn_results.png")

