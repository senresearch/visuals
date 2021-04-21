### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 8013f52c-044f-4b9d-87a7-0474b2556f89
begin
        using Plots
        using PlutoUI
        using LaTeXStrings
	    using Optim
end

# ╔═╡ b216d222-3405-4f51-94f5-d5079c77fe9f
md"""
# How the proximal operator works

    Śaunak Sen
    Division of Biostatistics
    Department of Preventive Medicine
    University of Tennessee Health Science Center

    2021-04-21
"""

# ╔═╡ 0633f88f-e899-4170-badd-396c4cea3080
md"""
## Introduction
"""

# ╔═╡ d3b51753-357b-4e50-ba86-bb0fa5a894b6
md"""

Proximal algorithms are a powerful class of algorithms widely used in optimization and machine learning that are useful for non-smooth functions.  A key construct in those algorithms is the use of the _proximal operator_, which is used repeatedly in the optimization routine.  In this note show how the operator works by use of some simple interactive examples.

Suppose, we want to optimize a potentially non-smooth function $f(\cdot)$.  The idea of the proximal operator is to solve a small optimization problem with a smooth version of the same function.
"""

# ╔═╡ 737be09a-9561-4007-b1ce-68df1a298690
md"""
### Envelope function

Consider the envelope function 

$$h(x,u) = f(x) + \frac{1}{2\rho}||x-u||^2.$$

This is a "smoothed" version of the original function $f$ with the property that is a majorizer, i.e. $h(x) \geq f(x), \forall x$ and $h(x) = f(x), \hbox{when} \; x=u$.  The smoothness is controlled by $\rho$.

In many cases, the envelope function is easier to minimize.
"""

# ╔═╡ a4ab238f-4241-4175-acfe-5341e4fd75aa
envelope(x,u,ρ,f::Function) = f(x) + (1/(2*ρ))*(x-u)^2

# ╔═╡ 15e85aad-f364-4358-b6d9-00474bdf2797
md"""
### Proximal operator

By minimizing the envelope function, we are guaranteed to improve upon your current estimate of the minimizing point (M-M algorithm).  The minimizer is called the proximal operator of the function $f$ (with smoothness parameter $\rho$).

$$\text{prox}_{\rho f}(u) = \arg\min_x h(x,u) = \arg\min_x \left[ f(x) + \frac{1}{2\rho} || x - u ||^2 \right].$$
"""

# ╔═╡ ab35b2a8-9d43-4021-9fc7-1cf24ad93bd9
md"""
Below, we define the envelope function and the proximal operator function.
"""

# ╔═╡ 27e9606b-f5cc-499b-a535-cc56835d0fb5
prox(u,ρ,f::Function) = optimize(x->envelope(x,u,ρ,f),-5,5).minimizer

# ╔═╡ 64d4708d-bbc5-44d9-8a4c-e9aaab4bbd4e
md"""
### Pick an example function

The choices are:

- Quadratic: $f(x) = (x-1)^2$
- Absolute value: $f(x) = |x|$
- Cauchy log likelihood: $f(x) = \log(1+x^2) + \log(1+(x{-}0.5)^2) +\log(1+(x{+}0.5)^2)$
- Wiggly: $f(x) = |x| + |x{-}2| + |x{+}1|+ 0.4 \sin(7\pi x)$
"""

# ╔═╡ 7616bd3f-8d2d-4c1b-9bdc-17dd59dbf4e4
@bind fstring Select(["quad" => "quadratic", "abs" => "absolute value", "cauchy" => "Cauchy log likelihood", "wiggly" => "wiggly"])

# ╔═╡ c4649193-3bd0-422d-a8aa-58e3ae71feea
begin
	if(fstring=="quad")
		f(x) = (x-1)^2
	elseif(fstring=="abs")
		f(x) = abs(x)
	elseif (fstring=="cauchy")
		f(x) = log(1+x^2) + log(1+(x-0.5)^2) +log(1+(x+0.5)^2)
	elseif fstring=="wiggly"
		f(x) = abs(x) + abs(x-2) + abs(x+1)+ 0.4*sin(7.0*π*x)
	end
end

# ╔═╡ 23cff64c-e4df-417a-b34c-36a13f3b7819
md"""
### Example function and envelope
Plot of a function $f$ and its envelope function, which agree at the current estimate $u_0$; the proximal operator minimizes the envelope function to get us the next estimate $u_1$.
"""

# ╔═╡ a92086ed-4ac9-417c-a727-486f4d6d0fab
md"""
Choose a value of $\rho$ which controls the degree of smoothness, and the initial estimate $u_0$.
"""

# ╔═╡ cb37cdd7-cbbb-4e7d-a749-c6e3eaecbd51
md"""
ρ: 0.5 $(@bind ρ Slider(0.5:0.1:2.0, default=1.0)) 2.0
"""

# ╔═╡ 67a43881-8946-4b87-8a68-35954cd4c7b6
md"""
u₀: -3.0 $(@bind u Slider(-3.0:0.01:3.0, default=0.0)) 3.0
"""

# ╔═╡ 2d24806f-dbdc-43bd-b866-363f0e043dff
begin
	plot(x-> f(x), -3,3,label="f(x)")
	plot!(x-> envelope(x,u,ρ,f), -3.0,3.0,label="envelope")
	scatter!([(u,0)],label="u₀")
	scatter!([(prox(u,ρ,f),0)],label="u₁=prox(u₀)")
end

# ╔═╡ 77d31d80-c645-410b-8a3f-79484ccd4e7a
md"""
### Example function and proximal operator

It is tedious to pick different values of $u_0$, and so we can convert it into an operator.  We show that here.  Note that the proximal operator for the absolute value is a soft thresholding operator.
"""

# ╔═╡ 991ff0ac-9787-4304-bded-21b83d150230
begin
	plot(u -> f(u), -3,3,label="f")
	plot!(u -> prox(u,ρ,f),-3.0,3.0,label="prox(f)")
end

# ╔═╡ 0ab7b397-09b3-4aa8-8a9e-4daff6308d9b
md"""
The proximal operator for some functions is easy to calculate.  For example, the proximal operator for the absolute value function is the soft threholding operator.

A number of algorithms have been proposed for minimizing functions of the form

$$f(x) + g(x),$$ 

where $f$ is smooth and convex, and $g$ is potentially non-smooth, but with a simple proximal operator.
"""

# ╔═╡ 8a74ea6e-8d51-453d-91a2-ddfdb58e81db
md"""
### Additional reading

- Parikh, N. and Boyd, S. (2014). Proximal algorithms. Foundations and Trends in Optimization 1 123–231.

"""

# ╔═╡ Cell order:
# ╟─b216d222-3405-4f51-94f5-d5079c77fe9f
# ╟─0633f88f-e899-4170-badd-396c4cea3080
# ╟─d3b51753-357b-4e50-ba86-bb0fa5a894b6
# ╟─8013f52c-044f-4b9d-87a7-0474b2556f89
# ╟─737be09a-9561-4007-b1ce-68df1a298690
# ╠═a4ab238f-4241-4175-acfe-5341e4fd75aa
# ╟─15e85aad-f364-4358-b6d9-00474bdf2797
# ╟─ab35b2a8-9d43-4021-9fc7-1cf24ad93bd9
# ╠═27e9606b-f5cc-499b-a535-cc56835d0fb5
# ╟─64d4708d-bbc5-44d9-8a4c-e9aaab4bbd4e
# ╟─7616bd3f-8d2d-4c1b-9bdc-17dd59dbf4e4
# ╟─c4649193-3bd0-422d-a8aa-58e3ae71feea
# ╟─23cff64c-e4df-417a-b34c-36a13f3b7819
# ╟─a92086ed-4ac9-417c-a727-486f4d6d0fab
# ╟─cb37cdd7-cbbb-4e7d-a749-c6e3eaecbd51
# ╟─67a43881-8946-4b87-8a68-35954cd4c7b6
# ╟─2d24806f-dbdc-43bd-b866-363f0e043dff
# ╟─77d31d80-c645-410b-8a3f-79484ccd4e7a
# ╟─991ff0ac-9787-4304-bded-21b83d150230
# ╟─0ab7b397-09b3-4aa8-8a9e-4daff6308d9b
# ╟─8a74ea6e-8d51-453d-91a2-ddfdb58e81db
