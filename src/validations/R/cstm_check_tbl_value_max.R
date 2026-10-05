# Custom validation checks for unrealistically high predicted values.
#
# Both functions in this file are deployed through `hub-config/validations.yml`
# as part of `validate_model_data()`. Because they share the internal helpers
# defined at the bottom of this file, the `source:` property of both check
# configurations points at this single script.
#
# - `cstm_check_tbl_value_max()`: values must not exceed a fixed maximum.
#   Used to check that `wk inc flu prop ed visits` predictions do not exceed a
#   plausible upper bound on the proportion of ED visits due to influenza.
#
# - `cstm_check_tbl_value_max_popn_frac()`: values must not exceed a
#   location-specific fraction of that location's population size. Used to check
#   that `wk inc flu hosp` predictions are not larger than a plausible fraction
#   of the population of the state being predicted.
#
# Both checks are inclusive of the threshold, i.e. a value exactly equal to the
# threshold passes. Rows with missing `value`s are ignored; missing values are
# reported by the standard `check_tbl_value_col()` check.


#' Check that predicted values do not exceed a fixed maximum.
#'
#' @param tbl a tibble of the model output data being validated.
#' @param file_path character string. Path to the file being validated, relative
#' to the hub's `model-output` directory.
#' @param hub_path character string. Path to the hub directory.
#' @param max_value single non-negative number. The largest permissible value.
#' @param targets either a single named list of task ID values or a list of such
#' lists, used to subset `tbl` to the rows the check applies to, e.g.
#' `list(target = "wk inc flu prop ed visits")`. `NULL` applies the check to all
#' rows.
#' @param output_types character vector of `output_type` values the check applies
#' to. Defaults to `"quantile"`.
#'
#' @return a `<message/check_success>`, `<error/check_failure>` or
#' `<message/check_info>` condition class object.
cstm_check_tbl_value_max <- function(
  tbl,
  file_path,
  hub_path,
  max_value,
  targets = NULL,
  output_types = "quantile"
) {
  checkmate::assert_number(max_value, lower = 0, finite = TRUE)
  output_types <- cstm_assert_chr(output_types, "output_types")
  cstm_assert_targets(targets, tbl, hub_path)

  check_tbl <- cstm_filter_check_rows(tbl, targets, output_types)
  if (nrow(check_tbl) == 0L) {
    return(
      hubValidations::capture_check_info(
        file_path = file_path,
        msg = "No rows matching the configured targets and output types.
               Check skipped."
      )
    )
  }

  check_tbl[["limit"]] <- max_value
  invalid <- cstm_invalid_rows(check_tbl)
  check <- nrow(invalid) == 0L

  if (check) {
    details <- NULL
    error_object <- NULL
  } else {
    error_object <- invalid
    details <- cstm_failure_details(invalid, n_checked = nrow(check_tbl))
  }

  hubValidations::capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cstm_target_label(targets),
    msg_verbs = c("are all", "must all be"),
    msg_attribute = cli::format_inline(
      "less than or equal to {.val {max_value}}."
    ),
    error_object = error_object,
    details = details
  )
}


#' Check that predicted values do not exceed a fraction of location population.
#'
#' @inheritParams cstm_check_tbl_value_max
#' @param popn_frac single number between 0 and 1. The fraction of a location's
#' population size that predicted values must not exceed.
#' @param popn_file_path character string. Path to the population data, relative
#' to the hub root. Defaults to `"auxiliary-data/locations.csv"`.
#' @param popn_col character string. Name of the population size column in the
#' population data.
#' @param location_col character string. Name of the location column. Must be
#' shared by the population data and the model output data.
#'
#' @return a `<message/check_success>`, `<error/check_failure>` or
#' `<message/check_info>` condition class object.
cstm_check_tbl_value_max_popn_frac <- function(
  tbl,
  file_path,
  hub_path,
  popn_frac,
  targets = NULL,
  output_types = "quantile",
  popn_file_path = "auxiliary-data/locations.csv",
  popn_col = "population",
  location_col = "location"
) {
  checkmate::assert_number(popn_frac, lower = 0, upper = 1)
  checkmate::assert_character(popn_file_path, len = 1L)
  checkmate::assert_character(popn_col, len = 1L)
  checkmate::assert_character(location_col, len = 1L)
  checkmate::assert_choice(location_col, choices = names(tbl))
  output_types <- cstm_assert_chr(output_types, "output_types")
  cstm_assert_targets(targets, tbl, hub_path)

  check_tbl <- cstm_filter_check_rows(tbl, targets, output_types)
  if (nrow(check_tbl) == 0L) {
    return(
      hubValidations::capture_check_info(
        file_path = file_path,
        msg = "No rows matching the configured targets and output types.
               Check skipped."
      )
    )
  }

  popn <- cstm_read_popn(hub_path, popn_file_path, popn_col, location_col)
  check_tbl <- dplyr::left_join(check_tbl, popn, by = location_col)

  if (anyNA(check_tbl[[popn_col]])) {
    # nolint start: object_usage_linter
    invalid_location <- unique(
      check_tbl[[location_col]][is.na(check_tbl[[popn_col]])]
    )
    # nolint end
    cli::cli_abort(
      "No match for {cli::qty(length(invalid_location))} location{?s}
       {.val {invalid_location}} found in {.path {popn_file_path}}"
    )
  }

  check_tbl[["limit"]] <- popn_frac * check_tbl[[popn_col]]
  invalid <- cstm_invalid_rows(check_tbl)
  check <- nrow(invalid) == 0L

  if (check) {
    details <- NULL
    error_object <- NULL
  } else {
    error_object <- invalid
    details <- cstm_failure_details(
      invalid,
      n_checked = nrow(check_tbl),
      location_col = location_col
    )
  }

  popn_pct <- popn_frac * 100 # nolint: object_usage_linter

  hubValidations::capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cstm_target_label(targets),
    msg_verbs = c("are all", "must all be"),
    msg_attribute = cli::format_inline(
      "less than or equal to {popn_pct}% of the population size of the
       location being predicted."
    ),
    error_object = error_object,
    details = details
  )
}


# ---- internal helpers -------------------------------------------------------

#' Coerce and check a character vector argument supplied through `validations.yml`
#'
#' YAML sequences are parsed as lists, so arguments expecting a character vector
#' are unlisted before being checked.
#' @noRd
cstm_assert_chr <- function(x, arg_name) {
  x <- as.character(unlist(x, use.names = FALSE))
  checkmate::assert_character(
    x,
    min.len = 1L,
    any.missing = FALSE,
    .var.name = arg_name
  )
  x
}

#' Build the message subject, naming the targets the check was applied to
#' @noRd
cstm_target_label <- function(targets) {
  target_sets <- cstm_as_target_sets(targets)
  if (length(target_sets) == 0L) {
    return("Predicted {.var value}s")
  }
  vals <- unique(as.character(unlist(target_sets, use.names = FALSE))) # nolint: object_usage_linter
  cli::format_inline("Predicted {.var value}s for {.val {vals}}")
}

#' Standardise `targets` to a list of named lists of task ID values
#' @noRd
cstm_as_target_sets <- function(targets) {
  if (is.null(targets)) {
    return(list())
  }
  if (purrr::pluck_depth(targets) == 2L) list(targets) else targets
}

#' Check that `targets` reference task IDs and values that exist
#'
#' Guards against a typo in `validations.yml` silently disabling a check by
#' filtering `tbl` down to zero rows.
#' @noRd
cstm_assert_targets <- function(targets, tbl, hub_path) {
  target_sets <- cstm_as_target_sets(targets)
  if (length(target_sets) == 0L) {
    return(invisible(TRUE))
  }
  config_vals <- cstm_config_task_id_vals(hub_path)

  purrr::walk(target_sets, function(target) {
    checkmate::assert_list(
      target,
      names = "named",
      any.missing = FALSE,
      min.len = 1L,
      .var.name = "targets"
    )
    invalid_ids <- setdiff(names(target), names(tbl)) # nolint: object_usage_linter
    if (length(invalid_ids) > 0L) {
      cli::cli_abort(
        "{cli::qty(length(invalid_ids))}Task ID{?s} {.val {invalid_ids}}
         {?is/are} not {?a column/columns} in the submission file."
      )
    }
    purrr::iwalk(target, function(vals, task_id) {
      vals <- as.character(unlist(vals, use.names = FALSE))
      invalid_vals <- setdiff(vals, config_vals[[task_id]]) # nolint: object_usage_linter
      if (length(invalid_vals) > 0L) {
        cli::cli_abort(
          "{cli::qty(length(invalid_vals))}Value{?s} {.val {invalid_vals}}
           {?is/are} not {?a valid value/valid values} of task ID
           {.var {task_id}} in the hub config."
        )
      }
    })
  })
  invisible(TRUE)
}

#' Collect all task ID values defined in `tasks.json`, keyed by task ID name
#' @noRd
cstm_config_task_id_vals <- function(hub_path) {
  config_tasks <- hubValidations::read_config(hub_path, "tasks")
  model_tasks <- do.call(
    c,
    purrr::map(config_tasks[["rounds"]], "model_tasks")
  )
  task_ids <- purrr::map(model_tasks, "task_ids")
  id_names <- unique(unlist(purrr::map(task_ids, names), use.names = FALSE))

  purrr::map(id_names, function(id_name) {
    purrr::map(
      task_ids,
      ~ as.character(unlist(.x[[id_name]], use.names = FALSE))
    ) |>
      unlist(use.names = FALSE) |>
      unique()
  }) |>
    stats::setNames(id_names)
}

#' Subset `tbl` to the rows a check applies to, preserving original row numbers
#' @noRd
cstm_filter_check_rows <- function(tbl, targets, output_types) {
  checkmate::assert_choice("output_type", choices = names(tbl))
  checkmate::assert_choice("value", choices = names(tbl))

  tbl[["row_id"]] <- seq_len(nrow(tbl))
  tbl <- tbl[as.character(tbl[["output_type"]]) %in% output_types, ]

  target_sets <- cstm_as_target_sets(targets)
  if (length(target_sets) == 0L) {
    return(tbl)
  }

  keep <- purrr::map(target_sets, function(target) {
    purrr::imap(target, function(vals, task_id) {
      as.character(tbl[[task_id]]) %in%
        as.character(unlist(vals, use.names = FALSE))
    }) |>
      purrr::reduce(`&`)
  }) |>
    purrr::reduce(`|`)

  tbl[keep, ]
}

#' Identify rows whose `value` exceeds their `limit`, worst offender first
#' @noRd
cstm_invalid_rows <- function(check_tbl) {
  value <- check_tbl[["value"]]
  limit <- check_tbl[["limit"]]
  # Missing values are ignored here; they are reported by `check_tbl_value_col()`.
  invalid <- !is.na(value) & value > limit
  out <- check_tbl[invalid, ]
  out[["excess"]] <- out[["value"]] - out[["limit"]]
  out[order(-out[["excess"]]), ]
}

#' Build a details message listing the worst offending rows
#' @noRd
cstm_failure_details <- function(
  invalid,
  n_checked,
  location_col = NULL,
  max_n = 10L
) {
  n_invalid <- nrow(invalid)
  shown <- utils::head(invalid, max_n)
  loc <- if (is.null(location_col)) {
    rep("", nrow(shown))
  } else {
    paste0(" (", location_col, " ", shown[[location_col]], ")")
  }
  rows <- paste0(
    "row ",
    shown[["row_id"]],
    ": value ",
    cstm_fmt_num(shown[["value"]]),
    " exceeds ",
    cstm_fmt_num(shown[["limit"]]),
    loc
  )
  more <- if (n_invalid > max_n) {
    paste0(" and ", n_invalid - max_n, " more.")
  } else {
    ""
  }
  paste0(
    n_invalid,
    " of ",
    n_checked,
    " checked values are too high. Largest first: ",
    paste(rows, collapse = "; "),
    ".",
    more
  )
}

#' Format numbers for inclusion in check messages
#' @noRd
cstm_fmt_num <- function(x) {
  vapply(
    x,
    function(.x) format(.x, trim = TRUE, scientific = FALSE, digits = 7),
    character(1),
    USE.NAMES = FALSE
  )
}

#' Read location population data from the hub
#' @noRd
cstm_read_popn <- function(hub_path, popn_file_path, popn_col, location_col) {
  popn_full_path <- fs::path(hub_path, popn_file_path)
  if (!fs::file_exists(popn_full_path)) {
    cli::cli_abort("File not found at {.path {popn_file_path}}")
  }
  popn <- switch(
    fs::path_ext(popn_full_path),
    csv = arrow::read_csv_arrow(popn_full_path),
    parquet = arrow::read_parquet(popn_full_path),
    arrow = arrow::read_feather(popn_full_path),
    cli::cli_abort(
      "Unsupported file extension for population data at
       {.path {popn_file_path}}"
    )
  )
  checkmate::assert_choice(location_col, choices = names(popn))
  checkmate::assert_choice(popn_col, choices = names(popn))
  popn[, c(location_col, popn_col)]
}
