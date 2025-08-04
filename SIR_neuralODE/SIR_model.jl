## SciML Bootcamp Assignment — Neural ODE: SIR Model
## Author: Arihant Raidani

using DifferentialEquations, Lux, DiffEqFlux, Optimization, OptimizationOptimisers,
      ComponentArrays, Plots, Random
using OptimizationOptimisers: Adam

# Set seed for reproducibility
rng = Random.default_rng()

# Parameters of the SIR model
N = 1000.0f0              # Total population
β = 0.3f0                 # Infection rate
γ = 0.1f0                 # Recovery rate

# Initial conditions: S₀ = 999, I₀ = 1, R₀ = 0
I₀, R₀ = 1.0f0, 0.0f0
S₀ = N - I₀ - R₀
u0 = Float32[S₀, I₀, R₀]

# Time span and sampling
tspan = (0.0f0, 160.0f0)
tsteps = range(tspan[1], tspan[2], length=161)

# True SIR ODE function
function sir!(du, u, p, t)
    S, I, R = u
    du[1] = -β * S * I / N
    du[2] = β * S * I / N - γ * I
    du[3] = γ * I
end

# Solve the true SIR system
prob_sir = ODEProblem(sir!, u0, tspan)
sol_sir = solve(prob_sir, Tsit5(); saveat=tsteps)
data = Array(sol_sir)  # Ground truth data

# Plot the true SIR model
plot(tsteps, data', label=["Susceptible" "Infected" "Recovered"], title="True SIR Model", lw=2)

# Define the Neural ODE
nn_dudt = Lux.Chain(
    x -> x ./ N,                     # Normalize input to ~[0,1]
    Lux.Dense(3, 32, tanh),
    Lux.Dense(32, 32, tanh),
    Lux.Dense(32, 3)                 # Output dS/dt, dI/dt, dR/dt
)

# Initialize network parameters
p, st = Lux.setup(rng, nn_dudt)

# Create NeuralODE object
n_ode = NeuralODE(nn_dudt, tspan, Tsit5(); saveat=tsteps)

# Prediction & Loss Functions
function predict(p)
    Array(n_ode(u0, p, st)[1])
end

function loss_neuralode(p)
    pred = predict(p)
    loss = sum(abs2, (data .- pred) ./ N)  # Normalized MSE
    return loss, pred
end

function loss_only(p)
    l, _ = loss_neuralode(p)
    return l
end

# Training Setup
p_init = ComponentArray(p)

# loss history
global_epoch = Ref(0)
loss_history = Float64[]

# Callback to store animation frames
frames = Any[]
function viz_callback(p, l, pred; doplot=true)
    global_epoch[] += 1
    push!(loss_history, l)
    println("Epoch $(global_epoch[]): Loss = ", round(l, digits=4))

    if doplot
        # Top subplot: predictions
        plt1 = plot(title="NeuralODE Training — Epoch $(global_epoch[])",
                    xlabel="Time (days)", ylabel="Population",
                    legend=:outertopright, lw=2)

        plot!(plt1, tsteps, data[1, :], label="S_true", color=:blue)
        plot!(plt1, tsteps, data[2, :], label="I_true", color=:red)
        plot!(plt1, tsteps, data[3, :], label="R_true", color=:green)

        plot!(plt1, tsteps, pred[1, :], label="S_pred", color=:blue, linestyle=:dot)
        plot!(plt1, tsteps, pred[2, :], label="I_pred", color=:red, linestyle=:dot)
        plot!(plt1, tsteps, pred[3, :], label="R_pred", color=:green, linestyle=:dot)

        annotate!(plt1, (5, N * 0.95, text("Loss = $(round(l, digits=2))", :black, 10)))

        # Bottom subplot: loss vs epoch
        epochs = 1:global_epoch[]
        plt2 = plot(epochs, loss_history, label="Loss", xlabel="Epoch", ylabel="Loss",
                    title="Loss over Time", lw=2, legend=:topright)

        # Combine both plots
        final_plot = plot(plt1, plt2; layout=(2, 1), size=(700, 700))
        push!(frames, final_plot)
    end
    return false
end

# Wrap callback to match Optimization.jl expectations
wrapped_callback = function (state, l)
    p = state.u
    _, pred = loss_neuralode(p)
    return viz_callback(p, l, pred; doplot=true)
end

# Run initial callback (before training)
viz_callback(p_init, loss_neuralode(p_init)...; doplot=true)

# Optimization loop
adtype = Optimization.AutoZygote()
optf = OptimizationFunction((x, p) -> loss_only(x), adtype)
optprob = OptimizationProblem(optf, p_init)

# Phase 1: Train with Adam optimizer
result_adam = Optimization.solve(optprob, Adam(0.01); callback=wrapped_callback, maxiters=500)

# Phase 2: Refine with BFGS optimizer
optprob2 = remake(optprob; u0 = result_adam.u)
result_bfgs = Optimization.solve(optprob2, Optim.BFGS(); callback=wrapped_callback)

# Final Prediction & Plot
final_pred = predict(result_bfgs.u)

plot(tsteps, data', label=["S_true" "I_true" "R_true"], title="Final Comparison", lw=2)
plot!(tsteps, final_pred', ls=:dash, label=["S_pred" "I_pred" "R_pred"])

# Save training animation as GIF
anim = Plots.Animation()
for plt in frames
    frame(anim, plt)
end
gif(anim, "sir_neuralode_model.gif", fps=10)

# Save final static plot for PDF report
using Printf

# Final predicted result
final_pred = predict(result_bfgs.u)
final_loss, _ = loss_neuralode(result_bfgs.u)

# Plot 1: SIR true vs predicted
plt1 = plot(title="Final NeuralODE Fit",
            xlabel="Time (days)", ylabel="Population",
            legend=:outertopright, lw=2)

plot!(plt1, tsteps, data[1, :], label="S_true", color=:blue)
plot!(plt1, tsteps, data[2, :], label="I_true", color=:red)
plot!(plt1, tsteps, data[3, :], label="R_true", color=:green)

plot!(plt1, tsteps, final_pred[1, :], label="S_pred", color=:blue, linestyle=:dot)
plot!(plt1, tsteps, final_pred[2, :], label="I_pred", color=:red, linestyle=:dot)
plot!(plt1, tsteps, final_pred[3, :], label="R_pred", color=:green, linestyle=:dot)

annotate!(plt1, (5, N * 0.95, text("Final Loss = $(Printf.@sprintf("%.4f", final_loss))", :black, 10)))

# Plot 2: loss curve
epochs = 1:length(loss_history)
plt2 = plot(epochs, loss_history, label="Loss", xlabel="Epoch", ylabel="Loss",
            title="Loss Over Epochs", lw=2, legend=:topright)

# Combine both
summary_plot = plot(plt1, plt2; layout=(2, 1), size=(800, 800))
#savefig(summary_plot, "sir_neuralode_static_summary.pdf")
savefig(summary_plot, "sir_neuralode_static_summary.png")  # for Overleaf

