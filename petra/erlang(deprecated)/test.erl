-module(test).
-import(io, [format/1]).
-import(couchbeam).
-export([greetings/0, start_app/0, save_doc/2, get_all_docs/0]).

greetings() -> format("Hello World!~n").

start_app() ->
	application:start(crypto),
	application:start(public_key),
	application:start(ssl),
	application:start(ibrowse),
	application:start(sasl),
	application:start(couchbeam).

connect_db() ->
	couchbeam:server_connection("127.0.0.1", 5984, "", []).

connect_table() ->
	couchbeam:open_db(connect_db(), "test", []).

save_doc(Name, Age) ->
	{ok, Db} = connect_table(),
	couchbeam:save_doc(Db, {[{<<"name">>, Name},{<<"age">>, Age}]}).

get_all_docs() ->
	{ok, Db} = connect_table(),
	couchbeam_view:fetch(Db, 'all_docs', [include_docs]).