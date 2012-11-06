-module(jazzhuset_start).
-export([get_info/0]).

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
    set_start(Body, Event).


set_start([$", $k, $o, $m, $m, $a, $n, $d, $e, $e, $v, $e, $n, $t, $"|T],
	                                                        Event) ->
    get_link(T, Event);
set_start([_H|T], Event) -> set_start(T, Event);
set_start([], _Event) ->
    srv ! {done, self()}.


get_link([$h, $r, $e, $f, $=, $"|T], Event) ->
    take_link(T,[], Event);
get_link([_H|T], Event) -> get_link(T, Event);
get_link([], _Event) -> ok. 
 

take_link([$"|T], List, Event) ->    
       NewLink = lists:reverse(List),
 {ok, {{_Version1, 200, _ReasonPhrase1}, _Headers1, Body1}} =
	httpc:request(NewLink), 
    jazzhuset:set_start(Body1, Event), 
    set_start(T, Event);
take_link([H|T], List, Event) ->
    take_link(T, [H|List], Event).

