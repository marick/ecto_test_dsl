A "little language" that lets you write a set of examples in a
declarative style that generates a set of test data ("examples"),
appropriate assertions for each example, and runners that check the
examples against the assertions.

You get terse tests and examples that explain a lot in (comparatively) few words. 

```elixir
    workflow(                                         :validation_error,
      bad_format: [
        params_like(:bossie, except: [date_string: "2001-01-0"]),
        changeset(
          no_changes: [:date, :days_since_2000],
          error: [date_string: "is not a valid date"]
        ),
      ]
    )
```

The separate repository [examples_for_ecto_test_dsl](https://github.com/marick/examples_for_ecto_test_dsl) has examples.

*This is a work in progress. However, I am actively looking for people who'd like me to try applying this package to their app and thus improve it.*

*Contact [marick@exampler.com](mailto:marick@exampler.com) or [@marick](https://twitter.com/marick/).*

