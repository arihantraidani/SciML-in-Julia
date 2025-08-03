# Scientific Machine Learning in Julia

This repository serves as a personal academic journal for my learning journey in **Scientific Machine Learning (SciML)** using the Julia programming language. It contains a curated collection of self-driven projects, experiments, and implementations covering a broad range of topics in differential equations, data-driven modeling, and neural networks applied to physical systems.

The objective of this repository is not only to practice SciML techniques but also to understand their mathematical foundations, interpret their behavior in physical systems, and develop reproducible research skills using Julia’s scientific ecosystem.

---

## Repository Structure

Each folder in this repository contains:

- A well-documented Julia script implementing the project
- Visualization outputs (plots, animations, etc.)
- A project-specific `README.md` that includes:
  - A concise problem statement
  - Methodological description
  - Key results and visualizations
  - Personal reflections and technical observations

This structure is designed to mirror a lab notebook, capturing both the technical implementation and the conceptual learning behind each project.

---

## Overview of Projects

| Project | Description | Methodology |
|--------|-------------|-------------|
| [`neural_ode_intro`](./neural_ode_intro) | Neural ODE trained on synthetic data from a 2D nonlinear system | Neural ODE |
| [`sir_classical`](./sir_classical) | Classical compartmental SIR model for disease spread | Ordinary Differential Equations |
| [`sir_neuralode`](./sir_neuralode) | Neural ODE trained on ground truth SIR data | Neural ODE |
| [`pinn_wave`](./pinn_wave) | Solving the 1D wave equation using Physics-Informed Neural Networks | PINN |
| [`pinn_poisson`](./pinn_poisson) | 2D Poisson equation with known analytical solution | PINN |
| [`heat_equation_exact`](./heat_equation_exact) | Heat equation with known exact solution for validation | Method of Lines (MOL) |
| [`heat_equation_numeric`](./heat_equation_numeric) | Numerical solution to heat equation using FD discretization | Method of Lines (MOL) |
| [`pde_schrodinger`](./pde_schrodinger) | Real and imaginary evolution of a Schrödinger-like system | Coupled PDEs via MOL |
| [`lorenz_attractor`](./lorenz_attractor) | Simulation of the chaotic Lorenz system | Dynamical Systems, ODE |
| [`forced_pendulum`](./forced_pendulum) | Solving a pendulum ODE under external periodic forcing | Classical Mechanics, ODE |

---

## Technical Stack

All projects are implemented in [Julia](https://julialang.org/), using the following core libraries from the SciML ecosystem:

- `DifferentialEquations.jl` — for solving ODEs and PDEs
- `DiffEqFlux.jl` — for Neural ODEs and differentiable programming
- `NeuralPDE.jl` — for Physics-Informed Neural Networks
- `ModelingToolkit.jl` — for symbolic and modular modeling of differential systems
- `Lux.jl` — for defining neural network architectures
- `Plots.jl` — for visualization of solutions and training dynamics
- `Optimization.jl` — for gradient-based optimization

---

## Motivation and Goals

My aim is to build strong conceptual and practical expertise in modeling dynamical systems using both traditional numerical methods and modern machine learning-based approaches. This includes:

- Understanding and applying continuous-time modeling techniques
- Exploring the use of neural networks in differential equation settings
- Studying the convergence, accuracy, and interpretability of different solvers
- Developing a disciplined habit of writing reproducible and well-documented code

This work serves as preparation for future research and potential graduate study in computational astrophysics, machine learning for physical systems, or gravitational wave modeling.

---

## Future Work

This repository will continue to evolve with more advanced topics, including:

- Partial differential equations with stochastic components
- Adjoint sensitivity analysis for parameter estimation
- Universal Differential Equations (UDEs)
- Neural Operator architectures for PDE learning
- Applications to gravitational wave source modeling and black hole spin evolution

---

## Author

**Arihant Raidani**  
Physics and Astrophysics enthusiast  
Email: arihantraidani@gmail.com  
GitHub: [arihantraidani](https://github.com/arihantraidani)



