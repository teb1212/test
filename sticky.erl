%% Author: Aliaksandr Karasiou
%% Email: aliaksandr12@yahoo.com
%% Personal number: 0736796331
%% www.stickyfingers.nu (part 2)  parser

%% Initializing module & exporting functions.
-module(sticky).
-export([check_text/2]).
        
%% Main function which goes through source code of event and depending on tags
%% it calls different functions in order to extract different kinds of data.
%% When parsing is finished (source code is finished) Event is sendt to 
%% database module.
check_text([$", $b, $a, $n, $d, $n, $a, $m, $e, $", $>|T], Event) -> 
    take_name(T,[], Event);
check_text([$", $n, $o, $r, $i, $g, $h, $t, $"|T], Event) -> find_pic(T, Event);
check_text([$", $c, $a, $l, $-, $d, $a, $t, $u, $m, $"|T], Event) -> 
    take_date(T, Event);
check_text([$n, $>, $c, $a, $., $ |T], Event) -> take_time(T, Event);
check_text([_H|T], Event) -> check_text(T, Event);
check_text([], [H1, H2, H3, H4|H5]) ->
       Place = "Sticky Fingers",
       Adress = "Kaserntorget 7 41118 Göteborg",
       Finalevent = [Place, Adress, H1, H2, H3, H4, H5],
       db:start(Finalevent),
       io:format("~s~n", [Place]).

%% Function takes source code which starts from the required information 
%% (thanks to "check_text" function), it is storing name to "List" until
%% specified tag. When it is done it is adding extracted name to the "Event" 
%% list.
take_name([$<|T], List, [Name|T2])  ->  
    check_text(T, [lists:reverse([Name|List])|T2]); 
take_name([H|T], List, Event) ->   take_name(T, [H|List], Event).

%% Searches for a date
take_date([$&, $n, $b, $s, $p, $;|T], Event) ->
 add_date(T,[],Event);
take_date([_H|T], Event) -> take_date(T, Event); 
take_date([], _Event) -> ok.

%% Stores date as a day of event, after specified tag it will store a month
%% in separate function.

add_date([$&, $n, $b, $s, $p, $;|T1], List,
	 [Name, Description,Time,Date|T2]) -> 
    add_month(T1, [], [Name, Description, Time, [lists:reverse(List)|Date]|T2]);
add_date([H|T], List, Event) ->
	add_date(T, [H|List], Event);
add_date([], _List, _Event) -> ok.

%% Searches for a month and after extracting it start format function for 
%% it.
add_month([$<|T], List, Event) -> format_month(T,lists:reverse(List),Event);
add_month([H|T], List, Event) -> add_month(T, [H|List], Event); 
add_month([], _List, _Event) -> ok. 

%% format month into a number, get current moth and date, passes everything 
%% to oanother function in order to specify year.
format_month(T1, MList, [Name, Description, Time, Date|T2]) ->
     {Year, Month, _} = erlang:date(),
    case MList of
	"Januari" -> M = 01,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Februari" -> M = 02,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Mars" -> M = 03,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"April" -> M = 04,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Maj" -> M = 05,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Juni" -> M = 06,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Juli" -> M = 07,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Augusti" -> M = 08,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"September" -> M = 09,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"Oktober" -> M = 10,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"November" -> M = 11,
	 add_year(T1, Year, Month, M, [Name, Description, Time, Date|T2]);
	"December" ->  M = 12,
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
%% (thanks to "check_text" function), it takes time as 5 next signs and adds
%% it to "Time" in "Event" list,the order of this information is aways the same
%% at www.stickyfingers.nu
take_time([H1, H2, H3, H4, H5|T1], [Name, Description, Time|T2]) ->
    check_text(T1, [Name, Description, [H1, H2, H3, H4, H5|Time]|T2]).

%% Looking for a place in source code where piture url is.
find_pic([$i, $m, $g, $ , $s, $r, $c, $=, $"|T], Event) ->
     take_pic(T, [], Event);
find_pic([_H|T], Event) -> find_pic(T, Event);
find_pic([], _Event) -> ok. 

%% Function takes source code which starts from the required information 
%% it is extracting picture url to "List" until specified tag, then stores 
%% it into "Picture" in "Event" list. After it found an url, it starts to 
%% searching for description (relying on the order of source page).

take_pic([$"|T], List, [Name, Description, Time, Date|Picture]) -> 
    FullLink = "http://www.stickyfingers.nu/",
    find_description(T, [Name, Description, Time, Date,
		   [FullLink ++ lists:reverse(List)|Picture]]);
take_pic([H|T], List, Event) -> take_pic(T, [H|List], Event).

%% Function searches for description by specified tag.

find_description([$<, $p|T], Event) -> description_p(T,[], Event);
find_description([_H|T], Event) -> find_description(T, Event);
find_description([], _Event) -> ok. 
     
%% Function takes source code after "<p" tag, then checks if next signs are not
%% tags, then it passes source code to another functions to extract information.
%% It also check for a tag which will stop extracting and save info to 
%% "Description" in "Event"; move the info to next line.

description_p([$>,H|T], List, Event) when [H]=/="<" ->
    take_description_p([H|T], List, Event);
description_p([$<,$/,$p,$>|T], List, [Name, Description|T2]) ->
    check_text(T,  [Name, [Description|lists:reverse(List)]|T2]);
description_p([$<, $b, $r, $ , $/|T], List, Event) ->
    Space = "\n",
    description_p(T, [Space|List], Event);
description_p([_H|T], List, Event) -> description_p(T, List, Event).

%% Function stores info to the "List" , moves info to the next line depending
%% on tag, and sends extracted info to "description_p" function if specified 
%% tag is met. In addition due to some formatting problems there is a filter 
%% for swedish letters which fix a problem.

take_description_p([$<, $b, $r|T], List, Event) -> 
    Space = "\n",
    description_p(T, [Space|List], Event);
take_description_p([$<|T], List, Event) ->
    description_p([$<|T], List, Event); 
take_description_p([$&, $a, $m, $p, $;|T], List, Event) -> 
    take_description_p(T, [$&|List], Event);
take_description_p([$&, $n, $b, $s, $p, $;|T], List, Event) -> 
    take_description_p(T, List, Event);
take_description_p([$&, $a, $r, $i, $n, $g, $;|T], List, Event) -> 
    take_description_p(T, [229|List], Event);
take_description_p([$&, $e, $a, $c, $u, $t, $e, $;|T], List, Event) -> 
    take_description_p(T, [233|List], Event);
take_description_p([$&, $A, $r, $i, $n, $g, $;|T], List, Event) -> 
    take_description_p(T, [197|List], Event);
take_description_p([$&, $a, $u, $m, $l, $;|T], List, Event) -> 
    take_description_p(T, [228|List], Event);
take_description_p([$&, $A, $u, $m, $l, $;|T], List, Event) -> 
    take_description_p(T, [196|List], Event);
take_description_p([$&, $o, $u, $m, $l, $;|T], List, Event) -> 
    take_description_p(T, [246|List], Event);
take_description_p([$&, $O, $u, $m, $l, $;|T], List, Event) -> 
    take_description_p(T, [214|List], Event);
take_description_p([$&, $q, $u, $o, $t, $;|T], List, Event) -> 
    take_description_p(T, [$"|List], Event);
take_description_p([H|T], List, Event) -> 
    take_description_p(T, [H|List], Event).
