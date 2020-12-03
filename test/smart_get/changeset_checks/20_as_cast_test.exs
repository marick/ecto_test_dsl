defmodule SmartGet.ChangesetChecks.AsCastTest do
  alias TransformerTestSupport, as: T
  use T.Case
  alias T.SmartGet.ChangesetChecks, as: Checks
  import T.Build
  alias T.RunningExample
  alias Template.Dynamic

  defmodule AsCast do
    use Ecto.Schema
    schema "table" do
      field :name, :string
      field :date, :date
      field :other, :string
      field :other2, :string

      field :species_id, :integer   # Faking a `belongs_to`
    end
  end

  defmodule Examples do 
    use Template.EctoClassic.Insert
  end

  describe "adding an automatic as_cast test" do
    test "starting with no existing checks" do
      [            as_cast: [:date],
       params:               [date:   "2001-01-01"]
      ] |> expect_changeset_checks(
        [        :valid,
                 changes:    [date: ~D[2001-01-01]]])
    end

    test "starting with existing checks" do
      [              as_cast: [:date],
       params:                 [date: "2001-01-01"],
       checks: [      changes: [name: "Bossie"]]       # <<<
      ] |> expect_changeset_checks(
        [          :valid,
                   changes:    [name: "Bossie"],
                   changes:    [date: ~D[2001-01-01]]])
    end

    test "it is OK for a parameter to be missing" do
      [              as_cast: [:other],               # <<<
       params:                 [date: "2001-01-01"],  # `other` not in params
       checks: [      changes: [name: "Bossie"]]
      ] |> expect_changeset_checks(
        [          :valid,
                   changes:    [name: "Bossie"],
                   no_changes: [:other]])             # <<<<
    end

    test "If the `cast` produces an error, that appears in the expected results" do
      [workflow:                                          :validation_error,
                     as_cast:      [:date, :name],
                      params:       [date: "2001-01-0",      # <<<<
                                            name: "Bossie"]
      ] |> expect_changeset_checks([:invalid,
                      changes:             [name: "Bossie"],
                      no_changes:  [:date],                  # <<<
                      errors:       [date: "is invalid"]])   # <<<
    end

    test "a field named in the `changeset` arg overrides auto-generated ones" do
      [               as_cast: [:date],
                       params: [date:   "2001-01-01"],
          checks: [no_changes: :date]                          # <<<
      ] |> expect_changeset_checks(
        [        :valid,
                 no_changes:   :date])
    end

    test "overriding a field's changeset prevents `as_cast` calculation" do
      [               as_cast: [:date],
                       params:  [date:   "2001-01-0"],
          checks:    [changes:  [date: ~D[2001-01-01]]]        #^^^ note the error
      ] |> expect_changeset_checks(
        [              :valid,
                      changes:  [date: ~D[2001-01-01]]])
      # The lack of an assertion failure, gives evidence that
      # the actual `cast` value of the `date` parameter is never calculated.
    end

    @tag :skip
    test "no check is made if the field wasn't changed" do
      # This would be relevant to update
      #    The data part of the changeset contains a bogus value.
      #    The params contains the same bogus value.
      #    This does not cause a changeset check, just as it would
      #    not cause a changeset value because those only apply to
      #
    end

    test "`previously` values are obeyed" do
      [ as_cast: [:species_id],
        params:  [ species_id: id_of(:prerequisite)],
        previously:              %{ {:prerequisite, __MODULE__} => %{id: 383}}
      ] |> expect_changeset_checks(
        [:valid,
         changes:  [species_id:                                          383]])
    end
  end

  # ----------------------------------------------------------------------------

  defp expect_changeset_checks(opts, expected) do
    as_cast = Keyword.fetch!(opts, :as_cast)
    workflow = Keyword.get(opts, :workflow, :validation_success)
    params = Keyword.fetch!(opts, :params)
    previously = Keyword.get(opts, :previously, %{})

    example_opts =
      case Keyword.get(opts, :checks) do
        nil -> [params(params)]
        checks -> [params(params), changeset(checks)]
      end


    Dynamic.configure(Examples, AsCast)
    |> field_transformations(as_cast: as_cast)
    |> Dynamic.example_in_workflow(workflow, example_opts)
    |> Checks.get_validation_checks(previously: previously)
    |> assert_equal(expected)
  end
end
