cdmTables <- convertIds(cdmTables)

# cdmTables[["visit_occurrence"]][["preceding_visit_occurrence_id"]]

# dictionary <- newIds(person_ids)

# person_ids <- cdmTables$person %>% pull(person_id) %>% unique()
# names(cdmTables)

persons <- cdmTables$person
# person_id

care_site <- cdmTables$care_site
# care_site_id

condition_era <- cdmTables$condition_era
names(condition_era)
# condition_era_id
# person_id

condition_occurrence <- cdmTables$condition_occurrence
names(condition_occurrence)
# condition_occurrence_id

death <- cdmTables$death
names(death)
# person_id

device_exposure <- cdmTables$device_exposure
names(device_exposure)
# device_exposure_id
# person_id
# visit_occurrence_id

dose_era <- cdmTables$dose_era
names(dose_era)
# dose_era_id
# person_id

drug_era <- cdmTables$drug_era
names(drug_era)
# drug_era_id
# person_id

drug_exposure <- cdmTables$drug_exposure
names(drug_exposure)
# drug_exposure_id
# person_id
# visit_occurrence_id

fact_relationship <- cdmTables$fact_relationship
names(fact_relationship)
# fact_id_1
# fact_id_2

measurement <- cdmTables$measurement
names(measurement)
# measurement_id
# person_id
# visit_occurrence_id

observation <- cdmTables$observation
names(observation)
# observation_id
# person_id
# visit_occurrence_id

observation_period <- cdmTables$observation_period
names(observation_period)
# observation_period_id
# person_id

persons <- cdmTables$person
names(persons)
# person_id

procedure_occurrence <- cdmTables$procedure_occurrence
names(procedure_occurrence)
# procedure_occurrence_id
# person_id
# visit_occurrence_id

specimen <- cdmTables$specimen
names(specimen)
# specimen_id
# person_id

visit_detail <- cdmTables$visit_detail
names(visit_detail)
# visit_detail_id
# person_id
# care_site_id
# visit_occurrence_id

visit_occurrence <- cdmTables$visit_occurrence
names(visit_occurrence)
# visit_occurrence_id
# person_id
# preceding_visit_occurrence_id

vocabulary <- cdmTables$vocabulary
names(vocabulary)
# vocabulary_concept_id

# cdm_source <- cdmTables$cdm_source
# location <- cdmTables$location

##  Vocab:
# concept <- cdmTables$concept
# concept_relationship <- cdmTables$concept_relationship




View(care_site)

result <- cdmTables$visit_occurrence %>%
  left_join(dictionary, by = c("person_id" = "person_id")) %>%
  mutate(person_id = number_id) %>%
  select(!number_id)

new_visit_ocu %>% pull(number_id)

unique(new_visit_ocu)


#
# person_ids <- cdmTables$person %>% pull(person_id) %>% unique()
#
# newIds <- function(ids) {
#
#   ids <- person_ids
#
#   dictionary <- data.frame(person_id = ids,
#                            number_id = 1:length(ids))
#
#   return(dictionary)
#
# }
#
#
# abs(column)
#
# numbers <- format(abs(column), scientific = FALSE, trim = TRUE)
#
# numbers <- substr(column, 1, 7)
#
# numbers <- as.numeric(column)
#
# assertTRUE(length(column) == length(column))
#
# table <- "person"
# column <- "person_id"
