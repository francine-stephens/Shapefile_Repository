###########################
# OUTPUT CENSUS GEOGRAPHY
# 
# DATE CREATED: 2/9/21
# LAST UPDATED: 2/25/21
###########################

## LIBRARIES
packages <- c(
  "tidyverse",
  "sf",
  "ggplot2",
  "scales",
  "tigris",
  "censusapi", 
  "tidycensus", 
  "tidygeocoder"
)
lapply(packages, library, character.only = T)

## PATHS
wd <- getwd()

shp2010_path <- "/2010USA_CensusGeog_Shp"
cbsa_path <- "/tl_2010_us_cbsa10/"
metdiv_path <- "/tl_2010_us_metdiv10/"
cbg10_path <- "/us_blck_grp_2010/"
#bg_10_2000_path <- "/nhgis0016_shapefile_tl2010_us_blck_grp_2000/"

# APIs
census_api_key("99ccb52a629609683f17f804ca875115e3f0804c",  overwrite = T)
Sys.setenv(CENSUS_KEY="99ccb52a629609683f17f804ca875115e3f0804c")


## Load census blocks
census_bg10 <-
  block_groups(cb = T, progress_bar = F, year = 2010) %>%
  st_transform(crs = 4326)

## LOAD SHAPEFILES
cbsa10 <- st_read(paste0(wd,
               shp2010_path, 
               cbsa_path, 
               "tl_2010_us_cbsa10.shp"),
        quiet = F)

metdiv10 <- st_read(paste0(wd,
                           shp2010_path, 
                           metdiv_path, 
                           "tl_2010_us_metdiv10.shp"),
                    quiet = F)

cbg_2010 <- st_read(paste0(wd,
                              shp2010_path,
                              cbg10_path,
                              "US_blck_grp_2010.shp"),
                       quiet = F)



## Decennial Census-------------------------------------------------------------
# Pull Decennial Census population counts by state
cbsa10_pop <- get_decennial(geography = "cbsa", 
                           variables = "P001001",
                           year = 2010) # default is 2010

top100_cbsa <- cbsa10_pop %>%
  arrange(-value) %>%
  slice(1:100) 

top100_metros_pop_graph <- top100_cbsa %>%
  mutate(NAME = str_remove(NAME, "Metro Area")) %>%
  ggplot(aes(x = value, y = reorder(NAME, value))) + 
  geom_point(color = "#041e42") + 
  labs(
    x = "Population",
    y = "Metro Area",
    title = "Top 100 Metros: 2010 Metro Area Population",
    caption = "2010 Census Data"
  ) + 
  scale_x_continuous(labels = unit_format(unit = "M", scale = 1e-6),
                     breaks=pretty_breaks(n=8)) +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 5),
        axis.text.x = element_text(angle = 45, hjust=0.75)
       # panel.background = element_rect(")
        )

ggsave(filename = "top100_metro_pop.jpeg",
       plot = top100_metros_pop_graph,
       width = 6,
       height = 6,
       units = "in")

## EXPORT CBGs in TOP 100 METROS
top100_cbsa_sf <- cbsa10 %>%
  filter(GEOID10 %in% top100_cbsa$GEOID)

top100_cbsa_cbgs <- cbg_2010 %>%
  st_transform(., st_crs(top100_cbsa_sf)) %>%
  st_join(., top100_cbsa_sf, st_within)

top100_cbsa_cbgs_for_export <- top100_cbsa_cbgs %>%
  filter(!is.na(GEOID10.y)) %>%
  select(GEOID10.x, GISJOIN, CBSAFP10, NAME10) %>%
  rename(GEOID10 = "GEOID10.x")

st_write(top100_cbsa_cbgs_for_export, paste0(wd,
                                             shp2010_path,
                                             "/top100_cbsa_blck_grp_2010/",
                                             "blck_grps_in_top_100_metros_2010.shp"))


## EXPORT NON-TOP 100 CBGs
small_cbsa_cbgs_for_export <- top100_cbsa_cbgs %>%
  filter(is.na(GEOID10.y)) %>%
  select(GEOID10.x, GISJOIN, CBSAFP10, NAME10) %>%
  rename(GEOID10 = "GEOID10.x")

st_write(small_cbsa_cbgs_for_export, paste0(wd,
                                             shp2010_path,
                                             "/top100_cbsa_blck_grp_2010/",
                                             "blck_grps_in_top_100_metros_2010.shp"))
