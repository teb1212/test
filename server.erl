-module(server).
-compile(export_all).

start() ->
    List = [parser_parken_start, sticky_start, jazzhuset_start, sprps],
    Pid = spawn(?MODULE, init, [List]),
    try register(srv, Pid)
    catch
	error:badarg ->
	    Pid ! {stop, self()}
    end,
    {ok, whereis(srv)}.

stop() ->
    case whereis(srv) of
	undefined ->
	    io:format("Already stopped!~n");
	_ ->
	    srv ! {stop, self()},
	    receive
		Msg ->
		    Msg
	    end
    end,
    stopp(),
    tercon().

stopp() ->
    List = [parser_parken_start, sticky_start, jazzhuset_start, sprps],
    stopp(List).

stopp([]) ->
    ok;
stopp([H|T]) ->
    %erlang:demonitor(H),
    case whereis(H) of
	undefined ->
	    already_stopped;
	_ ->
	    H ! stop
    end,
    stopp(T).

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

init(List) ->
    process_flag(trap_exit, true),
    loop(List).

loop(List) ->
    receive
	{stop, Pid} ->
	    Pid ! stopped;
	{fire, Pid} ->
	    Pid ! {ok, started},
	    tasker(List),
	    loop(List);
	{done, Pid} ->
	    Pid ! {ok, self()},
	    loop(List);
	{update, Pid} ->
	    Pid ! {ok, updated},
	    ?MODULE:loop(List);
	{'EXIT', Pid, normal} ->
	    io:format("normal exit ~p~n", [Pid]),
	    loop(List);
%Not sure if shutdown exit is necessary
	{'EXIT', Pid, shutdown} ->
	    io:format("shutdown exit ~p~n", [Pid]),
	    loop(List);
	{'EXIT', Pid, Reason} ->
	    io:format("~p crashed feck~n", [Pid]),
	    io:format("Reason: ~p~n", [Reason]),
	    loop(List);
	{'DOWN', Ref, process, {Name, Node}, Info} ->
	    io:format("~p~n", [[Ref, {Name, Node}, Info]]),
	    mini_tasker(Name),
	    loop(List)
    after 900000 ->
	    self() ! {fire, self()},
	    loop(List)
    end.

mini_tasker(Name) ->
    Pid = spawn_link(fun() -> Name:get_info() end),
    register(Name, Pid),
    erlang:monitor(process, Name).

tasker([]) ->
    ok;
tasker([H|T]) ->
    Pid = spawn_link(fun() -> H:get_info() end),
    try register(H, Pid)
    catch
	error:badarg ->
	    Pid ! stop
    end,
    erlang:monitor(process, H),
    tasker(T).

  
