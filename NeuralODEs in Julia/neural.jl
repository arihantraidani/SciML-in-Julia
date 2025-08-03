## Introduction to Neural ODEs
## Best explanation article I've found so far: https://jontysinai.github.io/jekyll/update/2019/01/18/understanding-neural-odes.html

using ComponentArrays, Lux, DiffEqFlux, OrdinaryDiffEq, Optimization, OptimizationOptimJL,
    OptimizationOptimisers, Random, Plots

rng = Random.default_rng()
u0 = Float32[2.0; 0.0]
datasize = 30
tspan = (0.0f0, 1.5f0)
tsteps = range(tspan[1], tspan[2]; length = datasize)


### UNderlying function which will be used to generate the data!

# du/dt = [du1/dt; du2/dt] = [u1^3 u2^3] * [ -0.1 2; -2 -0.1]
function trueODEfunc(du, u, p, t)
    true_A = [-0.1 2.0; -2.0 -0.1]
    du .= ((u .^ 3)'true_A)'
end

prob_trueode = ODEProblem(trueODEfunc, u0, tspan)

## Generating the ground truth data
ode_data = Array(solve(prob_trueode, Tsit5(); saveat = tsteps))

plot(ode_data')


### Define the Neural ODE
dudt2 = Lux.Chain(x -> x .^ 3, Lux.Dense(2, 50, tanh), Lux.Dense(50, 2))
p, st = Lux.setup(rng, dudt2)

prob_neuralode = NeuralODE(dudt2, tspan, Tsit5(); saveat = tsteps)

function predict_neuralode(p)
    Array(prob_neuralode(u0, p, st)[1])
end

### Define loss function as the difference between actual ground truth data and Neural ODE prediction
function loss_neuralode(p)
    pred = predict_neuralode(p)
    loss = sum(abs2, ode_data .- pred)
    return loss, pred
end

# Scalar-only loss function for training
function loss_only(p)
    l, _ = loss_neuralode(p)
    return l
end

# Create an array to store plot frames
frames = Any[]

# Visualization callback to save frames during training
callback = function (p, l, pred; doplot = true)
    println("Loss: ", l)
    if doplot
        plt = scatter(tsteps, ode_data[1, :]; label = "Ground Truth", legend=:topright, title="NeuralODE Training")
        scatter!(plt, tsteps, pred[1, :]; label = "Prediction")
        push!(frames, plt)  # store each frame
    end
    return false
end

# Wrapper callback for Optimization.jl
wrapped_callback = function (state, l)
    p = state.u
    _, pred = loss_neuralode(p)
    return callback(p, l, pred; doplot = true)
end

pinit = ComponentArray(p)

# Run initial callback for first frame
callback(pinit, loss_neuralode(pinit)...; doplot = true)


# use Optimization.jl to solve the problem
adtype = Optimization.AutoZygote()

optf = Optimization.OptimizationFunction((x, p) -> loss_only(x), adtype)
optprob = Optimization.OptimizationProblem(optf, pinit)

result_neuralode = Optimization.solve(optprob, OptimizationOptimisers.Adam(0.05); callback = wrapped_callback,
    maxiters = 300)

optprob2 = remake(optprob; u0 = result_neuralode.u)

result_neuralode2 = Optimization.solve(optprob2, Optim.BFGS(; initial_stepnorm = 0.01);
    callback = wrapped_callback, allow_f_increases = false)

callback(result_neuralode2.u, loss_neuralode(result_neuralode2.u)...; doplot = true)

# Save animation as GIF
anim = Plots.Animation()
for plt in frames
    frame(anim, plt)
end
gif(anim, "neural_ode_training.gif", fps = 10)

