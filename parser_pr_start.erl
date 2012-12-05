%% Author: Petra Beczi
%% Email: beczipetra89@gmail.com
%% Personal number: 8903302688
%% www.profilrestauranger.se parser


-module(parser_pr_start).
-export([get_info/0, makeref/0]).

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
    init(Event),
    loop().

makeref() ->
    make_ref().

init(Event) ->
	{ok, {{_Version, 200, _ReasonPhrase}, _Header, Body}} =
httpc:request("http://www.profilrestauranger.se/evenemang/kategori/goteborg/"), 
%%Visit target website and save the HTML content to Body
		%httpc:request("http://192.168.0.11:81/sencha/erlang.html"),
	io:format("Getting the web page...~n"),
	find_entry_urls(Body, Event). %% Parse HTML content Body into Event list and show it

find_entry_urls("<td><strong><a href="++[$\"|Rest], Event) -> %% Find URL to event detail page and parse it
 	parse_entry(Rest, [], Event);
find_entry_urls([_H|T], Event) -> %% If current character doesn't match the pattern above move on
 	find_entry_urls(T, Event);
find_entry_urls([], Event) -> 
    print(Event),
   srv ! {done, self()}.

parse_entry([$"|Rest], UrlReversed, Event) ->
	Url = lists:reverse(UrlReversed),
%	io:format("Processing entry:" ++ Url ++ "~n"),
	{ok, {{_Version, 200, _ReasonPhrase}, _Header, Body}} =
		httpc:request(Url), %% Visit event detail page and save the HTML content into Body
	Newevent = parser_simple:parse_entry_body(Body, Event),
        db:start(Newevent),
%% Parse the HTML content and add event information into Event list, the new 
%% list will be returned and saved into NewEvent list.
        % print(NewEvent),
	find_entry_urls(Rest, Event); %% Go back to find_entry_url to find next event URL
parse_entry([H|T], UrlReversed, Event) -> %% Continue 
	parse_entry(T, [H|UrlReversed], Event).


print([H1, H2, H3, H4, H5, H6, H7]) ->
    print(H1, H2, H3, H4, H5, H6, H7).
print([], [], [], [], [], [], []) ->
    ok;
print([H1|T1], [H2|T2], [H3|T3], [H4|T4], [H5|T5], 
      [H6|T6], [H7|T7]) ->
    Finalevent = [H1, H2, H3, H4, H5, H6, H7],
    print(T1, T2, T3, T4, T5, T6, T7).

%% @author Tomasz Rakalski
%% The function for the process part, waits for messages from the server and
%% runs the process again after 5 mins (after timeout).
loop() ->
    receive
	{ok, _Pid} ->
	    io:format("confirmation received~n"),
	    loop();
	stop ->
	    ok
    after 300000 ->
	    get_info(),
	    loop()
    end.

