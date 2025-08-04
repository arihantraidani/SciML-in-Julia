# Solving the 1D Heat Equation with Sine Initial Condition

This project numerically solves the one-dimensional heat equation using Julia's scientific computing ecosystem. It models the diffusion of heat in a rod with fixed-temperature boundaries and an initial temperature distribution shaped as a sine wave.

---

## Problem Overview

The heat equation in one spatial dimension is given by:

∂u/∂t = ∂²u/∂x²

where:
- `u(x, t)` is the temperature at position `x` and time `t`.
- The domain is `x ∈ [0, 1]`, `t ∈ [0, 1]`.

### Initial and Boundary Conditions:

- **Initial condition:**  
  `u(x, 0) = sin(πx)`

- **Boundary conditions:**  
  `u(0, t) = u(1, t) = 0`

This setup represents a rod that starts with a sine-shaped heat profile and is held at zero temperature at both ends. Over time, the heat will diffuse through the rod.

---

## Numerical Method

This simulation uses the **Method of Lines (MOL)**:

- The spatial domain is discretized using 100 grid points and finite differences.
- The resulting system of ODEs is solved using `Tsit5()`, a 5th-order Runge-Kutta solver.

This approach effectively transforms the PDE into a large system of ODEs in time, which is then integrated using Julia’s ODE solvers.

---

## Tools and Packages

- `ModelingToolkit.jl` — symbolic PDE definition
- `MethodOfLines.jl` — automatic space discretization
- `OrdinaryDiffEq.jl` — high-performance time integration
- `Plots.jl` — for visualization

---

## Results and Interpretation

At `t = 1.0`, the temperature profile shows clear diffusion from the sine-shaped initial condition:

- The central peak of the sine curve has significantly flattened.
- The profile has spread outward, losing heat symmetrically.
- The boundaries remain fixed at zero, as required by the Dirichlet conditions.

### Final Temperature Distribution

![heat_solution_plot](heat_solution_plot.png)

This result is consistent with the expected physical behavior of a rod dissipating internal heat over time under fixed-boundary constraints.

---

## Reflections

- This project reinforces the classical theory of heat diffusion and numerical PDE methods.
- MOL is a natural and efficient approach for solving parabolic PDEs in 1D.
- Julia's symbolic-to-numeric tools provide both abstraction and performance.
- The choice of a sine function as the initial condition allowed easy qualitative validation.
