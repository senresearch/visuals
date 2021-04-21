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

# ╔═╡ 638c74d9-ad4d-4776-831b-8166faf063ab
begin
	using Plots
	using PlutoUI
	using LaTeXStrings
	using Optim
	plotly()
end

# ╔═╡ e52889b0-9d46-11eb-33f1-cf0665f314a7
md"""
# How the L₁-penalty achieves sparsity

    Śaunak Sen
    Division of Biostatistics
    Department of Preventive Medicine
    University of Tennessee Health Science Center

    2021-04-21
"""

# ╔═╡ 7a97d5bb-9871-454c-a0be-ed54a54aab12
md"""

## Introduction

Suppose we are performing linear regression with models of the form

$$y = X\beta + \epsilon,$$

where $y$ is vector of the outcome of interest, $X$ is the "design matrix" derived from the predictor variables of interest, $\beta$ is the vector of regression coefficients to be estimated, and $\epsilon$ is the vector of errors assumed to have mean zero and constant variance.

Estimation is performed by least squares, i.e. by minimizing

$$\Vert y-X\beta \Vert_2^2$$

with respect to $\beta$, denoting by $\Vert . \Vert_2$, the L$_2$ norm or the square root of the sum of squares. It is well-known that this could lead to overfitting.  To prevent overfitting, some kind of regularization is needed.  Adding a penalty is one way to achieve that.  

Ridge regression adds a penalty proportional to the sum of squares of the coefficients (and has a Bayesian interpretion).  We minimize:

$$\Vert y-X\beta \Vert_2^2 + \lambda \Vert \beta \Vert_2^2,$$

where $\lambda$ is a tuning parameter that controls the strength of penalization.

Adding a sum of absolute values of the coefficients value penalty (or an L$_1$ penalty) has the added advantage of performing variable selection at the same time.  In this case, we minimize:

$$\Vert y-X\beta \Vert_2^2 + \lambda \Vert \beta \Vert_1^2,$$

denoting by $\Vert . \Vert_1$, the L$_1$ norm or the sum of absolute values, and $\lambda$ is a tuning parameter that controls the amount of penalization.  The first term in the above criterion is a goodness-of-fit criterion, and the second one is a measure of model size (or complexity).  The idea is to balance goodness of fit with model complexity.

In this note, using a "cartoon" implementation of L$_1$ penalized regression, we will show you how that works.
"""

# ╔═╡ d0c3b87e-05bd-44bd-8abb-18f97aa4c25e
md"""

## A cartoon problem

Consider, a simplified version of the problem, by trying to minimize with respect to (a scalar) $\beta$, the function:

$f(x) = (x-2)^2 + \lambda |x|.$

This has the same form as the L$_1$ penalized regression criterion, and is simplified to show the essential features.  The first term is a squared error loss, and the second term is the penalty.

"""

# ╔═╡ 48b97b44-963b-45a9-aefa-ca57aa8acf50
f(x,λ) = (x-2.0)^2 + λ*abs(x)

# ╔═╡ f3aeaeac-f622-4509-8fa3-5831c619073d
md"""
Now, we will plot this function by varying $\lambda$ with the slider.  We can see that when $\lambda=0$, the function is minimized at $2.0$, but as we increase $\lambda$, the point where the function is minimized is drawn (shrunk) towards $0.0$.
"""

# ╔═╡ 1e45a2cf-162b-4a01-9ba7-0f52d76479ac
md"""
---
"""

# ╔═╡ e99e3483-3f70-4ccb-928e-580f9288f19d
md"""
## Shrinkage of minimizer

The graph below shows the the quadratic loss (in grey) and the penalized version of the loss (in salmon).  Notice the kink of the penalized function at zero; this is due to the penalty term.  The curve is continuous, but does not have a continuous derivative at zero.

Vary the penalty with the $\lambda$ slider below.
"""

# ╔═╡ 634ad033-d869-4a98-9ea7-0e749d080e6e
md"""
λ: 0.0 $(@bind λ Slider(0.0:0.1:5.0, default=1.0)) 5.0
"""

# ╔═╡ de1e52c5-c798-4901-b959-43f1599614ca
begin
	plot(x-> f(x,0.0),-7,8,ylim=(0,80),label="(x-2)²",color="grey")
	plot!(x-> f(x,λ),-7,8,label="(x-2)²+λ|x|",color="salmon")
	scatter!([(2.0,0.0)],color="grey",label="LS minimizer")
	scatter!([(optimize(x->f(x,λ),-6,8).minimizer,0)],label="Penalized minimizer",color="salmon")
end

# ╔═╡ d69f3d84-53a9-4595-9d0c-87eeeec3e42f
md"""
The least squares (LS) minimizer is 2.0 (without) the penalty. The penalized minimizer slides towards zero, as the penalty is increased; when the penalty is large enough, the minimizer is zero.

This is also what happens with L$_1$-penalized regression.  When the penalty is zero, we get least squares estimates.  As we increase the penalty, the estimates shrink towards zero, and for large enough penalty, they are exactly zero.  By minimizing the penalized criterion, we can perform shrinkage estimation, and model selection (since some estimates will be exactly zero).

Thus, sparsity is achieved by making the penalty $\lambda$ large enough.
"""

# ╔═╡ Cell order:
# ╟─e52889b0-9d46-11eb-33f1-cf0665f314a7
# ╟─7a97d5bb-9871-454c-a0be-ed54a54aab12
# ╟─d0c3b87e-05bd-44bd-8abb-18f97aa4c25e
# ╟─48b97b44-963b-45a9-aefa-ca57aa8acf50
# ╠═638c74d9-ad4d-4776-831b-8166faf063ab
# ╟─f3aeaeac-f622-4509-8fa3-5831c619073d
# ╟─1e45a2cf-162b-4a01-9ba7-0f52d76479ac
# ╟─e99e3483-3f70-4ccb-928e-580f9288f19d
# ╟─634ad033-d869-4a98-9ea7-0e749d080e6e
# ╟─de1e52c5-c798-4901-b959-43f1599614ca
# ╟─d69f3d84-53a9-4595-9d0c-87eeeec3e42f
