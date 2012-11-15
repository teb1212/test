-module(sprps).
-compile(export_all).

get_info() ->
    {Y, M, D} = erlang:date(),
    work({Y, M, D}, 0, []),
    loop().

work({_, _, _}, 30, List) ->

    lists:reverse(List),
%OUTPUT, PASS TO DB
    io:format("~p~n", [List]),
%Dennis module    db:start(List),
    srv ! {done, self()};

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
		    Place = "Bistrot",
		    Address = "Lindholmen",
		    Name = "After Work",
		    Descr = "After Work @ Bistrot YAY",
		    Time = "16:00",
		    Date = {Y, M, D},
		    Pic = [],
		    List2 = List ++ [Place, Address, 
				     Name, Descr, 
				     Time, Date, Pic];
		6 ->
		    List2 = List,
		    ok;
		7 ->
		    List2 = List,
		    ok;
		_ ->
		    List2 = List,
		    ok
	    end,
	    work({Y, M, D+1}, Acc+1, List2)
    end,
    ok.


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
