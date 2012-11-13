-module(sprps).
-compile(export_all).

calculate() ->
    {Y, M, D} = erlang:date(),
    work({Y, M, D}, 0, []).

work({_, _, _}, 30, List) ->

    lists:reverse(List),
%OUTPUT, PASS TO DB
    io:format("~p~n", [List]);

work({Y, 13, _D}, Acc, List) ->
    work({Y+1, 1, 1}, Acc+1, List);

work({Y, M, D}, Acc, List) ->
%    io:format("~p~n", [{Y, M, D}]),
    case calendar:valid_date(Y, M, D) of
	false ->
	    work({Y, M+1, 1}, Acc, List);
	true ->
	    case calendar:day_of_the_week(Y, M, D) of
		5 ->
%INPUT AREA FOR FIXED WEEKDAYS, NUMBERS REPRESENT WEEKDAYS
		    List2 = List ++ [["Bistrot"], ["Lindholmen"], 
				     ["After Work"], ["After Work @ Bistrot YAY"], 
				     ["16:00"], [Y, M, D], []];
		_ ->
		    List2 = List,
		    ok
	    end,
	    work({Y, M, D+1}, Acc+1, List2)
    end,
    ok.
