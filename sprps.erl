%%%-------------------------------------------------------------------
%%% @author Tomasz Rakalski
%%% @copyright (C) 2012, Tomasz Rakalski
%%% @doc
%%% This module is described thoroughly in the design documentation
%%% for the Machete project.
%%% @end
%%% Created : 19 Nov 2012 by Tomasz Rakalski
%%%-------------------------------------------------------------------

-module(sprps).

%%% External function
-export([get_info/0, update/0]).

%%% Internal functions
-export([makeref/0, work/2, loop/0, filter_data/2]).

%% Starts the parser
get_info() ->
    {Y, M, D} = erlang:date(),
    work({Y, M, D}, 0),
    loop().

update() ->
    sprps ! {update, self()},
    receive
	Msg ->
	    Msg
    end.

%% Creates the unique reference for the parser, only used by the server
makeref() ->
    make_ref().

%% Internal calculations and functionality of the parser, calculates 30 days forward
%% and sends the information to the db module.
work({_, _, _}, 30) ->
    srv ! {done, self()};

%% Once the count reaches 13 on month count, year is flipped forward
work({Y, 13, _D}, Acc) ->
    work({Y+1, 1, 1}, Acc+1);

%% Checks for valid date, if false run again as next month, if true
%% check weekday, if friday/saturday/sunday.
work({Y, M, D}, Acc) ->
    case calendar:valid_date(Y, M, D) of
	false ->
	    work({Y, M+1, 1}, Acc);
	true ->
	    case calendar:day_of_the_week(Y, M, D) of
                %Thursday, condition (needs removal after 20-12-2012)
		4 when Y<20, M==12 ->
		    Place = "Glow",
		    Address = "Kungsportsavenyn 8, 400 16 Göteborg",
		    Name = "Glow Nightclub",
		    Descr = "Varmt välkomna till Göteborgs bästa nattklubb för Dig runt och över 30. Vi har handplockat det bästa från våra favoritklubbar världen över. Allt för att skapa vår version av den ultimata internationella nattklubben. Ett ställe där du kan ta en drink, träffa dina vänner och svepas med av stämningen så mycket att du bara inte kan stå still.

Glow är inte bara nattklubb utan även idealisk för alla sorters privat- och företagsevent. Vi kan ta upp till 140 sittande matgäster och vid stående buffé upp till 300 gäster. Kockarna från Brasserie Lipp ordnar maten – allt från snittar till exklusivaste galamiddagen.

Lokalen är också multimediaanpassad med två projektorer och flera storbildsskärmar för datavisningar, video, dvd, internet o videokonferenser. Klädsel: Vårdad",
		    NDescr = filter_data(Descr, []),
	
		    Time = "23:00 - 03:00",
		    Date = [integer_to_list(Y), $-, integer_to_list(M), $-,
			    integer_to_list(D)],
		    Pic = "http://www.glownightclub.se/wp-content/uploads/2011/06/discotjej1.jpg",
		    List = [Place, Address, Name, NDescr, Time, Date, Pic],
		    io:format("~s~n", [Place]),
		    db:start(List);

                % Friday
		5 ->
		    Place = "Glow",
		    Address = "Kungsportsavenyn 8, 400 16 Göteborg",
		    Name = "Glow Nightclub",
		    Descr = "Varmt välkomna till Göteborgs bästa nattklubb för Dig runt och över 30. Vi har handplockat det bästa från våra favoritklubbar världen över. Allt för att skapa vår version av den ultimata internationella nattklubben. Ett ställe där du kan ta en drink, träffa dina vänner och svepas med av stämningen så mycket att du bara inte kan stå still.

Glow är inte bara nattklubb utan även idealisk för alla sorters privat- och företagsevent. Vi kan ta upp till 140 sittande matgäster och vid stående buffé upp till 300 gäster. Kockarna från Brasserie Lipp ordnar maten – allt från snittar till exklusivaste galamiddagen.

Lokalen är också multimediaanpassad med två projektorer och flera storbildsskärmar för datavisningar, video, dvd, internet o videokonferenser. Klädsel: Vårdad",
		    NDescr = filter_data(Descr, []),
		    Time = "23:00 - 05:00",
		    Date = [integer_to_list(Y), $-, integer_to_list(M), $-,
			    integer_to_list(D)],
		    Pic = "http://www.glownightclub.se/wp-content/uploads/2011/06/discotjej1.jpg",
		    List = [Place, Address, Name, NDescr, Time, Date, Pic],
		    io:format("~s~n", [Place]),
		    db:start(List),
		    Place2 = "Bliss",
		    Address2 = "Magasinsgatan 3, 411 18 Göteborg",
		    Name2 = "Mumbo Jumbo, 25 år",
		    Descr2 = "Nu kör vi för fullt igen !!!

I lagom tid när Afterworken börjar avta kommer Mumbo-gänget och tar vid med gung i musiken och upptåg man inte trodde fanns. Eller har du hört talas om Nötjockey, ismaskinsdyk eller mobil kuddhörna. Det pratas även om pelikaner på bardisken… Grabbarna i Mumbo, Linus Kocken, Henrik Ulleryd, Christoph Schärf & Marcus Ulleryd är lika laddade varje fredag och har alltid nya hyss på gång för att dra igång kvällen. Om man är ute en fredag så se till att ha med Bliss på rundan.",
		    NDescr2 = filter_data(Descr2, []),
		    
		    Time2 = "22.30 - 02.00",
		    Date2 = Date = [integer_to_list(Y), $-, integer_to_list(M), $-,
				    integer_to_list(D)],
		    Pic2 = "http://www.blissresto.com/_images/site/mumbo.jpg",
		    List2 = [Place2, Address2, Name2, NDescr2, Time2, Date2, Pic2],
		    io:format("~s~n", [Place]),
		    db:start(List2);

                % Saturday
		6 ->
		    Place = "Glow",
		    Address = "Kungsportsavenyn 8, 400 16 Göteborg",
		    Name = "Glow Nightclub",
		    Descr = "Varmt välkomna till Göteborgs bästa nattklubb för Dig runt och över 30. Vi har handplockat det bästa från våra favoritklubbar världen över. Allt för att skapa vår version av den ultimata internationella nattklubben. Ett ställe där du kan ta en drink, träffa dina vänner och svepas med av stämningen så mycket att du bara inte kan stå still.

Glow är inte bara nattklubb utan även idealisk för alla sorters privat- och företagsevent. Vi kan ta upp till 140 sittande matgäster och vid stående buffé upp till 300 gäster. Kockarna från Brasserie Lipp ordnar maten – allt från snittar till exklusivaste galamiddagen.

Lokalen är också multimediaanpassad med två projektorer och flera storbildsskärmar för datavisningar, video, dvd, internet o videokonferenser. Klädsel: Vårdad",
		    NDescr = filter_data(Descr, []),
		    Time = "23:00 - 05:00",
		    Date = [integer_to_list(Y), $-, integer_to_list(M), $-,
			    integer_to_list(D)],
		    Pic = "http://www.glownightclub.se/wp-content/uploads/2011/06/discotjej1.jpg",
		    List = [Place, Address, Name, NDescr, Time, Date, Pic],
		    io:format("~s~n", [Place]),
		    db:start(List),
		    Place2 = "Bliss",
		    Address2 = "Magasinsgatan 3, 411 18 Göteborg",
		    Name2 = "DJ Fancy and Friends, 25 år",
		    Descr2 = "Denna dag har vi vår resident, DJ Fancy vid spakarna med undantag för vissa gästspel. DJ Fancy har varit med oss länge och levererar alltid musik på ett sätt som är av absolut världsklass! Ni som ha gästat oss en lördag de senaste åren vet exakt vad vi pratar om. Själva stämningen som är runt 01.00 går inte riktigt att sätta ord på utan måste upplevas på plats. Det är som ett lyckorus, man tappar begreppet om tid och rum och man befinner sig som i en Blissbubbla.",
		    NDescr2 = filter_data(Descr2, []),
		    Time2 = "22.30 - 02.00",
		    Date2 = Date = [integer_to_list(Y), $-, integer_to_list(M), $-,
				    integer_to_list(D)],
		    Pic2 = "http://www.blissresto.com/_images/site/fancy1.jpg",
		    List2 = [Place2, Address2, Name2, NDescr2, Time2, Date2, Pic2],
		    io:format("~s~n", [Place]),   
		    db:start(List2);

                % Sunday
		7 ->
		    ok;
                % Any other day
		_ ->
		    ok
	    end,
% Once the checks have been completed, function runs again
% with the day and total counters incremented by 1.
work({Y, M, D+1}, Acc+1)
    end,
    ok.

%% The function for the process part, waits for messages from the server and
%% runs the process again after 6 hours (after timeout).
loop() ->
    receive
	{ok, _Pid} ->
	    io:format("confirmation received~n"),
	    loop();
	{update, Pid} ->
	    Pid ! {ok, updated},
	    ?MODULE:loop();
	stop ->
	    ok
    after 2160000 ->
	    get_info(),
	    loop()
    end.


%% Author: Aliaksandr Karasiou
%% This function handles the signs specific to the swedish alphabet and processes
%% them so that the entries sent to th DB contain proper signs.
filter_data([_H, 165|T], List) ->
     filter_data(T, [229|List]);
filter_data([_H, 164|T], List) ->
     filter_data(T,[228|List]);
filter_data([_H, 182|T], List)->
     filter_data(T, [246|List]);
filter_data([_H, 160|T], List) -> 
     filter_data(T, [32|List]);
filter_data([_H, 169|T], List) ->
     filter_data(T,[233|List]);
filter_data([195, 150|T], List) ->
    filter_data(T, [214|List]);
filter_data([195, 132|T], List) ->
    filter_data(T, [196|List]);
filter_data([195, 133|T], List) ->
    filter_data(T, [197|List]);
filter_data([H|T], List) ->
     filter_data(T,[H|List]);
filter_data([], List) ->
     lists:reverse(List).

