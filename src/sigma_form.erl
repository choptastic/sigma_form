-module (sigma_form).
-include_lib("nitrogen_core/include/wf.hrl").
-include_lib("sigma_yesno/include/records.hrl").
-include("records.hrl").

-export([
	reflect/0,
	render_element/1,
	get_label/2
]).

reflect() -> record_info(fields, sigma_form).

render_element(#sigma_form{class=Class, html_id=HtmlID, data=Data, fields=Fields}) ->
	Body = [render_field(Data, F) || F <- lists:flatten(Fields)],
	wf_tags:emit_tag('div',Body, [
		{class,Class},
		{id, HtmlID}
	]).

render_field(Data, {Field, Label}) ->
	render_field(Data, {Field, Label, textbox});

render_field(Data, {Field, Label, Type}) ->
	render_field(Data, {Field, Label, Type, []});

render_field(Data, {Field, Label, Type, Opts}) ->
	Value = get_value(Data, Field),
	FieldClass = <<"sigma_form_field_",(wf:to_binary(Field))/binary>>,
	#panel{class=[sigma_form_field_wrapper,'form-group', FieldClass],body=[
		#label{text=Label},
		render_form_field(Field, Value, Type, Opts)
	]};
render_field(_, '-') ->
	#hr{};
render_field(_, Other) ->
	Other.

render_form_field(Field, Value, textbox, Opts) ->
	#textbox{id=Field,text=Value,class='form-control',placeholder=proplists:get_value(placeholder, Opts)};
render_form_field(Field, Value, date, Opts) ->
	#datepicker_textbox{id=Field,text=Value,class='form-control',placeholder=proplists:get_value(placeholder, Opts), options=Opts};
render_form_field(Field, Value, textarea, Opts) ->
	#textarea{id=Field,text=Value,class='form-control',placeholder=proplists:get_value(placeholder, Opts)};
render_form_field(Field, Value, {dropdown, DDOpts}, _Opts) ->
	#dropdown{id=Field, value=Value, class='form-control', options=DDOpts};
render_form_field(Field, Value, yesno, Opts) ->
	render_form_field(Field, Value, {yesno, "Yes", "No"}, Opts);
render_form_field(Field, Value, {yesno, YesText, NoText}, _Opts) ->
	#yesno{id=Field, value=Value, class='form-control', yes_text=YesText, no_text=NoText};
render_form_field(Field, Value, Type, Opts) ->
	#textbox{id=Field, text=Value, type=Type, class='form-control',placeholder=proplists:get_value(placeholder, Opts)}.

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
