test_that("workflow files created correctly in .github/workflows", {

  test_project <- file.path(
    tempdir(),
    "testgenerator-github-action-test"
  )
  unlink(
    test_project,
    recursive = TRUE
  )
  withr::defer(
    unlink(
      test_project,
      recursive = TRUE
    ),
    envir = testthat::teardown_env()
  )
  dir.create(
    test_project,
    recursive = TRUE
  )
  writeLines(
    c(
      "Package: testgeneratorActionTest",
      "Title: Test Project",
      "Version: 0.0.0.9000",
      "Description: Temporary project for TestGenerator tests.",
      "License: MIT",
      "Encoding: UTF-8"
    ),
    file.path(test_project, "DESCRIPTION")
  )
  usethis::local_project(
    test_project,
    .local_envir = testthat::teardown_env()
  )

  workflows_folder <- system.file(
    "workflows",
    package = "TestGenerator"
  )

  expect_true(
    dir.exists(workflows_folder)
    )

  dbms_types <- c(
    "postgresql",
    "sqlserver",
    "databricks"
    )

  workflow_files <- list.files(
    workflows_folder
    )

  github_folder <- usethis::proj_path(
    ".github",
    "workflows"
    )

  # Test individual workflow file creation
  for (i in 1:length(dbms_types)) {

    workflow_file_name <- stringr::str_subset(
      workflow_files,
      dbms_types[i]
    )

    destination_path <- file.path(
      github_folder,
      workflow_file_name
    )

    unlink(
      destination_path,
      recursive = TRUE
    )

    expect_false(
      checkmate::testFileExists(
        destination_path
      )
    )

    useGithubAction(
      dbms_type = dbms_types[i],
      overwrite = TRUE
      )

    expect_true(
      file.exists(destination_path)
      )

    unlink(
      destination_path,
      recursive = TRUE
    )

  }

  # Test all files were created at once
  useGithubAction()

  for (i in 1:length(workflow_files)) {

    path <- file.path(
      github_folder,
      workflow_files[i]
    )

    expect_true(
      file.exists(path)
    )

  }

  # Expect error if overwrite is FALSE
  expect_error(
    useGithubAction(
      overwrite = FALSE
      )
  )

  # Expect error if incorrect DBMS type
  expect_error(
    useGithubAction(
      dbms_type = c("sqlserver", "spark")
    )
  )

})
