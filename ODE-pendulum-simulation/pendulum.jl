using DifferentialEquations

#Defining the ODEs 
function pendulum!(dv, v, p, t)
    # Constants
    g = 9.81
    l = 1.0
    m = 1.0
    # M(t) is not specified in the problem. We can set it to:
    # M(t) = 0 ; Zero torque
    # M(t) = 1 ; constant
    # M(t) = sin(t) ; Realistic for a pendulum
    M = sin(t) #External periodic torque

    #Defining the ODEs 
    dv[1] = v[2]
    dv[2] = -(((3*g)/(2*l))*sin(v[1])) + (3/(m * (l^2))) * M
end

# initial conditions
v0 = [0.01, 0.0]
tspan = [0.0, 10.0]

# solving the ODEs
prob = ODEProblem(pendulum!, v0, tspan)
sol = solve(prob)

#Plotting
using Plots

# Plot both θ(t) and ω(t) 
p = plot(sol, 
    idxs=1, 
    label="θ(t): Angular Position", 
    xlabel="Time (s)", 
    ylabel="Value", 
    title="Pendulum Dynamics with External Torque",
    linewidth=2,
    legend=:topright,
    grid=true)

plot!(sol, 
    idxs=2, 
    label="ω(t): Angular Velocity", 
    linewidth=2)
