%% Author: Aliaksandr Karasiou
%% Email: aliaksandr12@yahoo.com
%% Personal number: 0736796331
%% www.parken.se (part 1) parser

%% initializing module/ exporting functions
-module(parken_start).
-export([get_info/0, init_m1/1, init_m2/1]).

%%% Internal functions, Tomasz
-export([makeref/0, loop/0]).
%%% // Tomasz

%% starts the module, runs inets libraries for http requests, creates a 
%% template for an Event, passes Event to two different functions.
get_info() ->

    inets:start(),
    Name = [],
    Description = [],
    Time = [],
    Date = [],
    Picture = [],
    Event = [Name, Description, Time, Date, Picture],
    

   
    init_m1(Event),
    init_m2(Event),

%%% Added a couple of lines to incorporate server messaging, Tomasz
    srv ! {done, self()},
    loop().
%%% // Tomasz

%%% Creates the unique reference for the parser, only used by the server, Tomasz
makeref() ->
    make_ref().
%%% // Tomasz 


%% Gets a source code from the web page (1st month in Parken calender)
%% and passes it (Body = source code) to another function.
init_m1(Event) ->
     {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
	httpc:request("http://parken.se/kalender?m=1"),
    get_links(Body, Event).

%% Gets a source code from the web page (2st month in Parken calender)
%% and passes it (Body = source code) to another function.
init_m2(Event) ->  
      {ok, {{_Version2, 200, _ReasonPhrase2}, _Headers2, Body2}} =
 	httpc:request("http://parken.se/kalender?m=2"),
    get_links(Body2, Event).

%% function goes through all source code of calender's month and is looking for
%% specified tag  in order to find a place in source code where the link is 
%% situated. Once it's found, it passes the source code to another function
get_links([$t,$i,$t,$l,$e,$t,$e,$x,$t,$",$ ,$h,$r,$e,$f,$=,$"|T], Event) ->
    take_link(T, [], Event);
get_links([_H|T], Event) -> 
    get_links(T, Event);
get_links([], _Event) ->  ok.

%% Takes sources code which always starts from some link (thanks to "get_links"
%% function and extracts the link into variable "List" until required tag.
%% When it is extracted it gets a source code for the event that matches this 
%% link(Body) and passes (spawns a process) it to another module for parsing 
%% the information. After it calls "get_links" again in order to find next link
%% for an event.
take_link([$"|T], List, Event) ->    
    NewLink = lists:reverse(List),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
	httpc:request("http://parken.se" ++ NewLink),
    parken:check_text(Body, Event),  
    get_links(T, Event);
take_link([H|T], List, Event) ->
    take_link(T, [H|List], Event).


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
%%% // Tomasz
