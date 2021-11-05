#-------------------------------------------------------------------------------
# CREATE SPECIALIZED SUBSETS OF CENSUS GEOGRAPHY 
#
# GEOGRAPHIES CREATED: Top 100 metros, Top 100 places
# AUTHOR: Francine Stephens
# DATE CREATED: 2/9/21
# LAST UPDATED: 11/3/21
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
tracts_path <- "/2010USA_CensusGeog_Shp/nhgis0005_shapefile_tl2010_us_tract_2010/"
student_path <- "C:/Users/Franc/Documents/Stanford/SOC176/"


# APIs
census_api_key("99ccb52a629609683f17f804ca875115e3f0804c",  overwrite = T)
Sys.setenv(CENSUS_KEY="99ccb52a629609683f17f804ca875115e3f0804c")


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

  ### 2020 data 
places_data <- read_csv(paste0(wd, "/places_pop_counts_census_2020.csv"))

places_top50 <- places_data %>% 
  arrange(-TPOP) %>%
  mutate(rank = dense_rank(desc(TPOP))) %>%
  filter(rank < 51) %>% 
  mutate_at(vars(WHITE_NH:HISPANIC), funs(("percent"  = (./TPOP) * 100))) %>%
  relocate(rank, .after = TPOP)

  ### 2010 data pull
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
write_csv(places_top50, "top50_places_2020Census.csv")
