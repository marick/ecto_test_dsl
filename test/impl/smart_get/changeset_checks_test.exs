defmodule Impl.SmartGet.ChangesetChecksTest do
  use TransformerTestSupport.Case
  alias TransformerTestSupport.Impl.SmartGet
  import TransformerTestSupport.Build

  # ----------------------------------------------------------------------------
  describe "validity additions" do 
    test "a :validation_failure category has an `invalid` check put at the front" do
      test_data =
        start() |>
        category(:validation_failure,
          oops: [changeset(no_changes: [:date])]
        ) |> propagate_metadata
      
      SmartGet.ChangesetChecks.get(test_data, :oops)
      |> assert_equal([:invalid, {:no_changes, [:date]}])
    end
    
    
    test "any other category gets a `valid` check" do
      test_data =
        start() |>
        category(:success,
          ok: [changeset(no_changes: [:date])]
        ) |> propagate_metadata
      
      
      SmartGet.ChangesetChecks.get(test_data, :ok)
      |> assert_equal([:valid, {:no_changes, [:date]}])
    end
    
    test "checks are added even if there's no changest" do
      test_data =
        start() |>
        category(:success, ok: [])
        |> propagate_metadata
      
      SmartGet.ChangesetChecks.get(test_data, :ok)
      |> assert_equal([:valid])
    end
  end

  # ----------------------------------------------------------------------------
  use Ecto.Schema

  embedded_schema do
    field :name, :string
    field :date, :date
    field :other, :string
    field :other2, :string
  end


  describe "adding an automatic as_cast test" do
    test "starting with nothing" do 
      test_data =
        TestBuild.one_category(
          [module_under_test: __MODULE__,
           field_transformations: [as_cast: [:date]]
          ],
          ok: [params(date: "2001-01-01")])

      SmartGet.ChangesetChecks.get(test_data, :ok)
      |> assert_equal([:valid, changes: [date: ~D[2001-01-01]]])
    end

    test "starting with something" do 
      test_data =
        TestBuild.one_category(
          [module_under_test: __MODULE__,
           field_transformations: [as_cast: [:date]]
          ],
          ok: [params(date: "2001-01-01"),
               changeset(changes: [name: "Bossie"])
              ])

      SmartGet.ChangesetChecks.get(test_data, :ok)
      |> assert_equal([:valid,
                      changes: [name: "Bossie"],
                      changes: [date: ~D[2001-01-01]]])
    end


    test "user values override" do 
      test_data =
        TestBuild.one_category(
          [module_under_test: __MODULE__,
           field_transformations: [as_cast: [:date]]
          ],
          ok: [params(date: "2001-01-01"),
               changeset(no_changes: :date)
              ])

      SmartGet.ChangesetChecks.get(test_data, :ok)
      |> assert_equal([:valid, no_changes: :date])
    end
  end
  

  test "unique_fields" do
    expect = fn changeset_checks, expected ->
      actual = SmartGet.ChangesetChecks.unique_fields(changeset_checks)
      assert actual == expected
    end

    # Handling of lone symbols
    [change: :a            ] |> expect.([:a])
    [change: :a, change: :b] |> expect.([:a, :b])
    [change: :a, error:  :a] |> expect.([:a])


    # Is not fooled by single-element (global) checks
    [:valid, change: :a    ] |> expect.([:a])
    
  end


  test "removing fields described by user" do
    expect = fn {fields, changeset_checks}, expected ->
      actual = SmartGet.ChangesetChecks.remove_fields_named_by_user(fields, changeset_checks)
      assert actual == expected
    end

    # Base cases.
    {  [],   [              ] } |> expect.([  ])
    {  [],   [some_check: :b] } |> expect.([  ])
    {  [:a], [              ] } |> expect.([:a])

    # singleton arguments
    {  [:default], [some_check: :other]  } |> expect.([:default])
    {  [:default], [some_check: :default]  } |> expect.([])

    # List arguments
    {  [:default], [some_check: [:other          ]]  } |> expect.([:default])
    {  [:default], [some_check: [:other, :default]]  } |> expect.([])

    # Keyword arguments
    {  [:default], [changes: [other: 5            ]]  } |> expect.([:default])
    {  [:default], [changes: [other: 5, default: 5]]  } |> expect.([])


    # Keyword arguments
    {  [:default], [changes: %{other: 5            }]  } |> expect.([:default])
    {  [:default], [changes: %{other: 5, default: 5}]  } |> expect.([])
  end
end 
