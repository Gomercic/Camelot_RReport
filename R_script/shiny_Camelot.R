library('tidyverse')
library('sf')
library('zoo')
library(suncalc)
# input variables -- folder name, start date, end date, Survey Name, aggregation time


# import "Full Export" from report Camelot (that include all Surveys)
full_export_Camelot <- read_csv(file = "full_export.csv")
filter <- read_csv(file = "filter.csv")

# replace space in Column name with _
a <- {full_export_Camelot %>% select_all(~gsub("\\s+|\\.", "_", .))}
a$'Date/Time' <- ymd_hms(a$`Date/Time`, tz=filter$TZ)
a <- a %>% 
  rename(Species = Species___52) %>% 
  replace_na(list(Life_stage = 'Adult')) %>% 
  filter(!is.na(`Date/Time`))

# *************** filter time interval *************************
# a <- a %>% filter(`Date/Time` >= ymd("2021-01-14"), `Date/Time` <= ymd("2021-04-30"))
if (!is.na(filter$start)) {a <- a %>% filter(`Date/Time` >= ymd(filter$start))} else {}
if (!is.na(filter$end)) {a <- a %>% filter(`Date/Time` <= ymd(filter$end))} else {}


if (is.na(filter$survey_01)) {
} else {
a <- a %>% filter(Survey_Name == filter$survey_01 |
                    Survey_Name == filter$survey_02 |
                    Survey_Name == filter$survey_03 |
                    Survey_Name == filter$survey_04 |
                    Survey_Name == filter$survey_05)
}


# list of Trap_Station_Name and active intervals
trap_station_interval <- a %>% 
  select("Trap_Station_Name",
         "Camelot_GPS_Latitude",
         "Camelot_GPS_Longitude",
         "Survey_Name",
         "Session_Start_Date",
         "Session_End_Date") %>% 
  group_by(Survey_Name, Trap_Station_Name, Session_Start_Date) %>% 
  summarise(Session_End_Date =mean(Session_End_Date),
            Camelot_GPS_Latitude = mean(Camelot_GPS_Latitude),
            Camelot_GPS_Longitude = mean(Camelot_GPS_Longitude)) %>% 
  arrange(Trap_Station_Name, Session_Start_Date) %>% 
  mutate(activ_days = difftime(Session_End_Date, Session_Start_Date, units = "days"))


start_date <- as.Date(trap_station_interval$Session_Start_Date)
end_date <- as.Date(trap_station_interval$Session_End_Date)

trap_station_interval$xxx <-  ifelse(start_date == lag(end_date), 1, 0)
trap_station_interval <- trap_station_interval %>% 
  mutate(xxx = ifelse(is.na(xxx), 0, xxx)) %>% 
  relocate(xxx, .after = Trap_Station_Name) %>% 
  arrange(Trap_Station_Name, Session_Start_Date)


x01 <- trap_station_interval
trap_station_interval_2 <- x01[1,]
for(i in 2:nrow(x01)) {
  tmp <- x01[i,]
  ifelse (x01[i,3] == 0, 
          trap_station_interval_2 <- rbind(trap_station_interval_2, tmp), 
          ifelse (x01[i,2] != x01[i-1,2],
                  trap_station_interval_2 <- rbind(trap_station_interval_2, tmp),
                  trap_station_interval_2[nrow(trap_station_interval_2),]$Session_End_Date <- tmp$Session_End_Date)
)
          }

trap_station_interval_2 <- trap_station_interval_2 %>% 
  select(-c(xxx, activ_days))

write.csv(trap_station_interval_2, "trap_station_interval.csv")

# list of Trap_Station_Name **************************
trap_station_start_end <- a %>% 
  select("Trap_Station_Name",
         "Camelot_GPS_Latitude",
         "Camelot_GPS_Longitude",
         "Session_Start_Date",
         "Session_End_Date") %>% 
  arrange(Trap_Station_Name,Session_Start_Date,Session_End_Date) %>% 
  group_by(Trap_Station_Name) %>% 
  summarise(Session_Start_Date2 =first(Session_Start_Date),
            Session_End_Date2 =last(Session_End_Date),
            Camelot_GPS_Latitude =mean(Camelot_GPS_Latitude),
            Camelot_GPS_Longitude =mean(Camelot_GPS_Longitude))

write.csv(trap_station_start_end, "trap_station_name.csv")

trap_list_GIS <- trap_station_start_end %>% 
  mutate(lon = Camelot_GPS_Longitude, lat = Camelot_GPS_Latitude) %>% 
  st_as_sf(coords = c("lon", "lat"), crs = 4326)  # crate point layer WGS84

st_write(trap_list_GIS, "trap_station_list.gpkg", driver="GPKG", append=FALSE)
# *******************************************************

# Start and End Survey
survey_start_end <- a %>% 
  select(Survey_Name,
         Session_Start_Date,
         Session_End_Date) %>% 
  group_by(Survey_Name) %>%
  summarise(Session_Start_Date3=min(Session_Start_Date),
            Session_End_Date3=max(Session_End_Date))

start_project <-  min(a$Session_Start_Date) 
end_project <- max(a$Session_End_Date)
month_seq <-  seq(start_project, end_project, by = "month")
month_int <-  interval(floor_date(month_seq, "month"), (ceiling_date(month_seq, "month")))


# MZ Camera Trap activity per month--------------------------------------------------------
DT <- trap_station_interval %>% 
  select(Survey_Name,
         id="Trap_Station_Name",
         GPS_Lat="Camelot_GPS_Latitude",
         GPS_Lon="Camelot_GPS_Longitude",
         start="Session_Start_Date",
         end="Session_End_Date",
  ) %>% 
  mutate(period = end - start)

DT$gap_test <- TRUE

for(i in 2:nrow(DT)) {
   if (DT[i,]$id == DT[i-1,]$id && DT[i,]$start != DT[i-1,]$end) {
    DT[i,]$gap_test <- FALSE
  }
}

DT <- DT %>% mutate(inter = interval(start, end))

for (i in 1:length(month_int)) {
 column_name <- as.character(month_int[i])
  column_name <- as.character(floor_date(month_seq[i], "month"))
  DT$temp <- intersect(DT$inter, month_int[i]) %>% 
    as.duration() %>% 
    as.numeric("days")
  names(DT)[names(DT) == "temp"] <- column_name
}

DT_id <- DT %>%
  ungroup() %>%
  group_by(id) %>% 
  mutate(across(.cols = 10: ncol(DT)-1,
                ~replace(., is.na(.), 0))) %>% 
  summarise(GPS_Lat=mean(GPS_Lat),
            GPS_Lon=mean(GPS_Lon),
            across(.cols = 10: ncol(DT)-1, 
                   .fns = sum),
            )
DT_id <- DT_id %>%
  mutate(sum_activ_days = rowSums(across(4:ncol(DT_id)))) %>% 
  relocate(sum_activ_days, .after = GPS_Lon)

write.csv(DT_id, "trap_station_activity_per_month.csv")
# *********************************camera trap activity END



# ****************** objedinjavanje unutar vremenskog intervala 10 min
# definiranje vremenskog agregacijskog intervala (10 min)
time_aggregation_period_seconds <- filter$agg_time

# stvaranje dedupliciranih vremenskih grupa unutar "Trap_Station_Name"-"Species"-"Life_stage" grupa
a_deduplicated_time_groups <- a %>% 
  arrange(Trap_Station_Name, Species_ID, `Date/Time`) %>%
  group_by(Trap_Station_Name, Species_ID) %>%
  mutate(prev_date_time = lag(`Date/Time`, n = 1L),
         prev_diff_seconds = `Date/Time` - prev_date_time,
         initial_time_group = row_number(),
         deduplicated_time_group = if_else(prev_diff_seconds > time_aggregation_period_seconds | is.na(prev_diff_seconds), initial_time_group, NA_integer_),
         deduplicated_time_group = na.locf(deduplicated_time_group)) %>%
  ungroup()

a <- a_deduplicated_time_groups %>%
  arrange(Trap_Station_Name, Species_ID, deduplicated_time_group, desc(coalesce(Sighting_Quantity, 0)), `Date/Time`, Life_stage) %>%
  group_by(Trap_Station_Name, Species_ID, deduplicated_time_group) %>%
  mutate(Subadult_Quantity = max(if_else(Life_stage == "Juvenile", coalesce(Sighting_Quantity, 0), 0)),
         Total_Quantity = max(if_else(Life_stage == "Juvenile", coalesce(Sighting_Quantity, 0), 0)) + max(if_else(Life_stage == "Adult", coalesce(Sighting_Quantity, 0), 0)),
         deduplication_rank = row_number()) %>%
  filter(deduplication_rank == 1) %>%
  ungroup() %>%
  select(-Life_stage, -Sighting_Quantity, -prev_date_time, -prev_diff_seconds, -initial_time_group, -deduplicated_time_group, -deduplication_rank)

remove(a_deduplicated_time_groups)

# ********************************** END DEDUPLICIRANJE **************************

# ***********Moon illuninosity, Dawn, Dusk ********************************
moon_illum <-  getMoonIllumination(date = as.Date(a$'Date/Time'), keep = c("fraction"))
a$moon_illum <- moon_illum$fraction

data_tmp <- data.frame(date = as.Date(a$`Date/Time`),
                   lat = a$Camelot_GPS_Latitude,
                   lon = a$Camelot_GPS_Longitude)
dusk_dawn <- getSunlightTimes(data = data_tmp, 
                              keep = c("dawn", "dusk"), tz = Sys.timezone())
dusk_dawn$day_long <- as.numeric(dusk_dawn$dusk - dusk_dawn$dawn)
a$dawn <- dusk_dawn$dawn
a$dusk <- dusk_dawn$dusk

dusk_dawn$dusk <- period_to_seconds(hms(format(dusk_dawn$dusk, format = "%H:%M:%S")))
dusk_dawn$dawn <- period_to_seconds(hms(format(dusk_dawn$dawn, format = "%H:%M:%S")))
dusk_dawn$date_time_sec <- period_to_seconds(hms(format(a$'Date/Time', format = "%H:%M:%S")))

dusk_dawn$part_of_day <- with(dusk_dawn, ifelse(date_time_sec < dawn,
                                                (86400 - dusk + date_time_sec) / (86400 - dusk + dawn) * -1, 
                                                ifelse(date_time_sec >= dawn &  date_time_sec <= dusk,
                                                       (date_time_sec - dawn) / (dusk - dawn),
                                                       ifelse(date_time_sec >= dusk,
                                                              (date_time_sec - dusk) / (86400 - dusk + dawn) * -1,
                                                              0))))
dusk_dawn <- dusk_dawn %>% 
  mutate(part_of_day2 = (part_of_day + 1) * 0.5) %>%
  mutate(part_of_day3 = part_of_day2 - 0.25) %>% 
  mutate(part_of_day3 = ifelse(part_of_day3 <= 0, part_of_day3 + 1, part_of_day3)) # !!!!!!! TREBA PROVJERITI !!!!!!!
a$part_of_day2 <- dusk_dawn$part_of_day2
a$part_of_day3 <- dusk_dawn$part_of_day3

b <- a %>% 
  select(Trap_Station_Name, Camelot_GPS_Latitude, Camelot_GPS_Longitude, Species, `Date/Time`,
         Total_Quantity, Subadult_Quantity, moon_illum, part_of_day3) %>% 
  arrange(Trap_Station_Name, `Date/Time`, Species)
write.csv(b, "aggregation_events.csv")
write.csv(a, "aggregation_events_full.csv")

# *********************************************************

# long pivot aktivnost Trap_Station_Name po mjesecima
DT_id_long <- DT_id %>% 
  select(- GPS_Lat, - GPS_Lon, - sum_activ_days) %>% 
  pivot_longer(!id, names_to = "month", values_to = "count") %>% 
  mutate(month_year = as.yearmon(month, "%Y-%m")) %>% 
  group_by(month_year) %>%  
  summarise(active_days=sum(count))

sum_activ_days <- as.integer(sum(DT_id$sum_activ_days))

count_of_species <- b %>%
  group_by(Species) %>% 
  summarise(event = n(),
            Total_Quantity = sum(Total_Quantity),
            Subadult_Quantity = sum(Subadult_Quantity))

count_of_species <- count_of_species %>% 
  mutate(Total_Quantity_per_30_days = Total_Quantity / sum_activ_days * 30,
         Total_Subadults_per_30_days = Subadult_Quantity / sum_activ_days * 30)
  
write.csv(count_of_species, "count_of_species.csv")

# APSOLUTNI broj videnja vrste po mjesecima
species_activity_per_months <- b %>% 
  select(Species, Trap_Station_Name, "Date/Time", Total_Quantity, Subadult_Quantity) %>% 
  mutate(month_year = as.yearmon(`Date/Time`, format = "%Y-%m")) %>%
  filter(!is.na(`Date/Time`), !is.na(Species))  %>% 
  group_by(Species, month_year) %>% 
  summarise(Events=n(),
            Total_animals = sum(Total_Quantity),
            Subadult_animals = sum(Subadult_Quantity))


# RELATIVE number of sighting per day per month for species for each month
species_activity_per_months <- species_activity_per_months %>% 
  left_join(select(DT_id_long, month_year, active_days)) %>% 
  mutate(sighting_per_day = Events / active_days,
         sighting_per_month = sighting_per_day * days_in_month(month_year),
         animals_per_day = Total_animals / active_days,
         animals_per_month = animals_per_day * days_in_month(month_year),
         subadult_animals_per_day = Subadult_animals / active_days,
         subadult_animals_per_month = subadult_animals_per_day * days_in_month(month_year),
         month = format(month_year, format = "%m"),
         year = format(month_year, format = "%Y")) %>% 
  relocate(month, .after = "month_year") %>% 
  relocate(year, .after = "month") %>% 
  arrange(Species, month_year)

species_activity_per_months2 <- species_activity_per_months %>% 
  mutate(month_year= as.character(format(month_year, format = "%Y-%m")))

write.csv(species_activity_per_months2, "species_activity_per_months.csv")


# za crtanje grafa po mjesecima sumarno
species_activity_per_sum_months <- species_activity_per_months %>% 
  group_by(Species, month) %>% 
  summarise(sighting_per_30_days = mean(sighting_per_month),
            apsolut_sighting = mean(Events),
            animals_per_30_days = mean(animals_per_month),
            subadult_animals_per_30_days = mean(subadult_animals_per_month))

write.csv(species_activity_per_sum_months, "species_activity_per_sum_months.csv")

# za crtanje grafa po godinama
species_activity_per_years <- species_activity_per_months %>% 
  group_by(Species, year) %>% 
  summarise(sighting_per_30_days = mean(sighting_per_month),
            apsolut_sighting = mean(Events),
            animals_per_30_days = mean(animals_per_month),
            subadult_animals_per_30_days = mean(subadult_animals_per_month))

write.csv(species_activity_per_years, "species_activity_per_years.csv")








