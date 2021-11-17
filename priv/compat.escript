#!/usr/bin/env escript
%% vim: ts=4 sw=4 et ft=erlang

%% Erlang 17 added maps, but sigma_form is supported before maps existed.
%% Further 17.0 introduced maps:get/2, but 17.1 introduced maps:get/3. So this
%% adds necessary support.
%% Note: This should be run *before* compiling!

main([]) ->
    crypto:start(),

	Filename = "include/compat.hrl",
	io:format("Generating ~p ...~n", [Filename]),

    TypeStrings = process_otp_version(erlang:system_info(otp_release)),

	Contents = [
        "%% Note: This file was automatically generated. Do not include it in source control\n",
        TypeStrings
	],

    ContentsBin = iolist_to_binary(Contents),
    case file:read_file(Filename) of
        {ok, ContentsBin} -> 
            io:format("...no changes needed to ~p. Skipping writing new file~n", [Filename]);
        _ -> 
            io:format("...writing ~p~n", [Filename]),
            file:write_file(Filename, Contents)
    end.

process_otp_version(Version = "R" ++ _) ->
    io:format("sigma_form compat: OTP ~s:~n", [Version]),
    io:format("      + does not support maps...~n"),
    [
        make_map_type_pre_17(),
        make_nomap_macro()
    ];
process_otp_version(Version) ->
    io:format("sigma_form compat: OTP ~s:~n", [Version]),
    io:format("      + supports maps...~n"),
    [
        make_map_type_17_plus(),
        make_map_macro()
    ].

make_map_type_pre_17() ->
    ["-type map() :: 'MAPS_DO_NOT_EXIST'.\n"].

make_map_type_17_plus() ->
    [].

make_map_macro() ->
    ["-define(IS_MAP(M), is_map(M)).\n"
    "-define(MAPS_GET(Key, Map, Default), ",
    case lists:member({get,3}, maps:module_info(exports)) of
        true ->
            io:format("      + supports maps:get/3...~n"),
            "maps:get(Key, Map, Default)";
        false ->
            io:format("      + only supports maps:get/2. Compensating...~n"),
            "?WF_IF(maps:is_key(Key, Map), maps:get(Key, Map), Default)"
    end, " )."].


make_nomap_macro() ->
    ["-define(IS_MAP(M), false).\n",
    "-define(MAPS_GET(Key, Map, Default), throw(maps_not_supported))."].
