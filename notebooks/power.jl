### A Pluto.jl notebook ###
# v0.14.5

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

# ╔═╡ 70919378-b4d7-11eb-2d76-db01c83f87b8
begin
	using Distributions
	using Plots
	using PlutoUI
end

# ╔═╡ 33afb7f3-e52a-4f49-8be2-8634c66db010
md"""
# How power depends on effect size, sample size, and the desired false positive rate
    Śaunak Sen
    Division of Biostatistics
    Department of Preventive Medicine
    University of Tennessee Health Science Center
    2021-04-21
"""

# ╔═╡ 1d5602ee-5f7b-42ec-b8e0-c9f2bd2c5b94
md"""
In the animation below, we show how power depends on effect size (μ1), sample size (n), and the desired false positive rate (α).  For simplicity we consider a one-sample normal test for the mean, where the null hypothesis is that the mean of the observationsi is μ0=0, and the alternative is that it is something else, μ1.  We assume that the variance of the observations is 1.0.

In the figure below, we show the distribution of the mean of n observations under the _null_ in blue, and under the _alternative_ in pink.

Given, a desired, false postitive rate, α, we have a critical region (or rejection region), that is shaded in blue.  The area of this region under the null should be α.
The area under the critical region under the alternative is shaded in pink.  On the right, we show the pink area expressed as a proportion.

Play around with the sliders:
- Effect size: When the effect size is zero, the two distributions will coincide, and the powe is exactly equal to the false positive rate.  As you pull the effect size in either direction, you can see the power increase.
- Sample size: As the sample size increases, the distributions narrow, and that will increase power.
- False positive rate: If you increase false positive rate, you increase power.  The trick is to find a balance between the two.
"""

# ╔═╡ 26160436-409f-41f0-8cf9-f59420b9b4c5
# power function for normal distribution
# μ is mean under null
# α is the level of significance

function power(μ=0.0,α=0.05)
    z = quantile(Normal(),1-α/2)
    return ccdf(Normal(μ,1),z) + cdf(Normal(μ,1),-z) 
end

# ╔═╡ f33de1eb-8d69-42f4-b3f5-5d24c074b455
md"""
Effect size μ1: -2.0 $(@bind μ1 Slider(-2.0:0.01:2.0, default=0.00)) 2.0
"""

# ╔═╡ 60f06071-b57a-4a51-9fe6-3e612bffadf4
md"""
Sample size n: 1 $(@bind n NumberField(1:1:100, default=1)) 100
"""

# ╔═╡ b4ea9dc9-f138-455f-86a4-cc1d191a34b2
md"""
False postitive rate α: 0.0 $(@bind α Slider(0.0:0.01:1.0, default=0.05)) 1.0
"""

# ╔═╡ 3d32ce55-428d-41ee-bb2c-7540b1c7d210
  begin
	# null mean
    μ0 = 0.0
	σ = 1.0/sqrt(n)
    # upper and lower cutoffs for critical region
    zhi = quantile( Normal(μ0,σ), 1-α/2 )
    zlo = quantile( Normal(μ0,σ), α/2 )

    # plot showing null and alternative distributions
    p1 = plot(x-> pdf(Normal(μ0,σ),x),-5,6,legend=false)
    # alt pdf
    plot!(p1,x-> pdf(Normal(μ1,σ),x));
    
    # shade area in critical region under alt
    plot!(p1,x-> pdf(Normal(μ1,σ),x), zhi, 6.0, 
        fill=(0,:lightpink));
    # shade area in critical region under null
    plot!(p1,x-> pdf(Normal(μ0,σ),x), zhi, 6.0, 
       fill=(0,:lightblue));
    plot!(p1,x-> pdf(Normal(μ0,σ),x), -6.0, zlo, 
                fill=(0,:lightblue)) 
    
    # plot showing the power as a barplot
    p2 = bar([0.0],[power(μ1/σ,α)],legend=false,ylim=(0,1),color=:lightpink,
        xtick=nothing,ytick=0:0.1:1.0,framestyle=:box)
    plot(p1,p2,layout = @layout([p1 p2{0.1w}]))
end

# ╔═╡ Cell order:
# ╟─33afb7f3-e52a-4f49-8be2-8634c66db010
# ╟─1d5602ee-5f7b-42ec-b8e0-c9f2bd2c5b94
# ╟─70919378-b4d7-11eb-2d76-db01c83f87b8
# ╟─26160436-409f-41f0-8cf9-f59420b9b4c5
# ╟─f33de1eb-8d69-42f4-b3f5-5d24c074b455
# ╟─60f06071-b57a-4a51-9fe6-3e612bffadf4
# ╟─b4ea9dc9-f138-455f-86a4-cc1d191a34b2
# ╟─3d32ce55-428d-41ee-bb2c-7540b1c7d210
