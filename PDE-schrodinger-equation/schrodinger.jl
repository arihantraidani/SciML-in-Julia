using MethodOfLines, OrdinaryDiffEq, Plots, DomainSets, ModelingToolkit

# define the time and space variables
@parameters t x

# define two unknown functions: u for real part of psi, v for imaginary part
@variables u(..) v(..)

# define differential operators
Dt = Differential(t)
Dxx = Differential(x)^2

# define the PDE system
# ∂u/∂t = - ∂²v/∂x²
# ∂v/∂t =   ∂²u/∂x²
eqs = [
    Dt(u(t,x)) ~ -Dxx(v(t,x)),
    Dt(v(t,x)) ~  Dxx(u(t,x))
]

# define initial condition for u: sin(2πx), v starts at 0
initial_u = x -> sin(2π * x)
initial_v = x -> 0.0

# set initial and boundary conditions
bcs = [
    u(0,x) ~ initial_u(x),        # initial condition for u
    v(0,x) ~ initial_v(x),        # initial condition for v
    u(t,0) ~ 0.0,                 # boundary condition for u at x = 0
    u(t,1) ~ 0.0,                 # boundary condition for u at x = 1
    v(t,0) ~ 0.0,                 # boundary condition for v at x = 0
    v(t,1) ~ 0.0                  # boundary condition for v at x = 1
]

# define time and space domains
domains = [t ∈ Interval(0.0, 1.0), x ∈ Interval(0.0, 1.0)]

# create the PDE system
@named sys = PDESystem(eqs, bcs, domains, [t, x], [u(t,x), v(t,x)])

# discretize only the x direction using 100 points
disc = MOLFiniteDifference([x => 100], t)

# convert the PDE to an ODE system
prob = discretize(sys, disc)

# solve the system using TRBDF2 method
sol = solve(prob, TRBDF2(), saveat = 0.01)

# extract space and time values for plotting
x_vals = sol[x]
t_vals = sol[t]
u_vals = sol[u(t,x)]
v_vals = sol[v(t,x)]

# animate real and imaginary parts of psi over time
anim = @animate for i in 1:length(t_vals)
    re = u_vals[i, :]        # real part
    im = v_vals[i, :]        # imaginary part
    plot(x_vals, [re im],
        ylim = (-1.5, 1.5),
        title = "t = $(round(t_vals[i], digits=2))",
        xlabel = "x", ylabel = "ψ(t,x)",
        label = ["Re(ψ)" "Im(ψ)"],
        legend = :topright
    )
end

# save the animation as a gif
gif(anim, "schrodinger_real_split.gif", fps = 15)

