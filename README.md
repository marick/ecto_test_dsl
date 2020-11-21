# Transformer Test Support

A "little language" that lets you write a set of examples in a
declarative style that generates a set of test data ("examples")
appropriate assertions for each example, and runners that check the
examples against the assertions.

You get terse tests:


```elixir
  test "workflows" do
    Params.check_form_validation(workflows: [:valid])
    Params.check_form_validation(workflows: [:invalid])
  end
  
  test "schema structure production" do
    Params.check_form_lowering(:valid)
  end
  
```

... and examples that explain a lot in (comparatively) few words. Consider
this form data:


```elixir
  @moduledoc """
  %{
    "in_service_datestring" => "today",
    "names" => "bad ass animal, animal of bliss",
    "out_of_service_datestring" => "never",
    "species_id" => "1"
  }
  """
```

The form under test allows a user to create *N* new animal records,
each with a different name.

The code under test fills a "view model" structure and validates
it. If valid, the view model is "lowered" into *N* Ecto Schema structures.

The test data declaration follows. (Note that this is an earlier
version of the notation used in an app of mine. This repo contains (or
will contain) a considerably improved mechanism and a
somewhat-rethought notation.)

```elixir
  @test_data build(
    module_under_test: VM.BulkAnimal,
    produces: Schemas.Animal,
    validates: [:names,
                :species_id,
                :in_service_datestring, :out_of_service_datestring],
    
    lowering_splits: %{:names => :name},
    lowering_retains: [:species_id],

    exemplars: [
      # -------------------------------------------VALID-------------------
      valid: %{params: to_strings(%{names: "Shelley, Bossie, cow12 ",
                                    species_id: @bovine_id,
                                    in_service_datestring: @iso_date_1,
                                    out_of_service_datestring: @iso_date_2}),
               lowering_adds: %{span: Datespan.customary(@date_1, @date_2)},
               workflows: [:valid],
              },

      # The front end should not ever send back blank datestrings, but
      # it's worth documenting the behavior if the impossible happens.
      blank_datestrings: %{workflows: [:valid],
                           params: like(:valid,
                             except: %{in_service_datestring: "",
                                       out_of_service_datestring: ""}),
                           # The underlying value, which defaults to
                           # "today" and "never", is retained.
                           unchanged: [:in_service_datestring,
                                       :out_of_service_datestring]
                          },

      # ----------------------------------------INVALID-----------------
      
      blank_names: %{
        shows_delegation: {FieldValidators, :namelist},
        params: like(:valid, except: %{names: "  ,"}),
        errors: [names: @no_valid_names_message],
        workflows: [:invalid],
      },
      
      out_of_order: %{
        shows_delegation: {FieldValidators, :date_order},
        params: like(:valid,
          except: %{in_service_datestring: @iso_date_4,
                    out_of_service_datestring: @iso_date_3}),
        errors: [out_of_service_datestring: @date_misorder_message],
        workflows: [:invalid],
      }
    ])
```
