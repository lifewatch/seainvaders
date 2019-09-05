# findingdemo

## How to

```r
# fetch WRiMS species list

sp <- get_wrims_species

# fetch temperature and salinity raster data

temp_data <- get_temperature()
sal_data <- get_salinity()

# extract raster data

t <- extract_raster(temp_data, 0, 55)

# fetch occurrence data for an AphiaID

occ <- get_occurrence(159559)

# launch shiny app

launch_app()
```
