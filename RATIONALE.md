# Rationale for this Ecto Test DSL

It's easier to write product that uses Ecto than it is to test that
code. It should be the other way around.

-------------------

Suppose you are using Ecto to manipulate an `animals` table in the
database. You want to test the code you write. But there are
problems:

1. A lot of what you need to test is, frankly, boring. Does the
   `changeset` function properly reject a blank field? Are database
   constraint errors put into the changeset? Etc.
   
2. Moreover, these boring checks require more elaborate tests than the
   ideas really deserve. To say "an attempt to change the `name` field
   to a name that already exists is rejected" requires setting up two
   table rows before you even get to the point of the test.
   
3. Things get even more complicated with associations. Every animal
   `belongs_to` a `species`, which means you can't even create an
   animal without creating a species. Managing all these prerequisites
   is a pain. Plus, you have to make sure primary keys of
   previously-inserted entities are in all the right places in any new
   entities you want to insert.
   
This library is all about reducing pain and boring work. It does that
by providing functions that do a lot of rote test work.

Let's look at that final problem, "creating the species". It should be
as simple as this:


```elixir
      ...
      bovine: [params(name: "bovine")],
```

(For this example, species only have names.)

OK, I lied. There has to be a bit of setup work like this:

```elixir
  use EctoTestDSL.Variants.PhoenixGranular.Insert

  def create_test_data do 
    start(
      module_under_test: Schemas.Species,
      repo: App.Repo
    )
```

But that's very rote, very fill-in-the-blank, and you only do type it once.

--------


While we're doing this creation, we might as well check that it worked:


      bovine: [params(name: "bovine"),
               fields(name: "bovine")],

That checks that the structure returned by `Ecto.insert` has the expected values. 

But...

This is a low-value test: it basically confirms that the `:string`
field named `:name` was given to `Changeset.cast`. However, it can't
*hurt* to document that fact, so long as it takes little time and
doesn't distract from what's more important.

So actual examples would look like this:
   
     def create_test_data do 
       start(
         module_under_test: Schemas.Species,
         repo: App.Repo
       ) |> 
       
       field_transformations(as_cast: [:id, :name]) |>   # <--------
   
       workflow(                                         :success,
         bovine: [params(name: "bovine")],               #^^^^^^^
         equine: [params(name: "equine")]
       )
       ....
   

For the `PhoenixGranual.Insert` *variant*, the `as_cast` annotation
means that whenever a changeset is created, the `:id` and `:name`
field inside `changeset.changes` must be the results of
`Changeset.cast/3`. Essentially, that forces (if you're doing strict
TDD) or checks (otherwise) that the first step of creating the
changeset contained the right list here:

      def changeset(struct, params) do 
        struct
        |> cast(params, [:id, :name]
        |> ...
        
That check will be made for all of the *examples* in the file (here,
`:bovine` and `:equine`).

--------

Both `:bovine` and `:equine` are part of the `:success`
*workflow*. When an example is *run* (roughly: tested), the workflow does the following:

1. Converts the parameters into the format Phoenix delivers them to a
   controller (mostly, turns keys and values into strings the
   way EEx does), 
   
2. Calls the module-under-test's designated changeset function (by default, `changeset`), 

3. Checks that the result is a `:valid` changeset, 

4. Checks the changeset values according to the global checks
   (`as_cast` and others) as well as specific checks that can look
   like this:
   
       changeset(changes: [name: "bossie"], errors: [...])
       
5. Inserts the changeset (using, by default, `Repo.insert`),

6. Checks that the result matches `{:ok, struct}`, and

7. Checks the field values in `struct` (if desired).

Other workflows act differently. For example, the `:constraint_error`
workflow requires that the attempt to insert fail. Such an example
looks like this:


    workflow(                             :constraint_error,
       duplicate_name: [
         previously(insert: :bovine),
         params_like(:bovine),
         constraint_changeset(error: [name: "has already been taken"])
       ] ...
         
The easy way to check for unique name constraints is to insert the
same params twice. Because that's such a common situation, it deserves
some shorthand:

       duplicate_name: [
         insert_twice(:bovine),     # <<<<<<<<<<<
         constraint_changeset(error: [name: "has already been taken"])
       ]

--------

To show how associations work, let's look at inserting an animal. To
do that, we have to first insert a species and get its primary key
into the `params`. That's done like this:

    workflow(                                              :success,
      note_free: [params(name: "Bossie",
                         notes: "",
                         species_id: id_of(bovine: Insert.Species))
                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                 ],

Although it's not obvious from just the example, `:as_cast` is used to
check the insertd values:
                 
    field_transformations(
      as_cast: [:name, :notes, :lock_uuid, :species_id]
    ) |>

---------

There's no visible evidence that the `bovine` species was actually
created, but that's easy to check:

    iex(1)> alias Examples.Schemas20.Insert.Animal.Tester
    iex(2)> EctoTestDSL.start
    {:ok, #PID<0.311.0>}
    
    iex(3)> Tester.params(:note_free)
    %{"name" => "Bossie", "notes" => "", "species_id" => "860"}
    
    iex(4)> App.Repo.get(Schemas.Species, 860)
    %App.Schemas20.Species{
      __meta__: #Ecto.Schema.Metadata<:loaded, "species">,
      animals: #Ecto.Association.NotLoaded<association :animals is not loaded>,
      id: 860,
      inserted_at: ~N[2021-02-28 22:02:32],
      name: "bovine",
      updated_at: ~N[2021-02-28 22:02:32]
    }

Functions like `Tester.params` effectively stop a workflow in the
middle and return h value of the final step. That allows a set of
examples to to be used as "fixtures' for regular ExUnit tests. For
example, you could write a controller test that checks animal deletion
like this:


    test "deletion by id" do 
      id = Tester.inserted(:note_free).id
      conn = delete(conn, Routes.animal_path(conn, :delete))
      ...
    end
    
