#-------------------------------------------------------------------------------
# CREATE SPECIALIZED SUBSETS OF CENSUS GEOGRAPHY 
#
# GEOGRAPHIES CREATED: Top 100 metros, Top 100 places
# AUTHOR: Francine Stephens
# DATE CREATED: 2/9/21
# LAST UPDATED: 3/4/21
#-------------------------------------------------------------------------------

## LIBRARIES
packages <- c(
  "readr",
  "tidyverse",
  "sf",
  "ggplot2",
  "tigris",
  "censusapi", 
  "tidycensus" 
)
lapply(packages, library, character.only = T)

## PATHS
wd <- getwd()

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
