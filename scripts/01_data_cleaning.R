
# Import and clean the five original field-data files
source("scripts/setup.R")

# Import raw CSV files
site_information <- read_csv(here("data", "raw", "site_information.csv"), show_col_types = FALSE)
growth_form_raw <- read_csv(here("data", "raw", "growth_form_raw.csv"), show_col_types = FALSE)
vegetation_height_raw <- read_csv(here("data", "raw", "vegetation_height_raw.csv"), show_col_types = FALSE)
soil_temperature_raw <- read_csv(here("data", "raw", "soil_temperature_raw.csv"), show_col_types = FALSE)
par_raw <- read_csv(here("data", "raw", "par_raw.csv"), show_col_types = FALSE)

# Clean site information and retain the original >40 designation
sites <- site_information %>%
  filter(!is.na(site)) %>%
  mutate(site = str_trim(site), time_since_fire_numeric = parse_number(time_since_fire_y))

# Remove duplicate growth-form records and standardise quadrat IDs
growth_form_raw_clean <- growth_form_raw %>%
  mutate(quadrat = str_remove_all(quadrat, "\\s+")) %>%
  distinct(site, quadrat, growth_form_presence, .keep_all = TRUE)

# Create processed growth-form data with three columns
growth_form_data <- growth_form_raw_clean %>%
  transmute(site = str_trim(site), quadrat = quadrat,
            growth_form = str_to_lower(str_trim(growth_form_presence)) %>%
              str_replace_all("[^a-z0-9]+", "_") %>%
              str_remove("_$"))

# Standardise identifiers and shading conditions
vegetation_height_data <- vegetation_height_raw %>%
  mutate(site = str_trim(site), quadrat = as.character(quadrat))

soil_temperature_data <- soil_temperature_raw %>%
  mutate(site = str_trim(site),
         quadrat = str_remove_all(quadrat, "\\s+"),
         shading_condition = str_to_lower(str_trim(shading_condition)))

par_data <- par_raw %>%
  mutate(site = str_trim(site))

# Check sampling coverage
sites %>% summarise(n_sites = n_distinct(site))
vegetation_height_data %>% count(site)
soil_temperature_data %>% count(site, shading_condition)
par_data %>% count(site)

# Check PAR sensor columns
par_data %>% select(starts_with("sensor_")) %>% names()

# Save cleaned data
write_csv(sites, here("data", "processed", "site_information_clean.csv"))
write_csv(growth_form_data, here("data", "processed", "growth_form_clean.csv"))
write_csv(vegetation_height_data, here("data", "processed", "vegetation_height_clean.csv"))
write_csv(soil_temperature_data, here("data", "processed", "soil_temperature_clean.csv"))
write_csv(par_data, here("data", "processed", "par_clean.csv"))

