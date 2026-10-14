# Reproduce linear regressions from Zomer & Ramsay (2021)
source("scripts/setup.R")

# Import site summaries and PAR sampling-point medians
site_summary <- read_csv(here("outputs", "summaries", "site_summary.csv"), show_col_types = FALSE)
par_point_medians <- read_csv(here("data", "processed", "par_point_medians.csv"), show_col_types = FALSE)

# Select sites 1.5–10 years after fire
selected <- site_summary %>%
  filter(time_since_fire_numeric >= 1.5, time_since_fire_numeric <= 10)


# 1. Growth-form diversity and richness
model_shannon <- lm(shannon_diversity ~ time_since_fire_numeric, data = selected)
model_richness <- lm(growth_form_richness ~ time_since_fire_numeric, data = selected)

summary(model_shannon)
summary(model_richness)

# 2. Individual growth-form frequencies
model_tussocks <- lm(freq_tussocks ~ time_since_fire_numeric, data = selected)
model_upright_shrubs <- lm(freq_upright_shrubs ~ time_since_fire_numeric, data = selected)
model_cushion_mat <- lm(freq_cushion_mat ~ time_since_fire_numeric, data = selected)
model_prostrate_herbs <- lm(freq_prostrate_herbs ~ time_since_fire_numeric, data = selected)
model_erect_herbs <- lm(freq_erect_herbs ~ time_since_fire_numeric, data = selected)
model_giant_basal_rosettes <- lm(freq_giant_basal_rosettes ~ time_since_fire_numeric, data = selected)
model_giant_stem_rosettes <- lm(freq_giant_stem_rosettes ~ time_since_fire_numeric, data = selected)
model_prostrate_shrubs <- lm(freq_prostrate_shrubs ~ time_since_fire_numeric, data = selected)
model_acaulescent_rosettes <- lm(freq_acaulescent_rosettes ~ time_since_fire_numeric, data = selected)
model_trailing_herbs <- lm(freq_trailing_herbs ~ time_since_fire_numeric, data = selected)

# Published significant growth-form relationships (Figure 5)
summary(model_prostrate_herbs)
summary(model_prostrate_shrubs)
summary(model_cushion_mat)
summary(model_giant_basal_rosettes)

# 3. Vegetation structure and environmental conditions
model_height <- lm(mean_height_cm ~ time_since_fire_numeric, data = selected)
model_temperature <- lm(mean_soil_temperature_c ~ time_since_fire_numeric, data = selected)
model_deep_shade <- lm(pct_points_under_10 ~ time_since_fire_numeric, data = selected)

summary(model_height)
summary(model_temperature)
summary(model_deep_shade)

# 4. PAR transmission using sampling-point medians
par_selected <- par_point_medians %>%
  inner_join(selected %>% select(site, time_since_fire_numeric), by = "site") %>%
  filter(!is.na(median_transmission_pct))

#updated from article 
model_par_lmer <- lmer(log1p(median_transmission_pct) ~ time_since_fire_numeric + (1 | site), data = par_selected)
summary(model_par_lmer)


# 5. Model diagnostics using DHARMa
simulateResiduals(model_shannon, plot = TRUE)
simulateResiduals(model_prostrate_herbs, plot = TRUE)
simulateResiduals(model_prostrate_shrubs, plot = TRUE)
simulateResiduals(model_cushion_mat, plot = TRUE)
simulateResiduals(model_giant_basal_rosettes, plot = TRUE)
simulateResiduals(model_height, plot = TRUE)
simulateResiduals(model_temperature, plot = TRUE)
simulateResiduals(model_deep_shade, plot = TRUE)
simulateResiduals(model_par_lmer, plot = TRUE)

# 6. Export regression results
models <- list(
  shannon_diversity = model_shannon,
  growth_form_richness = model_richness,
  freq_tussocks = model_tussocks,
  freq_upright_shrubs = model_upright_shrubs,
  freq_cushion_mat = model_cushion_mat,
  freq_prostrate_herbs = model_prostrate_herbs,
  freq_erect_herbs = model_erect_herbs,
  freq_giant_basal_rosettes = model_giant_basal_rosettes,
  freq_giant_stem_rosettes = model_giant_stem_rosettes,
  freq_prostrate_shrubs = model_prostrate_shrubs,
  freq_acaulescent_rosettes = model_acaulescent_rosettes,
  freq_trailing_herbs = model_trailing_herbs,
  mean_height_cm = model_height,
  mean_soil_temperature_c = model_temperature,
  pct_points_under_10 = model_deep_shade
)

regression_results <- imap_dfr(models, ~ {
  model_summary <- glance(.x)
  coefficients <- tidy(.x) %>% filter(term == "time_since_fire_numeric")
  tibble(variable = .y, n = nobs(.x),
         intercept = coef(.x)[1], slope = coefficients$estimate,
         r_squared = model_summary$r.squared,
         f_statistic = model_summary$statistic,
         p_value = coefficients$p.value)
})

write_csv(regression_results, here("outputs", "models", "regression_results.csv"))

# Export PAR mixed-effects model results
par_lmer_results <- broom.mixed::tidy(model_par_lmer, effects = "fixed")

write_csv(par_lmer_results, here("outputs", "models", "par_lmer_results.csv"))

#save 
saveRDS(c(models, list(par_transmission_pct = model_par_lmer)),
        here("outputs", "models", "fitted_models.rds"))
