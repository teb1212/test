%% Author: Petra Beczi
%% Email: beczipetra89@gmail.com
%% www.profilrestauranger.se parser

-module(parser_pr_start).
-compile([export_all]).
-export([get_info/0, init/1]).

get_info() ->
	%% Function to test parser and display the list
	inets:start(),	
	Place = "ProfilRestauranger",
	Address = "Trädgår'n",
	Name = [],
	Description = [],
	Time = [],
	Date = [],
	Picture = [],
	Event = [Place, Address, Name, Description, Time, Date, Picture],
	init(Event).

init([Place, Address|Event]) ->
	{ok, {{Version, 200, ReasonPhrase}, Header, Body}} =
		httpc:request("http://www.profilrestauranger.se/evenemang/kategori/tradgarn/"), %%Visit target website and save the HTML content to Body
	io:format("Getting the web page...~n"),
	display_event_list(Place, Address, find_entry_urls(Body, Event)). %% Parse HTML content Body into Event list and show it

find_entry_urls("<td><strong><a href="++[$"|Rest], Event) -> %% Find URL to event detail page and parse it
 	parse_entry(Rest, [], Event);
find_entry_urls([H|T], Event) -> %% If current character doesn't match the pattern above move on
 	find_entry_urls(T, Event);
find_entry_urls([],Event) ->  Event. %% Return Event list when finishes.

parse_entry([$"|Rest], UrlReversed, Event) ->
	Url = lists:reverse(UrlReversed),
	io:format("Processing entry:" ++ Url ++ "~n"),
	{ok, {{Version, 200, ReasonPhrase}, Header, Body}} =
		httpc:request(Url), %% Visit event detail page and save the HTML content into Body
	NewEvent = parser_simple:parse_entry_body(Body, Event), %% Parse the HTML content and add event information into Event list, the new list will be returned and saved into NewEvent list.
	find_entry_urls(Rest, NewEvent); %% Go back to find_entry_url to find next event URL
parse_entry([H|T], UrlReversed, Event) -> %% Continue 
	parse_entry(T, [H|UrlReversed], Event).

display_event_list(Place, Address, [[Name|T1],[Description|T2],[Time|T3],[Date|T4],[Picture|T5]]) ->
	%% Show the first entry in every coloumn in Event list and remove it from their seperative list. Call
	%% itself again until all the list are empty in Event list.
	io:format("~n~nPlace: [~s]~nAddress:[~ts]~n", [Place, Address]),
	io:fwrite("Name:[~s]~n", [Name]),
	io:format("Description:~n~ts~n", [Description]),
	io:format("Time:[~s]~n", [Time]),
	io:fwrite("Date:[~s]~n", [Date]),
	io:format("Picture:[~s]~n", [Picture]),
	display_event_list(Place, Address, [T1,T2,T3,T4,T5]);
display_event_list(_, _, [[],[],[],[],[]]) ->
	ok.
