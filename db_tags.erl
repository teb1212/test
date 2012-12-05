%%%-------------------------------------------------------------------
%%% @author Dionysios Papathanopoulos
%%% @copyright (C) 2012, Dionysios Papathanopoulos
%%% @doc
%%% This module is described thoroughly in the design documentation
%%% for the Machete project.
%%% @end
%%% Created : 19 Nov 2012 by Dionysios Papathanopoulos
%%%-------------------------------------------------------------------

-module(db_tags).
-export([start/1]).

% depend on the machine config
-define(DSN, "test").
-define(UID, "machete").
-define(PWD, "machete@1991").
-define(ConnectStr, "DSN=mysql;UID=machete;PWD=machete@1991").

start([Place, Name, Date]) ->
%start()->
    % Start a new ODBC server. The application must already be started.
     odbc:start(),
                                        
    % Connect to the database.
    {ok,Ref}  = odbc:connect(?ConnectStr,[]),	
    
	% We are quering a wordpress database so we use the wp_tables to have compatibility with the worpress.
	% That's why sometimes like this query that follows I have add additional fields which we don't use 
	% the wordpress is using 
		
	Insert_query = "INSERT INTO wp_terms (
	name, 
	slug, 
	term_group 
	) VALUES (	
	'"++Place++"',
	'"++Place++"', 
	0)",

	
	%% Since the parsers are always running we need an asynchronous check method to eliminate duplicates
	%% I first query the database with ia unique compination of the event arguments to see if it has already saved.
	%% If not then I insert th new event to the database

    	SelectStmt = "SELECT name FROM wp_terms WHERE name='"++Place++"'",
    	Sql1 = odbc:sql_query(Ref, SelectStmt),
		io:format("Select_1 returns ~p~n", [Sql1]),
			case Sql1 of 
    				Sql1 = {selected,["name"],[]} ->
					 _Sql3  = odbc:sql_query(Ref, Insert_query);				
				Sql1 = {selected,["name"],[_R]} ->
					io:format("Already exists")
			end,

    	Select = "SELECT term_id FROM wp_terms WHERE name='"++Place++"'",
    	Sql5 = odbc:sql_query(Ref, Select),
		io:format("Select_2 returns ~p~n", [Sql5]),
		case Sql5 of
		     Sql5 = {selected, ["term_id"],[]}->
				io:format("Problem_with_term_id");
                     Sql5 = {selected, ["term_id"],[Id_term]}->	
		 	_Sql4  = odbc:sql_query(Ref, "INSERT INTO wp_term_taxonomy (
					term_id,
					taxonomy, 
					description
					) VALUES (
					'"++convert(Id_term)++"',	
					'post_tag',
					'Events that happen at "++Place++"'
					)"),
		
		Select_3 = "SELECT id FROM wp_posts WHERE post_title='"++Name++"' AND custom_date = '"++Date++"' AND place ='"++Place++"'",
    		Sql6 = odbc:sql_query(Ref, Select_3),
    		io:format("Select_3 returns  ~p~n",[Sql6]),
		case Sql6 of
			Sql6 = {selected,["id"],[]}->
				io:format("Problem");
			Sql6 = {selected, ["id"],[Id_post]}->
			_Sql7 = odbc:sql_query(Ref, "INSERT INTO wp_term_relationships (
						object_id,
					 term_taxonomy_id ,
					term_order
					) VALUES (
					'"++convert(Id_post)++"',
					'"++convert(Id_term)++"',
					'0')")
				end
			end,
 	
	%Disconnect
	odbc:disconnect(Ref),
	
	% Stop the server
	odbc:stop().

	convert({X}) ->
		io:format("the ~s~n",[X]),
	X.

