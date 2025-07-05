# Time-Dependent Schrödinger Equation – PDE Simulation in Julia

## Overview

This project solves a fundamental equation in quantum mechanics: the **time-dependent Schrödinger equation** for a particle in a one-dimensional potential well. We implement a numerical solution in Julia using the **Method of Lines** with the help of `ModelingToolkit.jl`, `MOLFiniteDifference`, and `DifferentialEquations.jl`.

The goal is to simulate how the quantum wave function $\psi(t, x)$ evolves over time in a domain with fixed boundary conditions and visualize the evolution of its real and imaginary components.

## Background: The Schrödinger Equation

In quantum mechanics, the Schrödinger equation governs the evolution of the wave function $\psi(t, x)$, which encodes all information about a particle's quantum state.

The **time-dependent Schrödinger equation** in one spatial dimension (with $\hbar = 1$ and mass $m = 1/2$) is:

$$
  i \frac{\partial \psi(t, x)}{\partial t} = -\frac{\partial^2 \psi(t, x)}{\partial x^2} + V(x) \psi(t, x)
$$

In our case, the potential is zero: $V(x) = 0$, simplifying the equation to:

$$
  i \frac{\partial \psi(t, x)}{\partial t} = -\frac{\partial^2 \psi(t, x)}{\partial x^2}
$$

This models a **free quantum particle** in a one-dimensional box.

## Problem Setup

### Domain and Conditions

* Spatial domain: $x \in [0, 1]$
* Time domain: $t \geq 0$
* Initial condition: $\psi(0, x) = \sin(2\pi x)$
* Boundary conditions:

  * $\psi(t, 0) = 0$
  * $\psi(t, 1) = 0$

### Interpretation

The initial wave function is a sine mode consistent with the infinite square well boundary conditions. Over time, the wave evolves according to the kinetic energy operator, causing oscillations in both the real and imaginary parts of $\psi$.

## Numerical Method: Method of Lines (MOL)

The Method of Lines is a PDE discretization technique where:

* The spatial domain is discretized using finite differences.
* The resulting system is a large set of ODEs in time.
* These ODEs are solved using standard ODE solvers (e.g., from `OrdinaryDiffEq.jl`).

In this project:

* We use `ModelingToolkit.jl` to define the PDE.
* We use `MOLFiniteDifference` to discretize the spatial derivative.
* We solve the resulting ODE system using Julia's ODE solvers.

## Julia Implementation Overview

### 1. Define PDE Components

```julia
@parameters t x
@variables ψ(..)

Dt = Differential(t)
Dx = Differential(x)

V(x) = 0.0

pde = 1im * Dt(ψ(t, x)) ~ -Dx(Dx(ψ(t, x))) + V(x) * ψ(t, x)
```

### 2. Initial and Boundary Conditions

```julia
bcs = [
    ψ(0, x) ~ sin(2π * x),
    ψ(t, 0) ~ 0.0,
    ψ(t, 1) ~ 0.0
]
```

### 3. Discretization and Solving

```julia
domains = [t ∈ IntervalDomain(0.0, 2.0), x ∈ IntervalDomain(0.0, 1.0)]
desys = PDESystem(pde, bcs, domains, [t, x], [ψ])
discretization = MOLFiniteDifference([x => 100], t)

prob = discretize(desys, discretization)
sol = solve(prob, Tsit5(), saveat=0.01)
```

## Visualization Task

You are required to create a **GIF animation** that shows how the **real and imaginary parts** of the wave function $\psi(t, x)$ evolve over time.

### Key Elements:

* Plot both `real.(ψ)` and `imag.(ψ)` at each time step.
* Label axes clearly: `x` on the x-axis, `Re(ψ)` and `Im(ψ)` on the y-axis.
* Display the current time frame in the title or corner of each frame.

### Suggested Plotting Code

```julia
using Plots
anim = @animate for i in 1:10:length(sol.t)
    plot(sol[x], real.(sol.u[i]), label="Re(ψ)", xlabel="x", ylabel="ψ", ylim=(-1,1))
    plot!(sol[x], imag.(sol.u[i]), label="Im(ψ)", title="t = $(round(sol.t[i], digits=2))")
end

gif(anim, "schrodinger_wave_evolution.gif", fps=20)
```

## Expected Results and Interpretation

The animation will show:

* The **real and imaginary parts** of the wave function oscillating over time.
* **Wave-like behavior** as expected in quantum mechanics.
* The system remains confined within the domain due to the **Dirichlet boundary conditions**.
* The norm of the wave function remains approximately constant (probability conservation).

This simulation gives a visual and numerical insight into how quantum states evolve freely in a 1D box. The method used is applicable to more complex scenarios, such as potential barriers, tunneling, and scattering problems.

## Conclusion

This assignment demonstrates how to numerically solve the time-dependent Schrödinger equation using the Method of Lines in Julia. It bridges quantum mechanics and scientific computing, allowing exploration of fundamental physical phenomena via code. By extending this framework, one can study richer quantum systems, include potentials, and experiment with wave packets, superpositions, and interference effects.
