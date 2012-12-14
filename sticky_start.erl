%% Author: Aliaksandr Karasiou
%% Email: aliaksandr12@yahoo.com
%% Personal number: 0736796331
%% www.stickyfingers.nu (part 1) parser

%% initializing module/ exporting functions

-module(sticky_start).
-export([get_info/0]).

%%% Internal functions, Tomasz
-export([makeref/0, loop/0]).

%% starts the module, runs inets libraries for http requests and takes source
%% code from a page for extracting event links, creates a 
%% template for an Event, calls a function to find links.
get_info() ->

    inets:start(),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
	httpc:request("http://www.stickyfingers.nu/"),
    Name = [],
    Description = [],
    Time = [],
    Date = [],
    Picture = [],
    Event = [Name, Description, Time, Date, Picture],
    get_link(Body, Event),
    loop().

%% Creates the unique reference for the parser, only used by the server, Tomasz
makeref() ->
    make_ref().

%% function goes through all source code and is looking for
%% specified tag  in order to find a place in source code where the link is 
%% situated. Once it's found, it passes the source code to another function
get_link([$d, $", $>, $<, $a, $ , $h, $r, $e, $f, $=, $"|T], Event) ->
    take_link(T,[],Event)   ;
get_link([_H|T], Event) -> get_link(T, Event);
get_link([], _Event) -> 

    srv ! {done, self()}.

%% Takes sources code which always starts from some link (thanks to "get_links"
%% function and extracts the link into variable "List" until required tag.
%% When it is extracted it gets a source code for the event that matches this 
%% link(Body) and passes  it to another module for parsing the information. 
%% After it calls "get_links" again in order to find next link for an event.

take_link([$"|T], List, Event) ->    
    NewLink = lists:reverse(List),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
	httpc:request("http://www.stickyfingers.nu/" ++ NewLink), 
    sticky:check_text(Body, Event),
    get_link(T, Event);
take_link([H|T], List, Event) ->
    take_link(T, [H|List], Event).

%% @author Tomasz Rakalski
%% The function for the process part, waits for messages from the server and
%% runs the process again after 6 hours (after timeout).
loop() ->
    receive
	{ok, _Pid} ->
	    io:format("confirmation received~n"),
	    loop();
	stop ->
	    ok
    after 2160000 ->
	    get_info(),
	    loop()
    end.
