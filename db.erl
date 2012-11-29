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

start([Place, _Address, Name, Desc, _Time, Date, Img_url]) ->
%start()->
    % Start a new ODBC server. The application must already be started.
     odbc:start(),
                                        
    % Connect to the database.
    {ok,Ref}  = odbc:connect(?ConnectStr,[]),

    
% We are quering a wordpress database so we use the wp_tables to have compatibility with the worpress.
% That's why sometimes like this query that follows I have add additional fields which we don't use 
% the wordpress is using 
%Img_url_string = "<img class=""alignright"" title="++Place++" src="++Img_url++" width="126" height="252" />",
%Img_url_string = "<img class=""alignright"" title=""Parkeb"" src=""'"++Img_url++"'""alt="" width=""126"" height=""252""/>",

Img_url_string  = "<img class= \"alignright\"  title=\""++Place++"\" src=\""++Img_url++"\" alt=\"\""" width=\"126\" height=\"180\" />",
	
	Insert_query = "INSERT INTO wp_posts (
	post_author,
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
	comment_count,
	custom_date,
	place
	) VALUES (	
	1,
	'"++Date++" 22:05:53',
	'2012-11-01 22:05:53', 
	'"++Img_url_string++Desc++"',
	'"++Name++"', 
	'"" ',
	'publish', 
	'open', 
	'open',
	'', 
	'post_name', 
	'""', 
	'pinged', 
	'2012-11-01 22:05:53', 
	'2012-11-01 22:05:53', 
	'post_content_filtered', 
	'0', 
	'http://localhost/Machete/?p=12', 
	0, 
	'post',
	'post_mime_type', 
	'0',
	'"++Date++"',
	'"++Place++"'
	)",

	%% Since the parsers are always running we need an asynchronous check method to eliminate duplicates
	%% I first query the database with a unique compination of the event arguments to see if it has already saved.
	%% If not then I insert th new event to the database

    SelectStmt = "SELECT id FROM wp_posts WHERE post_title='"++Name++"' AND place = '"++Place++"' AND custom_date ='"++Date++"'",
 	 Sql1 = odbc:sql_query(Ref, SelectStmt),
    io:format("execute_stmt Select statement returns ~p~n",
             [Sql1]),
		case Sql1 of 
    			Sql1 = {selected,["id"],[]}->
				_Sql3  = odbc:sql_query(Ref, Insert_query);
			Sql1 = {selected,["id"],[_R]} ->
				io:format("Already exists")
			end,  
 
	db_tags:start([Place, Name, Date]),

	%Disconnect
	odbc:disconnect(Ref),
	
	% Stop the server
	odbc:stop(). 
