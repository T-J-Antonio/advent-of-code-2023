:- use_module(library(pcre)).

main :-
    read_file_to_string("day18_input.txt", Content, []),
    split_string(Content, "\n", "", Lines),
    assert_info(Lines, (0, 0)),
    important_ys(ImportantYs),
    sum_areas(ImportantYs, [], Result),
    writeln(Result).

sum_areas([_], Intervals, FinalRow) :-
    total_width(Intervals, FinalRow).
sum_areas([Y, Y2 | Ys], PrevIntervals, N) :-
    corners_from_y(Y, Corners),
    corner_shapes(Corners, Shapes),
    apply_intervals(PrevIntervals, Shapes, NewIntervals, Shrinkage),
    Height is Y2 - Y,
    total_width(NewIntervals, Width),
    sum_areas([Y2 | Ys], NewIntervals, M),
    N is Height * Width + Shrinkage + M.

total_width([], 0).
total_width([(X1, X2) | Intervals], Width) :-
    total_width(Intervals, PrevWidth),
    Width is X2 - X1 + 1 + PrevWidth.

apply_intervals(Intervals, [], Intervals, 0).
apply_intervals(PrevIntervals, [Shape | Shapes], NewIntervals, NewShrinkage) :-
    apply_interval(PrevIntervals, Shape, IntermediateIntervals, Shrinkage),
    apply_intervals(IntermediateIntervals, Shapes, NewIntervals, PrevShrinkage),
    NewShrinkage is PrevShrinkage + Shrinkage.

apply_interval(PrevIntervals, (ft, X1, X2), NewIntervals, Shrinkage) :-
    nth0(_, PrevIntervals, (Start, End), Without),
    Start < X1,
    End > X2,
    append(Without, [(Start, X1), (X2, End)], NewIntervals),
    Shrinkage is X2 - X1 - 1,
    !.

apply_interval(PrevIntervals, (ft, X1, X2), NewIntervals, 0) :-
    \+ (
        member((Start, End), PrevIntervals),
        Start < X1,
        End > X2
    ),
    append(PrevIntervals, [(X1, X2)], NewIntervals),
    !.

apply_interval(PrevIntervals, (lj, X1, X2), NewIntervals, 0) :-
    nth0(_, PrevIntervals, (Start, X1), Without),
    nth0(_, Without, (X2, End), Without2),
    append(Without2, [(Start, End)], NewIntervals),
    !.

apply_interval(PrevIntervals, (lj, X1, X2), NewIntervals, Shrinkage) :-
    nth0(_, PrevIntervals, (X1, X2), NewIntervals),
    Shrinkage is X2 - X1 + 1,
    !.

apply_interval(PrevIntervals, (lt, X1, X2), NewIntervals, 0) :-
    nth0(_, PrevIntervals, (Start, X1), Without),
    append(Without, [(Start, X2)], NewIntervals),
    !.

apply_interval(PrevIntervals, (lt, X1, X2), NewIntervals, Shrinkage) :-
    nth0(_, PrevIntervals, (X1, End), Without),
    append(Without, [(X2, End)], NewIntervals),
    Shrinkage is X2 - X1,
    !.

apply_interval(PrevIntervals, (fj, X1, X2), NewIntervals, 0) :-
    nth0(_, PrevIntervals, (X2, End), Without),
    append(Without, [(X1, End)], NewIntervals),
    !.

apply_interval(PrevIntervals, (fj, X1, X2), NewIntervals, Shrinkage) :-
    nth0(_, PrevIntervals, (Start, X2), Without),
    append(Without, [(Start, X1)], NewIntervals),
    Shrinkage is X2 - X1,
    !.

% there's always an even number of corners on a line so this makes sense
corner_shapes([], []).
corner_shapes([C1, C2 | Corners], [(fj, X1, X2) | Shapes]) :-
    X1-f = C1,
    X2-j = C2,
    corner_shapes(Corners, Shapes).
corner_shapes([C1, C2 | Corners], [(lt, X1, X2) | Shapes]) :-
    X1-l = C1,
    X2-t = C2,
    corner_shapes(Corners, Shapes).
corner_shapes([C1, C2 | Corners], [(ft, X1, X2) | Shapes]) :-
    X1-f = C1,
    X2-t = C2,
    corner_shapes(Corners, Shapes).
corner_shapes([C1, C2 | Corners], [(lj, X1, X2) | Shapes]) :-
    X1-l = C1,
    X2-j = C2,
    corner_shapes(Corners, Shapes).

corners_from_y(Y, Corners) :-
    findall(X-S, corner((X, Y), S), UnsortedCorners),
    sort(0, @=<, UnsortedCorners, Corners).

assert_info([Line | Lines], Position) :-
    assert_info([Line | Lines], Position, Line).

assert_info([Line], Position, First) :- assert_line(Line, First, Position, _).

assert_info([Line, Line2 | Lines], Position, First) :-
    assert_line(Line, Line2, Position, NewPosition),
    assert_info([Line2 | Lines], NewPosition, First). 

:- dynamic corner/2.

assert_line(Line, Line2, Position, NewPosition) :-
    re_matchsub("([0-9]|[a-f]){5}", Line, Dict, []),
    get_dict(0, Dict, HexString),
    parse_hex(HexString, Number),
    string_chars(Line, Chars), reverse(Chars, Srahc), nth0(1, Srahc, C), translate(C, Direction),
    string_chars(Line2, Chars2), reverse(Chars2, Srahc2), nth0(1, Srahc2, C2), translate(C2, NextDirection),
    assert_corner(Direction, NextDirection, Number, Position, NewPosition).

assert_corner("U", NextDirection, Number, (X, Y), (X, NewY)) :-
    shape("U", NextDirection, Shape),
    NewY is Y - Number,
    assert(corner((X, NewY), Shape)).

assert_corner("D", NextDirection, Number, (X, Y), (X, NewY)) :-
    shape("D", NextDirection, Shape),
    NewY is Y + Number,
    assert(corner((X, NewY), Shape)).

assert_corner("L", NextDirection, Number, (X, Y), (NewX, Y)) :-
    shape("L", NextDirection, Shape),
    NewX is X - Number,
    assert(corner((NewX, Y), Shape)).

assert_corner("R", NextDirection, Number, (X, Y), (NewX, Y)) :-
    shape("R", NextDirection, Shape),
    NewX is X + Number,
    assert(corner((NewX, Y), Shape)).

parse_hex(H, N) :-
    atom_concat('0x', H, HexaAtom),
    atom_codes(HexaAtom, HexaCodes),
    number_codes(N, HexaCodes).

translate('0', "R").
translate('1', "D").
translate('2', "L").
translate('3', "U").

% It is assumed that no two consecutive rows will have the same directions.
shape("D", "L", j).
shape("R", "U", j).
shape("D", "R", l).
shape("L", "U", l).
shape("U", "R", f).
shape("L", "D", f).
shape("U", "L", t).
shape("R", "D", t).

important_ys(ImportantYs) :-
    findall(Y, corner((_, Y), _), UnsortedImportantYs),
    sort(0, @=<, UnsortedImportantYs, ImportantYsWithDups),
    list_to_set(ImportantYsWithDups, ImportantYs).
