#-------------------------------------------------------------------------------
# LINK CENSUS BLOCK GROUPS TO OTHER GEOGRAPHIES
# AUTHOR: Francine Stephens
# DATE CREATED: 3/4/21
# LAST UPDATED: 3/4/21
#-------------------------------------------------------------------------------

#SET-UP-------------------------------------------------------------------------
## LIBRARIES
packages <- c(
  "readr",
  "tidyverse",
  "sf",
  "tigris",
  "censusapi", 
  "tidycensus"
)
lapply(packages, library, character.only = T)

## PATHS
setwd("~/Shapefile_Repository")
wd <- getwd()
shp2010_path <- "/2010USA_CensusGeog_Shp"   # CHANGE
cbsa_path <- "/tl_2010_us_cbsa10/"          # CHANGE
metdiv_path <- "/tl_2010_us_metdiv10/"      # CHANGE
cbg_path <- "/us_blck_grp_2010/"            # CHANGE
places_path <- "/tl2010_us_place_2010/"     # CHANGE


## LOAD SHAPEFILES
cbg <- st_read(paste0(wd, 
                      shp2010_path,
                      cbg10_path,
                      "US_blck_grp_2010.shp"), 
               quiet = F)

place <- st_read(paste0(wd,
                        shp2010_path,
                        places10_path,
                        "US_place_2010.shp"), 
                 quiet = F)

cbsa <- st_read(paste0(wd, 
                       shp2010_path, 
                       cbsa_path, 
                       "tl_2010_us_cbsa10.shp"), 
                quiet = F)

metdiv <- st_read(paste0(wd,
                           shp2010_path, 
                           metdiv_path, 
                           "tl_2010_us_metdiv10.shp"), 
                  quiet = F)

#SELECT KEY GEOGRAPHIC IDENTIFIERS, RENAME & SET PROJECTION---------------------
cbg <- cbg %>%
  select(GEOID10, GISJOIN)

place <- place %>%
  select(PLACEID='GEOID10', PLACE_NM='NAMELSAD10') %>%
  st_transform(., st_crs(cbg))

cbsa <- cbsa %>% 
  select(CBSAFP10, CBSA_NM='NAMELSAD10') %>%
  st_transform(., st_crs(cbg))

metdiv <- metdiv %>%
  select(METDIVFP10, METDIV_NM='NAMELSAD10') %>%
  st_transform(., st_crs(cbg))


#PERFORM SPATIAL JOINS TO LINK HIGHER GEOGRAPHIES TO CBGs-----------------------

## CBGs IN CENSUS PLACES
cbg_joined_places <- cbg %>%
  st_join(., place, st_within) %>%
  st_set_geometry(NULL)

## CBGs IN CBSAs
cbg_joined_cbsa <- cbg %>% 
  st_join(., cbsa, st_within) %>%
  st_set_geometry(NULL)

## CBGs IN METDIVs
cbg_joined_metdivs <- cbg %>% 
  st_join(., metdiv, st_within) %>%
  st_set_geometry(NULL)


#JOIN ALL CBG-BASED JOINS-------------------------------------------------------
cbg_full_geog_identifiers <- plyr::join_all(
  list(cbg_joined_places,cbg_joined_cbsa,cbg_joined_metdivs), 
  by=c('GEOID10', 'GISJOIN'),
  type='left')


#EXPORT-------------------------------------------------------------------------
write.csv(cbg_full_geog_identifiers, "cbg_full_geog_identifers.csv", na="")
saveRDS(cbg_full_geog_identifiers, "cbg_full_geog_identifers.rds")
