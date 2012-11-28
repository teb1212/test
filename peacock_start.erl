-module(peacock_start).
-compile(export_all).

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

find_links([$K, $o, $m, $m, $a, $n, $d, $e|T], Event) -> find_link(T, Event);
find_links([_H|T], Event) ->
    find_links(T, Event).

find_link([$T, $i, $d, $i, $g, $a, $r, $e|_T], _Event) -> 
    srv ! {done, self()};
find_link([$h, $r, $e, $f, $=, $\"|T], Event) -> get_link(T,[],Event);
find_link([_H|T], Event) ->
    find_link(T, Event).


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

