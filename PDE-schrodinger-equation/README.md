# Time-Dependent Schrödinger Equation – PDE Simulation in Julia

## Overview

This project involves solving the time-dependent Schrödinger equation for a quantum particle in a one-dimensional box. The goal was to model the evolution of a quantum wave function $\psi(t,x)$, and visualize its behavior using Julia. The equation was solved using the **Method of Lines**, and since the Schrödinger equation is complex-valued, I split it into two real-valued partial differential equations (PDEs): one for the real part and one for the imaginary part.

This exercise helped me understand how to numerically solve PDEs, how to represent complex systems using coupled equations, and how to implement and visualize physical simulations in Julia.

---

## The Schrödinger Equation

The time-dependent Schrödinger equation in one spatial dimension (with $\hbar = 1$ and mass $m = 1/2$) is given by:

$$
i \frac{\partial \psi(t,x)}{\partial t} = -\frac{\partial^2 \psi(t,x)}{\partial x^2}
$$

This equation is fundamental in quantum mechanics, describing how the wave function $\psi(t,x)$ of a quantum particle evolves with time. The solution $\psi$ is a complex-valued function, which encodes both the amplitude and phase of the quantum state.

However, `ModelingToolkit.jl` and `MethodOfLines.jl` do not directly support complex-valued PDEs. Therefore, I rewrote the equation in terms of its real and imaginary components:

$\psi(t,x) = u(t,x) + i v(t,x)$

Substituting into the original equation and separating real and imaginary parts yields a coupled system:

\[
\begin{aligned}
\frac{\partial u}{\partial t} &= -\frac{\partial^2 v}{\partial x^2} \\\\
\frac{\partial v}{\partial t} &= \phantom{-}\frac{\partial^2 u}{\partial x^2}
\end{aligned}
\]


This system describes how the real part $u(t,x)$ and the imaginary part $v(t,x)$ evolve over time.

---

## Problem Description

We simulate the evolution of a wave function $\psi(t,x)$ in a potential-free box using the split real-imaginary form. The problem is defined as follows:

* **Spatial domain**: $x \in [0, 1]$
* **Time domain**: $t \in [0, 1]$
* **Initial conditions**:

  * $u(0,x) = \sin(2\pi x)$ (real part)
  * $v(0,x) = 0$ (imaginary part)
* **Boundary conditions**:

  * $u(t,0) = u(t,1) = 0$
  * $v(t,0) = v(t,1) = 0$

This setup represents a quantum particle in an infinite square well, where the wave function must vanish at the walls.

---

## Method of Lines

To solve the coupled PDE system numerically, I used the **Method of Lines (MOL)**. This approach involves:

1. **Discretizing the spatial domain** into a grid of points using finite differences.
2. **Keeping time continuous**, turning the PDEs into a system of ODEs in time.
3. Solving the resulting ODE system using an ODE solver like `TRBDF2()` from `OrdinaryDiffEq.jl`.

Mathematically:

* The second spatial derivatives $\partial^2 u / \partial x^2$ and $\partial^2 v / \partial x^2$ are approximated using central difference formulas.
* The result is a large system of ODEs, one for each spatial grid point.

This method is well-suited to time-evolution problems, especially for PDEs with fixed spatial boundaries.

---

## Implementation Summary

I implemented the solution in Julia using the following approach:

1. Defined the symbolic variables and differential operators using `ModelingToolkit.jl`.
2. Wrote the coupled PDE system for $u(t,x)$ and $v(t,x)$.
3. Applied initial and boundary conditions.
4. Used `MOLFiniteDifference` from `MethodOfLines.jl` to discretize the spatial domain.
5. Used `discretize()` to convert the PDE system into an ODE system.
6. Solved the system using `TRBDF2()` with `saveat=0.01`.
7. Animated the results using `Plots.jl` to visualize both $\text{Re}(\psi)$ and $\text{Im}(\psi)$.

---

## Results and Interpretation

The output is an animated GIF: `schrodinger_real_split.gif`. It shows:

* The **real part** $u(t,x) = \text{Re}(\psi)$
* The **imaginary part** $v(t,x) = \text{Im}(\psi)$

Key observations:

* Both components exhibit oscillatory wave behavior.
* The wave remains confined between $x = 0$ and $x = 1$, satisfying boundary conditions.
* There is no damping — the wave maintains its shape and energy, illustrating **unitary evolution** of quantum systems.
* The wave appears to shift phase over time, showing the expected quantum harmonic behavior.

This reflects the physics of a particle in an infinite potential well, where the wave function evolves according to its quantized energy levels.

---

## Reflections and Learning

This project helped me:

* Understand how to translate complex PDEs into real-valued coupled systems.
* Learn the Method of Lines and its application in Julia.
* Practice working with `ModelingToolkit`, `MethodOfLines`, and `OrdinaryDiffEq`.
* Develop confidence in solving and visualizing PDEs.

I also saw how mathematical structure (e.g., linearity, boundary conditions) translates directly into solver performance and behavior.

---

It demonstrates how to numerically solve the time-dependent Schrödinger equation using the Method of Lines in Julia. It bridges quantum mechanics and scientific computing, allowing exploration of fundamental physical phenomena via code. By extending this framework, one can study richer quantum systems, include potentials, and experiment with wave packets, superpositions, and interference effects.
