-module(kitty).
-export([start_link/0, order_cat/4, return_cat/2, close_shop/1]).
-export([init/1, handle_call/3, handle_cast/2]).

-record(cat, {name, color=gren, description}).

start_link() ->
    myserver:start_link(?MODULE, []).

order_cat(Pid, Name, Color, Description) ->
    myserver:call(Pid, {order, Name, Color, Description}).

return_cat(Pid, Cat = #cat{}) ->
    myserver:cast(Pid, {return, Cat}).

close_shop(Pid) ->
    myserver:call(Pid, terminate).

init([]) ->
    [].

handle_call({order, Name, Color, Description}, From, Cats) ->
    if Cats =:= [] ->
	    myserver:reply(From, make_cat(Name, Color, Description)),
	    Cats;
       Cats =/= [] ->
	    myserver:reply(From, hd(Cats)),
	    tl(Cats)
    end;
handle_call(terminate, From, Cats) ->
    myserver:reply(From, ok),
    terminate(Cats).

handle_cast({return, Cat = #cat{}}, Cats) ->
    [Cat|Cats].

make_cat(Name, Col, Desc) ->
    #cat{name=Name, color=Col, description=Desc}.

terminate(Cats) ->
    [io:format("~p was set free.~n", [C#cat.name]) || C <- Cats],
    exit(normal).
