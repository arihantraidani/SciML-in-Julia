# Julia ODEs and PDEs

This repository documents my journey of learning **Ordinary Differential Equations (ODEs)** and **Partial Differential Equations (PDEs)** using Julia's `DifferentialEquations.jl` ecosystem. It is intended to serve both as a coding portfolio and an explanatory guide for those interested in understanding the role of differential equations in physics and the natural sciences.

## What Are Differential Equations?

A **differential equation** is a mathematical equation that relates a function to its derivatives. In simpler terms, it describes how something changes over time or space. These equations are extremely important because they allow us to model and predict how systems evolve. Almost every law of physics can be written as a differential equation.

There are two main types:

### 1. Ordinary Differential Equations (ODEs)

An ordinary differential equation involves derivatives with respect to a single independent variable, usually time $t$. These equations are used when a system evolves only over time.

**Examples:**

* Newton's Second Law:
  $m \frac{d^2x}{dt^2} = F(x, t)$
  This equation describes how an object moves when forces are applied to it. If we know the force, we can solve for the position $x(t)$ over time.

* Population Growth:
  $\frac{dP}{dt} = rP$
  This equation models how a population $P$ grows over time with a constant rate $r$.

### 2. Partial Differential Equations (PDEs)

Partial differential equations involve derivatives with respect to more than one independent variable, usually both time and space. These are used when we are interested in how things change over both time and position.

**Examples:**

* Heat Equation (diffusion of temperature):
  $\frac{\partial u}{\partial t} = D \frac{\partial^2 u}{\partial x^2}$
  This equation describes how heat spreads through a rod over time.

* Wave Equation (vibrating string):
  $\frac{\partial^2 u}{\partial t^2} = c^2 \frac{\partial^2 u}{\partial x^2}$
  This models wave motion, such as a string fixed at both ends.

## Why Are Differential Equations Important?

Differential equations form the foundation of all physical sciences. They help us understand systems that evolve and change. Here are some examples:

* **Classical mechanics:** Motion of objects is governed by Newton's laws, which are second-order ODEs.
* **Electrical circuits:** The behavior of voltage and current over time is described by ODEs.
* **Epidemiology:** The spread of diseases is modeled using systems of ODEs (like the SIR model).
* **Heat flow and wave propagation:** These are described using PDEs.
* **Quantum mechanics and electromagnetism:** Governed by PDEs like the Schrödinger and Maxwell equations.

In short, if something moves, changes, spreads, or reacts, differential equations are likely involved in describing how it happens.

## Why Julia?

Julia is a high-performance language designed for numerical and scientific computing. It combines the ease of Python with the speed of C. The `DifferentialEquations.jl` package is a powerful tool that provides many solvers for ODEs, PDEs, stochastic equations, and more.

Some reasons I chose Julia for this project:

* Clean and readable syntax that resembles the mathematics
* Extremely fast computation
* Robust solver ecosystem for stiff and non-stiff equations
* Integrated plotting and visualization

## What This Repository Contains

Each folder in this repository contains a small project focused on solving and visualizing a specific differential equation. Every project includes:

* A Julia script that sets up and solves the equation
* Comments and explanations in the code
* A plot showing the behavior of the system over time
* A short write-up in the folder's README summarizing the physical model, mathematical formulation, and results

## References

* [DifferentialEquations.jl Documentation](https://diffeq.sciml.ai)
* Arfken & Weber — Mathematical Methods for Physicists
* Strogatz — Nonlinear Dynamics and Chaos
* Gerald & Wheatley — Applied Numerical Analysis
* [JuliaLang.org Tutorials](https://julialang.org/learning/)

---

If you would like to follow my work or get in touch, feel free to visit my [LinkedIn](https://www.linkedin.com/in/arihant-raidani/) or [GitHub](https://github.com/arihantraidani).

