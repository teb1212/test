%% Author: Aliaksandr Karasiou
%% Email: aliaksandr12@yahoo.com
%% Personal number: 0736796331
%% www.jazzhuset.se (part 2)  parser

%% Initializing module & exporting functions.

-module(jazzhuset).
-export([set_start/2]).

%% Function sets a strting point in the source code where it will start 
%% to check the data.
set_start([$\", $l, $e, $f, $t, $c, $o, $n, $t, $e, $n, $t, $\"|T], Event) ->
         check_text(T, Event);
set_start([_H|T], Event) -> set_start(T,Event);
set_start([], _Event) -> ok.

%% Main function which goes through source code of event and depending on tags
%% it calls different functions in order to extract different kinds of data.
%% When parsing is finished (source code is finished) Finalevent is sent to 
%% database module.

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
       io:format("~s~n", [H1]).

%% Function takes source code which starts from the required information 
%% (thanks to "check_text" function), it is storing name to "List" until
%% specified tag. When it is done it is adding extracted name to the "Event" 
%% list. In addition due to some formatting problems there is a filter 
%% for swedish letters which fix a problem.

take_name([$<|T], List, [Name|T2]) ->  
    check_text(T, [lists:reverse([Name|List])|T2]); 
take_name([$&, $#, $0,$3,$8,$;|T], List, Event) -> 
    take_name(T, [$&|List], Event);
take_name([$&, $#, $8, $2, $1, $7, $;|T], List, Event) -> 
    take_name(T, [$'|List], Event);
take_name([$&, $#, $8, $2, $1, $2, $;, $-|T], List, Event) -> 
    take_name(T, [$_,$_|List], Event);
take_name([$&, $#, $8, $2, $3, $0, $;|T], List, Event) -> 
    take_name(T, [$.,$.,$.|List], Event);
take_name([$&, $n, $b, $s, $p, $;|T], List, Event) -> 
    take_name(T, List, Event);
take_name([$&, $a, $m, $p, $;|T], List, Event) -> 
    take_name(T, [$&|List], Event);
take_name([$&, $#, $8, $2, $1, $1, $;|T], List, Event) -> 
    take_name(T, [$-|List], Event);
take_name([_H, 165|T], List, Event) ->
    take_name(T, [229|List], Event);
take_name([_H, 164|T], List, Event) ->
    take_name(T,[228|List], Event);
take_name([_H, 182|T], List, Event)->
    take_name(T, [246|List], Event);
take_name([_H, 160|T], List, Event) ->
    take_name(T, [32|List], Event);
take_name([_H, 169|T], List, Event) ->
    take_name(T,[233|List], Event);
take_name([194|T], List, Event) ->
    take_name(T, List, Event);
take_name([H|T], List, Event) -> take_name(T, [H|List], Event).


%% Function takes source code after "<p" tag, then checks if next signs are not
%% tags, then it passes source code to another functions to extract information.
%% It also check for a tag which will stop extracting and save info to 
%% "Description" in "Event"; move the info to next line.

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


%% Function stores info to the "List" , moves info to the next line depending
%% on tag, and sends extracted info to "description_p" function if specified 
%% tag is met. In addition due to some formatting problems there is a filter 
%% for swedish letters which fix a problem.


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
take_description_p([_H, 165|T], List, Event) ->
    take_description_p(T, [229|List], Event);
take_description_p([_H, 164|T], List, Event) ->
    take_description_p(T,[228|List], Event);
take_description_p([_H, 182|T], List, Event)->
    take_description_p(T, [246|List], Event);
take_description_p([_H, 160|T], List, Event) ->
    take_description_p(T, [32|List], Event);
take_description_p([_H, 169|T], List, Event) ->
    take_description_p(T,[233|List], Event);
take_description_p([194|T], List, Event) ->
    take_description_p(T, List, Event);
take_description_p([H|T], List, Event) -> 
    take_description_p(T, [H|List], Event).

%% Function takes source code which starts from the required information 
%% (thanks to "check_text" function), it stores date to the "List" until
%% specified tag, then it stores it to the "Time" in "Event" list.

take_time([$ |T], List, [Name, Description, Time|T2]) -> 
    check_text(T, [Name, Description,lists:reverse([Time|List])|T2]); 
take_time([H|T], List, Event) -> take_time(T, [H|List], Event).

%% Function takes two signs which represent date and stores it to the "Date"
%% in "Event"

take_date([H1, H2|T1], [Name, Description, Time, Date|T2]) -> 
    check_text(T1, [Name, Description, Time, [H1, H2|Date]|T2]).

%% Function takes first three letters which represent a month, converts it to 
%% the numbers. it also identifies current date for later use in another
%% function (add_year).

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

%% This function compares moth of event and current month. If event month
%% is less than current one, we are adding 1 to current year (next year). 
%% If event month is equal or more than current one, we are adding current
%% year to the date.

add_year(List, Year, Month, M, [Name, Description, Time, Date|T])
                                                         when Month > M ->
    check_text(List,[Name, Description, Time,
              [integer_to_list(Year+1), $-, integer_to_list(M), $-|Date]|T]);
add_year(List, Year, _Month, M, [Name, Description, Time, Date|T]) ->
    check_text(List, [Name, Description, Time, 
              [integer_to_list(Year), $-, integer_to_list(M), $-|Date]|T]).


%% Function takes source code which starts from the required information 
%% (thanks to "check_text" function), it is extracting picture url to "List" 
%% until specified tag, then stores it into "Picture" in "Event" list.
%% In addition due to some formatting problems there is a filter 
%% for swedish letters which fix a problem.

take_pic([$"|T], List,[Name, Description, Time, Date|Picture]) -> 
    check_text(T, [Name, Description, Time, Date, 
                                      [lists:reverse(List)|Picture]]);
take_pic([_H, 165|T], List, Event) ->
    take_pic(T, [229|List], Event);
take_pic([_H, 164|T], List, Event) ->
    take_pic(T,[228|List], Event);
take_pic([_H, 182|T], List, Event)->
    take_pic(T, [246|List], Event);
take_pic([_H, 160|T], List, Event) ->
    take_pic(T, [32|List], Event);
take_pic([_H, 169|T], List, Event) ->
    take_pic(T,[233|List], Event);
take_pic([194|T], List, Event) ->
    take_pic(T, List, Event);
take_pic([H|T], List, Event) -> take_pic(T, [H|List], Event).




