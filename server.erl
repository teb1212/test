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
	    Pid ! parsers_launched,
	    tasker(),
	    loop();
	{done, Pid} ->
	    Pid ! {ok, self()},
	    loop();
	{update, Pid} ->
	    Pid ! {ok, updated},
	    loop();
	{'EXIT', Pid, normal} ->
	    io:format("normal exit ~p~n", [Pid]),
	    loop();
	{'EXIT', Pid, shutdown} ->
	    io:format("shutdown exit ~p~n", [Pid]),
	    loop();
	{'EXIT', Pid, Reason} ->
	    io:format("~p crashed feck~n", [Pid]),
	    io:format("Reason: ~p~n", [Reason]),
	    loop()
    after 900000 ->
	    self() ! {fire, self()},
	    loop()
    end.

tasker() ->
    spawn_link(fun() -> parser_parken_start:get_info() end),
    spawn_link(fun() -> jazzhuset_start:get_info() end),
    spawn_link(fun() -> sticky_start:get_info() end).
    
