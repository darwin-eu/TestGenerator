TRUNCATE TABLE @cdm_database_schema.PERSON;
TRUNCATE TABLE @cdm_database_schema.DRUG_EXPOSURE;
TRUNCATE TABLE @cdm_database_schema.OBSERVATION_PERIOD;
TRUNCATE TABLE @cdm_database_schema.CONDITION_OCCURRENCE;
TRUNCATE TABLE @cdm_database_schema.VISIT_OCCURRENCE;


INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT 1, 8532, 1980, 0, 0, NULL;
INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT 2, 8507, 1980, 0, 0, NULL;
INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT 3, 8532, 1965, 0, 0, NULL;
INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT 4, 8532, 2010, 0, 0, NULL;
INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT 5, 8532, 1936, 0, 0, NULL;
INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT 6, 8532, 1970, 0, 0, NULL;
INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT 7, 8532, 1988, 0, 0, NULL;
INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT 8, 8507, 1998, 0, 0, NULL;
INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT 9, 8507, 1990, 0, 0, NULL;
INSERT INTO @cdm_database_schema.PERSON (person_id, gender_concept_id, year_of_birth, race_concept_id, ethnicity_concept_id, person_source_value)
                  SELECT 10, 8532, 1945, 0, 0, NULL;
INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT 1, 1, '2000-01-01', '2002-01-01', 32880;
INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT 2, 2, '2000-01-01', '2002-01-10', 32880;
INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT 3, 3, '2010-01-01', '2017-11-01', 32880;
INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT 4, 4, '2010-05-01', '2020-06-05', 32880;
INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT 5, 5, '1990-06-01', '2015-04-01', 32880;
INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT 6, 6, '2005-03-05', '2023-01-01', 32880;
INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT 7, 7, '2019-01-01', '2022-12-30', 32880;
INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT 8, 8, '2013-09-10', '2022-06-01', 32880;
INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT 9, 9, '2018-07-01', '2022-12-01', 32880;
INSERT INTO @cdm_database_schema.OBSERVATION_PERIOD (observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
                  SELECT 10, 10, '2000-01-01', '2019-03-07', 32880;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 1, 1, 1316262, '2005-01-01', '2005-01-31', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 2, 1, 1316262, '2005-02-01', '2005-03-03', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 3, 1, 1316262, '2005-03-06', '2005-04-05', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 4, 1, 1337068, '2005-03-20', '2005-05-19', 60, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 5, 2, 1337068, '2001-07-16', '2001-09-14', 60, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 6, 3, 19098071, '2016-03-06', '2016-04-05', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 7, 3, 19098071, '2016-06-05', '2016-07-05', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 8, 4, 19098072, '2016-01-01', '2016-03-31', 90, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 9, 4, 19098072, '2016-02-01', '2016-03-02', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 10, 5, 1316262, '1995-01-01', '1995-01-31', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 11, 5, 1316262, '2013-06-01', '2013-07-01', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 12, 5, 1316262, '2013-07-05', '2013-08-04', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 13, 5, 1337068, '2014-12-01', '2014-12-31', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 14, 6, 21065940, '2022-12-01', '2023-03-01', 90, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 15, 7, 792987, '2019-03-05', '2019-04-04', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 16, 7, 792987, '2022-05-01', '2022-05-31', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 17, 8, 1316262, '2015-08-05', '2015-10-04', 60, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 18, 9, 1442132, '2020-03-01', '2020-05-30', 90, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 19, 9, 1337068, '2020-03-01', '2020-03-31', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 20, 9, 1321636, '2020-04-01', '2020-06-30', 90, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 21, 9, 792987, '2020-09-01', '2020-10-01', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 22, 10, 1336926, '1998-02-01', '1998-04-12', 70, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 23, 10, 1336926, '2002-07-01', '2002-07-31', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 24, 10, 1337068, '2015-03-01', '2015-03-31', 30, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 25, 8, 1103314, '2020-07-01', '2020-07-11', 10, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 26, 7, 1103314, '2018-07-01', '2018-07-11', 10, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 27, 1, 19048353, '2004-12-31', '2005-01-10', 10, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 28, 4, 792987, '2015-06-01', '2015-06-11', 10, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 29, 7, 19096757, '2018-07-01', '2018-07-11', 10, 0;
INSERT INTO @cdm_database_schema.DRUG_EXPOSURE (drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date, drug_exposure_end_date, quantity, drug_type_concept_id)
                  SELECT 30, 10, 44506614, '2015-03-01', '2015-03-31', 30, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 1, 1, 4013643, '38352', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 2, 2, 4013643, '37073', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 3, 3, 4013643, '42436', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 4, 4, 4013643, '42255', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 5, 5, 4013643, '41426', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 6, 6, 4013643, '44866', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 7, 7, 4013643, '43525', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 8, 9, 44782560, '43831', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 9, 10, 4013643, '35796', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 10, 10, 4013643, '37506', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 11, 10, 44783621, '42005', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 12, 4, 255573, '42125', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 13, 4, 316139, '42255', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 14, 4, 3223886, '42370', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 15, 7, 46271022, '43501', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 16, 7, 440417, '43101', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 17, 7, 320128, '43586', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 18, 7, 440417, '43585', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 19, 10, 4306655, '43531', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 20, 3, 134057, '30/8/2017', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 21, 4, 134057, '20/3/2022', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 22, 5, 134057, '28/12/2014', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 23, 6, 134057, '44722', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 24, 7, 134057, '44783', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 25, 9, 134057, '44721', 32817, 0, 0;
INSERT INTO @cdm_database_schema.CONDITION_OCCURRENCE (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_type_concept_id, condition_status_concept_id, condition_source_concept_id)
                  SELECT 26, 10, 134057, '30/12/2018', 32817, 0, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 1, 1, 32693, '2004-12-31', 2004-12-31, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 2, 2, 262, '2001-07-01', 2001-07-10, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 3, 3, 32693, '2016-03-07', 2016-03-07, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 4, 4, 262, '2015-09-08', 2015-09-18, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 5, 5, 32693, '2013-06-01', 2013-06-01, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 6, 6, 32760, '2022-11-01', 2022-11-05, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 7, 7, 262, '2019-03-01', 2019-03-14, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 8, 9, 38004515, '2020-01-01', 2020-01-01, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 9, 10, 9203, '1998-01-01', 1998-01-01, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 10, 10, 9201, '2002-09-07', 2002-09-17, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 11, 10, 9201, '2015-01-01', 2015-01-12, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 12, 4, 262, '2015-05-01', 2015-05-12, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 13, 4, 9203, '2015-09-08', 2015-09-08, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 14, 4, 38004515, '2016-01-01', 2016-01-01, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 15, 7, 9203, '2019-02-05', 2019-02-05, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 16, 7, 9203, '2018-01-01', 2018-01-01, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 17, 7, 9201, '2019-05-01', 2019-05-12, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 18, 7, 38004515, '2019-04-30', 2019-04-30, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 19, 10, 262, '2019-03-07', 2019-03-09, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 20, 3, 9203, '2017-09-01', 2017-10-01, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 21, 4, 9201, '2020-03-01', 2020-03-31, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 22, 5, 9201, '2015-01-01', 2015-01-31, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 23, 6, 9203, '2022-01-10', 2022-02-09, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 24, 7, 9203, '2022-01-10', 2022-02-09, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 25, 9, 9203, '2022-01-09', 2022-02-08, 32817, 0;
INSERT INTO @cdm_database_schema.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_end_date, visit_type_concept_id, visit_source_concept_id)
                  SELECT 26, 10, 9201, '2019-01-01', 2019-01-31, 32817, 0;