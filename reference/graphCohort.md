# \`graphCohort()\` aids in the visualisation of cohorts timelines, useful to get a grip on intersections.

\`graphCohort()\` aids in the visualisation of cohorts timelines, useful
to get a grip on intersections.

## Usage

``` r
graphCohort(subject_id, cohorts = list())
```

## Arguments

- subject_id:

  Only one subject id per visualisation

- cohorts:

  List of cohorts

## Value

A ggplot graph

## Examples

``` r
hosptalised <- tibble::tibble(cohort_definition_id = 2,
                              subject_id = 1,
                              cohort_start_date = "2018-01-01",
                              cohort_end_date = "2018-01-10")

icu_patients <- tibble::tibble(cohort_definition_id = 5,
                              subject_id = 1,
                              cohort_start_date = "2018-01-02",
                              cohort_end_date = "2018-01-04")

drugs_treatment <- tibble::tibble(cohort_definition_id = 5,
                                  subject_id = 1,
                              cohort_start_date = "2018-01-07",
                              cohort_end_date = "2018-01-09")

TestGenerator::graphCohort(subject_id = 1, cohorts = list("hosptalised" = hosptalised,
                                                      "icu_patients" = icu_patients,
                                                      "drugs_treatment" = drugs_treatment))
#> Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
#> ℹ Please use `linewidth` instead.
#> ℹ The deprecated feature was likely used in the TestGenerator package.
#>   Please report the issue at
#>   <https://github.com/darwin-eu/TestGenerator/issues>.
#> Warning: Ignoring unknown aesthetics: fill
```
