# LMEASDRs

[![Build Status](https://github.com/RezaDastranj/LMEASDRs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/RezaDastranj/LMEASDRs.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Build Status](https://app.travis-ci.com/RezaDastranj/LMEASDRs.jl.svg?branch=main)](https://app.travis-ci.com/RezaDastranj/LMEASDRs.jl)

# Analysing Age-Specific Death Rates with MixedModels.jl

A linear mixed-effects ([LME](https://en.wikipedia.org/wiki/Mixed_model#Qualitative_Description:~:text=traits.%20%5B16%5D-,Definition,-%5Bedit%5D)) model is proposed for modelling and forecasting single and multi-population age-specific death rates (`ASDRs`). The innovative approach that we take in this study treats age, the interaction between gender and age, their interactions with predictors, and cohort as [fixed effects](https://en.wikipedia.org/wiki/Mixed_model#/media/File:Mixedandfixedeffects.jpg). Furthermore, we incorporate additional random effects to account for variations in the intercept, predictor coefficients, and cohort effects among different age groups of females and males across various countries. In the single-population case, we will see how the random effects of intercept and slope change over different age groups. We will show that the `LME` model is identifiable. We perform a [bootstrap](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)) resampling of the parameters of the LME model to compute $95\%$ uncertainty intervals for death rate forecasts. We will use data from the Human Mortality Database (HMD) to illustrate the procedure. We assess the predictive performance of the `LME` model in comparison to the Lee-Carter (LC) models fitted to individual populations. Additionally, we evaluate the predictive accuracy of the `LME` model relative to the Li-Lee (LL) model. Our results indicate that the `LME` model provides a more precise representation of observed mortality rates within the HMD, demonstrates robustness in calibration rate selection, and exhibits superior performance when contrasted with the LC and LL models.

## Keywords

Life insurance, Mortality forecasting, Restricted maximum likelihood, Model selection, Random walks with drift, [MixedModels.jl](https://github.com/JuliaStats/MixedModels.jl).


