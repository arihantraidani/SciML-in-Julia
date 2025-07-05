# SIR model function
function sir!(ds, s, p, t)
    #Constants
    N = 1000 #population
    b = 0.3 #transmission rate
    g = 0.1 #recovery rate

    #ODEs 
    #NOtation: S(t) = s[1] ; I(t) = s[2] ; R(t) = s[3]
    ds[1] = - (b * s[1] * s[2])/ N
    ds[2] = ((b * s[1] * s[2])/ N) - (g * s[2])
    ds[3] = g * s[2]
end

using DifferentialEquations

# initial conditions
s0 = [999.0, 1.0, 0.0]
tspan = [0.0, 160.0]

#solve
prob = ODEProblem(sir!, s0, tspan)
sol = solve(prob)


# Creating the plot

using Plots

# Extract time and solution vectors
t = sol.t
S = sol[1, :]
I = sol[2, :]
R = sol[3, :]

# Plot them
p = plot(
    t, S, 
    label="Susceptible (S)", 
    xlabel="Time (days)", 
    ylabel="Number of People", 
    title="SIR Model Dynamics",
    linewidth=2
)

plot!(t, I, label="Infected (I)", linewidth=2)
plot!(t, R, label="Recovered (R)", linewidth=2)



#subplot 

p1 = plot(sol, idxs=1, label="S(t)", title="Susceptible", legend=:topright, xlabel="Time (days)", ylabel="People", linewidth=2)
p2 = plot(sol, idxs=2, label="I(t)", title="Infected", legend=:topright, xlabel="Time (days)", ylabel="People", linewidth=2)
p3 = plot(sol, idxs=3, label="R(t)", title="Recovered", legend=:topright, xlabel="Time (days)", ylabel="People", linewidth=2)

final_plot = plot(p1, p2, p3, layout=(3, 1), size=(800, 900), titlefontsize=12, guidefontsize=10)
