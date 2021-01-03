defmodule TransformerTestSupport.Link.FieldCalculation do
  use TransformerTestSupport.Drink.Me
  use TransformerTestSupport.Drink.AssertionJuice

  alias T.SmartGet.Example
  alias T.Nouns.FieldCalculator
  
  @moduledoc """
  """

  def add(existing_changeset_checks, example, calculated_field_descriptions) do
    calculated_field_descriptions
    |> Enum.reduce(existing_changeset_checks, fn field_description, acc ->
         case Example.workflow_name(example) do
           :validation_error ->
             acc
           _ ->
             acc ++ [{:__custom_changeset_check, make__checker(field_description)}]
         end
       end)
  end

  def make__checker({field_name, %FieldCalculator{calculation: f, args: arg_template}}) do 
    fn changeset ->
      if prerequisite_fields_available?(arg_template, changeset) do
        check_changeset(changeset, field_name, f, arg_template)
      else
        :ok
      end
    end
  end

  def check_changeset(changeset, field, f, arg_template) do
    args = Enum.map(arg_template, &(translate_arg &1, changeset))
    transformer_spec = "#{inspect f}#{inspect arg_template}"

    unless Map.has_key?(changeset.changes, field) do
      flunk("The changeset has all the prerequisites to calculate `#{inspect field}` (using #{transformer_spec}), but `#{inspect field}` is not in the changeset's changes")
    end
    
    expected = 
      try do
        apply(f, args)
      rescue
        ex ->
          exception_name = inspect ex.__struct__
          elaborate_flunk("#{exception_name} was raised when field transformer #{transformer_spec} was applied to #{inspect args}",
            [left: Exception.format(:error, ex)])
      end
    elaborate_assert(
      changeset.changes[field] == expected,
      "Changeset field `#{inspect field}` (left) does not match the value calculated from #{transformer_spec}",
      left: changeset.changes[field],
      right: expected)
    :ok
  end

  defp prerequisite_fields_available?(arg_template, changeset) do
    Enum.all?(arg_template, fn one ->
      cond do
        not is_atom(one) -> true
        Map.has_key?(changeset.changes, one) -> true
        :else -> false
      end
    end)
  end

  defp translate_arg(arg,  changeset) when is_atom(arg), do: changeset.changes[arg]
  defp translate_arg(arg, _changeset),                   do:                   arg
end
