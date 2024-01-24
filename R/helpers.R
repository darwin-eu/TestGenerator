# Helper Functions ------------
initTestCase <- function() {
  tableList <- list("PERSON",
                    "DRUG_EXPOSURE",
                    "OBSERVATION_PERIOD",
                    "CONDITION_OCCURRENCE",
                    "VISIT_OCCURRENCE",
                    "VISIT_DETAIL",
                    "DEATH")
  templateSql <- "TRUNCATE TABLE @cdm_database_schema.@table_name;"
  sql <- ""
  for (i in 1:length(tableList)) {
    if (i == 1) {
      sql <- SqlRender::render(sql=templateSql, table_name = tableList[i])
    } else {
      sql <- paste(sql, SqlRender::render(sql=templateSql, table_name = tableList[i]), sep="\n")
    }
  }
  return(paste0(sql, "\n\n"))
}

nullify <- function(val) {
  returnVal <- ifelse(is.null(val), 'NULL', val)
  if (is.character(val)) {
    returnVal = paste0('\'', val, '\'')
  }
  return(returnVal)
}
createCdmPerson <- function(person) {
  templateSql <- "INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT @person_id, @gender_concept_id, @year_of_birth, @race_concept_id, @ethnicity_concept_id, @person_source_value;"

  sql <- SqlRender::render(sql=templateSql,
                           person_id = person$person_id,
                           gender_concept_id = person$gender_concept_id,
                           year_of_birth = person$year_of_birth,
                           race_concept_id = person$race_concept_id,
                           ethnicity_concept_id = person$ethnicity_concept_id,
                           person_source_value = nullify(person$person_source_value))
  return(sql)
}
createCdmObservationPeriod <- function(op) {
  templateSql <- "INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT @observation_period_id, @person_id, '@observation_period_start_date', '@observation_period_end_date', @period_type_concept_id;"

  sql <- SqlRender::render(sql=templateSql,
                           observation_period_id = op$observation_period_id,
                           person_id = op$person_id,
                           observation_period_start_date = op$observation_period_start_date,
                           observation_period_end_date = op$observation_period_end_date,
                           period_type_concept_id = op$period_type_concept_id)
  return(sql)
}
createCdmDrugExposure <- function(de) {
  templateSql <- "INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT @drug_exposure_id, @person_id, @drug_concept_id, '@drug_exposure_start_date', '@drug_exposure_end_date', @quantity, @drug_type_concept_id;"

  sql <- SqlRender::render(sql=templateSql,
                           drug_exposure_id = de$drug_exposure_id,
                           person_id = de$person_id,
                           drug_concept_id = de$drug_concept_id,
                           drug_exposure_start_date = de$drug_exposure_start_date,
                           drug_exposure_end_date = de$drug_exposure_end_date,
                           quantity = de$quantity,
                           drug_type_concept_id = de$drug_type_concept_id)
  return(sql)
}
createCdmConditionOccurrence <- function (co) {
  templateSql <- "INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT @condition_occurrence_id, @person_id, @condition_concept_id, '@condition_start_date', @condition_type_concept_id, @condition_status_concept_id, @condition_source_concept_id;"

  sql <- SqlRender::render(sql=templateSql,
                           condition_occurrence_id = co$condition_occurrence_id,
                           person_id = co$person_id,
                           condition_concept_id = co$condition_concept_id,
                           condition_start_date = co$condition_start_date,
                           condition_type_concept_id = co$condition_type_concept_id,
                           condition_status_concept_id = co$condition_status_concept_id,
                           condition_source_concept_id = co$condition_source_concept_id)
  return(sql)
}

createCdmVisitOccurrence <- function (vo) {
  templateSql <- "INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT @visit_occurrence_id, @person_id, @visit_concept_id, '@visit_start_date', '@visit_end_date', @visit_type_concept_id, @visit_source_concept_id;"

  sql <- SqlRender::render(sql=templateSql,
                           visit_occurrence_id = vo$visit_occurrence_id,
                           person_id = vo$person_id,
                           visit_concept_id = vo$visit_concept_id,
                           visit_start_date = vo$visit_start_date,
                           visit_end_date = vo$visit_end_date,
                           visit_type_concept_id = vo$visit_type_concept_id,
                           visit_source_concept_id = vo$visit_source_concept_id)
  return(sql)
}

createCdmVisitDetail <- function (vd) {
  templateSql <- "INSERT INTO @cdm_database_schema.VISIT_DETAIL (visit_detail_id, person_id, visit_detail_concept_id, visit_detail_start_date, visit_detail_end_date, visit_detail_type_concept_id, visit_detail_source_concept_id)
                  SELECT @visit_detail_id, @person_id, @visit_detail_concept_id, '@visit_detail_start_date', '@visit_detail_end_date', @visit_detail_type_concept_id, @visit_detail_source_concept_id;"

  sql <- SqlRender::render(sql=templateSql,
                           visit_detail_id = vd$visit_detail_id,
                           person_id = vd$person_id,
                           visit_detail_concept_id = vd$visit_detail_concept_id,
                           visit_detail_start_date = vd$visit_detail_start_date,
                           visit_detail_end_date = vd$visit_detail_end_date,
                           visit_detail_type_concept_id = vd$visit_detail_type_concept_id,
                           visit_detail_source_concept_id = vd$visit_detail_source_concept_id)
  return(sql)
}

createCdmDeath <- function (de) {
  templateSql <- "INSERT INTO @cdm_database_schema.DEATH (person_id, death_date, death_type_concept_id, cause_concept_id, cause_source_value, cause_source_concept_id)
                  SELECT @person_id, '@death_date', @death_type_concept_id, @cause_concept_id, @cause_source_value, @cause_source_concept_id;"

  sql <- SqlRender::render(sql=templateSql,
                           person_id = de$person_id,
                           death_date = de$death_date,
                           death_type_concept_id = de$death_type_concept_id,
                           cause_concept_id = de$cause_concept_id,
                           cause_source_value = de$cause_source_value,
                           cause_source_concept_id = de$cause_source_concept_id)
  return(sql)
}

testCleanup <- function(tableList) {
  templateSql <- "TRUNCATE TABLE @cohort_database_schema.@table_name;\nDROP TABLE @cohort_database_schema.@table_name;\n"
  sql <- ""
  for (i in 1:length(tableList)) {
    sql <- paste(sql, SqlRender::render(sql=templateSql, table_name = tableList[i]), sep="\n")
  }
  return(sql)
}
