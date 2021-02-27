defmodule Integration.GranularInsertion.Workflow.Examples do
  use EctoTestDSL.Variants.PhoenixGranular.Insert
  alias Integration.Animal.Schema
  use Integration.Support
  
  def create_test_data do
    start(
      module_under_test: Schema,
      repo: "there is no repo",
      insert_with: &tunable_insert/2
    ) |> 
    
    field_transformations(
      as_cast: Schema.fields_to_cast(),
      date: on_success(Date.from_iso8601!(:date_string)),
      days_since_2000: on_success(Date.diff(:date, ~D[2000-01-01]))
    ) |>
    
    workflow(:success,
      only_required: [
        params(age: 55, date_string: "2000-01-02", species_id: 1)
      ], 
      complete: [
        params_like(:only_required, except: [
              optional_comment: "optional comment",
              defaulted_comment: "defaulted comment override"
            ])],
      unexpected_syntax_errors: [
        params_like(:complete, except: [age: "1d", date_string: "2001-01-"])
      ],
      override_incorrectly: [
        params_like(:complete),
        changeset(changes: [days_since_2000: 5])
      ],
      insertion_will_unexpectedly_fail: [
        params_like(:complete, except: [optional_comment: "Please fail insertion"])
      ]
    )
  end
end
