-module(jazzhuset).
-export([set_start/2]).

set_start([$\", $l, $e, $f, $t, $c, $o, $n, $t, $e, $n, $t, $\"|T], Event) ->
         check_text(T, Event);
set_start([_H|T], Event) -> set_start(T,Event);
set_start([], _Event) -> ok.

check_text([$m, $o, $n, $t, $h, $\", $>|T], Event) -> take_month(T, Event);
check_text([$d, $a, $t, $e, $\", $>|T], Event) -> take_date(T, Event);
check_text([$h, $e, $a, $d, $i,$n,$g, $\", $>|T], Event) ->
        take_name(T, [], Event);
check_text([$<, $p|T], Event) -> description_p(T, [], Event);
check_text([$T, $i, $d, $:, $ |T], Event) -> take_time(T, [], Event); 
check_text([_H|T], Event) -> check_text(T, Event);
check_text([], [H1, H2, H3, H4|H5]) -> 
       Place = "Jazzhuset",
       Adress = "Erik Dahlbergsgatan 3 41126 Göteborg",
       Finalevent = [Place, Adress, H1, H2, H3, H4, H5],
       db:start(Finalevent),
       io:format("~s~n", [Place]).
		

take_month([H1, H2, H3|T1],[Name, Description, Time, Date|T2]) ->
     {Year, Month, _} = erlang:date(),
    case [H1, H2, H3] of
	"Jan" ->  M = 01, 
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Feb" ->  M = 02, 
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Mar" ->  M = 03, 
         add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Apr" ->  M = 04, 
         add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"May" ->  M = 05, 
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Jun" ->  M = 06,
         add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Jul" ->  M = 07, 
         add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Aug" ->  M = 08, 
         add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Sep" ->  M = 09, 
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Oct" ->  M = 10, 
         add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Nov" ->  M = 11, 
         add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Dec" ->  M = 12, 
         add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2])
	 end.
	   
add_year(List, Year, Month, M, [Name, Description, Time, Date|T])
                                                         when Month > M ->
    check_text(List,[Name, Description, Time,
              [integer_to_list(Year+1), $-, integer_to_list(M), $-|Date]|T]);
add_year(List, Year, _Month, M, [Name, Description, Time, Date|T]) ->
    check_text(List, [Name, Description, Time, 
              [integer_to_list(Year), $-, integer_to_list(M), $-|Date]|T]).


take_date([H1, H2|T1], [Name, Description, Time, Date|T2]) -> 
    check_text(T1, [Name, Description, Time, [H1, H2|Date]|T2]).


take_pic([$"|T], List,[Name, Description, Time, Date|Picture]) -> 
    check_text(T, [Name, Description, Time, Date, 
                                      [lists:reverse(List)|Picture]]);
take_pic([H|T], List, Event) -> take_pic(T, [H|List], Event).


take_name([$<|T], List, [Name|T2]) ->  
    check_text(T, [lists:reverse([Name|List])|T2]); 
take_name([$&, $#, $0,$3,$8,$;|T], List, Event) -> 
    take_name(T, [$&|List], Event);
take_name([H|T], List, Event) -> take_name(T, [H|List], Event).


description_p([$>,H|T], List, Event) when [H]=/="<" ->
    take_description_p([H|T], List, Event);
description_p([$s, $r, $c, $=, $\", $h, $t|T], _List, Event) -> 
    take_pic([$h, $t|T], [], Event);
description_p([$<,$/,$a,$>|T], List, Event) -> 
    Space = "\n",
    description_p(T, [Space|List], Event);
description_p([$<,$/,$p,$>|T], [], Event) ->
    check_text(T, Event);
description_p([$<,$/,$p,$>|T], List, [Name, Description|T2]) ->
    check_text(T,  [Name, [Description|lists:reverse([$\n|List])]|T2]);
description_p([_H|T], List, Event) -> description_p(T, List, Event).

take_description_p([$<|T], List, Event) ->
    description_p([$<|T], List, Event); 
take_description_p([$&, $#, $8, $2, $1, $7, $;|T], List, Event) -> 
    take_description_p(T, [$'|List], Event);
take_description_p([$&, $#, $8, $2, $1, $2, $;, $-|T], List, Event) -> 
    take_description_p(T, [$_,$_|List], Event);
take_description_p([$&, $#, $8, $2, $3, $0, $;|T], List, Event) -> 
    take_description_p(T, [$.,$.,$.|List], Event);
take_description_p([$&, $n, $b, $s, $p, $;|T], List, Event) -> 
    take_description_p(T, List, Event);
take_description_p([$&, $a, $m, $p, $;|T], List, Event) -> 
    take_description_p(T, [$&|List], Event);
take_description_p([$&, $#, $8, $2, $1, $1, $;|T], List, Event) -> 
    take_description_p(T, [$-|List], Event);
take_description_p([H|T], List, Event) -> 
    take_description_p(T, [H|List], Event).

take_time([$ |T], List, [Name, Description, Time|T2]) -> 
    check_text(T, [Name, Description,lists:reverse([Time|List])|T2]); 
take_time([H|T], List, Event) -> take_time(T, [H|List], Event).
