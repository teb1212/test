-module(sticky_start).
-compile(export_all).

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

%Tomasz
    
    loop().

get_link([$d, $", $>, $<, $a, $ , $h, $r, $e, $f, $=, $"|T], Event) ->
    take_link(T,[],Event)   ;
get_link([_H|T], Event) -> get_link(T, Event);
get_link([], _Event) -> 

%Tomasz
%    inets:stop(),
    srv ! {done, self()}.


take_link([$"|T], List, Event) ->    
    NewLink = lists:reverse(List),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
	httpc:request("http://www.stickyfingers.nu/" ++ NewLink), 
    sticky:check_text(Body, Event),
    get_link(T, Event);
take_link([H|T], List, Event) ->
    take_link(T, [H|List], Event).

%Tomasz

loop() ->
    receive
	{ok, _Pid} ->
	    io:format("confirmation received~n"),
	    loop();
	stop ->
%	    srv ! {'EXIT', whereis(sticky), shutdown},
	    ok
    after 300000 ->
	    get_info(),
	    loop()
    end.
