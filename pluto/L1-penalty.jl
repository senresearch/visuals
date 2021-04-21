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
	using Symbolics
	plotly()
end

# ╔═╡ e52889b0-9d46-11eb-33f1-cf0665f314a7
md"""
# Gradient descent

Gradient descent is a widely-used optimization method.  Here we examine its application in the simple case of minimizing a quadratic loss function.

Consider the problem of minimizing the function

$f(x) = (x-2)^2 + \lambda |x|.$
"""

# ╔═╡ 48b97b44-963b-45a9-aefa-ca57aa8acf50
f(x,λ) = (x-2.0)^2 + λ*abs(x)

# ╔═╡ f3aeaeac-f622-4509-8fa3-5831c619073d
md"""
Now, we will plot this function by varying $\lambda$ with the slider.  We can see that when $\lambda=0$, the function is minimized at $2.0$, but as we increase $\lambda$, the point where the function is minimized is drawn (shrunk) towards $0.0$.
"""

# ╔═╡ 634ad033-d869-4a98-9ea7-0e749d080e6e
md"""
λ: 0.0 $(@bind λ Slider(0.0:0.1:6.0, default=1.0)) 6.0
"""

# ╔═╡ de1e52c5-c798-4901-b959-43f1599614ca
begin
	plot(x-> f(x,0.0),-3,7,label="",ylim=(0,60))
	plot!(x-> f(x,λ),-3,7,label="")
end

# ╔═╡ Cell order:
# ╟─e52889b0-9d46-11eb-33f1-cf0665f314a7
# ╠═48b97b44-963b-45a9-aefa-ca57aa8acf50
# ╟─638c74d9-ad4d-4776-831b-8166faf063ab
# ╟─f3aeaeac-f622-4509-8fa3-5831c619073d
# ╟─634ad033-d869-4a98-9ea7-0e749d080e6e
# ╟─de1e52c5-c798-4901-b959-43f1599614ca
