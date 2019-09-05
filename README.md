# findingdemo

## How to

```r
# fetch WRiMS species list

sp <- get_wrims_species

# fetch temperature and salinity raster data

temp <- get_temperature()
sal <- get_salinity()

# extract raster data

t <- extract_raster(temp, 0, 55)

# fetch occurrence data for an AphiaID

occ <- get_occurrence(159559)

# create habitat suitability maps

hs <- make_suitability(occ, temp, sal)

df <- as.data.frame(hs, xy = TRUE) %>%
  mutate(suitability = 1 / layer)
ggplot() +
    geom_raster(data = df, aes(x = x, y = y, fill = suitability)) +
    scale_fill_viridis_c(trans = "log10") +
    coord_quickmap()

![suitability](suitability.png)

# launch shiny app

launch_app()
```
