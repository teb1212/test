%% Author: Aliaksandr Karasiou
%% Email: aliaksandr12@yahoo.com
%% Personal number: 0736796331
%% www.jazzhuset.se (part 1) parser
-module(jazzhuset_start).
-export([get_info/0]).

%%% Internal functions, Tomasz
-export([makeref/0, loop/0]).
%%% // Tomasz

%% starts the module, runs inets libraries for http requests, creates a 
%% template for an Event, get the source code of a page (Body) and passes to
%% another function.

get_info() ->

    inets:start(),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
	httpc:request("http://www.jazzhuset.se/"),
    Name = [],
    Description = [],
    Time = [],
    Date = [],
    Picture = [],
    Event = [Name, Description, Time, Date, Picture],
    set_start(Body, Event),
    loop().

%% Creates the unique reference for the parser, only used by the server, Tomasz
makeref() ->
    make_ref().
%% // Tomasz

%% Function searches for a place where it will start to look for links of
%% events.

set_start([$", $k, $o, $m, $m, $a, $n, $d, $e, $e, $v, $e, $n, $t, $"|T],
	                                                        Event) ->
    get_link(T, Event);
set_start([_H|T], Event) -> set_start(T, Event);
set_start([], _Event) ->

    srv ! {done, self()}.

%% Functions finds a place in source where link is starting by a particular
%% tag.

get_link([$h, $r, $e, $f, $=, $"|T], Event) ->
    take_link(T,[], Event);
get_link([_H|T], Event) -> get_link(T, Event);
get_link([], _Event) -> ok. 
 

%% Function extracts a link of an event, get a source code of this page (Body1)
%% and passes it to the module which parses it.
take_link([$"|T], List, Event) ->    
       NewLink = lists:reverse(List),
 {ok, {{_Version1, 200, _ReasonPhrase1}, _Headers1, Body1}} =
	httpc:request(NewLink), 
    jazzhuset:set_start(Body1, Event), 
    set_start(T, Event);
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
