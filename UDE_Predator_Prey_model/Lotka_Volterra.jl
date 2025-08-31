#########################################################################
# SciML Bootcamp Assignment 6: Universal Differential Equations (UDE) for 
# Modeling Predator-Prey Dynamics (Lotka-Volterra equations).
# 
# This script generates synthetic predator-prey data from the Lotka-Volterra model,
# then sets up a Universal Differential Equation where the predator-prey interaction
# terms (βxy and γxy) are replaced by neural networks, and trains the neural networks 
# to fit the data:contentReference[oaicite:0]{index=0}. The code uses Julia's SciML ecosystem (DifferentialEquations.jl, 
# Lux.jl for neural networks, and Zygote for automatic differentiation):contentReference[oaicite:1]{index=1}.
# All code is heavily commented for clarity.
#########################################################################

# ---- 1. Package Imports ----
using DifferentialEquations        # For solving ODEs:contentReference[oaicite:2]{index=2}
using SciMLSensitivity             # For ODE adjoint sensitivity (gradients)
using Lux                          # For defining neural networks (Lux is SciML-preferred):contentReference[oaicite:3]{index=3}
using ComponentArrays              # To handle network parameters as a flat vector
using Optimization, OptimizationOptimisers  # For optimization (ADAM optimizer)
using Zygote                       # Automatic differentiation (reverse-mode AD):contentReference[oaicite:4]{index=4}
using Plots                        # For plotting results:contentReference[oaicite:5]{index=5}
using StableRNGs                   # For reproducible random numbers (if needed)
using StaticArrays                 # For efficient fixed-size arrays (used in neural networks)
using Statistics                # For statistical functions (e.g., mean, std)
gr()  # Use GR backend for Plots (common choice)

# ---- 2. Generate Synthetic Data from Lotka-Volterra Model ----

# Define the classical Lotka-Volterra ODE (prey-predator model):contentReference[oaicite:6]{index=6}.
# dx/dt = α*x - β*x*y
# dy/dt = γ*x*y - δ*y
function lotka_volterra!(du, u, p, t)
    # Unpack state and parameters for clarity
    x, y       = u        # x = prey population, y = predator population
    α, β, γ, δ = p        # p is a tuple or vector of parameters
    du[1] = α * x - β * x * y   # Prey growth minus predation term
    du[2] = γ * x * y - δ * y   # Predator growth from eating prey minus natural death
end

# Set "true" parameter values for data generation (from assignment):contentReference[oaicite:7]{index=7}:
α = 0.4
β = 0.01
γ = 0.2
δ = 0.02
true_params = (α, β, γ, δ)  # pack as a tuple

# Choose initial populations (prey, predator). The assignment didn't specify, but 
# we'll use a commonly used example initial condition (e.g., 40 prey, 9 predators) 
# which is around the equilibrium for these parameters:contentReference[oaicite:8]{index=8}.
u0 = [40.0, 9.0]  # initial prey and predator counts (can adjust as needed)

# Set the simulation time span (0 to 8 time units as per assignment):contentReference[oaicite:9]{index=9}.
tspan = (0.0, 8.0)

# Solve the Lotka-Volterra ODE to generate synthetic data.
prob = ODEProblem(lotka_volterra!, u0, tspan, true_params)
sol = solve(prob, Tsit5(); saveat=0.1)   # using Tsit5 solver, saving data at 0.1 increments

# Extract time points and solution values for prey (x) and predator (y).
t_train = sol.t                      # time points (0, 0.1, 0.2, ..., 8.0)
X_train = Array(sol)                 # solution values as a 2 x N matrix (rows: species; cols: time points)

# We now have `X_train` as our synthetic dataset for training:
# X_train[1, :] = prey population over time
# X_train[2, :] = predator population over time

# ---- 3. Define the Universal Differential Equation (UDE) ----

# We will replace the interaction terms -β*x*y and +γ*x*y with neural networks:contentReference[oaicite:10]{index=10}.
# That is:
#    dx/dt = α*x + NN_θ1(x, y)   (instead of α*x - β*x*y)
#    dy/dt = -δ*y + NN_θ2(x, y)  (instead of -δ*y + γ*x*y)
# Here NN_θ1 and NN_θ2 are neural networks with trainable parameters θ1, θ2:contentReference[oaicite:11]{index=11}.

# Define the neural networks using Lux.jl.
# We'll create two small feedforward neural networks (2 inputs -> 1 output each),
# each with 2 hidden layers and ReLU activations:contentReference[oaicite:12]{index=12}.
# (Alternatively, one network with 2 outputs could be used, but we use two for clarity.)

# Network 1: approximates the prey interaction term (replaces -β*x*y).
# Network 2: approximates the predator interaction term (replaces +γ*x*y).
rng = StableRNG(42)  # reproducible random number generator

# Define a small helper to create a 2-hidden-layer network
# with ReLU activations and a single output.
function make_net()
    return Lux.Chain(
        Lux.Dense(2, 16, relu),   # 2 inputs -> 16 hidden, ReLU activation
        Lux.Dense(16, 16, relu),  # 16 -> 16 hidden, ReLU activation
        Lux.Dense(16, 1)          # 16 -> 1 output (linear activation by default)
    )
end

# Initialize both neural networks and get their initial parameters.
NN1 = make_net()
NN2 = make_net()
p1, st1 = Lux.setup(rng, NN1)   # p1: initial parameters for NN1, st1: state (not used, no stateful layers)
p2, st2 = Lux.setup(rng, NN2)   # p2: initial parameters for NN2, st2: state (unused)
# Convert parameters to Float64 (Lux uses Float32 by default, but we want Float64 for consistency).
# This is important for numerical stability in training.
p1 = Lux.fmap(x -> convert.(Float64, x), p1)
p2 = Lux.fmap(x -> convert.(Float64, x), p2)


# We'll keep the neural network state constant (since no batchnorm/dropout, state is not used).
const net_state1 = st1
const net_state2 = st2

# Known fixed parameters for the ODE (we assume α and δ are known):contentReference[oaicite:13]{index=13}.
p_known = (α = α, δ = δ)  # using the true α and δ from our data-generation params

# Define the UDE ODE function (with neural network terms) in-place form for performance.
function ude_dynamics!(du, u, θ, t)
    # u: state vector [x, y]
    # θ: combined trainable parameters (contains NN1 and NN2 weights)
    # We access known parameters α and δ from closure (p_known).
    x, y = u              # current state
    # Evaluate neural networks on current state:
    # Each Lux model returns a tuple: (output, updated_state), so we take [1] to get output vector.
    xy = Float64[x, y]     
    # NN1 output (should approximate -β*x*y)
    nn_out1, _ = NN1(xy, θ.theta1, net_state1)  # network output is a 1-element vector
    # NN2 output (should approximate +γ*x*y)
    nn_out2, _ = NN2(xy, θ.theta2, net_state2)
    # Combine known physics and neural network outputs:
    du[1] = p_known.α * x + nn_out1[1]         # dx/dt = α*x + NN1(x, y):contentReference[oaicite:14]{index=14}
    du[2] = - p_known.δ * y + nn_out2[1]       # dy/dt = -δ*y + NN2(x, y):contentReference[oaicite:15]{index=15}
end

# We need to package the two networks' parameters into a single parameter structure 
# for the ODEProblem. We can use a ComponentVector (from ComponentArrays.jl) 
# to combine them, preserving their separate parts.
θ0 = ComponentVector(theta1 = p1, theta2 = p2)  # initial combined parameters

# Create the ODE problem for the UDE with neural networks.
prob_ude = ODEProblem(ude_dynamics!, u0, tspan, θ0)  # initial state and tspan same as before

# Note: In `ude_dynamics!`, we captured `p_known` (α and δ) in a closure, so α and δ 
# remain fixed at their known values during training. Only θ (NN weights) will change.

# ---- 4. Training Setup ----

# Define a prediction function that, given a set of NN parameters θ, 
# simulates the UDE and returns the state trajectories at the training time points:contentReference[oaicite:16]{index=16}.
function predict(θ)
    # Remake the ODE problem with new parameters θ (keeping initial condition and tspan same):contentReference[oaicite:17]{index=17}.
    _prob = remake(prob_ude, p = θ)
    # Solve the ODE with current parameters. We use a stable ODE solver and the same time grid as data.
    sol = solve(_prob, Tsit5(); saveat=t_train, abstol=1e-6, reltol=1e-6,
            sensealg=InterpolatingAdjoint(autojacvec=ZygoteVJP()))
  # using Zygote for backprop:contentReference[oaicite:18]{index=18}
    return Array(sol)  # return solution as 2 x N array (same shape as X_train)
end

# Define the loss function as the mean squared error (MSE) between predicted trajectories and true data:contentReference[oaicite:19]{index=19}.
function loss(θ)
    X_pred = predict(θ)
    # Compute mean squared error over all time points and both species.
    return mean(abs2, X_train .- X_pred)
end

# (The loss is differentiable w.r.t. θ because we used a differentiable solver and Zygote for gradients.)

# Set up an optimization problem for ADAM. We'll use Optimization.jl to handle the training loop.
# Use Zygote AD (reverse-mode) for computing gradients in the optimization:contentReference[oaicite:20]{index=20}.
optf = OptimizationFunction((θ, _)-> loss(θ), Optimization.AutoZygote())
optprob = OptimizationProblem(optf, θ0)

# Choose the ADAM optimizer with a given learning rate. 
# The assignment results explored learning rates 0.001 and 0.01:contentReference[oaicite:21]{index=21}; we'll use 0.001 here.
optimizer = Optimisers.Adam(0.001)  # from OptimizationOptimisers.jl (alias Optimisers)

# Set up a callback to record the training loss at each iteration (and optionally print progress):contentReference[oaicite:22]{index=22}.
loss_history = Float64[]
callback = function (p, l)
    # p: current parameters, l: current loss
    push!(loss_history, l)
    if length(loss_history) % 100 == 0
        @info "Iteration $(length(loss_history)) - Training loss: $l"
    end
    return false  # do not interrupt optimization
end

# ---- 5. Train the UDE (fit neural networks to data) ----

# Run the optimization for a certain number of iterations (epochs).
max_epochs = 5000  # e.g., 5000 iterations (adjustable; assignment used 10000):contentReference[oaicite:23]{index=23}
res = solve(optprob, optimizer; callback=callback, maxiters=max_epochs)

# After optimization, `res.minimizer` contains the optimized parameter vector (neural net weights).
θ_opt = res.minimizer  # optimal parameters (ComponentVector with theta1, theta2)

@info "Training completed. Final loss: $(loss_history[end])"

# ---- 6. Save trained model and results ----

# Save the trained neural network parameters to disk (using BSON for safe serialization).
using BSON
BSON.@save "trained_model.bson" θ_opt

# Also save the loss history and any other relevant data if needed.
BSON.@save "training_history.bson" loss_history t_train X_train

# ---- 7. Data Visualization ----

# (a) Plot the learned interaction terms vs true interaction terms over time.
# Compute true interaction terms from the synthetic data and predicted from the learned NN.
x_data = X_train[1, :];  y_data = X_train[2, :]  # prey and predator from true data
true_term1 = -β .* x_data .* y_data   # true -β*x*y over time (prey eq interaction term):contentReference[oaicite:24]{index=24}
true_term2 =  γ .* x_data .* y_data   # true +γ*x*y over time (predator eq interaction term)

# Evaluate neural nets (with trained weights) on each data point (x,y).
# We use the Lux models NN1, NN2 with θ_opt (the trained parameters) to get predictions.
pred_term1 = [NN1(Float64[x_data[i], y_data[i]], θ_opt.theta1, net_state1)[1][1] 
              for i in eachindex(x_data)]
pred_term2 = [NN2(Float64[x_data[i], y_data[i]], θ_opt.theta2, net_state2)[1][1] 
              for i in eachindex(x_data)]
# Note: Each NN output is a 1-element vector, so we take the first element [1] to get the scalar value.

# Plot interaction terms:
p1 = plot(t_train, true_term1, label="True -β*x*y term", lw=2)
plot!(p1, t_train, pred_term1, label="Learned NN₁ term", ls=:dash, lw=2)
xlabel!(p1, "Time")
ylabel!(p1, "Prey interaction term")
title!(p1, "Prey Interaction: True vs Learned")

p2 = plot(t_train, true_term2, label="True γ*x*y term", lw=2)
plot!(p2, t_train, pred_term2, label="Learned NN₂ term", ls=:dash, lw=2)
xlabel!(p2, "Time")
ylabel!(p2, "Predator interaction term")
title!(p2, "Predator Interaction: True vs Learned")

plot_interactions = plot(p1, p2, layout=(1,2), size=(800,300))
savefig(plot_interactions, "interaction_terms.png")  # save the figure to disk:contentReference[oaicite:25]{index=25}

# (b) Plot trajectory comparisons between true model and learned UDE.
# We already have true trajectories (X_train). Let's simulate the UDE with learned parameters to get its trajectories.
sol_ude = solve(remake(prob_ude, p=θ_opt), Tsit5(); saveat=t_train)
X_ude = Array(sol_ude)  # 2 x N array of UDE solution

# Plot prey and predator over time, comparing true vs UDE.
q1 = plot(t_train, X_train[1, :], label="True Prey", lw=2)
plot!(q1, t_train, X_ude[1, :], label="UDE Prey", ls=:dot, lw=3)
xlabel!(q1, "Time");  ylabel!(q1, "Prey Population")

q2 = plot(t_train, X_train[2, :], label="True Predator", lw=2)
plot!(q2, t_train, X_ude[2, :], label="UDE Predator", ls=:dot, lw=3)
xlabel!(q2, "Time");  ylabel!(q2, "Predator Population")

plot_trajectories = plot(q1, q2, layout=(2,1), size=(600,600))
savefig(plot_trajectories, "trajectories_comparison.png")  # save trajectories plot

# (c) Plot training loss curve over iterations.
r = plot(1:length(loss_history), loss_history, lw=2, label="Training Loss")
xlabel!(r, "Iteration")
ylabel!(r, "Loss (MSE)")
title!(r, "UDE Training Loss Convergence")
savefig(r, "training_loss_curve.png")  # save loss curve plot

# All plots have been saved to disk:
#  - "interaction_terms.png"
#  - "trajectories_comparison.png"
#  - "training_loss_curve.png"
