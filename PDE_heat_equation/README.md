# Solving the 1D Heat Equation using the Method of Lines

This project implements a numerical solution to the one-dimensional heat equation using the **Method of Lines (MOL)** in Julia. The goal is to simulate the diffusion of heat in a 1D rod with fixed temperature boundaries and an initial sine distribution.

---

## Problem Overview

The **1D heat equation** describes the evolution of temperature `u(x, t)` in a homogeneous rod:

∂u/∂t = ∂²u/∂x²

We solve this over the spatial domain `x ∈ [0, 1]` and time domain `t ∈ [0, 1]` with the following:

- **Initial condition:**  
  `u(x, 0) = sin(πx)`

- **Boundary conditions:**  
  `u(0, t) = u(1, t) = 0`  (Dirichlet)

Physically, this models a rod with both ends held at zero temperature, and an initial internal temperature profile shaped like a sine curve. Heat gradually diffuses over time.

---

## Numerical Method

The equation is solved using the **Method of Lines**, where:

- The spatial domain is discretized using finite differences.
- The resulting ODE system is solved using the `Tsit5()` Runge-Kutta method.

This transforms the PDE into:

du/dt = A * u

Where `A` is the discrete Laplacian matrix.

---

## Tools and Packages

- `ModelingToolkit.jl` — for symbolic PDE modeling
- `MethodOfLines.jl` — for space discretization
- `OrdinaryDiffEq.jl` — for time integration
- `Plots.jl` — for visual output

---

## Results and Interpretation

The simulation computes the temperature profile at final time `t = 1.0`. As expected:

- The sine-shaped initial temperature dissipates over time.
- Heat spreads out uniformly, approaching equilibrium.
- The boundary temperature remains zero throughout.

### Plot: Temperature at `t = 1`

![heat_solution_plot](heat_solution_plot.png)

---

## Reflections

- The method of lines is intuitive and powerful for parabolic PDEs like the heat equation.
- Julia’s SciML tools provide a symbolic-to-numeric workflow that scales well.
- This project deepened my understanding of both diffusion physics and numerical PDE methods.

