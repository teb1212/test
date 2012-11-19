%%%-------------------------------------------------------------------
%%% @author Dionysios Papathanopoulos
%%% @copyright (C) 2012, Dionysios Papathanopoulos
%%% @doc
%%% This module is described thoroughly in the design documentation
%%% for the Machete project.
%%% @end
%%% Created : 19 Nov 2012 by Dionysios Papathanopoulos
%%%-------------------------------------------------------------------

-module(db).
-export([start/1]).

% depend on the machine config
-define(DSN, "test").
-define(UID, "machete").
-define(PWD, "machete@1991").
-define(ConnectStr, "DSN=mysql;UID=machete;PWD=machete@1991").

start([Place, Address, Name, Desc, Time, Date, Img_url]) ->
%start()->
    % Start a new ODBC server. The application must already be started.
     odbc:start(),
                                        
    % Connect to the database.
    {ok,Ref}  = odbc:connect(?ConnectStr,[]),

    
% We are quering a wordpress database so we use the wp_tables to have compatibility with the worpress.
% That's why sometimes like this query that follows I have add additional fields which we don't use 
% the wordpress is using 
		
	Insert_query = "INSERT INTO wp_posts (post_author,
	post_date, 
	post_date_gmt, 
	post_content, 
	post_title, 
	post_excerpt, 
	post_status, 
	comment_status, 
	ping_status,
	post_password, 
	post_name, 
	to_ping, 
	pinged, 
	post_modified, 
	post_modified_gmt, 
	post_content_filtered, 
	post_parent, 
	guid, 
	menu_order, 
	post_type, 
	post_mime_type, 
	comment_count) VALUES (	1,
	'2012-11-01 22:05:53',
	'2012-11-01 22:05:53', 
	'"++Desc++"',
	'"++Name++"', 
	'"++Place++" ',
	'publish', 
	'open', 
	'open',
	'', 
	'post_name', 
	'"++Date++"', 
	'pinged', 
	'2012-11-01 22:05:53', 
	'2012-11-01 22:05:53', 
	'post_content_filtered', 
	'0', 
	'http://localhost/Machete/?p=12', 
	0, 
	'post',
	'post_mime_type', 
	0)",

	%% Since the parsers are always running we need an asynchronous check method to eliminate duplicates
	%% I first query the database with a unique compination of the event arguments to see if it has already saved.
	%% If not then I insert th new event to the database

    SelectStmt = "SELECT id FROM wp_posts WHERE post_title='"++Name++"' AND post_excerpt = '"++Place++"' AND to_ping ='"++Date++"'",
    Sql1 = odbc:sql_query(Ref, SelectStmt),
    io:format("execute_stmt Select statement returns ~p~n",
             [Sql1]),
		case Sql1 of 
    			Sql1 = {selected,["id"],[]}->
				Sqd3  =	odbc:sql_query(Ref, Insert_query);
			Sql1 = {selected,["id"],[R]} ->
				io:format("Already exists")
			end,   


	%Disconnect
	odbc:disconnect(Ref),
	
	% Stop the server
	odbc:stop(). 
