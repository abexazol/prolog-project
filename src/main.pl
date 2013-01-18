% % % % % % % % % % % % % % % % % % % % % % % % % % %
% Declarative Programming Project: Stable Matchings %
% Kenny Deschuyteneer                               %
% main.pl                                           %
% % % % % % % % % % % % % % % % % % % % % % % % % % %

% :- use_module(prefset).
:- include(prefset).
:- include(marriage).


% MAIN
% % % % % % % % % % % % % % % % % %

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% main: runs the stable matching algorithm for a given file.

	main(Filename) :-
		open(Filename, read, Stream),
		from_stream(Stream, Prefset),
		stable_coupling(Prefset, X),
		write(X), nl,
		close(Stream).