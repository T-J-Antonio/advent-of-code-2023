:- use_module(library(pcre)).

main :-
    read_file_to_string("day18_input.txt", Content, []),
    split_string(Content, "\n", "", Lines),
    assert_info(Lines, (0, 0)),
    min_y(MinY),
    max_y(MaxY),
    findall(Y-N, (between(MinY, MaxY, Y), cells_in_line(Y, N)), InsideList),
    pairs_values(InsideList, Values),
    sum_list(Values, TotalInside),
    findall(Border, border(Border), BorderList),
    list_to_set(BorderList, BorderSet),
    length(BorderSet, TotalBorders),
    findall(Corner, corner(Corner, _), CornerList),
    list_to_set(CornerList, CornerSet),
    length(CornerSet, TotalCorners),
    Result is TotalBorders + TotalCorners + TotalInside,
    write(Result). 

assert_info([Line | Lines], Position) :-
    assert_info([Line | Lines], Position, Line).

assert_info([Line], Position, First) :- assert_line(Line, First, Position, _).

assert_info([Line, Line2 | Lines], Position, First) :-
    assert_line(Line, Line2, Position, NewPosition),
    assert_info([Line2 | Lines], NewPosition, First). 

:- dynamic border/1.
:- dynamic corner/2.

assert_line(Line, Line2, Position, NewPosition) :-
    re_matchsub("U|D|L|R", Line, Dict, []),
    get_dict(0, Dict, Direction),
    re_matchsub("U|D|L|R", Line2, Dict2, []),
    get_dict(0, Dict2, NextDirection),
    re_matchsub("[0-9]+", Line, Dict3, []),
    get_dict(0, Dict3, NumberS),
    number_string(Number, NumberS),
    assert_direction_number(Direction, NextDirection, Number, Position, NewPosition).

% It is assumed that no two consecutive rows will have the same directions.
shape("D", "L", j).
shape("R", "U", j).
shape("D", "R", l).
shape("L", "U", l).
shape("U", "R", f).
shape("L", "D", f).
shape("U", "L", t).
shape("R", "D", t).

assert_direction_number("U", Next, 1, (X, Y), (X, NewY)) :-
    NewY is Y - 1,
    shape("U", Next, Shape),
    assert(corner((X, NewY), Shape)).

assert_direction_number("U", Next, N, (X, Y), P) :-
    N > 1,
    NewY is Y - 1,
    assert(border((X, NewY))),
    N2 is N - 1,
    assert_direction_number("U", Next, N2, (X, NewY), P).

assert_direction_number("D", Next, 1, (X, Y), (X, NewY)) :-
    NewY is Y + 1,
    shape("D", Next, Shape),
    assert(corner((X, NewY), Shape)).

assert_direction_number("D", Next, N, (X, Y), P) :-
    N > 1,
    NewY is Y + 1,
    assert(border((X, NewY))),
    N2 is N - 1,
    assert_direction_number("D", Next, N2, (X, NewY), P).

assert_direction_number("L", Next, 1, (X, Y), (NewX, Y)) :-
    NewX is X - 1,
    shape("L", Next, Shape),
    assert(corner((NewX, Y), Shape)).

assert_direction_number("L", Next, N, (X, Y), P) :-
    N > 1,
    NewX is X - 1,
    assert(border((NewX, Y))),
    N2 is N - 1,
    assert_direction_number("L", Next, N2, (NewX, Y), P).

assert_direction_number("R", Next, 1, (X, Y), (NewX, Y)) :-
    NewX is X + 1,
    shape("R", Next, Shape),
    assert(corner((NewX, Y), Shape)).

assert_direction_number("R", Next, N, (X, Y), P) :-
    N > 1,
    NewX is X + 1,
    assert(border((NewX, Y))),
    N2 is N - 1,
    assert_direction_number("R", Next, N2, (NewX, Y), P).

min_x(X) :- border((X, _)), forall(border((OtherX, _)), OtherX >= X), !.
max_x(X) :- border((X, _)), forall(border((OtherX, _)), OtherX =< X), !.
min_y(Y) :- border((_, Y)), forall(border((_, OtherY)), OtherY >= Y), !.
max_y(Y) :- border((_, Y)), forall(border((_, OtherY)), OtherY =< Y), !.

cells_in_line(Y, Number) :-
    findall(X-Shape, corner((X, Y), Shape), Corners),
    findall(X-o, border((X, Y)), Borders),
    append(Corners, Borders, CornersAndBorders),
    sort(0, @=<, CornersAndBorders, Sorted),
    entrances(Sorted, Entrances),
    borders_according_to_entrances(Entrances, Number, Y),
    !.

entrances([], []).
entrances([X-o | Atoms], [X | Others]) :- entrances(Atoms, Others).
entrances([X-f | Atoms], List) :-
    take_until(Atoms, j, t, NewAtoms, Result, N),
    entrances(NewAtoms, Others),
    F is X + N + 1,
    (Result = j, List = [(X, F) | Others]; Result = t, List = Others).
entrances([X-l | Atoms],List) :-
    take_until(Atoms, t, j, NewAtoms, Result, N),
    entrances(NewAtoms, Others),
    F is X + N + 1,
    (Result = t, List = [(X, F) | Others]; Result = j, List = Others).

take_until([_-Shape | Xs], Shape, _, Xs, Shape, 0).
take_until([_-Shape | Xs], _, Shape, Xs, Shape, 0).
take_until([_-Shape | Xs], Shape2, Shape3, Xss, R, N) :-
    Shape \= Shape2, Shape \= Shape3, take_until(Xs, Shape2, Shape3, Xss, R, M),
    N is M + 1.

borders_according_to_entrances([], 0, _).
borders_according_to_entrances([X, X2 | Xs], N, Y) :-
    number(X), number(X2),
    borders_according_to_entrances(Xs, M, Y),
    UpperBound is X2 - 1,
    LowerBound is X + 1,
    forall(
        between(LowerBound, UpperBound, SomeX),
        (retractall(border((SomeX, Y))), retractall(corner((SomeX, Y), _)))
    ),
    N is M + X2 - X - 1.
borders_according_to_entrances([(_, X), X2 | Xs], N, Y) :-
    number(X2),
    borders_according_to_entrances(Xs, M, Y),
    UpperBound is X2 - 1,
    LowerBound is X + 1,
    forall(
        between(LowerBound, UpperBound, SomeX),
        (retractall(border((SomeX, Y))), retractall(corner((SomeX, Y), _)))
    ),
    N is M + X2 - X - 1.
borders_according_to_entrances([X, (X2, _) | Xs], N, Y) :-
    number(X),
    borders_according_to_entrances(Xs, M, Y),
    UpperBound is X2 - 1,
    LowerBound is X + 1,
    forall(
        between(LowerBound, UpperBound, SomeX),
        (retractall(border((SomeX, Y))), retractall(corner((SomeX, Y), _)))
    ),
    N is M + X2 - X - 1.

borders_according_to_entrances([(_, X), (X2, _) | Xs], N, Y) :-
    borders_according_to_entrances(Xs, M, Y),
    UpperBound is X2 - 1,
    LowerBound is X + 1,
    forall(
        between(LowerBound, UpperBound, SomeX),
        (retractall(border((SomeX, Y))), retractall(corner((SomeX, Y), _)))
    ),
    N is M + X2 - X - 1.

line(Y, Line) :-
    min_x(MinX),
    max_x(MaxX),
    findall(C, (between(MinX, MaxX, X), char((X, Y), C)), Cs),
    string_chars(Line, Cs).

char(P, '.') :- \+ border(P), \+ corner(P, _).
char(P, '#') :- border(P).
char(P, C) :- corner(P, S), string_chars(S, Cs), nth0(0, Cs, C).