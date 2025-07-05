# SIR Epidemiological Model – ODE Simulation in Julia

## Overview

This project simulates the spread of an infectious disease using the SIR (Susceptible-Infected-Recovered) model, one of the foundational compartmental models in epidemiology. It is widely used in mathematical biology, public health, and disease modeling to understand how contagious diseases progress through a population.

The simulation is implemented in Julia using the `DifferentialEquations.jl` package, solving a system of nonlinear ordinary differential equations (ODEs). The model provides insights into how varying infection and recovery rates impact the dynamics of an outbreak.

The objective of this task is to:

* Understand the mathematical formulation of the SIR model,
* Implement the model as a system of ODEs in Julia,
* Simulate the disease progression over time,
* Visualize and interpret the number of susceptible, infected, and recovered individuals,
* Build an intuitive understanding of disease dynamics in a closed population.

## What is the SIR Model?

The SIR model divides the population into three compartments:

* **S(t)**: Number of **susceptible** individuals at time $t$
* **I(t)**: Number of **infected** individuals at time $t$
* **R(t)**: Number of **recovered** (or removed) individuals at time $t$

The total population $N$ is assumed constant:

$N = S(t) + I(t) + R(t)$

The model is governed by the following system of ODEs:

$$
\frac{dS}{dt} = -\beta \frac{S I}{N}
$$

$$
\frac{dI}{dt} = \beta \frac{S I}{N} - \gamma I
$$

$$
\frac{dR}{dt} = \gamma I
$$

Where:

* $\beta$: Transmission rate (probability of disease transmission per contact)
* $\gamma$: Recovery rate (proportion of infected individuals recovering per unit time)

These equations model the transitions:

* Susceptible individuals become infected at a rate proportional to their contact with infected individuals.
* Infected individuals recover at a constant rate.

## Applications and Relevance

The SIR model is fundamental in epidemiology and public health decision-making. It is used to:

* Predict outbreak dynamics (e.g., peak infections, duration)
* Estimate the basic reproduction number $R_0 = \frac{\beta}{\gamma}$
* Analyze the impact of interventions like vaccination or quarantine
* Assess healthcare system load and response needs

SIR models are applied to study diseases such as influenza, COVID-19, measles, and more, especially in contexts where recovered individuals gain immunity.

## Problem Statement

We simulate the SIR model for a closed population of 1000 individuals, using the following parameters:

* Total population: $N = 1000$
* Initial infected: $I(0) = 1$
* Initial recovered: $R(0) = 0$
* Initial susceptible: $S(0) = N - I(0) - R(0) = 999$
* Transmission rate: $\beta = 0.3$
* Recovery rate: $\gamma = 0.1$
* Simulation duration: $t \in [0, 160]$ days

## Julia Implementation

We implement the system using Julia and the `DifferentialEquations.jl` package.

### SIR Model Function

```julia
function sir!(du, u, p, t)
    S, I, R = u
    
    N = 1000.0
    β = 0.3
    γ = 0.1

    du[1] = -β * S * I / N             # dS/dt
    du[2] = β * S * I / N - γ * I        # dI/dt
    du[3] = γ * I                       # dR/dt
end
```

### Initial Conditions and Time Span

```julia
u0 = [999.0, 1.0, 0.0]       # [S(0), I(0), R(0)]
tspan = (0.0, 160.0)
```

### Solving the System

```julia
using DifferentialEquations
prob = ODEProblem(sir!, u0, tspan)
sol = solve(prob)
```

## Visualization

We visualize the number of susceptible, infected, and recovered individuals over time.

```julia
using Plots

t = sol.t
S = sol[1, :]
I = sol[2, :]
R = sol[3, :]

p = plot(t, S, label="Susceptible (S)", xlabel="Time (days)", ylabel="Number of People", title="SIR Model Dynamics", linewidth=2)
plot!(t, I, label="Infected (I)", linewidth=2)
plot!(t, R, label="Recovered (R)", linewidth=2)
savefig(p, "sir_model_dynamics.pdf")
```

Alternatively, we can use subplots:

```julia
p1 = plot(sol, idxs=1, label="S(t)", title="Susceptible", legend=:topright, xlabel="Time (days)", ylabel="People", linewidth=2)
p2 = plot(sol, idxs=2, label="I(t)", title="Infected", legend=:topright, xlabel="Time (days)", ylabel="People", linewidth=2)
p3 = plot(sol, idxs=3, label="R(t)", title="Recovered", legend=:topright, xlabel="Time (days)", ylabel="People", linewidth=2)

plot(p1, p2, p3, layout=(3, 1), size=(800, 900))
savefig("sir_model_subplots.pdf")
```

## Interpretation of Results

The plots show how an infectious disease spreads and recedes in a closed population:

* The **susceptible population** decreases over time as individuals get infected.
* The **infected population** initially increases, reaches a peak (the outbreak peak), then declines as recovery surpasses new infections.
* The **recovered population** increases monotonically and eventually plateaus as herd immunity is reached.

These plots allow us to:

* Identify the **peak infection day** and its intensity
* Estimate how long the outbreak lasts
* Visualize the burden on the population over time
