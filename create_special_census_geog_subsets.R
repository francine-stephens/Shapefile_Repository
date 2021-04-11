#-------------------------------------------------------------------------------
# CREATE SPECIALIZED SUBSETS OF CENSUS GEOGRAPHY 
#
# GEOGRAPHIES CREATED: Top 100 metros, Top 100 places
# AUTHOR: Francine Stephens
# DATE CREATED: 2/9/21
# LAST UPDATED: 4/11/21
#-------------------------------------------------------------------------------

## LIBRARIES
packages <- c(
  "readr",
  "tidyverse",
  "sf",
  "ggplot2",
  "tigris",
  "censusapi", 
  "tidycensus", 
  "leaflet"
)
lapply(packages, library, character.only = T)

## PATHS
wd <- getwd()
sf_shapes <- "/san_francisco_shapes/analysis_nhoods_2010_census_tracts/"
student_path <- "C:/Users/Franc/Documents/Stanford/SOC176/"

# APIs
census_api_key("99ccb52a629609683f17f804ca875115e3f0804c",  overwrite = T)
Sys.setenv(CENSUS_KEY="99ccb52a629609683f17f804ca875115e3f0804c")


## DATA
sf_hoods <- st_read(paste0(wd, 
                           sf_shapes,
                          "geo_export_afde1190-a893-43d3-9611-1325253cf07f.shp"),
                    quiet = F)



# SOCIAL LIFE OF NEIGHBORHOOD CENSUS TRACTS------------------------------------- 

leaflet() %>%
  addTiles() %>%
  addPolygons(data = excelsior,
              fillColor = NULL,
              color = "Black",
              opacity = 0.5,
              fillOpacity = 0.5,
              weight = 1.5,
              #label = ~paste0(geoid)
  )

census_tracts <- c("06075026100", 
                   "06075026301",
                   "06075026004",
                   "06075026001",
                   "06075025500")
excelsior <- sf_hoods %>%
  filter(geoid %in% census_tracts) %>%
  mutate(nhood = "Excelsior") %>%
  group_by(nhood) %>%
  summarize(tracts = n())

st_write(excelsior, "excelsior_sf.shp")




#Decennial Census Data----------------------------------------------------------
## CBSA COUNTS
cbsa_pop <- get_decennial(geography = "cbsa", 
                            variables = "P001001", 
                            year = 2010) # default is 2010

top100_cbsa <- cbsa_pop %>%
  arrange(-value) %>%
  slice(1:100) %>%
  rename(CBSAFP="GEOID", CBSA_NM="NAME") %>% 
  mutate(rank_pop_size=rank(-value, ties.method = "first"),
         top_100=1
         ) %>%
  select(-variable:-value)

  ##EXPORTS
write_csv(top100_cbsa, "top100_cbsa_2010bounds.csv")


##PLACES COUNTS
places_pop <- get_decennial(geography = "place", 
                            variables = "P001001", 
                            year = 2010) # default is 2010

top100_places <- places_pop %>%
  arrange(-value) %>%
  slice(1:100) %>%
  rename(PLACEFP="GEOID", PLACE_NM="NAME") %>% 
  mutate(rank_pop_size=rank(-value, ties.method = "first"),
         top_100=1
  ) %>%
  select(-variable:-value)

##EXPORTS
write_csv(top100_places, "top100_places_2010bounds.csv")
