main :-
    read_file_to_string("day16_input.txt", String, []),
    split_string(String, "\n", "", Lines),
    findall(CharList, (member(Line, Lines), string_chars(Line, CharList)), Matrix),
    assert_info(Matrix),
    assert(tile('.', (-1, 0))),
    forall(propagate((-1, 0), right), true),
    findall(P, passed(P, _, _), PList),
    list_to_set(PList, PSet),
    length(PSet, Length),
    Result is Length - 1,
    write(Result).

:- dynamic(tile/2).

assert_info(Matrix) :-
    forall(
        (nth0(Y, Matrix, Line), nth0(X, Line, Tile)), 
        assert(tile(Tile, (X, Y)))
    ).

:- dynamic(passed/3).

% If the light has already passed through this tile with this direction,
% we don't need to keep calculating this propagation.
propagate((X, Y), Direction) :-
    forall(
        new_direction((X, Y), Direction, NewDirection),
        passed((X, Y), Direction, NewDirection)
    ).

propagate((X, Y), Direction) :-
    new_direction((X, Y), Direction, right),
    \+ passed((X, Y), Direction, right),
    assert((passed((X, Y), Direction, right))),
    NewX is X + 1,
    propagate((NewX, Y), right).

propagate((X, Y), Direction) :-
    new_direction((X, Y), Direction, left),
    \+ passed((X, Y), Direction, left),
    assert(passed((X, Y), Direction, left)),
    NewX is X - 1,
    propagate((NewX, Y), left).

propagate((X, Y), Direction) :-
    new_direction((X, Y), Direction, up),
    \+ passed((X, Y), Direction, up),
    assert(passed((X, Y), Direction, up)),
    NewY is Y - 1,
    propagate((X, NewY), up).

propagate((X, Y), Direction) :-
    new_direction((X, Y), Direction, down),
    \+ passed((X, Y), Direction, down),
    assert(passed((X, Y), Direction, down)),
    NewY is Y + 1,
    propagate((X, NewY), down).

new_direction(P, right, right) :- tile('.', P); tile('-', P).
new_direction(P, right, down) :- tile('\\', P); tile('|', P).
new_direction(P, right, up) :- tile('/', P); tile('|', P).
new_direction(P, left, left) :- tile('.', P); tile('-', P).
new_direction(P, left, down) :- tile('/', P); tile('|', P).
new_direction(P, left, up) :- tile('\\', P); tile('|', P).
new_direction(P, up, up) :- tile('.', P); tile('|', P).
new_direction(P, up, right) :- tile('/', P); tile('-', P).
new_direction(P, up, left) :- tile('\\', P); tile('-', P).
new_direction(P, down, down) :- tile('.', P); tile('|', P).
new_direction(P, down, right) :- tile('\\', P); tile('-', P).
new_direction(P, down, left) :- tile('/', P); tile('-', P).