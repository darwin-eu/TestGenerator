# Internal: create test CDM on a remote database
.patientsCDM_remote <- function(pathJson, testName, cdmVersion, cdmName, dbms, writeSchema = NULL) {

  n_steps <- 5L

  # ---- Step 1: Create local DuckDB CDM ----
  cli::cli_progress_step("Step 1/{n_steps}: Creating local DuckDB test CDM")
  local_cdm <- patientsCDM(
    pathJson = pathJson,
    testName = testName,
    cdmVersion = cdmVersion,
    cdmName = cdmName,
    dbms = "duckdb"
  )

  # Track the duckdb file path so we can clean it up later
  local_con <- CDMConnector::cdmCon(local_cdm)
  duckdb_path <- local_con@driver@dbdir

  # ---- Step 2: Trim vocabulary ----
  cli::cli_progress_step("Step 2/{n_steps}: Trimming vocabulary")
  local_cdm <- CDMConnector::cdmTrimVocabulary(local_cdm)

  # ---- Step 3: Connect to remote database and create schema ----
  remote_con <- .connect_remote(dbms)
  if (!is.null(writeSchema)) {
    cli::cli_progress_step("Step 3/{n_steps}: Connecting to {dbms} using schema {.val {writeSchema}}")
    test_schema <- writeSchema
  } else {
    cli::cli_progress_step("Step 3/{n_steps}: Connecting to {dbms} and creating test schema")
    test_schema <- .create_test_schema(remote_con, dbms)
    cli::cli_alert_info("Created test schema: {.val {paste(test_schema, collapse = '.')}}")
  }

  # ---- Step 4: Upload CDM to remote database ----
  cli::cli_progress_step("Step 4/{n_steps}: Uploading test CDM to {dbms}")
  cdm_remote <- CDMConnector::copyCdmTo(
    con = remote_con,
    cdm = local_cdm,
    schema = test_schema,
    overwrite = TRUE
  )

  # ---- Step 5: Create CDM referemce ----

  cdm <- CDMConnector::cdmFromCon(
    con = remote_con,
    cdmSchema = test_schema,
    writeSchema = test_schema,
    cdmName = cdmName,
    cdmVersion = cdmVersion
  )

  # ---- Step 6: Clean up local DuckDB resources ----
  cli::cli_progress_step("Step 5/{n_steps}: Cleaning up local DuckDB files")
  DBI::dbDisconnect(local_con, shutdown = TRUE)

  # Remove duckdb file and any WAL files
  if (nzchar(duckdb_path) && file.exists(duckdb_path)) {
    unlink(duckdb_path)
    unlink(paste0(duckdb_path, ".wal"))
  }

  cli::cli_alert_success("Remote test CDM ready on {dbms}")
  return(cdm)
}

# Internal: early check that required env vars are set before doing any work
.check_remote_env_vars <- function(dbms) {
  required_vars <- switch(dbms,
                          "sqlserver" = c(
                            "SQLSERVER_SERVER",
                            "SQLSERVER_DBNAME",
                            "SQLSERVER_PORT",
                            "SQLSERVER_USER",
                            "SQLSERVER_PASSWORD"
                          ),
                          "postgresql" = c(
                            "POSTGRESQL_SERVER",
                            "POSTGRESQL_DBNAME",
                            "POSTGRESQL_PORT",
                            "POSTGRESQL_USER",
                            "POSTGRESQL_PASSWORD"
                          ),
                          "databricks" = c(
                            "DATABRICKS_HOST",
                            "DATABRICKS_TOKEN",
                            "DATABRICKS_HTTPPATH"
                          )
  )
  .check_env_vars(required_vars, dbms)
}

# Internal: connect to a remote database using environment variables
.connect_remote <- function(dbms) {
  switch(dbms,
         "sqlserver" = .connect_sqlserver(),
         "databricks" = .connect_databricks(),
         "postgresql" = .connect_postgresql(),
         cli::cli_abort("Unsupported dbms: {.val {dbms}}")
  )
}

.connect_sqlserver <- function() {
  required_vars <- c(
    "SQLSERVER_SERVER",
    "SQLSERVER_DBNAME",
    "SQLSERVER_PORT",
    "SQLSERVER_USER",
    "SQLSERVER_PASSWORD"
  )
  .check_env_vars(required_vars, "SQL Server")

  DBI::dbConnect(
    odbc::odbc(),
    Driver   = Sys.getenv("SQL_SERVER_DRIVER", "ODBC Driver 18 for SQL Server"),
    Server   = Sys.getenv("SQLSERVER_SERVER"),
    Database = Sys.getenv("SQLSERVER_DBNAME"),
    UID      = Sys.getenv("SQLSERVER_USER"),
    PWD      = Sys.getenv("SQLSERVER_PASSWORD"),
    TrustServerCertificate = "yes",
    Port     = Sys.getenv("SQLSERVER_PORT")
  )
}

.connect_postgresql <- function() {
  required_vars <- c(
    "POSTGRESQL_SERVER",
    "POSTGRESQL_DBNAME",
    "POSTGRESQL_PORT",
    "POSTGRESQL_USER",
    "POSTGRESQL_PASSWORD"
  )
  .check_env_vars(required_vars, "Postgresql")

  portStr <- trimws(Sys.getenv("POSTGRESQL_PORT"))
  if (!grepl("^[0-9]+$", portStr)) {
    cli::cli_abort(
      "{.envvar POSTGRESQL_PORT} must be a valid integer for PostgreSQL."
    )
  }
  port <- as.integer(portStr)

  DBI::dbConnect(
    RPostgres::Postgres(),
    host     = Sys.getenv("POSTGRESQL_SERVER"),
    dbname   = Sys.getenv("POSTGRESQL_DBNAME"),
    port     = port,
    user     = Sys.getenv("POSTGRESQL_USER"),
    password = Sys.getenv("POSTGRESQL_PASSWORD")
  )
}

.connect_databricks <- function() {
  required_vars <- c(
    "DATABRICKS_HOST",
    "DATABRICKS_TOKEN",
    "DATABRICKS_HTTPPATH",
    "DATABRICKS_USER"
  )
  .check_env_vars(required_vars, "Databricks")

  DBI::dbConnect(
    drv = odbc::odbc(),
    Driver = "Databricks ODBC Driver",
    Host = sub("^https://", "", Sys.getenv("DATABRICKS_HOST")),
    Port = 443,
    SSL = 1,
    ThriftTransport = 2,
    SparkServerType = 3,
    AuthMech = 3,
    HTTPPath = Sys.getenv("DATABRICKS_HTTPPATH"),
    UID = Sys.getenv("DATABRICKS_USER", "token"),
    PWD = Sys.getenv("DATABRICKS_TOKEN"),
    UseNativeQuery = 0,
    bigint = "numeric"
  )
}

# Internal: check that required environment variables are set
.check_env_vars <- function(vars, label) {
  missing <- vars[!nzchar(Sys.getenv(vars))]
  if (length(missing) > 0) {
    bullets <- stats::setNames(missing, rep("*", length(missing)))
    cli::cli_abort(c(
      "Missing required environment variables for {label}:",
      bullets,
      "i" = "Set them in your {.file .Renviron} by running {.code usethis::edit_r_environ()}"
    ))
  }
}

# Internal: create a unique test schema on the remote database
.create_test_schema <- function(con, dbms) {
  schema_name <- paste0("cdm_testgenerator_", format(Sys.time(), "%Y%m%d_%H%M%S"), "_", sample(1000:9999, 1))

  switch(dbms,
         "sqlserver" = {
           DBI::dbExecute(con, paste("CREATE SCHEMA", schema_name))
           schema_name
         },
         "postgresql" = {
           DBI::dbExecute(con, paste("CREATE SCHEMA", schema_name))
           schema_name
         },
         "databricks" = {
           catalog <- Sys.getenv("DATABRICKS_WORKSPACE", "hive_metastore")
           schema <- c(catalog = catalog, schema = schema_name)
           DBI::dbExecute(con, paste0(
             "CREATE SCHEMA IF NOT EXISTS ",
             paste(schema, collapse = ".")
           ))
           schema
         }
  )
}

#' Clean up a test CDM on a remote database
#'
#' Drops the schema containing the test CDM and disconnects from the database.
#'
#' @param cdm A CDM reference object created by \code{patientsCDM()} with a
#'   remote database backend.
#'
#' @return Invisibly returns NULL.
#' @export
cleanupTestCdm <- function(cdm) {
  con <- CDMConnector::cdmCon(cdm)
  schema <- CDMConnector::cdmWriteSchema(cdm)
  writeSchema <- paste(schema, collapse = ".")
  dbms_class <- class(con)

  if (!grepl("testgenerator", writeSchema, ignore.case = TRUE)) {
    cli::cli_abort("Refusing to drop schema {.val {writeSchema}} because it does not contain {.val testgenerator} in the name.")
  }

  if (any(grepl("OdbcConnection", dbms_class)) || any(grepl("Microsoft SQL Server", dbms_class))) {
    # SQL Server: drop all tables first, then drop schema
    tables <- CDMConnector::listTables(con, schema = schema)
    schema_name <- if (length(schema) == 1) schema else schema[length(schema)]
    for (tbl in tables) {
      tryCatch(
        DBI::dbExecute(con, paste0("DROP TABLE IF EXISTS ", schema_name, ".", tbl)),
        error = function(e) NULL
      )
    }
    DBI::dbExecute(con, paste("DROP SCHEMA", schema_name))
    cli::cli_alert_success("Dropped SQL Server schema: {.val {schema_name}}")
  } else if (any(grepl("PqConnection", dbms_class))) {
    # Postgresql: drop all tables first, then drop schema
    tables <- CDMConnector::listTables(con, schema = schema)
    schema_name <- if (length(schema) == 1) schema else schema[length(schema)]
    for (tbl in tables) {
      tryCatch(
        DBI::dbExecute(con, paste0("DROP TABLE IF EXISTS ", schema_name, ".", tbl)),
        error = function(e) NULL
      )
    }
    DBI::dbExecute(con, paste("DROP SCHEMA", schema_name))
    cli::cli_alert_success("Dropped Postgresql schema: {.val {schema_name}}")
  } else if (any(grepl("Spark|databricks", dbms_class, ignore.case = TRUE))) {
    # Databricks/Spark
    schema_full <- paste(schema, collapse = ".")
    DBI::dbExecute(con, paste0("DROP SCHEMA IF EXISTS ", schema_full, " CASCADE"))
    cli::cli_alert_success("Dropped Spark schema: {.val {schema_full}}")
  } else {
    cli::cli_abort("Could not detect database type for cleanup. Connection class: {.val {paste(dbms_class, collapse = ', ')}}")
  }

  DBI::dbDisconnect(con)
  cli::cli_alert_success("Disconnected from remote database")
  invisible(NULL)
}
