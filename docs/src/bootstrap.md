# Parametric bootstrap for LMEASDRs



```@example Main
using Arrow, DataFrames

# File path to the Arrow data file
arrow_file_path = "df_filtered.arrow"

# Create a DataFrame from the Arrow data
df_filtered = DataFrame(Arrow.Table(arrow_file_path));

# Display a summary of the df_filtered, including statistics and information about each column
describe(df_filtered)
```

## Fit a linear mixed-effects model with a reduced dataset
```@example Main
using MixedModels

# Define the contrasts for categorical variables
contrasts = Dict(:cgx => Grouping());

# Define the formula for the mixed-effects model
f = @formula y ~ age + gender&age + gender&age&kc1 + gender&age&kc2 + k2 + cohort + (k2 + cohort | cgx)

# Fit the mixed-effects model (m2) to the data (df_filtered)
# REML=true specifies the use of Restricted Maximum Likelihood for estimation; contrasts are used
m2 = fit(MixedModel, f, df_filtered, REML=true; contrasts)

# Print the variance components of the mixed-effects model
VarCorr(m2)
```


```@example Main
using CairoMakie
using MixedModelsMakie

# Generate a quantile-quantile caterpillar plot for the mixed-effects model (m2)
qqcaterpillar(m2)
```


## Parametric bootstrap for the LME model 'm2'


```@example Main
using Random
# Set up a constant random number generator (RNG) using MersenneTwister with seed 61
const RNG = MersenneTwister(61)

# Perform parametric bootstrap with 10 samples based on the mixed-effects model m2
boot = parametricbootstrap(RNG, 1_000, m2);

# Access the table of results from the bootstrap samples
# tbl = boot.tbl;

# Access the parameter estimates from the bootstrap samples
df_boot = DataFrame(boot.allpars);

# Display the first 10 rows of the DataFrame
first(df_boot, 10)
```

```@example Main
using Gadfly

# Plotting parametric bootstrap estimates of σ
Gadfly.plot(x = boot.σ, Geom.density, Guide.xlabel("Parametric bootstrap estimates of σ"))
```




```@example Main

# Generate coverage intervals from the original bootstrap object
dfshci = DataFrame(shortestcovint(boot))

first(dfshci,30)
```


## References



[Bootstrapping](https://en.wikipedia.org/wiki/Bootstrapping_(statistics))


[MixedModels.parametricbootstrap](https://juliastats.org/MixedModels.jl/stable/bootstrap/)



```@raw html
<iframe width="560" height="315" src="https://www.youtube.com/embed/h_LweqiIotE" title="Statistical Learning: 5.4 The Bootstrap" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
```


