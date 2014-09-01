# sigma_form

A simple form generator plugin element for the [Nitrogen Web Framework](http://nitrogenproject.com)

## Installing into a Nitrogen Application

Add it as a rebar dependency by adding into the deps section of rebar.config:

```erlang
	{sigma_form, ".*", {git, "git://github.com/choptastic/sigma_form.git", {branch, master}}}
```

### Using Nitrogen's built-in plugin installer (Requires Nitrogen 2.2.0)

Run `make` in your Application. The rest should be automatic.

### Manual Installation (Nitrogen Pre-2.2.0)

Run the following at the command line:

```shell
	./rebar get-deps
	./rebar compile
```

Then add the following includes into any module requiring the form

```erlang
	-include_lib("sigma_form/include/records.hrl").
```

## Usage

```erlang
	#sigma_form{data=PlayerData, fields=[
		{name, "Your name"},
		{email, "Your email Address"},
		{class, "Preferred Class", {dropdown, [
			{"D","Druid"},
			{"H"," Hunter"},
			{"B", "Bard"},
			{"F", "Fighter"}]}},
		{description, "Tell us about yourself", textarea}
	]},
	#button{text="Create Character", postback=create}
```

The `data` attribute can be any of the following:
  + A [proplist](http://www.erlang.org/doc/man/proplists.html) containing the data.
  + A [dict](http://www.erlang.org/doc/man/dict.html) containing the data.
  + A function with arity 1. This function will be called for each field as
    `LookupFun(FieldName)`. For example, this could be used to retrieve a
    single field value from a database.
  + With the release of Erlang R17, it will support
    [maps](https://github.com/psyeugenic/eep/blob/egil/maps/eeps/eep-0043.md).

The format for the `fields` attribute is any of the following formats:

```erlang
	{Fieldid, Label},
	{Fieldid, Label, Type},
	{Fieldid, Label, Type, Options}
```

  + `Fieldid` will be the ID the generated element, and is also the key of the
    related data in the `data` attribute.
  + `Label` is just the text label for the element
  + `Type` is either the atoms `textbox`, `textarea`, `password`, `date`, or the
    tuple `{dropdown, DropdownOptions}`, or any acceptable value for an HTML
    input's `type` attribute
  + `Options`, is a proplist, which currently supports one option: `{placeholder,
    "Placeholder Text"}` and which only works on textboxes and textareas.
  + `DropdownOptions` is a list of options which are acceptable as the `options`
    attribute of the [#dropdown](http://nitrogenproject.com/doc/elements/dropdown.html)

**Note:** If any item in the `fields` attribute does not match one of the above
formats, the value is passed through anyway.  This allows you to include more
elaborate controls or breaks that include just text, or anything in between.

**Note** `sigma_form` does not do any postbacks, buttons, or validations.
That is up to you.

## License

Copyright (c) 2013, [Jesse Gumm](http://sigma-star.com/page/jesse)
([@jessegumm](http://twitter.com/jessegumm))

MIT License
