%% Author: Petra Beczi
%% Email: beczipetra89@gmail.com
%% Personal number: 8903302688
%% www.profilrestauranger.se parser

-module(parser_simple).
-export([parse_entry_body/2]).

%% Main Function
parse_entry_body("<h1>" ++ Rest, [Place, Address|Event]) ->
	%% Looking for <h1> and then send the rest of the content into event name parser.
	grab_name(Rest, [], [Place, Address|Event]);
parse_entry_body("Datum: <strong>" ++ Rest,Event)->
	%% Looking for Datum: <strong> pattern and send the content rest into event date parser.
	grab_date(Rest, [], Event);
parse_entry_body("Restaurang:" ++ Rest,Event)-> 
    find_place(Rest, Event);
parse_entry_body("images/uploads/" ++ Rest, Event)->
	%% Looking for image URL pattern and then parse the image URL, event description and event time.
	{NewRest, NewEvent} = grab_picture(Rest, [], Event), %% parse image URL, return the content after it and a new Event list
	DescriptionHTML = crop_description(NewRest), %% keep the event description raw content and drop the rest
	NewEvent2 = grab_time(DescriptionHTML, [], NewEvent), %% parse the event time, if there are any. Return a new Event list
	grab_description(DescriptionHTML, [], [], NewEvent2); %% parse the event description
parse_entry_body([_H|T], Event) -> %% continue if couldn't find any of the patterns
	parse_entry_body(T, Event);
parse_entry_body([], [H1,H2,H3,H4,H5,H6,H7]) ->
         NewH1 = filter_data(H1, []),
         NewH2 = filter_data(H2, []),
         NewH3 = filter_data(H3, []), 	
         io:format("~s~n", [NewH1]),
	 [NewH1,NewH2,NewH3,H4,H5,H6,H7].

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

find_place("\">" ++ Rest, Event) -> 
    grab_place(Rest, [], Event);
find_place([_H|Rest],Event) -> 
    find_place(Rest, Event).
 
grab_place("</" ++ Rest, List, [_Place|Event]) -> 
    add_adress(Rest, [lists:reverse(List)|Event]);
grab_place([H|Rest], List, Event) -> 
    grab_place(Rest, [H|List], Event). 
    
add_adress(Rest, [Place, _H|Event]) ->
  case Place of
	"Trädgår'n" -> Address = "Nya Allen 11411 38 Göteborg",
			Place_2 = "Trädgårn",
		       parse_entry_body(Rest, [Place_2, Address|Event]); 
        "ETT" -> Address = "Kungsportsavenyn 1 41119 Göteborg",
	 	       parse_entry_body(Rest, [Place, Address|Event]); 
        "Rådhuskällaren" -> Address = "Stortorget 2  211 35 Malmö",
	 	       parse_entry_body(Rest, [Place, Address|Event])
       end.
        

grab_name("</h1>" ++ Rest, EventNameReversed, [Place, Address, _Name, Description, Time, Date, Picture]) -> 
%% if meets </h1>, reverse the EventNameReversed and save it into Name List in Event list. Send the content rest to parse_entry_body.
	EventName = lists:reverse(EventNameReversed),
	parse_entry_body(Rest, [Place, Address, EventName, Description, Time, Date, Picture]);
grab_name([H|T], EventNameReversed, Event) ->
	grab_name(T, [H|EventNameReversed], Event).

grab_date(" </strong>" ++ Rest, EventDateReversed, [Place, Address, Name, Description, Time, Date, Picture])-> 
%% if meets </h1>, reverse the EventDateReversed and save it into Date List in Event list. Send the content rest to parse_entry_body.
	EventDate = date_formatter(lists:reverse(EventDateReversed)),
	parse_entry_body(Rest, [Place, Address, Name, Description, Time, lists:reverse([EventDate|Date]), Picture]);
grab_date([H|T], EventDateReversed, Event)->
	grab_date(T, [H|EventDateReversed], Event).

grab_picture([$"|Rest], EventPictureReversed, [Place, Address, Name, Description, Time, Date, Picture])-> 
%% if meets ", reverse the EventPictureReversed and add the prefix. Then save it into Picture List in Event list. Send the content rest to parse_entry_body.
	EventPicture = "http://www.profilrestauranger.se/images/sized/images/uploads/" 
		++ lists:reverse(EventPictureReversed),
	{Rest, [Place, Address, Name, Description, Time, Date, lists:reverse([EventPicture|Picture])]};
grab_picture([H|T], EventPictureReversed, Event)->
	grab_picture(T, [H|EventPictureReversed], Event).

grab_time("ppnar: " ++ [H|T], [], Event)->
%% if it meets "ppnar: " and EventTimeReversed is empty, save the content into EventTimeReversed list and call itself again.
	grab_time(T, [H], Event);
grab_time("<br />" ++ Rest, [], Event) ->
%% If no time is included in the event page, keep EventTimeReversed empty.
    grab_time(Rest, [], Event);
grab_time("<br />"  ++ _Rest, EventTimeReversed, [Place, Address, Name, Description, Time, Date, Picture])->
%% if it meets "<br />", then the time entry is passed. Reverse EventTimeReversed and save it into Time list in Event list, return the new Event list.
	EventTime = lists:reverse(EventTimeReversed),
	[Place, Address, Name, Description, lists:reverse([EventTime|Time]), Date, Picture]; %return the new Event list.
grab_time([_H|T], [], Event) ->
%% if none of the pattern above matches and EventTimeReversed list is empty, continue looking and don't save anything
	grab_time(T, [], Event);
grab_time([H|T], EventTimeReversed, Event)->
%% if none of the pattern above matches and EventTimeReversed list is not empty, continue saving H into EventTimeReversed list and continue with T
	grab_time(T, [H|EventTimeReversed], Event);
grab_time([], [], [Place, Address, Name, Description, Time, Date, Picture]) ->
%% if none is left and EventTimeReversed is empty, then return with an empty EventTime in the list.
	[Place, Address, Name, Description, lists:reverse([[]|Time]), Date, Picture]. %return the result with empty time

crop_description("<p>" ++ Rest) ->
%% when see <p>, that means main content of the event starts, send the rest of the content to save_description_HTML, and return its result.
	return_descrition_HTML(Rest, []);
crop_description([_H|T]) ->
	crop_description(T).

return_descrition_HTML("<p><a href" ++ _Rest, DescriptionHTML) ->
%% when meets "<p><a href", that means the main content of the event ends, reverse the saved HTML content and return it as result.
	lists:reverse(DescriptionHTML);
return_descrition_HTML([H|T], DescriptionHTML) ->
	return_descrition_HTML(T, [H|DescriptionHTML]).

grab_description("</p>" ++ Rest, EventDescriptionReversed, EventDescription, Event)->
%% when sees </p>, that means a paragraph is finished, reverse EventDescriptionReversed and add the result into current EventDescription list.
%% call itself again with an empty EventDescriptionReversed and the rest of the content
	NewEventDescription = lists:reverse(EventDescriptionReversed),
	grab_description(Rest, [], [NewEventDescription|EventDescription], Event);
grab_description("<p>" ++ Rest, EventDescriptionReversed, EventDescription, Event) ->
%% when sees <p>, that means a new paragraph starts, call it itself again with the rest of the content.
	grab_description(Rest, EventDescriptionReversed, EventDescription, Event);
grab_description("<br />" ++ Rest, EventDescriptionReversed, EventDescription, Event) ->
%% when sees <br />, omit it and call itself again with the rest of the content
	grab_description(Rest, EventDescriptionReversed, EventDescription, Event);
grab_description("<a href=" ++ Rest, EventDescriptionReversed, EventDescription, Event)->
%% when sees <a href=, call itself with the hyperlink removed content
	grab_description(omit_link(Rest, []), EventDescriptionReversed, EventDescription, Event);
grab_description("<span class=" ++ Rest, EventDescriptionReversed, EventDescription, Event) ->
%% when sees a <span class=, call itself with the tag removed content
	grab_description(remove_span(Rest, []), EventDescriptionReversed, EventDescription, Event);
grab_description([_H, 165|Rest], EventDescriptionReversed, EventDescription, 
		 Event) ->
    grab_description([229|Rest], EventDescriptionReversed, EventDescription, 
		     Event);
grab_description([_H, 164|Rest], EventDescriptionReversed, EventDescription, 
		 Event) ->
    grab_description([228|Rest], EventDescriptionReversed, EventDescription, 
		     Event);
grab_description([_H, 182|Rest], EventDescriptionReversed, EventDescription, 
		 Event) ->
    grab_description([246|Rest], EventDescriptionReversed, EventDescription, 
		     Event);
grab_description([_H, 160|Rest], EventDescriptionReversed, EventDescription, 
		 Event) ->
    grab_description([32|Rest], EventDescriptionReversed, EventDescription, 
		     Event);
grab_description([_H, 169|Rest], EventDescriptionReversed, EventDescription, 
		 Event) ->
    grab_description([233|Rest], EventDescriptionReversed, EventDescription, 
		     Event);
grab_description([226, _H1, _H2|Rest], EventDescriptionReversed, 
		 EventDescription, Event) ->
    grab_description(Rest, EventDescriptionReversed, EventDescription, Event);
grab_description([$&, $#, $8, $2, $1, $7, $;|Rest], EventDescriptionReversed, 
		 EventDescription, Event) ->
    grab_description([$'|Rest], EventDescriptionReversed, EventDescription, 
		     Event);
grab_description([$&, $#, $3, $8, $;|Rest], EventDescriptionReversed, 
		 EventDescription, Event) ->
    grab_description([$&|Rest], EventDescriptionReversed, EventDescription,
		     Event);
grab_description([$&, $#, $8, $2, $3, $0, $;|Rest], EventDescriptionReversed, 
		 EventDescription, Event) ->
    grab_description([$.,$.,$.|Rest], EventDescriptionReversed, 
		     EventDescription, Event);
grab_description([$&, $#, $8, $2, $1, $1, $;|Rest], EventDescriptionReversed, 
		 EventDescription, Event) ->
    grab_description([$-|Rest], EventDescriptionReversed, 
		     EventDescription, Event);
grab_description([$&, $#, $8, $2, $2, $0, $;|Rest], EventDescriptionReversed, 
		 EventDescription, Event) ->
    grab_description([$\"|Rest], EventDescriptionReversed, 
		     EventDescription, Event);
grab_description([$&, $#, $8, $2, $2, $1, $;|Rest], EventDescriptionReversed, 
		 EventDescription, Event) ->
    grab_description([$\"|Rest], EventDescriptionReversed, 
		     EventDescription, Event);
grab_description([H|T], EventDescriptionReversed, EventDescription, Event)->
%% nothing above matches, save the current character into EventDescriptionReversed and continue
	grab_description(T, [H|EventDescriptionReversed], EventDescription, Event);
grab_description([], EventDescriptionReversed, EventDescription, [Place, Address, Name, Description, Time, Date, Picture]) ->
%% nothing left ot parse, reverse EventDescriptionReversed and add it into EventDescription list. 
%% Then add EventDescription list into Description list in Event list.
	NewEventDescription = lists:reverse(EventDescriptionReversed),
	EventDescriptionList = lists:reverse([NewEventDescription|EventDescription]),
	parse_entry_body([], 
		[
		Place, 
		Address, 
		Name, 
		lists:reverse([string:join(EventDescriptionList, "")|Description]),
		Time,
		Date,
		Picture
		]).

omit_link("</a>" ++ Rest, TextReversed) ->
%% when meets </a>, that means a hyperlink tag finishes, reverse the tag content and return it together with the rest of the content
	lists:reverse(TextReversed)++Rest;
omit_link(">" ++ [H|T], []) ->
%% when meets > and the TextReversed list is empty. Put H into the list and continue
	omit_link(T, [H]);
omit_link([_H|T], []) ->
%% if nothing matches above and TextReversed list is empty. continue.
	omit_link(T, []);
omit_link([H|T], TextReversed) ->
%% if nothing matches above and TextReversed list is not empty. save H into TextReversed and continue.
	omit_link(T, [H|TextReversed]).

remove_span("</span>" ++ Rest, TextReversed) ->
%% when meets </span>, that means a span tag finishes, reverse the tag content and return it together with the rest of the content
	lists:reverse(TextReversed) ++ Rest;
remove_span(">" ++ [H|T], []) ->
%% when meets > and the TextReversed list is empty. Put H into the list and continue
	remove_span(T, [H]);
remove_span([_H|T], []) ->
%% if nothing matches above and TextReversed list is empty. continue.
	remove_span(T, []);
remove_span([H|T], TextReversed) ->
%% if nothing matches above and TextReversed list is not empty. save H into TextReversed and continue.
	remove_span(T, [H|TextReversed]).

date_formatter(Date) -> 
	ReversedDate = lists:reverse(Date),
	{ReversedYear, Rest} = lists:split(4, ReversedDate),
	ReversedMonth = lists:sublist(Rest, 2, 3),
	ReversedDay = fix_date(lists:sublist(Rest, 5, 3)),
	%% Returns in "2012-01-13" format
	[lists:reverse(ReversedYear), $-, convert_month_to_digit(lists:reverse(ReversedMonth)), $-, lists:reverse(ReversedDay)]. 


fix_date(Date) ->
         case Date of
	" 1" -> "10";
        " 2" -> "20";
        " 3" -> "30";
        " 4" -> "40";
        " 5" -> "50";
        " 6" -> "60";
        " 7" -> "70";
        " 8" -> "80";
        " 9" -> "90";
         [H|T] -> T
        end.


convert_month_to_digit("jan") -> "01";
convert_month_to_digit("feb") -> "02";
convert_month_to_digit("mar") -> "03";
convert_month_to_digit("apr") -> "04";
convert_month_to_digit("maj") -> "05";
convert_month_to_digit("jun") -> "06";
convert_month_to_digit("jul") -> "07";
convert_month_to_digit("aug") -> "08";
convert_month_to_digit("sep") -> "09";
convert_month_to_digit("oct") -> "10";
convert_month_to_digit("nov") -> "11";
convert_month_to_digit("dec") -> "12".
