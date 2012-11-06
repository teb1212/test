
-module(parser_parken_start).
-export([get_info/0, init_m1/1, init_m2/1]).

get_info() ->
    inets:start(),
    Name = [],
    Description = [],
    Time = [],
    Date = [],
    Picture = [],
    Event = [Name, Description, Time, Date, Picture],
    
    spawn(parser_parken_start, init_m1, [Event]),
    spawn(parser_parken_start, init_m2, [Event]).

init_m1(Event) ->
     {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
	httpc:request("http://parken.se/kalender?m=1"),
    get_links(Body, Event),
    srv ! {done, self()}.

init_m2(Event) ->  
      {ok, {{_Version2, 200, _ReasonPhrase2}, _Headers2, Body2}} =
 	httpc:request("http://parken.se/kalender?m=2"),
    get_links(Body2, Event),
    srv ! {done, self()}.

get_links([$t,$i,$t,$l,$e,$t,$e,$x,$t,$",$ ,$h,$r,$e,$f,$=,$"|T], Event) ->
    take_link(T, [], Event);

get_links([_H|T], Event) -> get_links(T, Event);
get_links([], _Event) ->  ok.


take_link([$"|T], List, Event) ->    
    NewLink = lists:reverse(List),
    {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
	httpc:request("http://parken.se" ++ NewLink),
    spawn(parser_parken, check_text, [Body, Event]),  
    get_links(T, Event);

take_link([H|T], List, Event) ->
    take_link(T, [H|List], Event).
