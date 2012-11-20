%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-module(parken).
-export([check_text/2]).

check_text([$<, $h, $1, $>|T], Event) -> take_name(T,[], Event);
check_text([$h, $r, $e, $f, $=, $", $/, $k, $a, $l, $e, $n, $d, $e, $r, $/|T],
	   Event) ->
    take_date(T, Event);
check_text([$i, $m, $g, $E, $v, $e, $n, $t, $", $ , $s, $r, $c, $= ,$"|T],
	   Event) -> 
    take_pic(T,[], Event);
check_text([$<, $p|T], Event) -> description_p(T,[], Event);
check_text([$<, $d, $i, $v, $>|T], Event) -> description_div([$>|T],[], Event);
check_text([$<,$e,$m|T], Event) ->  description_div(T,[],Event);
check_text([$p, $p, $e, $t, $:, $ |T], Event) ->  take_time(T, Event);
check_text([$<, $h, $4, $>|T], Event) -> description_h4(T, [], Event);
check_text([_H|T], Event) -> check_text(T, Event); 
check_text([], [H1, H2, H3, H4|H5]) -> 
       Place = "Parken",
       Adress = "Vasagatan 43 5218 Göteborg",
       Finalevent = [Place, Adress, H1, H2, H3, H4, H5],
       %db:start(Finalevent),
       io:format("~s~n", [Place]).
          

take_pic([$"|T], List, [Name, Description, Time, Date|Picture]) -> 
    check_text(T, [Name, Description, Time, Date,
		   [lists:reverse(List)|Picture]]);
take_pic([H|T], List, Event) -> take_pic(T, [H|List], Event).
			       


take_time([H1, H2, H3, H4, H5|T1], [Name, Description, Time|T2]) ->
    check_text(T1, [Name, Description, [H1, H2, H3, H4, H5|Time]|T2]).

description_h4([$<, $/|T1], List, [Name, Description|T2]) -> 
   check_text(T1,  [Name, [Description|[List|"\n"]]|T2]);
description_h4([_H, H1|T], List, Event) when H1 == 165 ->
    description_h4(T, [229|List], Event);
description_h4([_H, H1|T], List, Event) when H1 == 164 ->
    description_h4(T,[228|List], Event);
description_h4([_H, H1|T], List, Event) when H1 == 182 ->
    description_h4(T, [246|List], Event);
description_h4([_H, H1|T], List, Event) when H1 == 160 ->
    description_h4(T, [32|List], Event);
description_h4([_H, H1|T], List, Event) when H1 == 169 ->
    description_h4(T,[233|List], Event);
description_h4([H|T], List, Event) -> 
    description_h4(T, [H|List], Event).

description_p([$>,H|T], List, Event) when [H]=/="<" ->
    take_description_p([H|T], List, Event);
description_p([$<,$/,$p,$>|T], [], Event) ->
    check_text(T, Event);
description_p([$<,$/,$p,$>|T], List, [Name, Description|T2]) ->
    check_text(T,  [Name, [Description|lists:reverse(List)]|T2]);
description_p([$<, $b, $r, $ , $/|T], List, Event) ->
    Space = "\n",
    description_p(T, [Space|List], Event);
description_p([_H|T], List, Event) -> description_p(T, List, Event).


description_div([$>,H|T],List, Event) when H =/= $< ->
    take_description_div([H|T], List, Event);
description_div([_H|T], List, Event) ->
    description_div(T, List, Event).


take_description_div([$<|T], [H2|_T2], Event)  when H2 == $\n
						     orelse H2 == $\t ->
    check_text(T, Event);
take_description_div([$<,$/|T], [H2|T2], [Name, Description|T3])  ->
    NewList = lists:reverse([H2|T2]),
    check_text(T,  [Name, [Description|[NewList|"\n"]]|T3]);

take_description_div([$<,$e,$m,$>|T], List, Event) ->
    take_description_div(T, List, Event);
take_description_div([_H, H1|T], List, Event) when H1 == 165 ->
    take_description_div(T, [229|List], Event);
take_description_div([_H, H1|T], List, Event) when H1 == 164 ->
    take_description_div(T,[228|List], Event);
take_description_div([_H, H1|T], List, Event) when H1 == 182 ->
    take_description_div(T, [246|List], Event);
take_description_div([_H, H1|T], List, Event) when H1 == 160 ->
    take_description_div(T, [32|List], Event);
take_description_div([_H, H1|T], List, Event) when H1 == 169 ->
    take_description_div(T,[233|List], Event);
take_description_div([H|T], List, Event) ->
    take_description_div(T, [H|List], Event).


take_description_p([$<, $b, $r|T], List, Event) -> 
    Space = "\n",
    description_p(T, [Space|List], Event);
take_description_p([$<|T], List, Event) ->
    description_p([$<|T], List, Event); 
take_description_p([_H, H1|T], List, Event) when H1 == 165 ->
    take_description_p(T, [229|List], Event);
take_description_p([_H, H1|T], List, Event) when H1 == 164 ->
    take_description_p(T,[228|List], Event);
take_description_p([_H, H1|T], List, Event) when H1 == 182 ->
    take_description_p(T, [246|List], Event);
take_description_p([_H, H1|T], List, Event) when H1 == 160 ->
    take_description_p(T, [32|List], Event);
take_description_p([_H, H1|T], List, Event) when H1 == 169 ->
    take_description_p(T,[233|List], Event);
take_description_p([H|T], List, Event) -> 
    take_description_p(T, [H|List], Event).
    
			       
take_date([H1, H2, H3, H4, H5, H6, H7, H8, H9, H10|T1],
	  [Name, Description, Time, Date|T2]) ->
check_text(T1, [Name, Description, Time,
		[H1,H2,H3,H4,H5,H6,H7,H8,H9,H10|Date]|T2]).


take_name([$<|T], List, [Name|T2])  ->  
    check_text(T, [lists:reverse([Name|List])|T2]); 
take_name([H|T], List, Event) ->   take_name(T, [H|List], Event).
