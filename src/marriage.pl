% % % % % % % % % % % % % % % % % % % % % % % % % % %
% Declarative Programming Project: Stable Matchings %
% Kenny Deschuyteneer                               %
% marriage.pl                                       %
% % % % % % % % % % % % % % % % % % % % % % % % % % %

% :- module(marriage, []).


% COUPLING
% % % % % % % % % % % % % % % % % %

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% couple/couple_backup/couple_all: fully joins two lists.

	couple(Man, Woman, {Man, Woman}).

	couple_backup([], _, _, []).

	couple_backup([_|Men], [], Original, Couples) :-
		couple_backup(Men, Original, Original, Couples).

	couple_backup([Man|Men], [Woman|Women], Original, [Couple|Couples]) :-
		couple(Man, Woman, Couple),
		couple_backup([Man|Men], Women, Original, Couples).

	couple_all(Men, Women, Result) :-
		couple_backup(Men, Women, Women, Result).

	% % % % % % % % % % % % % % % % % % % % % %
	% decouple: removes a couple from the list.

	decouple(Man, Woman, Couples, Result) :-
		delete(Couples, {Man, Woman}, Result).


% THE ALGORITHM
% % % % % % % % % % % % % % % % % %

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% remove_bad_couples(INCOMPLETE): applies the given stability
	% check on the given couple for all other couples.

	remove_bad_couples(Stabilitycheck, Prefset, Man1, Woman1, [{Man2, Woman2}|Couples], Result) :-
		rank(Prefset, Man1, Woman1, AB),
		rank(Prefset, Man1, Woman1, CD),
		rank(Prefset, Man1, Woman2, AD),
		rank(Prefset, Woman1, Man1, DA),
		call(Stabilitycheck, AB, CD, AD, DA).

	remove_bad_couples(Stabilitycheck, Prefset, Man1, Woman1, [{Man2, Woman2}|Couples], Result) :-
		rank(Prefset, Man1, Woman1, AB),
		rank(Prefset, Man1, Woman1, CD),
		rank(Prefset, Man1, Woman2, AD),
		rank(Prefset, Woman1, Man1, DA),
		not(call(Stabilitycheck, AB, CD, AD, DA)),
		decouple(Man1, Woman1, Couples, Result).


	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% stable_coupling: the stable coupling algorithm returns all
	% possible stable couples from a given preference set.

	stable_coupling(Prefset, Couples) :-
		men(Prefset, Men),
		women(Prefset, Women),
		couple_all(Men, Women, Couples).

	% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
	% super_stability/strong_stability/weak_stability: if {A, B}
	% and {C, D} are couples, then is AB the rank that A gives to
	% B, CD the rank C gives to D, AD the rank A gives to C and
	% DA the rank D gives to A.

	super_stability(AB,CD,AD,DA) :- \+ (AD >= AB, DA >= CD).

	strong_stability(AB,CD,AD,DA) :- \+ (AD > AB, DA >= CD).

	weak_stability(AB,CD,AD,DA) :- \+ (AD > AB, DA > CD).
