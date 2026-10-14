# Calculate site-level vegetation and microenvironmental summaries.
source("scripts/setup.R")

# Import cleaned data
sites <- read_csv(here("data", "processed", "site_information_clean.csv"), show_col_types = FALSE)
growthform <- read_csv(here("data", "processed", "growth_form_clean.csv"), show_col_types = FALSE)
height <- read_csv(here("data", "processed", "vegetation_height_clean.csv"), show_col_types = FALSE)
temperature <- read_csv(here("data", "processed", "soil_temperature_clean.csv"), show_col_types = FALSE)
par <- read_csv(here("data", "processed", "par_clean.csv"), show_col_types = FALSE)

# Growth-form frequencies: occupied quadrats out of 100
frequencies <- growthform %>%
  count(site, growth_form, name = "frequency") %>%
  complete(site = sites$site, growth_form, fill = list(frequency = 0))

# Richness and Shannon diversity (natural logarithm)
diversity <- frequencies %>%
  group_by(site) %>%
  mutate(proportion = frequency / sum(frequency)) %>%
  summarise(growth_form_richness = sum(frequency > 0),
            shannon_diversity = -sum(proportion[proportion > 0] * log(proportion[proportion > 0])),
            .groups = "drop")

frequency_wide <- frequencies %>%
  mutate(growth_form = paste0("freq_", growth_form)) %>%
  pivot_wider(names_from = growth_form, values_from = frequency)

# Mean and SD of vegetation height and soil temperature
height_summary <- height %>%
  group_by(site) %>%
  summarise(mean_height_cm = mean(vegetation_height_cm, na.rm = TRUE),
            sd_height_cm = sd(vegetation_height_cm, na.rm = TRUE), .groups = "drop")

temperature_summary <- temperature %>%
  group_by(site) %>%
  summarise(mean_soil_temperature_c = mean(soil_temperature_c, na.rm = TRUE),
            sd_soil_temperature_c = sd(soil_temperature_c, na.rm = TRUE),
            .groups = "drop")

# Calculate transmitted PAR (%) from incident PAR and 64 sensors
par_sensors <- par %>%
  pivot_longer(starts_with("sensor_"), names_to = "sensor", values_to = "sensor_par") %>%
  mutate(transmission_pct = if_else(total_par > 0, 100 * sensor_par / total_par, NA_real_))

# Median sensor transmission at each of 50 sampling points
par_points <- par_sensors %>%
  group_by(site, sampling_point) %>%
  summarise(median_transmission_pct = if (all(is.na(transmission_pct))) NA_real_ else median(transmission_pct, na.rm = TRUE),
            .groups = "drop")

# Plot summaries; retain both definitions of deep shade for verification
par_summary <- par_points %>%
  group_by(site) %>%
  summarise(n_par_points = sum(!is.na(median_transmission_pct)),
            median_par_pct = median(median_transmission_pct, na.rm = TRUE),
            se_par_pct = sd(median_transmission_pct, na.rm = TRUE) / sqrt(n_par_points),
            pct_points_under_10 = 100 * mean(median_transmission_pct < 10, na.rm = TRUE),
            .groups = "drop")

par_sensor_shade <- par_sensors %>%
  group_by(site) %>%
  summarise(pct_sensors_under_10 = 100 * mean(transmission_pct < 10, na.rm = TRUE),
            .groups = "drop")

# Combine site-level variables
site_summary <- sites %>%
  select(site, time_since_fire_y, time_since_fire_numeric) %>%
  left_join(frequency_wide, by = "site") %>%
  left_join(diversity, by = "site") %>%
  left_join(height_summary, by = "site") %>%
  left_join(temperature_summary, by = "site") %>%
  left_join(par_summary, by = "site") %>%
  left_join(par_sensor_shade, by = "site")

write_csv(par_points, here("data", "processed", "par_point_medians.csv"))
write_csv(site_summary, here("outputs", "summaries", "site_summary.csv"))
