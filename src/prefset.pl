% % % % % % % % % % % % % % % % % % % % % % % % % % %
% Declarative Programming Project: Stable Matchings %
% Kenny Deschuyteneer                               %
% prefset.pl                                        %
% % % % % % % % % % % % % % % % % % % % % % % % % % %

% :- module(prefset, [from_stream/2]).

:- op(600, xfy, >).

% % % % % % % % % % % % % % % % % % % % % % % % % % %
% A file should have the following structure:       %
%                                                   %
%	man = {woman1, woman2, ..., womanN}.            %
%	women = {man1, man2, ..., manN}.                %
%                                                   %
%	man1 : pref1 > pref2 > .. > prefN.              %
%                                                   %
%	woman1 : pref1 > pref2 > .. > prefN.            %
% % % % % % % % % % % % % % % % % % % % % % % % % % %


% READING
% % % % % % % % % % % % % % % % % %

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% read_file: converts a file into a list which will be parsed.

	read_file(Stream, [Men, Women, Prefs]) :-
	    \+ at_end_of_stream(Stream),
	    read(Stream, Men),
	    read(Stream, Women),
	    read_preferences(Stream, Prefs).

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% read_preferences: reads the preference lines and puts them
	% all into a list which will be parsed later on.

	read_preferences(Stream,[]) :-
	    at_end_of_stream(Stream).

	read_preferences(Stream, [Prefs|Tail]) :-
		\+ at_end_of_stream(Stream),
		read(Stream, Prefs),
		read_preferences(Stream, Tail).


% PARSING
% % % % % % % % % % % % % % % % % %

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% parse_men/parse_women: respectively parse the men and women
	% lists of a file.

	parse_men(man={L}, Men) :- parse_list(L, Men).
	parse_women(women={L}, Women) :- parse_list(L, Women).

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% parse_list: auxiliary function that parses a list of format
	% "a, b, c, .." to a list [a, b, c, ..].

	parse_list((Head,X), [Head|Tail]) :- parse_list(X, Tail),!.
	parse_list(Head, [Head]).

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% parse_prefs: parses every preference line in the file one
	% by one and collects the resulting values in a list.

	parse_prefs([Head|Tail], [Pref|Prefs]) :-
		parse_single_prefs(Head, Pref),
		parse_prefs(Tail, Prefs).

	parse_prefs([Head], [Pref]) :- parse_single_prefs(Head, Pref).

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% parse_single_prefs: parses one line of the preference lists.

	parse_single_prefs(Name:X, [Name, Prefs]) :- parse_pref_list(X, 1, Prefs).


	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% parse_pref_list: parses the "name1 > name2 > .." part of
	% a 'preference line'.

	parse_pref_list({Name1, Name2}>X, Rank, [{Rank, Name1}, {Rank, Name2}|Tail]) :-
		Newrank is Rank + 1,
		parse_pref_list(X, Newrank, Tail).

	parse_pref_list(Name>X, Rank, [{Rank, Name}|Tail]) :-
		Newrank is Rank + 1,
		parse_pref_list(X, Newrank, Tail).

	parse_pref_list({Name1, Name2}, Rank, [{Rank, Name1}, {Rank, Name2}]).
	parse_pref_list(Name, Rank, [{Rank, Name}]).


% PREFERENCE SETS ADT
% % % % % % % % % % % % % % % % % %

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% autocomplete_list: auxiliary function that copies a list,
	% and puts "{norank, X}" for every X that is not in an other
	% list.

	autocomplete_list([Head|Tail], List, [{Rank, Head}|Result]) :-
		member({Rank, Head}, List),
		autocomplete_list(Tail, List, Result).

	autocomplete_list([Head|Tail], List, [{norank, Head}|Result]) :-
		not(member({_, Head}, List)),
		autocomplete_list(Tail, List, Result).

	autocomplete_list([], _, []).

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% autocomplete_single_prefs: completes a preference list, i.e.
	% adds every person that is not in the list and marks that
	% person with "norank".

	autocomplete_single_prefs([Men, Women, _], [Name, Prefs], [Name, Prefsmodif]) :-
		member(Name, Women),
		autocomplete_list(Men, Prefs, Prefsmodif).

	autocomplete_single_prefs([Men, Women, _], [Name, Prefs], [Name, Prefsmodif]) :-
		member(Name, Men),
		autocomplete_list(Women, Prefs, Prefsmodif).

	autocomplete_prefs([Men, Women, []], [Men, Women, []]).

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% autocomplete_prefs: completes all preference lists of a 
	% preference set.

	autocomplete_prefs([Men, Women, [Pref|Prefs]], [Men, Women, [Prefmodif|Prefmodifs]]) :-
		autocomplete_single_prefs([Men, Women, [Pref|Prefs]], Pref, Prefmodif),
		autocomplete_prefs([Men, Women, Prefs], [Men, Women, Prefmodifs]).

	% % % % % % % % % % % % % % % % % % % % % % % % % % %
	% from_stream: parses a preference set from a stream
	% and autocompletes afterwards.

	from_stream(Stream, Prefset) :-
		read_file(Stream, [M, W, P]),
		parse_men(M, Men),
		parse_women(W, Women),
		parse_prefs(P, Preferences),
		autocomplete_prefs([Men, Women, Preferences], Prefset).

	% % % % % % % % % % % % % % % % % % % % % % % % % % %
	% rank_for/rank: gets the rank that Name gives to
	% Othername.

	rank_for(Name, Rank, [_, Prefs]) :-
		member({Rank, Name}, Prefs).

	rank([_, _, Preferences], Name, Othername, Rank) :-
		member([Name, Prefs], Preferences),
		rank_for(Othername, Rank, [Name, Prefs]).

	% % % % % % % % % % % % % % % % % % % % % % % % % % %
	% men/women: two simple "getters".

	men([Men, _, _], Men).
	women([_, Women, _], Women).
