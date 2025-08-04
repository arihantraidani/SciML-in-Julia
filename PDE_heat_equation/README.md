# Solving the 1D Heat Equation using the Method of Lines

This project implements a numerical solution to the one-dimensional heat equation using the **Method of Lines (MOL)** in Julia. The goal is to simulate the diffusion of heat in a 1D rod with fixed temperature boundaries and an initial sine distribution.

---

## Problem Overview

The **1D heat equation** describes the evolution of temperature \( u(x, t) \) in a homogeneous rod:

\[
\frac{\partial u}{\partial t} = \frac{\partial^2 u}{\partial x^2}
\]

We solve this over the spatial domain \( x \in [0, 1] \) and temporal domain \( t \in [0, 1] \), with the following conditions:

- **Initial condition:**  
  \[
  u(x, 0) = \sin(\pi x)
  \]

- **Boundary conditions:**  
  \[
  u(0, t) = u(1, t) = 0 \quad \text{(Dirichlet boundaries)}
  \]

Physically, this models a rod with both ends held at zero temperature, and an initial internal temperature profile shaped like a sine curve. The system is closed and loses heat over time through diffusion.

---

## Mathematical and Numerical Method

We discretize the **spatial dimension** using finite differences (100 internal points) and treat **time** as continuous. This converts the PDE into a system of ODEs, which is then integrated using `Tsit5()`, a high-order Runge-Kutta method.

This technique — known as the **Method of Lines (MOL)** — transforms:

\[
\frac{\partial u}{\partial t} = \frac{\partial^2 u}{\partial x^2}
\]

into a large system:

\[
\frac{d\mathbf{u}}{dt} = A \mathbf{u}
\]

where \( A \) is the discretized Laplacian operator matrix.

---

## Tools and Packages

- **`ModelingToolkit.jl`**: for symbolic PDE definitions and automatic discretization
- **`MethodOfLines.jl`**: to convert the PDE into an ODE system using finite differences
- **`OrdinaryDiffEq.jl`**: to solve the resulting ODE system numerically
- **`Plots.jl`**: to visualize the temperature distribution

---

## Results and Interpretation

The simulation computes the temperature profile at the final time \( t = 1.0 \). The result confirms expected physical behavior:

- Heat diffuses symmetrically from the sine-shaped initial state.
- The temperature approaches zero everywhere as the system tends toward thermal equilibrium.
- The boundary conditions are correctly enforced at \( x = 0 \) and \( x = 1 \), where the temperature remains zero throughout.

### Visualization

The following plot shows the temperature distribution \( u(x, t=1.0) \):

![heat_solution_plot](heat_solution_plot.png)

This visual confirms that the sine-shaped heat pulse has dissipated significantly over time — a hallmark of diffusion-driven dynamics.

---

## Reflections

- The **method of lines** provides a clean and modular approach to solving PDEs numerically by leveraging the strength of ODE solvers.
- Julia’s **ModelingToolkit.jl** and **MethodOfLines.jl** abstract away much of the boilerplate while maintaining flexibility.
- The use of symbolic PDE formulation feels intuitive and scales well to more complex systems.
- This project solidified my understanding of numerical PDE discretization and heat diffusion physics.




