-module(server).
-compile(export_all).

start() ->
    Pid = spawn(?MODULE, init, []),
    try register(srv, Pid)
    catch
	error:badarg ->
	    Pid ! stop
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

init() ->
    process_flag(trap_exit, true),
    loop().

loop() ->
    receive
	{stop, Pid} ->
	    Pid ! stopped;
	{fire, Pid} ->
	    Pid ! parsers_launched,
%	    parser_parken_start:get_info(),
	    tasker(),
	    loop();
	{done, _Pid} ->
	    io:format("parser finished~n"),
	    loop()
    after 5000 ->
	    self() ! {fire, self()},
	    loop()
    end.

tasker() ->
    spawn(fun() -> parser_parken_start:get_info() end),
    spawn(fun() -> jazzhuset_start:get_info() end).
    
