%% Author: Krisztian Litavszky
%% Mail: krisztian.litavszky@gmail.com
%% Personal number: 19860926-6153


%% Initializing module & exporting functions.
-module(peacock).
-compile(export_all).


%% Main function which goes through source code of event and depending on tags
%% it calls different functions in order to extract different kinds of data.
%% When parsing is finished (source code is finished) Event is sended to 
%% database module.

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






%% Function takes source code after "<p" tag, then checks if next signs are not
%% tags, then it passes source code to another functions to extract information.
%% It also check for a tag which will stop extracting and save info to 
%% "Description" in "Event"; move the info to next line.

description_p([$>,H|T],List, Event) when [H]=/="<" ->
    take_description_p([H|T],List,Event);
description_p([$<,$/,$p,$>|T],[], Event) ->
    check_text(T, Event);
description_p([$<,$/,$p,$>|T],List, [Name, Description|T2]) ->
    check_text(T,  [Name, [Description|lists:reverse(List)]|T2]);

description_p([_H|T],List,Event) -> description_p(T,List, Event).

%% Function stores info to the "List" , moves info to the next line depending
%% on tag, and sends extracted info to "description_p" function if specified 
%% tag is met. In addition due to some formatting problems there is a filter 
%% for swedish letters which fix a problem.

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

%% This function searches for event picture in the source code.
    
find_pic([$s, $r, $c, $=, $\"|T], Event) -> get_pic(T,[],Event);
find_pic([_H|T], Event) -> find_pic(T, Event).

%% Function takes source code which starts from the required information 
%% it is extracting picture url to "List" until specified tag, then stores 
%% it into "Picture" in "Event" list. After it found an url, it starts to 
%% searching for description (relying on the order of source page).

get_pic([$\"|T], List, [Name, Description, Time, Date, Picture]) ->
    check_text(T, [Name, Description, Time, Date,
                         [lists:reverse(List)|Picture]]);

get_pic([H|T],List,Event) -> get_pic(T, [H|List], Event);
get_pic([], _List, _Event) -> ok. 

%% This function searches for a date
find_date([$s, $i, $n, $g, $l, $e, $\", $>|T], Event) -> store_date(T,[],Event);
find_date([_H|T],Event) -> find_date(T, Event);
find_date([], _Event) -> ok. 



%% This is a main function to convert the date to our date template.
take_datum([$ |T]) -> 
     Day =  lists:reverse(get_day((T), [])),
     Month = get_month((T)),
     NewDatum = "2012-" ++ Month ++ "-" ++ Day,
     NewDatum;
take_datum([_H|T]) -> take_datum(T).

%% This function takes the value of the day letter by letter
get_day([$ |_T], List) -> format_day(List);
get_day([H|T], List) ->  get_day(T, [H|List]).
%% This function takes the value of the month letter by letter
get_month([$ |T]) -> format_month(T);
get_month([_H|T]) ->  get_month(T).



%% This function helps to convert the month names to numbers. We use YYYY-MM-DD format.

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

%% This function helps to convert and reverse the first ten days of the month. We use YYYY-MM-DD format.

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




%% This function checks the date with the event name. If the event equels with the right date,
%% then it saves it.
store_date([$<, $/|T], List, Event) -> 
    find_event_name(T,lists:reverse(List), Event);
store_date([H|T], List, Event) ->
    store_date(T, [H|List], Event);
store_date([], _List, _Event) -> ok.


%% This function searches for event names.

find_event_name([$<, $h, $2, $>|T], Date, Event) -> store_event_name(T, Date, [], Event);
find_event_name([_H|T], Date, Event) ->
    find_event_name(T, Date, Event).

%% This function stores the event names into databese module.
%% And it checks duplicate as well. See down below.

store_event_name([$<, $/, $h, $2|T], Date, List, Event) -> 
    compare_names(T, Date,lists:reverse(List), Event); 
store_event_name([H|T], Date, List, Event) ->
    store_event_name(T, Date, [H|List], Event).
   
compare_names(T, Date, Name, [Name, Description, Time, _Date2|T2]) ->
    check_text(T, [Name, Description, Time, Date|T2]);
compare_names(T,_Date, _Event_name, [Name|T2]) ->
     find_date(T, [Name|T2]).
