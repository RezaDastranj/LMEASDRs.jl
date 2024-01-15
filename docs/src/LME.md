# Analysing Age-Specific Death Rates with MixedModels.jl

We construct ASDRs data as explained here: [ASDRs](https://rezadastranj.github.io/LME-ASDRs). After saving in RDA format in R, we load the data in Julia.



```@example Main
using RData

# Specify the path to the RDA file containing ASDRs data
rdanm = "ASDRs.rda"

# Check the size of the RDA file
filesize(rdanm)
```
We convert the data to `Arrow` format. Arrow is optimized for in-memory analytics, and its columnar format can lead to more efficient memory usage. This can be important when working with large datasets or when dealing with memory-intensive operations, such as fitting mixed-effects models.

```@example Main
using Arrow, DataFrames
# Load ASDRs data from the RDA file
ASDRs = load(rdanm)

# Data preprocessing
ASDRs["age"] = Arrow.DictEncode(lpad.(ASDRs["age"], 3, '0'))
ASDRs["gender"] = Arrow.DictEncode(ASDRs["gender"])
ASDRs["Country"] = Arrow.DictEncode(ASDRs["Country"])
ASDRs["cohort"] = Int16.(ASDRs["cohort"])
ASDRs["year"] = Int16.(ASDRs["year"])

# Write the data to Arrow format with Zstandard compression
arrownm = Arrow.write("./ASDRs.arrow", DataFrame(ASDRs); compress=:zstd)

# Check the size of the Arrow file
filesize(arrownm)
```



```@example Main
# Load the Arrow data stored in the file 'arrownm' into a DataFrame
df = DataFrame(Arrow.Table(arrownm))

# Display a summary of the DataFrame, including statistics and information about each column
describe(df)
```

```@example Main
# Create a new column 'cgx' in the DataFrame by combining 'Country', 'gender', and 'age' columns
df[!, :cgx] = df.Country .* df.gender .* df.age

# Display a summary of the DataFrame after adding the new 'cgx' column
first(df, 6)  # Display the first 6 rows
```

```@example Main
# Display a summary of the DataFrame after adding the new 'cgx' column
last(df, 6)   # Display the last 6 rows
```

## Insights through ASDRs: Visualizing Age-Specific Death Rates

```@example Main
# Import the Gadfly library for plotting
using Gadfly

# Define a subset of the DataFrame based on specific conditions (Country, gender, and age groups)
subset_df = filter(row -> row.Country == "CZE" && row.gender == "Male" && row.age in ["000", "010", "020", "040", "050", "060", "070", "080"], df)

# Create a dark-themed plot using Gadfly
Gadfly.with_theme(:dark) do
    Gadfly.plot(
        subset_df,                  # DataFrame to be plotted
        x=:year,                    # X-axis corresponds to the 'year' column
        y=:y,                       # Y-axis corresponds to the 'y' column
        color=:age,                 # Color differentiation based on the 'age' column
        Geom.point,                  # Point geometry for data points
        Geom.line,                   # Line geometry for connecting data points
        linestyle=[:dash],           # Dash linestyle for lines
        size=[1.72pt],               # Set point size
        Guide.xlabel("Year"),        # X-axis label
        Guide.ylabel("Mortality(log)"),  # Y-axis label
        Guide.colorkey(title="Age")  # Color key title
    )
end
```



```@example Main

# Define a subset of the DataFrame based on specific conditions (Country, gender, and age groups)
subset_df = filter(row -> row.Country == "AUT" && row.gender == "Male" && row.age in ["000", "010", "020", "040", "050", "060", "070", "080"], df)

# Define custom LaTeX fonts for Gadfly plot aesthetics
latex_fonts = Gadfly.Theme(
    major_label_font="CMU Serif",             # Major label font type
    major_label_font_size=16pt,               # Major label font size
    minor_label_font="CMU Serif",             # Minor label font type
    minor_label_font_size=14pt,               # Minor label font size
    key_title_font="CMU Serif",               # Key title font type
    key_title_font_size=12pt,                 # Key title font size
    key_label_font="CMU Serif",               # Key label font type
    key_label_font_size=10pt                  # Key label font size
)

# Apply the custom LaTeX fonts to the Gadfly theme
Gadfly.push_theme(latex_fonts)

# Create a Gadfly plot with the customized theme
Gadfly.plot(
    subset_df,                              # DataFrame to be plotted
    x=:year,                                # X-axis corresponds to the 'year' column
    y=:y,                                   # Y-axis corresponds to the 'y' column
    color=:age,                             # Color differentiation based on the 'age' column
    Geom.point,                             # Point geometry for data points
    Geom.line,                              # Line geometry for connecting data points
    linestyle=[:dash],                      # Dash linestyle for lines
    size=[1.72pt],                          # Set point size
    Guide.xlabel("Year"),                   # X-axis label
    Guide.ylabel("Mortality(log)"),         # Y-axis label
    Guide.colorkey(title="Age")             # Color key title
)
```


```@example Main
# Apply a dark theme to Gadfly for improved visualization in a dark background
Gadfly.with_theme(:dark) do
    # Set the default plot size to 14cm x 8cm
    set_default_plot_size(14cm, 8cm)
    
    # Create a Gadfly violin plot
    Gadfly.plot(
        df,                         # DataFrame to be plotted
        x=:Country,                 # X-axis corresponds to the 'Country' column
        y=:y,                       # Y-axis corresponds to the 'y' column
        color=:Country,             # Color differentiation based on the 'Country' column
        Geom.violin                 # Violin geometry for displaying distribution
    )
end
```
## Modelling ASDRs using MixedModels.jl

We use the `MixedModels.jl` package to fit a linear mixed-effects model to mortality data. We consider a general model with random effects specified for 'cgx' grouping variable. `REML` (Restricted Maximum Likelihood) is employed for parameter estimation:

```@example Main
using MixedModels

# Define the contrasts for categorical variables
contrasts = Dict(:cgx => Grouping());

# Define the formula for the linear mixed-effects model
f = @formula y ~ age + gender&age + gender&age&kc1 + gender&age&kc2 + k1 + k2 + cohort + (k1 + k2 + cohort | cgx);

# Fit the model using the specified formula, DataFrame 'df', and REML estimation

m1 = fit(MixedModel, f, df, REML=true; contrasts);

VarCorr(m1)
```


!!! warning
     The random effects are designed with a mean of 0, which means that any non-zero mean for a term in the random effects must be integrated into the fixed-effects terms. Consequently, we may need to consider incorporating new covariates as fixed effects if warranted. [Mixed-Effects Models in S and S-PLUS](https://link.springer.com/chapter/10.1007/0-387-22747-4_2)



Determine the floating-point type used internally for the matrices, vectors, and scalars in the model. The type of 'm1' represents the internal floating-point type for parameter optimization. Currently, the NLopt package is used for optimization, allowing only Float64 for parameter vectors. In theory, other floating-point types like BigFloat or Float32 can be used, but only Float64 works in practice.


```@example Main
typeof(m1)
```


```@example Main
# Generate fitted values and residuals from the linear mixed effects model 'm1'
df.fitted = predict(m1)        # Fitted values
df.residuals = residuals(m1)    # Residuals

```

## Check for Heteroskedasticity and Assess Normality

Scatter plot to check for `heteroskedasticity`

```@example Main
# Scatter plot of residuals against fitted values with highlighting
Gadfly.plot(
    y = df.residuals,
    x = df.fitted,
    Geom.point,
    Gadfly.Theme(discrete_highlight_color=x -> "red", default_color="white"),
    Guide.xlabel("Fitted Values"),
    Guide.ylabel("Residuals"),
    Guide.title("Scatter Plot for Heteroskedasticity")
)
```


```@example Main
using Statistics
# QQ plot for residuals with fitted normal distribution
Gadfly.plot(
    x = df.residuals,
    y = Normal(mean(df.residuals), std(df.residuals)),
    Stat.qq,
    Geom.point,
    Gadfly.Theme(discrete_highlight_color=c -> nothing, alphas=[0.5], point_size=2pt)
)
```

## Refine the Model


```@example Main
# Filter out data points with absolute residuals outside the range [-0.10, 0.10]
df_filtered = df[abs.(df.residuals) .<= 0.10, :]

# Write the data to Arrow format with Zstandard compression
Arrow.write("./df_filtered.arrow", DataFrame(df_filtered); compress=:zstd)

# Fit a linear mixed-effects model with a reduced dataset
m2 = let
    f = @formula y ~ age + gender&age + gender&age&kc1 + gender&age&kc2 + k2 + cohort + (k2 + cohort | cgx)
    fit(MixedModel, f, df_filtered, REML=true; contrasts)
end
```

```@example Main
# Predict and compute residuals for the reduced model
df_filtered.fitted = predict(m2)
df_filtered.residuals = residuals(m2)
```


Scatter plot to check for `heteroskedasticity`


```@example Main
Gadfly.plot(
    df_filtered,
    x=:fitted,
    y=:residuals,
    Geom.point,
   Gadfly.Theme(discrete_highlight_color=x -> "red", default_color="white"),
   Guide.xlabel("Fitted Values"),
   Guide.ylabel("Residuals"),
   Guide.title("Scatter Plot for Heteroskedasticity")
)
```

```@example Main
# QQ plot for residuals
Gadfly.plot(
    df_filtered,
    x=:residuals,
    y=Normal(mean(df_filtered[!, :residuals]), std(df_filtered[!, :residuals])),
    Stat.qq,
    Geom.point,
    Gadfly.Theme(discrete_highlight_color=c -> nothing, alphas=[0.5], point_size=2pt),
    Guide.xlabel("Theoretical Quantiles"),
    Guide.ylabel("Sample Quantiles"),
    Guide.title("Normal QQ Plot of Clamped Residuals")
)
```




## References

[Examples of linear mixed-effects model fits](https://juliastats.org/MixedModels.jl/stable/constructors/#Examples-of-linear-mixed-effects-model-fits)


[Analysis of Variance: Why It Is More Important than Ever](https://www.jstor.org/stable/3448650)


