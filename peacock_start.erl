%% Author: Krisztian Litavszky
%% Mail: krisztian.litavszky@gmail.com
%% Personal number: 19860926-6153


%% Initializing module & exporting functions.
-module(peacock).
-module(peacock_start).
-compile(export_all).


%% It starts the module, runs inets libraries for http requests and takes source
%% code from a page for extracting event links, creates a 
%% template for an Event, calls a function to find links.
get_info() ->

get_info() ->
    Name = [],
    Description = [],
    Time = "22:00 - 05:00",
    Date = [],
    Picture = [],
    Event = [Name, Description, Time, Date, Picture],
        inets:start(),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
	httpc:request("http://www.peacockdinnerclub.com/club"),
    find_links(Body, Event),
    loop().

makeref() ->
    make_ref().


%% This function goes through all source code and is looking for
%% specified tag  in order to find a place in source code where the link is 
%% situated. Once it's found, it passes the source code to another function

find_links([$K, $o, $m, $m, $a, $n, $d, $e|T], Event) -> find_link(T, Event);
find_links([_H|T], Event) ->
    find_links(T, Event).

find_link([$T, $i, $d, $i, $g, $a, $r, $e|_T], _Event) -> 
    srv ! {done, self()};
find_link([$h, $r, $e, $f, $=, $\"|T], Event) -> get_link(T,[],Event);
find_link([_H|T], Event) ->
    find_link(T, Event).


%% Takes sources code which always starts from some link (thanks to "get_links"
%% function and extracts the link into variable "List" until required tag.
%% When it is extracted it gets a source code for the event that matches this 
%% link(Body) and passes  it to another module for parsing the information. 
%% After it calls "get_links" again in order to find next link for an event.
get_link([$\", $>, $<|T], _List, Event) ->
   find_link(T, Event);
get_link([$\", $>|T], List, Event) ->

  {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
  httpc:request("http://www.peacockdinnerclub.com" ++ lists:reverse(List)),
   peacock:check_text(Body, Event),
   find_link(T, Event);
get_link([H|T], List, Event) ->
    get_link(T, [H|List], Event).

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
