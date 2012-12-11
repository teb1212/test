-module(server_test).
-include_lib("eunit/include/eunit.hrl").


start_test() ->
    List = [parken_start, sticky_start, jazzhuset_start, sprps, 
	    nefertiti_init, parser_pr_start, peacock_start],
    server:start(),
    server:launch(),
    ?assertEqual({ok, started}, srv ! {fire, self()}),
    ?assertEqual({ok, updated}, srv ! {update, self()}),
    listloop(List),
    ?assertEqual(stopped, srv ! {stop, self()}).

listloop([]) ->
    io:format("~nAll done"),
    ok;
listloop([H|T]) ->
    ?assertEqual(ok, H ! stop),
    listloop(T).
	
    
