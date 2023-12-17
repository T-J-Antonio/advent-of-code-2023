main :-
    read_file_to_string("day16_input.txt", String, []),
    split_string(String, "\n", "", Lines),
    findall(CharList, (member(Line, Lines), string_chars(Line, CharList)), Matrix),
    assert_info(Matrix),
    max_tiles_energized(Result),
    write(Result).

:- dynamic tile/2.
:- dynamic max_x/1.
:- dynamic max_y/1.

assert_info(Matrix) :-
    forall(
        (nth0(Y, Matrix, Line), nth0(X, Line, Tile)), 
        assert(tile(Tile, (X, Y)))
    ),
    length(Matrix, MaxY),
    assert(max_y(MaxY)),
    nth0(0, Matrix, Line),
    length(Line, MaxX),
    assert(max_x(MaxX)).

possible_start((-1, Y), right) :- max_y(MaxY), Limit is MaxY - 1, between(0, Limit, Y).
possible_start((X, -1), down) :- max_x(MaxX), Limit is MaxX - 1, between(0, Limit, X).
possible_start((MaxX, Y), left) :- max_x(MaxX), max_y(MaxY), Limit is MaxY - 1, between(0, Limit, Y).
possible_start((X, MaxY), up) :- max_x(MaxX), max_y(MaxY), Limit is MaxX - 1, between(0, Limit, X).

max_tiles_energized(Tiles) :-
    findall(SomeTiles, (  
        possible_start(P, Direction),
        tiles_energized(P, Direction, SomeTiles)
    ), TilesList),
    member(Tiles, TilesList),
    forall(member(OtherTiles, TilesList), OtherTiles =< Tiles).

:- dynamic passed/3.

tiles_energized(P, Direction, Tiles) :-
    assert(tile('.', P)),
    propagate(P, Direction, TilesList),
    length(TilesList, Length),
    Tiles is Length - 1,
    retractall(passed(_, _, _)),
    retract(tile('.', P)).

% If the light has already passed through this tile with this direction,
% we don't need to keep calculating this propagation.
propagate(P, Direction, []) :-
    forall(
        new_direction(P, Direction, NewDirection),
        passed(P, Direction, NewDirection)
    ).

propagate(P, Direction, List) :-
    findall(
        SubTiles,
        (
            new_direction(P, Direction, NewDirection),
            \+ passed(P, Direction, NewDirection),
            assert(passed(P, Direction, NewDirection)),
            new_position(P, NewDirection, NewPosition),
            propagate(NewPosition, NewDirection, SubTiles)
        ),
        Lists
    ),
    flatten(Lists, Flattened),
    list_to_set([P | Flattened], List).

new_position((X, Y), right, (NewX, Y)) :- NewX is X + 1, tile(_, (NewX, Y)).
new_position((X, Y), left, (NewX, Y)) :- NewX is X - 1, tile(_, (NewX, Y)).
new_position((X, Y), up, (X, NewY)) :- NewY is Y - 1, tile(_, (X, NewY)).
new_position((X, Y), down, (X, NewY)) :- NewY is Y + 1, tile(_, (X, NewY)).

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