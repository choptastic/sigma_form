# sigma_form

A simple form generator plugin element for the [Nitrogen Web Framework](http://nitrogenoproject.com)

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
	#sigma_form{data=PlayerData,fields=[
		{name,"Your name"},
		{email, "Your email Address"},
		{class, "Preferred Class", {dropdown, [{"D","Druid"}, {"H"," Hunter"}, {"B", "Bard"}, {"F", "Fighter"}]}},
		{description, "Tell us about yourself", textarea}
	]},
	#button{text="Create Character", postback=create}
```

`PlayerData` can be a prop list, dict, lookup function (arity 1), and after the release of Erlang R17, a map.

The format for the `fields` attribute is any of the following formats:

```erlang
	{Fieldid, Label},
	{Fieldid, Label, Type},
	{Fieldid, Label, Type, Options}
```

+ `Fieldid` will be the ID the generated element, and is also the key of the related data in `PlayerData`.
+ `Label` is just the text label for the element
+ `Type` is either the atoms `textbox`, `textarea`, `password`, or the tuple `{dropdown, DropdownOptions}`
+ `Options`, is a proplist, which currently supports one option: `{placeholder, "Placeholder Text"}` and which only works on textboxes and textareas.
+ `DropdownOptions` is a list of options which are acceptable as the `options` attribute of the [#dropdown](http://nitrogenproject.com/doc/elements/dropdown.html)

## License

Copyright (c) 2013, [Jesse Gumm](http://sigma-star.com/page/jesse)
([@jessegumm](http://twitter.com/jessegumm))

MIT License
