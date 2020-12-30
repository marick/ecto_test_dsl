defmodule TransformerTestSupport.Build do
  use TransformerTestSupport.Drink.Me
  alias T.Parse.TopLevel.Validate
  alias T.Nouns.{FieldCalculator}
  alias T.Parse.{Start}

  @moduledoc """
  """


  @required_keys [:module_under_test, :variant] ++ Map.keys(Start.starting_test_data)
  @optional_keys []

  def validate_keys_including_variant_keys(test_data, variant_required, variant_optional) do
    required = @required_keys ++ variant_required
    optional = @optional_keys ++ variant_optional
    Validate.assert_valid_keys(test_data, required, optional)
  end

  def step(f, key) do
    fn running ->
      Keyword.fetch!(running.history, key) |> f.()
    end
  end
  

  # ----------------------------------------------------------------------------


  # ----------------------------------------------------------------------------

  defmacro id_of(extended_example_desc) do
    quote do
      een = een(unquote(extended_example_desc))
      FieldRef.new(id: een)
    end
  end


  # ----------------------------------------------------------------------------


  defmacro on_success(funcall) do
    from = "on_success(#{Macro.to_string(funcall)})"
    case Macro.decompose_call(funcall) do
      {{:__aliases__, _, aliases},  fun_atom, args} -> 
        composed_module = Enum.reduce(aliases, :Elixir, fn alias, acc ->
          Module.safe_concat(acc, alias)
        end)
        fun = Function.capture(composed_module, fun_atom, length(args))
        quote do
          FieldCalculator.new(unquote(fun), unquote(args), unquote(from))
        end

      {fun_atom, args} ->
        quote do 
          fun = Function.capture(__MODULE__, unquote(fun_atom), length(unquote(args)))
          FieldCalculator.new(fun, unquote(args), unquote(from))
        end

      _ ->
        raise """
        The argument to `on_success/1` does not look like a function call.
        You may want the `on_success(f, applied_to: args)` variant.
        """
    end
  end

  def on_success(f, applied_to: fields) when is_list(fields),
    do: FieldCalculator.new(f, fields, "on_success(<fn>, applied_to: #{inspect fields})")
  def on_success(f, applied_to: field),
    do: on_success(f, applied_to: [field])



end
