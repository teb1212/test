%%%-------------------------------------------------------------------
%%% @author Tomasz Rakalski
%%% @copyright (C) 2012, Tomasz Rakalski
%%% @doc
%%% This module is described thoroughly in the design documentation
%%% for the Machete project.
%%% @end
%%% Created : 19 Nov 2012 by Tomasz Rakalski
%%%-------------------------------------------------------------------

-module(server).

%%% External functions
-export([start/0, stop/0, stopp/0, tercon/0, launch/0, update/0]).

%%% Internal functions
-export([init/1, loop/1, mini_tasker/1, tasker/1]).

%% Launches the server, List contains the names of the parsers
start() ->
    List = [parser_parken_start, sticky_start, jazzhuset_start, sprps],
    Pid = spawn(?MODULE, init, [List]),
    try register(srv, Pid)
    catch
	error:badarg ->
	    Pid ! {stop, self()}
    end,
    {ok, whereis(srv)}.

%% Terminates the server as well as the subprocesses and the inets
%% connection.
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

%% Terminates the subparsers, List contains parser names as well as 
%% their references

%% NEEDS REVISION FOR DEMONITOR !!!
stopp() ->
%    List = [parser_parken_start, sticky_start, jazzhuset_start, sprps],
    
    List = [{parser_parken_start, parser_parken_start:makeref()}, 
	    {sticky_start, sticky_start:makeref()}, 
	    {jazzhuset_start, jazzhuset_start:makeref()}, 
	    {sprps, sprps:makeref()}],

    stopp(List).

stopp([]) ->
    ok;
stopp([{Name, _Ref}|T]) ->
%    erlang:demonitor(Ref),
    case whereis(Name) of
	undefined ->
	    already_stopped;
	_ ->
	    Name ! stop
    end,
    stopp(T).

%% Sends the server a message that tells it to run internal functions
%% that spawn the parsers
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

%% Terminates the inets connection
tercon() ->
    inets:stop().

%% Sends the server a message that makes it run the latest code
update() ->
    srv ! {update, self()},
    receive
	Msg ->
	    Msg
    end.

%% Initializes the event server loop (supervisor enabled)
init(List) ->
    process_flag(trap_exit, true),
    loop(List).

%% Event server loop, takes in custom messages linked to external functions
%% as well as EXIT and DOWN messages used to monitor the processes.
%% Tasker and mini_tasker are used in the server loop to spawn the processes.
%% List contains the names of the parsers.
%% A timeout of (______) is added so that in an event of all parsers terminating,
%% the server will restart them.
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

%% This function is used to respawn a process that shut down.
mini_tasker(Name) ->
    Pid = spawn_link(fun() -> Name:get_info() end),
    register(Name, Pid),
    erlang:monitor(process, Name).

%% Spawns all the parsers, registers them and enables a monitor.
%% Uses a list of parser names to launch them.
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

  
