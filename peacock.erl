-module(peacock).
-compile(export_all).

check_text([$<, $h, $1, $>|T], Event) -> get_name(T,[],Event);

check_text([$c, $l, $a, $s, $s, $=, $\", $i, $m, $a, $g, $e|T], Event) -> find_pic(T, Event);
check_text([$<, $p|T], Event) -> description_p(T,[], Event);
check_text([$K, $o, $m, $m, $a, $n, $d, $e|T], Event) -> find_date(T, Event);
check_text([_H|T], Event) -> check_text(T, Event);
check_text([], [H1,H2,H3,H4,H5]) ->  

    Place = "Peacock",
    Address = "Kungsportsavenyn 21, 411 36 Göteborg",
    NewH4 = take_datum(H4),
    NewH1 = format_name(H1, []),
   Finalevent = [Place, Address, NewH1,H2,H3,NewH4,H5],
    db:start(Finalevent),
    io:format("~s~n" , [NewH1]).



description_p([$>,H|T],List, Event) when [H]=/="<" ->
    take_description_p([H|T],List,Event);
description_p([$<,$/,$p,$>|T],[], Event) ->
    check_text(T, Event);
description_p([$<,$/,$p,$>|T],List, [Name, Description|T2]) ->
    check_text(T,  [Name, [Description|lists:reverse(List)]|T2]);

description_p([_H|T],List,Event) -> description_p(T,List, Event).

take_description_p([$<, $b, $r|T], List,Event) -> 
    Space = "\n",
    description_p(T, [Space|List],Event);
take_description_p([$<|T], List,Event) ->
    description_p([$<|T], List,Event); 
take_description_p([$&, $n, $b, $s, $p, $;|T], List, Event)  -> 
    take_description_p(T, [$&|List], Event);
take_description_p([$&, $a, $m, $p, $;|T], List, Event) -> 
    take_description_p(T, [$&|List], Event);
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
take_description_p([H|T], List,Event) -> 
    take_description_p(T, [H|List],Event).


get_name([$<, $/, $h, $1, $>|T], List, [_Name|T2]) ->

    check_text(T, [lists:reverse(List)|T2]);
get_name([H|T], List, Event) -> get_name(T, [H|List], Event).

format_name([$&, $a, $m, $p, $;|T], List) -> format_name(T, [$&|List]);
format_name([H|T], List) -> format_name(T , [H|List]);
format_name([], List) -> lists:reverse(List). 
    
find_pic([$s, $r, $c, $=, $\"|T], Event) -> get_pic(T,[],Event);
find_pic([_H|T], Event) -> find_pic(T, Event).

get_pic([$\"|T], List, [Name, Description, Time, Date, Picture]) ->
    check_text(T, [Name, Description, Time, Date,
                         [lists:reverse(List)|Picture]]);

get_pic([H|T],List,Event) -> get_pic(T, [H|List], Event);
get_pic([], _List, _Event) -> ok. 


find_date([$s, $i, $n, $g, $l, $e, $\", $>|T], Event) -> store_date(T,[],Event);
find_date([_H|T],Event) -> find_date(T, Event);
find_date([], _Event) -> ok. 




take_datum([$ |T]) -> 
     Day =  lists:reverse(get_day((T), [])),
     Month = get_month((T)),
     NewDatum = "2012-" ++ Month ++ "-" ++ Day,
     NewDatum;
take_datum([_H|T]) -> take_datum(T).

%% Take the value of the Day letter by letter
get_day([$ |_T], List) -> format_day(List);
get_day([H|T], List) ->  get_day(T, [H|List]).
%% Take the value of the Month letter by letter
get_month([$ |T]) -> format_month(T);
get_month([_H|T]) ->  get_month(T).


format_month("jan") ->
    "01";
format_month("feb") ->
    "02";
format_month("mar") ->
    "03";
format_month("apr") ->
    "04";
format_month("maj") ->
    "05";
format_month("jun") ->
    "06";
format_month("jul") ->
    "07";
format_month("aug") ->
    "08";
format_month("sep") ->
    "09";
format_month("okt") ->
    "10";
format_month("nov") ->
    "11";
format_month("dec") ->
    "12";
format_month(List) -> List.

format_day("1") ->
    "10";
format_day("2") ->
    "20";
format_day("3") ->
    "30";
format_day("4") ->
    "40";
format_day("5") ->
    "50";
format_day("6") ->
    "60";
format_day("7") ->
    "70";
format_day("8") ->
    "80";
format_day("9") ->
    "90";
format_day(List) ->
    List.




   
store_date([$<, $/|T], List, Event) -> 
    find_event_name(T,lists:reverse(List), Event);
store_date([H|T], List, Event) ->
    store_date(T, [H|List], Event);
store_date([], _List, _Event) -> ok.




find_event_name([$<, $h, $2, $>|T], Date, Event) -> store_event_name(T, Date, [], Event);
find_event_name([_H|T], Date, Event) ->
    find_event_name(T, Date, Event).

store_event_name([$<, $/, $h, $2|T], Date, List, Event) -> 
    compare_names(T, Date,lists:reverse(List), Event); 
store_event_name([H|T], Date, List, Event) ->
    store_event_name(T, Date, [H|List], Event).
   
compare_names(T, Date, Name, [Name, Description, Time, _Date2|T2]) ->
    check_text(T, [Name, Description, Time, Date|T2]);
compare_names(T,_Date, _Event_name, [Name|T2]) ->
     find_date(T, [Name|T2]).
