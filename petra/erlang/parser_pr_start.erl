%% Author: Petra Beczi
%% Email: beczipetra89@gmail.com
%% Personal number: 8903302688
%% www.profilrestauranger.se parser


-module(parser_pr_start).
-export([get_info/0]).

get_info() ->
	%% Function to test parser and display the list
	inets:start(),	
	Place = [],
	Address = [],
	Name = [],
	Description = [],
	Time = [],
	Date = [],
	Picture = [],
	Event = [Place, Address, Name, Description, Time, Date, Picture],
	init(Event).

init(Event) ->
	{ok, {{_Version, 200, _ReasonPhrase}, _Header, Body}} =
		httpc:request("http://www.profilrestauranger.se/evenemang/kategori/tradgarn/"), %%Visit target website and save the HTML content to Body
		%httpc:request("http://192.168.0.11:81/sencha/erlang.html"),
	io:format("Getting the web page...~n"),
	find_entry_urls(Body, Event). %% Parse HTML content Body into Event list and show it

find_entry_urls("<td><strong><a href="++[$"|Rest], Event) -> %% Find URL to event detail page and parse it
 	parse_entry(Rest, [], Event);
find_entry_urls([_H|T], Event) -> %% If current character doesn't match the pattern above move on
 	find_entry_urls(T, Event);
find_entry_urls([],Event) -> 
	Event. %% Return Event list when finishes.

parse_entry([$"|Rest], UrlReversed, Event) ->
	Url = lists:reverse(UrlReversed),
	io:format("Processing entry:" ++ Url ++ "~n"),
	{ok, {{_Version, 200, _ReasonPhrase}, _Header, Body}} =
		httpc:request(Url), %% Visit event detail page and save the HTML content into Body
	NewEvent = parser_simple:parse_entry_body(Body, Event), %% Parse the HTML content and add event information into Event list, the new list will be returned and saved into NewEvent list.
	find_entry_urls(Rest, NewEvent); %% Go back to find_entry_url to find next event URL
parse_entry([H|T], UrlReversed, Event) -> %% Continue 
	parse_entry(T, [H|UrlReversed], Event).
	
