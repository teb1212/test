%% Author: Aliaksandr Karasiou
%% Email: aliaksandr12@yahoo.com
%% Personal number: 0736796331
%% www.parken.se (part 2)  parser

%% Initializing module & exporting functions.

-module(parken).
-export([check_text/2]).


%% Main function which goes through source code of event and depending on tags
%% it calls different functions in order to extract different kinds of data.
%% When parsing is finished (source code is finished) Event is sent to 
%% database module.

check_text([$<, $h, $1, $>|T], Event) -> 
    take_name(T,[], Event);
check_text([$h, $r, $e, $f, $=, $", $/, $k, $a, $l, $e, $n, $d, $e, $r, $/|T],
	   Event) ->
    take_date(T, Event);
check_text([$i, $m, $g, $E, $v, $e, $n, $t, $", $ , $s, $r, $c, $= ,$"|T],
	   Event) -> 
    take_pic(T,[], Event);
check_text([$<, $p|T], Event) -> 
    description_p(T,[], Event);
check_text([$\", $>, $<, $s, $p, $a, $n|T], Event) -> 
    check_text(T, Event);
check_text([$<, $s, $p, $a, $n|T], Event) -> 
    description_span(T,[], Event);
check_text([$<, $d, $i, $v, $>|T], Event) -> 
    description_div([$>|T],[], Event);
check_text([$<,$e,$m|T], Event) ->  
    description_div(T,[],Event);
check_text([$<, $h, $4, $>|T], Event) -> 
    description_h4(T, [], Event);
check_text([$p, $p, $e, $t, $:, $ |T], Event) ->  
    take_time(T, Event);
check_text([_H|T], Event) -> 
    check_text(T, Event); 
check_text([], [H1, H2, H3, H4|H5]) -> 
       Place = "Parken",
       Adress = "Vasagatan 43 5218 Göteborg",
    Finalevent = [Place, Adress, H1, H2, H3, H4, H5],
    db:start(Finalevent).

%% Function takes source code which starts from the required information 
%% (thanks to "check_text" function), it is storing name to "List" until
%% specified tag. When it is done it is adding extracted name to the "Event" 
%% list. In addition due to some formatting problems there is a filter 
%% for swedish letters which fix a problem.
  
take_name([$<|T], List, [Name|T2])  ->  
    check_text(T, [lists:reverse([Name|List])|T2]); 
take_name([$&, $a, $m, $p, $;|T], List, Event) ->
    take_name(T, [38|List], Event);
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
take_name([226, _H1, _H2|T], List, Event) ->
    take_name(T, List, Event);
take_name([194|T], List, Event) ->
    take_name(T, List, Event);
take_name([195, 150|T], List, Event) ->
    take_name(T, [214|List], Event);
take_name([195, 132|T], List, Event) ->
    take_name(T, [196|List], Event);
take_name([195, 133|T], List, Event) ->
    take_name(T, [197|List], Event);
take_name([H|T], List, Event) ->   
    take_name(T, [H|List], Event).

%% Function takes source code which starts from the required information 
%% (thanks to "check_text" function), it takes date as 10 next signs and adds
%% it to "Date" in "Event" list,the order of this information is aways the same
%%  at www.parken.se

take_date([H1, H2, H3, H4, H5, H6, H7, H8, H9, H10|T1],
	  [Name, Description, Time, Date|T2]) ->
    check_text(T1, [Name, Description, Time,
		[H1,H2,H3,H4,H5,H6,H7,H8,H9,H10|Date]|T2]).

%% Function takes source code which starts from the required information 
%% (thanks to "check_text" function), it is extracting picture url to "List" 
%% until specified tag, then stores it into "Picture" in "Event" list.

take_pic([$"|T], List, [Name, Description, Time, Date|Picture]) -> 
    check_text(T, [Name, Description, Time, Date,
		   [lists:reverse(List)|Picture]]);
take_pic([H|T], List, Event) -> take_pic(T, [H|List], Event).


%% Function takes source code after "<p" tag, then checks if next signs are not
%% tags, then it passes source code to another functions to extract information.
%% It also check for a tag which will stop extracting and save info to 
%% "Description" in "Event"; move the info to next line.

description_p([$>,H|T], List, Event) when [H]=/="<" ->
    take_description_p([H|T], List, Event);
description_p([$<,$/,$p,$>|T], [], Event) ->
    check_text(T, Event);
description_p([$<,$/,$p,$>|T], List, [Name, Description|T2]) ->
    check_text(T,  [Name, [Description|lists:reverse(List)]|T2]);
description_p([$<, $b, $r, $ , $/|T], List, Event) ->
    Space = "\n",
    description_p(T, [Space|List], Event);
description_p([_H|T], List, Event) -> 
    description_p(T, List, Event).

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
    take_description_p(T, [38|List], Event);
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
take_description_p([226, _H1, _H2|T], List, Event) ->
    take_description_p(T, List, Event);
take_description_p([194|T], List, Event) ->
    take_description_p(T, List, Event);
take_description_p([195, 150|T], List, Event) ->
    take_description_p(T, [214|List], Event);
take_description_p([195, 132|T], List, Event) ->
    take_description_p(T, [196|List], Event);
take_description_p([195, 133|T], List, Event) ->
    take_description_p(T, [197|List], Event);
take_description_p([H|T], List, Event) -> 
    take_description_p(T, [H|List], Event).

%% Function takes source code after "<span" tag, then checks next signs are not
%% tags, then it passes source code to another functions to extract information.
%% It also check for a tag which will stop extracting and save info to 
%% "Description" in "Event"; move the info to next line.

description_span([$>,H|T], List, Event) when [H]=/="<" ->
    take_description_span([H|T], List, Event);
description_span([$<,$/,$s, $p, $a, $n ,$>|T], List, [Name, Description|T2]) ->
    check_text(T,  [Name, [Description|lists:reverse(List)]|T2]);
description_span([$<, $b, $r, $ , $/|T], List, Event) ->
    Space = "\n",
  description_span(T, [Space|List], Event);
description_span([_H|T], List, Event) -> description_span(T, List, Event).

%% Function stores info to the "List" , moves info to the next line depending
%% on tag, and sends extracted info to "description_span" function if specified 
%% tag is met. In addition due to some formatting problems there is a filter 
%% for swedish letters which fixes a problem.

take_description_span([$<, $b, $r|T], List, Event) -> 
    Space = "\n",
    description_span(T, [Space|List], Event);
take_description_span([$(,$e,$-,$p,$o,$s,$t,$),$<|T], List, Event) ->
    description_span([$<|T], List, Event); 
take_description_span([$<|T], List, Event) ->
    description_span([$<|T], List, Event); 
take_description_span([$&, $a, $m, $p, $;|T], List, Event) ->
    take_description_span(T, [38|List], Event);
take_description_span([_H, 165|T], List, Event) ->
    take_description_span(T, [229|List], Event);
take_description_span([_H, 164|T], List, Event) ->
    take_description_span(T,[228|List], Event);
take_description_span([_H, 182|T], List, Event)->
    take_description_span(T, [246|List], Event);
take_description_span([_H, 160|T], List, Event) ->
    take_description_span(T, [32|List], Event);
take_description_span([_H, 169|T], List, Event) ->
    take_description_span(T,[233|List], Event);
take_description_span([226, _H1, _H2|T], List, Event) ->
    take_description_span(T, List, Event);
take_description_span([194|T], List, Event) ->
    take_description_span(T, List, Event);
take_description_span([195, 150|T], List, Event) ->
    take_description_span(T, [214|List], Event);
take_description_span([195, 132|T], List, Event) ->
    take_description_span(T, [196|List], Event);
take_description_span([195, 133|T], List, Event) ->
    take_description_span(T, [197|List], Event);
take_description_span([H|T], List, Event) -> 
    take_description_span(T, [H|List], Event).

%% Function takes source code after "<div" tag, then checks next signs are not
%% tags, then it passes source code to another functions to extract information.

description_div([$>,H|T],List, Event) when H =/= $< ->
    take_description_div([H|T], List, Event);
description_div([_H|T], List, Event) ->
    description_div(T, List, Event).

%% Function stores info to the "List", moves info to the next line depending
%% on tag, and sends extracted info to "description_div" function if specified 
%% tag is met. In addition due to some formatting problems there is a filter 
%% for swedish letters which fixes a problem.

take_description_div([$<|T], [H2|_T2], Event)  when H2 == $\n
						     orelse H2 == $\t ->
    check_text(T, Event);
take_description_div([$<,$/|T], [H2|T2], [Name, Description|T3])  ->
    NewList = lists:reverse([H2|T2]),
    check_text(T,  [Name, [Description|[NewList|"\n"]]|T3]);
take_description_div([$<, $b, $r|T], List, Event) -> 
    Space = "\n",
    description_div(T, [Space|List], Event);
take_description_div([$<,$e,$m,$>|T], List, Event) ->
    take_description_div(T, List, Event);
take_description_div([$&, $a, $m, $p, $;|T], List, Event) ->
    take_description_div(T, [38|List], Event);
take_description_div([_H, 165|T], List, Event) ->
    take_description_div(T, [229|List], Event);
take_description_div([_H, 164|T], List, Event) ->
    take_description_div(T,[228|List], Event);
take_description_div([_H, 182|T], List, Event)->
    take_description_div(T, [246|List], Event);
take_description_div([_H, 160|T], List, Event) ->
    take_description_div(T, [32|List], Event);
take_description_div([_H, 169|T], List, Event) ->
    take_description_div(T,[233|List], Event);
take_description_div([226, _H1, _H2|T], List, Event) ->
    take_description_div(T, List, Event);
take_description_div([194|T], List, Event) ->
    take_description_div(T, List, Event);
take_description_div([195, 150|T], List, Event) ->
    take_description_div(T, [214|List], Event);
take_description_div([195, 132|T], List, Event) ->
    take_description_div(T, [196|List], Event);
take_description_div([195, 133|T], List, Event) ->
    take_description_div(T, [197|List], Event);
take_description_div([H|T], List, Event) ->
    take_description_div(T, [H|List], Event).

%% Function stores info to the "List" and stores it to "Description" after 
%% specified tag is met. In addition due to some formatting problems there is 
%% a filter for swedish letters which fixes a problem.
			       
description_h4([$<, $/|T1], List, [Name, Description|T2]) -> 
   check_text(T1,  [Name, [Description|[lists:reverse(List)|"\n"]]|T2]);
description_h4([$&, $a, $m, $p, $;|T], List, Event) ->
    description_h4(T, [38|List], Event);
description_h4([_H, 165|T], List, Event) ->
    description_h4(T, [229|List], Event);
description_h4([_H, 164|T], List, Event) ->
    description_h4(T,[228|List], Event);
description_h4([_H, 182|T], List, Event)->
    description_h4(T, [246|List], Event);
description_h4([_H, 160|T], List, Event) ->
    description_h4(T, [32|List], Event);
description_h4([_H, 169|T], List, Event) ->
    description_h4(T,[233|List], Event);
description_h4([226, _H1, _H2|T], List, Event) ->
    description_h4(T, List, Event);
description_h4([194|T], List, Event) ->
    description_h4(T, List, Event);
description_h4([195, 150|T], List, Event) ->
    description_h4(T, [214|List], Event);
description_h4([195, 132|T], List, Event) ->
    description_h4(T, [196|List], Event);
description_h4([195, 133|T], List, Event) ->
    description_h4(T, [197|List], Event);
description_h4([H|T], List, Event) -> 
    description_h4(T, [H|List], Event).

%% Function takes source code which starts from the required information 
%% (thanks to "check_text" function), it takes time as 5 next signs and adds
%% it to "Time" in "Event" list,the order of this information is aways the same
%% at www.parken.se

take_time([H1, H2, H3, H4, H5|T1], [Name, Description, Time|T2]) ->
    check_text(T1, [Name, Description, [H1, H2, H3, H4, H5|Time]|T2]).









    			       


