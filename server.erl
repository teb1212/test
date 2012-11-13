-module(server).
-compile(export_all).

start() ->
    Pid = spawn(?MODULE, init, []),
    try register(srv, Pid)
    catch
	error:badarg ->
	    Pid ! {stop, self()}
    end,
    {ok, whereis(srv)}.

stop() ->
    case whereis(srv) of
	undefined ->
	    already_stopped;
	_ ->
	    srv ! {stop, self()},
	    receive
		Msg ->
		    Msg
	    end
    end,
    stop_prc(),
    tercon().

stop_prc() ->
    case whereis(parser_parken_start) of
	undefined ->
	    already_stopped;
	_  ->
	    parser_parken_start ! stop
    end,
    case whereis(sticky_start) of
	undefined ->
	    already_stopped;
	_  ->
	    sticky_start ! stop
    end,
    case whereis(jazzhuset_start) of
	undefined ->
	    already_stopped;
	_  ->
	    jazzhuset_start ! stop
    end,
    case whereis(sprps) of
	undefined ->
	    already_stopped;
	_ ->
	    sprps ! stop
    end.

launch() ->
    case whereis(srv) of
	undefined ->
	    not_running;
	_ ->
	    srv ! {fire, self()},
	    receive
		Msg ->
		    Msg
	    end
    end.

tercon() ->
    inets:stop().

%Needs revision

update() ->
    srv ! {update, self()},
    receive
	Msg ->
	    Msg
    end.

init() ->
    process_flag(trap_exit, true),
    loop().

loop() ->
    receive
	{stop, Pid} ->
	    Pid ! stopped;
	{fire, Pid} ->
	    Pid ! {ok, started},
	    tasker(),
	    loop();
	{done, Pid} ->
	    Pid ! {ok, self()},
	    loop();
	{update, Pid} ->
	    Pid ! {ok, updated},
	    ?MODULE:loop();
	{'EXIT', Pid, normal} ->
	    io:format("normal exit ~p~n", [Pid]),
	    loop();
	{'EXIT', Pid, shutdown} ->
	    io:format("shutdown exit ~p~n", [Pid]),
	    loop();
	{'EXIT', Pid, Reason} ->
	    io:format("~p crashed feck~n", [Pid]),
	    io:format("Reason: ~p~n", [Reason]),
	    loop();
	{'DOWN', Ref, process, {Name, Node}, Info} ->
	    io:format("~p~n", [[Ref, {Name, Node}, Info]]),
	    mini_tasker(Name),
	    loop()
    after 900000 ->
	    self() ! {fire, self()},
	    loop()
    end.

mini_tasker(Name) ->
    Pid = spawn_link(fun() -> Name:get_info() end),
    register(Name, Pid),
    erlang:monitor(process, Name).

tasker() ->
    Pid = spawn_link(fun() -> parser_parken_start:get_info() end),
    try register(parser_parken_start, Pid)
    catch
	error:badarg ->
	    Pid ! stop
    end,
    erlang:monitor(process, parser_parken_start),
    Pid2 = spawn_link(fun() -> jazzhuset_start:get_info() end),
    try register(jazzhuset_start, Pid2)
    catch
	error:badarg ->
	    Pid2 ! stop
    end,
    erlang:monitor(process, jazzhuset_start),
    Pid3 = spawn_link(fun() -> sticky_start:get_info() end),
    try register(sticky_start, Pid3)
    catch
	error:badarg ->
	    Pid3 ! stop
    end,
    erlang:monitor(process, sticky_start),
    Pid4 = spawn_link(fun() -> sprps:get_info() end),
    try register(sprps, Pid4)
    catch
	error:badarg ->
	    Pid4 ! stop
    end,
    erlang:monitor(process, sprps).


    
