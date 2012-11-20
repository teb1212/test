%%%-------------------------------------------------------------------
%%% @author Tomasz Rakalski
%%% @copyright (C) 2012, Tomasz Rakalski
%%% @doc
%%% This module is described thoroughly in the design documentation
%%% for the Machete project.
%%% @end
%%% Created : 19 Nov 2012 by Tomasz Rakalski
%%%-------------------------------------------------------------------

-module(sprps).

%%% External function
-export([get_info/0]).

%%% Internal functions
-export([makeref/0, work/3, loop/0]).

%% Starts the parser
get_info() ->
    {Y, M, D} = erlang:date(),
    work({Y, M, D}, 0, []),
    loop().

%% Creates the unique reference for the parser, only used by the server
makeref() ->
    make_ref().

%% Internal calculations and functionality of the parser, calculates 30 days forward
%% and sends the information to the db module. 
work({_, _, _}, 30, List) ->

    lists:reverse(List),
%OUTPUT, PASS TO DB
    io:format("~p~n", [List]),
%Dennis module    db:start(List),
    srv ! {done, self()};

%% Once the count reaches 13 on month count, year is flipped forward
work({Y, 13, _D}, Acc, List) ->
    work({Y+1, 1, 1}, Acc+1, List);

%% Checks for valid date, if false run again as next month, if true
%% check weekday, if friday/saturday/sunday add data to the List that
%% is being passed around.
work({Y, M, D}, Acc, List) ->
    case calendar:valid_date(Y, M, D) of
	false ->
	    work({Y, M+1, 1}, Acc, List);
	true ->
	    case calendar:day_of_the_week(Y, M, D) of
		% Friday
		5 ->
		    % Input area for fixed recurring information
		    Place = "Bistrot",
		    Address = "Lindholmen",
		    Name = "After Work",
		    Descr = "After Work @ Bistrot YAY",
		    Time = "16:00",
		    Date = [integer_to_list(Y), $-, integer_to_list(M), $-, 
			    integer_to_list(D)],
		    Pic = [],
		    List2 = List ++ [Place, Address, 
				     Name, Descr, 
				     Time, Date, Pic]
		    %DB saving
		    List3 = [Place, Address, Name, Descr, Time, Date, Pic];
		    %db:start(List3);
		
		% Saturday
		6 ->
		    List2 = List,
		    ok;
		% Sunday
		7 ->
		    List2 = List,
		    ok;
		% Any other day
		_ ->
		    List2 = List,
		    ok
	    end,
	    % Once the checks have been completed, function runs again
	    % with the day and total counters incremented by 1.
	    work({Y, M, D+1}, Acc+1, List2)
    end,
    ok.

%% The function for the process part, waits for messages from the server and
%% runs the process again after 5 mins (after timeout).
loop() ->
    receive
	{ok, _Pid} ->
	    io:format("confirmation received~n"),
	    loop();
	stop ->
	    ok
    after 300000 ->
	    get_info(),
	    loop()
    end.
