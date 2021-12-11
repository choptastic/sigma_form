-module (sigma_form).
-include_lib("nitrogen_core/include/wf.hrl").
-include_lib("sigma_yesno/include/records.hrl").
-include_lib("time_dropdown/include/records.hrl").
-include("records.hrl").
-include("compat.hrl").

-export([
	reflect/0,
	render_element/1,
	get_label/2,
	wrapper_class/1,
	wrapper_selector/1
]).

reflect() -> record_info(fields, sigma_form).

render_element(#sigma_form{class=Class, html_id=HtmlID, data=Data, fields=Fields}) ->
	Body = render_fields(Data, Fields),
	wf_tags:emit_tag('div',Body, [
		{class,Class},
		{id, HtmlID}
	]).

render_fields(Data, Fields) ->
	[render_field(Data, F) || F <- lists:flatten(Fields)].

render_field(Data, #inline_group{header=Header, fields=Fields, class=Class}) ->
    #panel{class=[sigma_form_inline_group, 'form-inline', Class], body=[
        Header,
        render_fields(Data, Fields)
    ]};

render_field(Data, {Field, Label}) ->
	render_field(Data, {Field, Label, textbox});

render_field(Data, {Field, Label, Type}) ->
	render_field(Data, {Field, Label, Type, []});

render_field(Data, {Field, Label, Type, Opts}) ->
	Value = get_value(Data, Field),
	FieldClass = wrapper_class(Field),
	#panel{class=[sigma_form_field_wrapper,'form-group', FieldClass],body=[
		#label{text=Label},
		render_form_field(Field, Value, Type, Opts)
	]};
render_field(_, '-') ->
	#hr{};
render_field(_, Other) ->
	Other.

wrapper_class(Field) ->
	<<"sigma_form_field_",(wf:to_binary(Field))/binary>>.

wrapper_selector(Field) ->
	<<".",(wrapper_class(Field))/binary>>.

render_form_field(Field, Value, textbox, Opts) ->
	#textbox{id=Field,text=Value,class='form-control',placeholder=proplists:get_value(placeholder, Opts)};
render_form_field(Field, Value, date, Opts) ->
	#datepicker_textbox{id=Field,text=Value,class='form-control',placeholder=proplists:get_value(placeholder, Opts), options=Opts};
render_form_field(Field, Value, date_dropdown, Opts) ->
    Format = proplists:get_value(format, Opts, ymd),
    #date_dropdown{id=Field, value=Value, class='form-control', format=Format};
render_form_field(Field, Value, textarea, Opts) ->
    Rows = proplists:get_value(rows, Opts, undefined),
    Cols = proplists:get_value(columns, Opts, undefined),
	#textarea{id=Field,text=Value,class='form-control', rows=Rows, columns=Cols, placeholder=proplists:get_value(placeholder, Opts)};
render_form_field(Field, Value, dropdown, DDOpts) ->
	render_form_field(Field, Value, {dropdown, DDOpts}, []);
render_form_field(Field, Value, {dropdown, DDOpts}, _Opts) ->
	#dropdown{id=Field, value=Value, class='form-control', options=DDOpts};
render_form_field(Field, Value, {year, Min, Max}, _Opts) ->
    #dropdown{id=Field, value=Value, class='form-control', options=make_year_options(Min, Max)};
render_form_field(Field, Value, time, Opts) ->
    render_form_field(Field, Value, {time, "12am", "11:59pm"}, Opts);
render_form_field(Field, Value, {time, From, To}, Opts) ->
    Interval = proplists:get_value(interval, Opts, 60),
    Format = proplists:get_value(format, Opts, "g:ia"),
    IntervalType = proplists:get_value(interval_type, Opts, minutes),
    #time_dropdown{id=Field, value=Value, class='form-control', from=From, to=To, interval=Interval, format=Format, interval_type=IntervalType};
render_form_field(Field, Value, yesno, Opts) ->
	render_form_field(Field, Value, {yesno, "Yes", "No"}, Opts);
render_form_field(Field, Value, {yesno, YesText, NoText}, _Opts) ->
	#yesno{id=Field, value=Value, class='form-control', yes_text=YesText, no_text=NoText};
render_form_field(Field, Value, Type, Opts) ->
	#textbox{id=Field, text=Value, type=Type, class='form-control',placeholder=proplists:get_value(placeholder, Opts)}.

make_year_options(now, Max) ->
    make_year_options(element(1, date()), Max);
make_year_options(Min, now) ->
    make_year_options(Min, element(1, date()));
make_year_options(Min, Max) when is_integer(Min), is_integer(Max), Min=<Max ->
    [{Y,Y} || Y <- lists:seq(Min,Max)];
make_year_options(Min, Max) when is_integer(Min), is_integer(Max), Min>Max ->
    lists:reverse(make_year_options(Max, Min)).

get_value(Data, Field) when ?IS_MAP(Data) ->
    ?MAPS_GET(Field, Data, "");
get_value(Data, Field) when is_function(Data, 1) ->
	Data(Field);
get_value([{_,_}|_]=Data, Field) ->
	case lists:keyfind(Field, 1, Data) of
		false -> "";
		{_,Val} -> Val
	end;
get_value(Dict, Field) when is_tuple(Dict) andalso element(1,Dict)=:=dict ->
	case dict:find(Field, Dict) of
		{ok, Value} -> Value;
		error -> ""
	end;
get_value([], _) ->
	"";
get_value(undefined, _) ->
	"";
get_value(Data, _) ->
	throw({error,{invalid_data_format, Data}}).

get_label(Field, Fields) ->
	case lists:keyfind(Field, 1, Fields) of
		false -> {not_found, Field};
		Rec -> element(2, Rec)
	end.
