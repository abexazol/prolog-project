% % % % % % % % % % % % % % % % % % % % % % % % % % %
% Declarative Programming Project: Stable Matchings %
% Kenny Deschuyteneer                               %
% File.pl                                           %
% % % % % % % % % % % % % % % % % % % % % % % % % % %

% :- use_module(prefset).
:- include(prefset).


% MAIN
% % % % % % % % % % % % % % % % % %

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% main: runs the stable matching algorithm for a given file.

	main(Filename) :-
		open(Filename, read, Stream),
		from_stream(Stream, X),
		write(X), nl,
		close(Stream).