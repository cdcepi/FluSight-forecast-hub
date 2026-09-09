# Custom validation functions

Custom `hubValidations` check functions for this hub. Scripts in `R/` are sourced
during validation via the `source:` property of the corresponding check entry in
[../../hub-config/validations.yml](../../hub-config/validations.yml), and run as
part of `hubValidations::validate_submission()` — both locally and in the
[Hub Submission Validation](../../.github/workflows/validate-submission.yaml)
GitHub Action on every pull request touching `model-output/`.

See the hubValidations articles on
[writing custom check functions](https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html)
and
[deploying custom validation functions](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.html)
before adding to this directory.

## Contents

| Script | Functions | Deployed as |
| ------ | --------- | ----------- |
| `R/cstm_check_tbl_value_max.R` | `cstm_check_tbl_value_max()`, `cstm_check_tbl_value_max_popn_frac()` | `max_prop_ed_visits`, `max_hosp_popn_frac` under `validate_model_data` |

Both functions in `cstm_check_tbl_value_max.R` place an upper bound on predicted
values to catch gross scale and unit errors; see
[plausibility bounds on predicted values](../../model-output/README.md#plausibility-bounds-on-predicted-values)
for the bounds currently in force and the rationale for them. They share the
internal helpers defined in that script, so both check configurations point their
`source:` property at the same file.

## Dependencies

These functions use only packages already in the `hubValidations` dependency tree
(`arrow`, `checkmate`, `cli`, `dplyr`, `fs`, `purrr`), so no changes to the
validation workflow's installed packages are needed. Any custom check that
introduces a new dependency must add it to the `setup-r-dependencies` step of
[../../.github/workflows/validate-submission.yaml](../../.github/workflows/validate-submission.yaml)
*and* be documented for submitting teams, who also run these checks locally.
