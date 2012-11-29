%%% ---------------------------------------------------------------------------
%%% @author Maoyi Huang
%%% @doc
%%% This module is working on extracting the information from the website 
%%% after getting connection to the website.
%%% for the Machete project.
%%% Created : 19 Nov 2012 by Maoyi Huang
%%%----------------------------------------------------------------------------

%% Create the module
-module(nefertiti).
%% Create the main method 
-export([check_text/2]).

%% Create a method called "check_text" that goes through the whole website 
%% and finds the information (name/datum/tid/picture/description) of the 
%% event by searching a specific tag. Each of the information domain is 
%% checked and saved in one list individually.
check_text([$<, $h, $2, $>|T], Event) -> take_name(T,[], Event);
check_text([$D, $a, $t, $u, $m, $<, $/, $d, $t, $>|T],  Event) ->  
    take_datum1(T, Event);
check_text([$T, $i, $d, $<, $/, $d, $t, $>|T], Event) -> 
    take_tid1(T, Event);
check_text([$., $., $/, $i, $m, $g, $/, $p|T],
	   Event) ->  take_pic(T,[], Event);
check_text([$<, $p|T], Event) -> description_p(T,[], Event);
check_text([$<,$/,$d,$l,$>|_T], [H1, H2, H3, H4|H5]) -> 
    Place = "Nefertiti Jazz Club",
    Adress = "Hvitfeldtsplatsen 6411 20 Göteborg.",
    Finalevent = [Place, Adress, H1, H2, H3, H4, H5],
    %db:start(Finalevent);
    %io:format("~s~n",[H4])
       io:format("~s~n", [H4]);
check_text([_H|T], Event) -> check_text(T, Event). 


%% This method is to collect the value of the event's name letter by letter.
take_name([$<|T], List, [Name|T2])  ->  
    check_text(T, [lists:reverse([Name|List])|T2]); 
take_name([H|T], List, Event) ->   take_name(T, [H|List], Event).
          
%% It extracts the whole datum information
take_datum1([$<, $d, $d, $>,_H1,_H2,_H3,_H4|T], Event) -> 
    take_datum(T,[], Event);
take_datum1([_H|T], Event) -> 
    take_datum1(T,Event).

%% It splits the value of 'datum' into two parts and re-formated into 
%% a right way 
take_datum([$<|T], List, [Name, Description, Tid,_Datum|T2]) -> 
     Day =  lists:reverse(get_day(lists:reverse(List), [])),
     Month = get_month(lists:reverse(List)),
     {Year, Curmonth, _} = erlang:date(),
     Newyear = add_year(Year, Curmonth, list_to_integer(Month)),
     NewDatum = Newyear ++ "-" ++ Month ++ "-" ++ Day,
    check_text(T, [Name, Description, Tid, NewDatum|T2]); 
take_datum([H|T], List, Event) -> take_datum(T, [H|List], Event).

%% Author : Aliaksandr Karasiou.
%% This function compares moth of event and current month. If event month
%% is less than current one, we are adding 1 to current year (next year).

add_year(Year, CurMonth, Month) when CurMonth > Month ->
    integer_to_list(Year+1);
add_year(Year, _Month, _M) ->
           integer_to_list(Year).
%% // Aliaksandr Karasiou.

%% Take the value of the Day letter by letter
get_day([$/|_T], List) -> List;
get_day([H|T], List) ->  get_day(T, [H|List]).
%% Take the value of the Month letter by letter
get_month([$/|T]) -> T;
get_month([_H|T]) ->  get_month(T).

%% Due to the duplicated tag issue this method goes to check another 
%% tag to locate the 'Tid'  after the first checking 
take_tid1([$<, $d, $d, $>|T],  Event) ->  take_tid(T,[], Event);
take_tid1([_H|T], Event) -> take_tid1(T,Event).

%% The value of Tid is extracted and saved into a list
take_tid([$<|T], List, [Name, Description, Tid|T2])  ->  
    check_text(T, [Name, Description,lists:reverse([Tid|List])|T2]); 
take_tid([H|T], List, Event) ->   take_tid(T, [H|List], Event).

%% Locate the picture of the event and put it in a list
take_pic([$"|T], List, [Name, Description, Tid, Datum|_Picture]) -> 
    NewPicture = "www.nefertiti.se/img/p" ++ lists:reverse(List),
    check_text(T, [Name, Description, Tid, Datum, NewPicture]);
%take_pic([_H, 165|T], List, Event) ->
%    take_pic(T, [229|List], Event);
%take_pic([_H, 164|T], List, Event) ->
%    take_pic(T,[228|List], Event);
%take_pic([_H, 182|T], List, Event)->
%    take_pic(T, [246|List], Event);
%take_pic([_H, 160|T], List, Event) ->
%    take_pic(T, [32|List], Event);
%take_pic([_H, 169|T], List, Event) ->
%    take_pic(T,[233|List], Event);
%take_pic([226, _H1, _H2|T], List, Event) ->
%    take_pic(T, List, Event);
take_pic([H|T], List, Event) -> take_pic(T, [H|List], Event).


%% This method extracts the description of the event and save it in a list
description_p([$>,H|T],List, Event) when [H]=/="<" ->
    take_description_p([H|T],List,Event);
description_p([$<,$/,$p,$>|T],[], Event) ->
    check_text(T, Event);
description_p([$<,$/,$p,$>|T],List, [Name, Description|T2]) ->
    check_text(T,  [Name, [Description|lists:reverse(List)]|T2]);
description_p([_H|T],List,Event) -> description_p(T,List, Event).


%% This method gets the value of the event's description and does a mis-spelling checking for the description. When there is any wrong sign or letter then it will be fixed and replaced for the wrong one
take_description_p([$<|T], List,Event) ->
    description_p([$<|T], List,Event); 
take_description_p([H|T], List,Event) -> 
    take_description_p(T, [H|List],Event).

    






