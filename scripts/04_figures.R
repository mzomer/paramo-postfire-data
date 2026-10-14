
# Plot regression results from Zomer & Ramsay (2021)
source("scripts/setup.R")

site_summary <- read_csv(here("outputs", "summaries", "site_summary.csv"), show_col_types = FALSE)
par_point_medians <- read_csv(here("outputs", "summaries", "par_point_medians.csv"), show_col_types = FALSE)
models <- readRDS(here("outputs", "models", "fitted_models.rds"))

selected <- site_summary %>%
  filter(between(time_since_fire_numeric, 1.5, 10))

par_selected <- par_point_medians %>%
  inner_join(selected %>% select(site, time_since_fire_numeric), by = "site") %>%
  filter(!is.na(median_transmission_pct))

# Predictions from fitted models
model_fit <- tibble(time_since_fire_numeric = seq(1.5, 10, length.out = 100)) %>%
  mutate(
    shannon = predict(models$shannon_diversity, newdata = .),
    richness = predict(models$growth_form_richness, newdata = .),
    prostrate_herbs = predict(models$freq_prostrate_herbs, newdata = .),
    prostrate_shrubs = predict(models$freq_prostrate_shrubs, newdata = .),
    cushion_mat = predict(models$freq_cushion_mat, newdata = .),
    giant_basal_rosettes = predict(models$freq_giant_basal_rosettes, newdata = .),
    height = predict(models$mean_height_cm, newdata = .),
    temperature = predict(models$mean_soil_temperature_c, newdata = .),
    deep_shade = predict(models$pct_points_under_10, newdata = .),
    par = predict(models$par_transmission_pct, newdata = ., re.form = NA)
  )


# Figure 4: Growth-form diversity and richness
fig_shannon <- ggplot(selected, aes(time_since_fire_numeric, shannon_diversity)) +
  geom_point() +
  geom_line(data = model_fit, aes(y = shannon), color = "black", linewidth = 0.4) +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 10, 2), expand = c(0, 0), name = "Time since fire (years)") +
  scale_y_continuous(expand = expansion(mult = 0.05), name = "Shannon diversity") +
  theme_classic()

fig_richness <- ggplot(selected, aes(time_since_fire_numeric, growth_form_richness)) +
  geom_point() +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 10, 2), expand = c(0, 0), name = "Time since fire (years)") +
  scale_y_continuous(expand = expansion(mult = 0.05), name = "Growth-form richness") +
  theme_classic()


# Figure 5: Growth-form frequencies
fig_prostrate_herbs <- ggplot(selected, aes(time_since_fire_numeric, freq_prostrate_herbs)) +
  geom_point() +
  geom_line(data = model_fit, aes(y = prostrate_herbs), color = "black", linewidth = 0.4) +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 10, 2), expand = c(0, 0), name = "Time since fire (years)") +
  scale_y_continuous(breaks = seq(0, 100, 20), name = "Prostrate herbs frequency (%)") +
  coord_cartesian(ylim = c(-5, 105)) +
  theme_classic()

fig_prostrate_shrubs <- ggplot(selected, aes(time_since_fire_numeric, freq_prostrate_shrubs)) +
  geom_point() +
  geom_line(data = model_fit, aes(y = prostrate_shrubs), color = "black", linewidth = 0.4) +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 10, 2), expand = c(0, 0), name = "Time since fire (years)") +
  scale_y_continuous(breaks = seq(0, 100, 20), name = "Prostrate shrubs frequency (%)") +
  coord_cartesian(ylim = c(-5, 105)) +
  theme_classic()

fig_cushion_mat <- ggplot(selected, aes(time_since_fire_numeric, freq_cushion_mat)) +
  geom_point() +
  geom_line(data = model_fit, aes(y = cushion_mat), color = "black", linewidth = 0.4) +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 10, 2), expand = c(0, 0), name = "Time since fire (years)") +
  scale_y_continuous(breaks = seq(0, 100, 20), name = "Cushions/mats frequency (%)") +
  coord_cartesian(ylim = c(-5, 105)) +
  theme_classic()

fig_giant_basal_rosettes <- ggplot(selected, aes(time_since_fire_numeric, freq_giant_basal_rosettes)) +
  geom_point() +
  geom_line(data = model_fit, aes(y = giant_basal_rosettes), color = "black", linewidth = 0.4) +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 10, 2), expand = c(0, 0), name = "Time since fire (years)") +
  scale_y_continuous(breaks = seq(0, 100, 20), name = "Giant basal rosettes frequency (%)") +
  coord_cartesian(ylim = c(-5, 105)) +
  theme_classic()


# Figure 7: Vegetation and environmental conditions
fig_height <- ggplot(selected, aes(time_since_fire_numeric, mean_height_cm)) +
  geom_point() +
  geom_line(data = model_fit, aes(y = height), color = "black", linewidth = 0.4) +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 10, 2), expand = c(0, 0), name = "Time since fire (years)") +
  scale_y_continuous(expand = expansion(mult = 0.05), name = "Mean vegetation height (cm)") +
  theme_classic()

fig_temperature <- ggplot(selected, aes(time_since_fire_numeric, mean_soil_temperature_c)) +
  geom_point() +
  geom_line(data = model_fit, aes(y = temperature), color = "black", linewidth = 0.4) +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 10, 2), expand = c(0, 0), name = "Time since fire (years)") +
  scale_y_continuous(expand = expansion(mult = 0.05), name = "Mean soil temperature at 20 cm depth (°C)") +
  theme_classic()

fig_par <- ggplot(par_selected, aes(time_since_fire_numeric, log1p(median_transmission_pct))) +
  geom_point(alpha = 0.2) +
  geom_line(data = model_fit, aes(y = par), color = "black", linewidth = 0.4) +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 10, 2), expand = c(0, 0), name = "Time since fire (years)") +
  scale_y_continuous(name = "log(1 + Median PAR reaching ground (%))") +
  theme_classic()

fig_heavy_shade <- ggplot(selected, aes(time_since_fire_numeric, pct_points_under_10)) +
  geom_point() +
  geom_line(data = model_fit, aes(y = deep_shade), color = "black", linewidth = 0.4) +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 10, 2), expand = c(0, 0), name = "Time since fire (years)") +
  scale_y_continuous(limits = c(0, 100), expand = expansion(mult = 0.05), name = "% light readings with <10% PAR reaching ground") +
  theme_classic()


# Display figures in RStudio
fig_shannon
fig_richness
fig_prostrate_herbs
fig_prostrate_shrubs
fig_cushion_mat
fig_giant_basal_rosettes
fig_height
fig_temperature
fig_par
fig_heavy_shade


# Save figures
figures <- list(
  shannon = fig_shannon,
  richness = fig_richness,
  prostrate_herbs = fig_prostrate_herbs,
  prostrate_shrubs = fig_prostrate_shrubs,
  cushion_mat = fig_cushion_mat,
  giant_basal_rosettes = fig_giant_basal_rosettes,
  height = fig_height,
  temperature = fig_temperature,
  par = fig_par,
  deep_shade = fig_deep_shade
)

for (figure_name in names(figures)) {
  ggsave(here("outputs", "figures", paste0(figure_name, ".png")),
         plot = figures[[figure_name]], width = 5, height = 4, dpi = 300)
}
