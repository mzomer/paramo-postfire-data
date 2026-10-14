# Variable descriptions

This document describes the variables and coding conventions in the five raw-data files.

### Sampling conventions

- **Site identifiers:** `A` = El Ángel; `B` = La Bretaña.
- **Quadrat identifiers:** Growth-form data use `01+` to `50+` and `01-` to `50-`; vegetation-height data use `1` to `50` and `-1` to `-50`, distinguishing the two rows of quadrats.

### 1. Site information — `site_information.csv`

Site metadata and fire history (one row per site).

| Variable | Description |
|---|---|
| `site` | Unique site identifier |
| `year_of_fire` | Year of the most recent known fire |
| `survey_date` | Date of field sampling (DD-Mon-YY) |
| `time_since_fire_y` | Time since fire (years); `>40` identifies the long-unburned site |
| `place` | Study area or reserve |
| `location` | Location within or relative to the reserve |
| `cordillera` | Andean cordillera (Eastern or Western) |
| `altitude_m` | Elevation above sea level (m) |
| `land_use` | Description of land use and grazing |
| `lat` | Latitude (decimal degrees) |
| `lon` | Longitude (decimal degrees) |

### 2. Growth-form presence — `growth_form_raw.csv`

Plant growth-form presence in individual quadrats. Each row represents one growth form recorded as present; absences are not listed.

| Variable | Description |
|---|---|
| `place` | Study area |
| `time_since_fire_y` | Time since fire (years) |
| `site` | Site identifier |
| `quadrat` | Quadrat identifier (`01+` to `50+`, `01-` to `50-`) |
| `growth_form_presence` | Plant growth form recorded as present |

Ten growth forms are distinguished: Tussocks, Upright Shrubs, Prostrate Shrubs, Prostrate Herbs, Erect Herbs, Cushion/Mat, Giant Basal Rosettes, Giant Stem Rosettes, Acaulescent Rosettes, and Trailing Herbs.

Duplicate records have been removed and minor formatting inconsistencies corrected.

### 3. Vegetation height — `vegetation_height_raw.csv`

Vegetation height measured using a drop disc, with one measurement per quadrat.

| Variable | Description |
|---|---|
| `place` | Study area |
| `time_since_fire_y` | Time since fire (years) |
| `site` | Site identifier |
| `quadrat` | Quadrat identifier (`1` to `50`, `-1` to `-50`) |
| `vegetation_height_cm` | Vegetation height (cm) |

### 4. Soil temperature — `soil_temperature_raw.csv`

Soil temperature measured at 20 cm depth under three shading conditions at five positions along each transect.

| Variable | Description |
|---|---|
| `place` | Study area |
| `time_since_fire_y` | Time since fire (years) |
| `site` | Site identifier |
| `quadrat` | Sampling quadrat identifier |
| `shading_condition` | Shading condition (`open`, `intermediate`, `shaded`) |
| `soil_temperature_c` | Soil temperature at 20 cm depth (°C) |

### 5. Photosynthetically active radiation — `par_raw.csv`

Photosynthetically active radiation (PAR) measured using a SunScan instrument at 50 sampling points per site.

| Variable | Description |
|---|---|
| `site` | Site identifier |
| `sampling_point` | Sampling position along the transect (1–50 meters) |
| `total_par` | Total incident PAR |
| `sensor_1`–`sensor_64` | PAR readings from 64 individual SunScan sensors |

PAR measurements are missing for sampling point 50 at site `B03`.

### Reference

Zomer, M. A., & Ramsay, P. M. (2021). Post-fire changes in plant growth form composition and diversity in Andean páramo grassland. *Applied Vegetation Science*, 24, e12554. https://doi.org/10.1111/avsc.12554