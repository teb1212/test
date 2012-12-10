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


% This function starts the db module. With method I start ODBC server, connected to db and make 
% the necessary queries to insert the data in the db.
 
start([Place, _Address, Name, Desc, _Time, Date, Img_url]) ->


  %   Start a new ODBC server. The application must already be started.
     odbc:start(),
                                        
    % Connect to the database.
   {ok,Ref}  = odbc:connect(?ConnectStr,[]),

    
% I am quering a wordpress database so we use the wp_tables. 
% I have modify according the wp_tables we are using so there is compatibility with our data and our queries. 


% Create a small String that contects the first 320 charactes of our event description
% We use this String in order to create a preview of the Event for our main page.

Post_excerpt = "<img class= \"alignright\"  title=\""++Place++"\" src=\""++Img_url++"\" alt=\"\""" width=\"126\" height=\"180\" /> "++word_count(320,Desc)++"...click the title for more",


% Contract a the String of the Img url in the way that's compartable with the content of our post.

Img_url_string  = "<img class= \"alignright\"  title=\""++Place++"\" src=\""++Img_url++"\" alt=\"\""" width=\"126\" height=\"180\" /> " ,
	
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
	'"++Post_excerpt++" ',
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
	%% I first query the database with a unique combination of the event arguments to see if it has already saved.
	%% The combination is the name of the event, the place where is happening and the date.
	%% If the event does not exists then I insert the new event to the database.

    SelectStmt = "SELECT id FROM wp_posts WHERE post_title='"++Name++"'AND place = '"++Place++"'AND custom_date ='"++Date++"'",
 	 Sql1 = odbc:sql_query(Ref, SelectStmt),
    io:format("execute_stmt Select statement returns ~p~n",
             [Sql1]),
		case Sql1 of 
   			Sql1 = {selected,["id"],[]}->
				_Sql3  = odbc:sql_query(Ref, Insert_query);
			Sql1 = {selected,["id"],[_R]} ->
				io:format("Already exists");
			Sql1 = {selected,["id"],[_R],[_W]} ->
				io:format("Already exists")
			end,  
 		
	%% We tag every event where is happening so we can generate our tag cloud.
	%% With this function I supply the necessary information to db_tags module.
		db_tags:start([Place, Name, Date]),

	%Disconnect
	odbc:disconnect(Ref),
	
	% Stop the server
	odbc:stop(). 

	% This function counts the number of characters of the post description and returns the 
	% amount of the firsts characters we want to generate the preview of our post description. 

	word_count(N,List)->
	word_count(N,List,[]).
	word_count(0,_,Small) -> reverse(Small);
	word_count(_N,[],Small) -> reverse(Small);
	%word_count(1,[_|[]],Small) -> word_count(0,[],Small);

	word_count(N,[22|List],Small)-> word_count(N-1,List,[32|Small]);
	word_count(N,[32|List],Small)-> word_count(N-1,List,[32|Small]);
	word_count(N,[10|List],Small)-> word_count(N-1,List,[32|Small]);
	word_count(N,[H|List],Small) -> word_count(N-1,List,[H|Small]).

	reverse([]) -> [];
		reverse([H|T]) -> reverse(T)++[H].


