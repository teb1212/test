-module(sticky_start).

-export([get_info/0]).

%%% Internal functions, Tomasz
-export([makeref/0, loop/0]).

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

%% Creates the unique reference for the parser, only used by the server
makeref() ->
    make_ref().

get_link([$d, $", $>, $<, $a, $ , $h, $r, $e, $f, $=, $"|T], Event) ->
    take_link(T,[],Event)   ;
get_link([_H|T], Event) -> get_link(T, Event);
get_link([], _Event) -> 

    srv ! {done, self()}.


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
