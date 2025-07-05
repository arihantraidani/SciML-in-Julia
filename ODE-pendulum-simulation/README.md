# Pendulum Dynamics with External Torque – ODE Simulation in Julia

## Overview

This project models and simulates the motion of a physical pendulum under the influence of both gravity and an external torque. The system is represented as a second-order nonlinear ordinary differential equation (ODE) and solved numerically using the Julia programming language with the `DifferentialEquations.jl` package.

The objective was to:

* Derive the governing equations of motion for a pendulum with external forcing,
* Reformulate the second-order ODE as a first-order system,
* Solve the system numerically,
* Visualize the angular displacement and angular velocity over time,
* Understand how external torques influence pendulum dynamics.

## Physical Model

We consider a rigid pendulum consisting of a mass $m$ attached to a massless rod of length $l$, oscillating in a vertical plane. The pendulum is subject to:

1. A restoring torque due to gravity, which tends to bring it back to the vertical equilibrium position.
2. An external time-dependent torque $M(t)$, which could drive or oppose the natural oscillation.

Let:

* $\theta(t)$: Angular displacement from vertical (radians)
* $\omega(t) = \frac{d\theta}{dt}$: Angular velocity (radians per second)

The governing equation derived from Newton’s second law for rotational motion is:

$\frac{d\omega}{dt} = -\frac{3g}{2l} \sin(\theta) + \frac{3}{ml^2} M(t)$

The first term on the right-hand side represents the gravitational restoring torque (nonlinear due to the sine), and the second term accounts for the external torque. This is a nonlinear second-order ODE. To solve it numerically, we convert it to a system of first-order ODEs by defining:

$\frac{d\theta}{dt} = \omega$
$\frac{d\omega}{dt} = -\frac{3g}{2l} \sin(\theta) + \frac{3}{ml^2} M(t)$

## Constants and Initial Conditions

We use the following values as provided in the assignment:

* Length of the pendulum: $l = 1.0$ m
* Mass of the pendulum: $m = 1.0$ kg
* Gravitational acceleration: $g = 9.81$ m/\s^2
* External torque: $M(t) = \sin(t)$ (chosen to simulate periodic driving)
* Initial angle: $\theta(0) = 0.01$ rad
* Initial angular velocity: $\omega(0) = 0.0$ rad/s
* Simulation time: $t \in [0, 10]$ seconds

## Julia Implementation

We use Julia's `DifferentialEquations.jl` to define and solve the system.

### ODE Function

```julia
function pendulum!(du, u, p, t)
    g = 9.81
    l = 1.0
    m = 1.0
    M = sin(t)  # External periodic torque

    du[1] = u[2]  # dθ/dt = ω
    du[2] = -(3 * g / (2 * l)) * sin(u[1]) + (3 / (m * l^2)) * M
end
```

### Solving the System

```julia
using DifferentialEquations

u0 = [0.01, 0.0]             # Initial state: [θ(0), ω(0)]
tspan = (0.0, 10.0)          # Time span for simulation
prob = ODEProblem(pendulum!, u0, tspan)
sol = solve(prob)
```

## Visualization

To analyze the behavior of the pendulum over time, we plot both the angular displacement and angular velocity:

```julia
using Plots

plot(sol, idxs=1, label="θ(t): Angular Position", xlabel="Time (s)", ylabel="Value", title="Pendulum Dynamics with External Torque", linewidth=2, legend=:topright)
plot!(sol, idxs=2, label="ω(t): Angular Velocity", linewidth=2)
savefig("pendulum_dynamics.pdf")
```

This combined plot shows how the periodic external torque influences the pendulum's motion. Depending on the driving frequency and amplitude, the pendulum may exhibit resonance-like amplification or complex oscillatory behavior.

## Observations

* The inclusion of the sine-driven torque $M(t) = \sin(t)$ introduces sustained energy into the system, preventing damping and maintaining oscillations.
* The angular displacement and velocity exhibit rich dynamics beyond the simple harmonic approximation.
* The system is nonlinear due to the sine term $\sin(\theta)$, which makes analytical solutions difficult — justifying the use of numerical ODE solvers.

## Conclusion

This simulation successfully models the dynamics of a pendulum under an external periodic torque. Using Julia’s DifferentialEquations.jl ecosystem enables compact, performant, and expressive implementation of physics-based ODEs. The exercise reinforces both physical understanding and practical modeling skills relevant for scientific computing, control systems, and nonlinear dynamics.
