main :-
    read_file_to_string("day10_input.txt", Content, []),
    split_string(Content, "\n", "", Lines),
    findall(CharList, (member(Line, Lines), string_chars(Line, CharList)), Matrix),
    assert_info(Matrix),
    tile('S', StartPos),
    points_at(StartPos, SecondPos),
    points_at(SecondPos, StartPos),
    loop(StartPos, SecondPos, Loop),
    replace_s(Loop),
    findall(Pos, is_inside(Pos, Loop), PositionsInside),
    length(PositionsInside, N),
    write(N).

:- dynamic(tile/2).
:- dynamic(max_x/1).
:- dynamic(max_y/1).

assert_info(Matrix) :-
    forall(
        (nth0(Y, Matrix, Line), nth0(X, Line, Tile)), 
        assert(tile(Tile, (X, Y)))
    ),
    length(Matrix, YLength),
    MaxY is YLength - 1,
    assert(max_y(MaxY)),
    nth0(0, Matrix, Line),
    length(Line, XLength),
    MaxX is XLength - 1,
    assert(max_x(MaxX)).

points_at((X, Y), (X2, Y2)) :-
    tile(Tile, (X, Y)),
    max_x(MaxX),
    max_y(MaxY),
    (
        (Tile = 'S'; Tile = '-'; Tile = 'L'; Tile = 'F'), X < MaxX, X2 is X+1, Y2 is Y;
        (Tile = 'S'; Tile = '-'; Tile = '7'; Tile = 'J'), X > 0, X2 is X-1, Y2 is Y;
        (Tile = 'S'; Tile = '|'; Tile = '7'; Tile = 'F'), Y < MaxY, Y2 is Y+1, X2 is X;
        (Tile = 'S'; Tile = '|'; Tile = 'L'; Tile = 'J'), Y > 0, Y2 is Y-1, X2 is X
    ).

loop(PrevPos, CurrPos, [PrevPos, CurrPos]) :-
    points_at(CurrPos, NextPos),
    points_at(NextPos, CurrPos),
    NextPos \= PrevPos,
    tile('S', NextPos),
    !.

loop(PrevPos, CurrPos, [PrevPos | Positions]) :-
    points_at(CurrPos, NextPos),
    points_at(NextPos, CurrPos),
    NextPos \= PrevPos,
    loop(CurrPos, NextPos, Positions).

is_inside(Position, Loop) :-
    tile(_, Position),
    \+ member(Position, Loop),
    (X, Y) = Position,
    Limit is X - 1,
    findall(Border, (between(0, Limit, X2), member((X2, Y), Loop), tile(Border, (X2, Y))), BordersLeftOfPosition),
    string_chars(BordersString, BordersLeftOfPosition),
    entrances(BordersString, Entrances),
    1 =:= Entrances mod 2.

replace_s([(X1, Y1), (X2, Y2) | Rest]) :-
    last(Rest, (XN, YN)),
    retract(tile('S', (X1, Y1))),
    (
        X2 > X1, XN < X1, assert(tile('-', (X1, Y1)));
        X2 < X1, XN > X1, assert(tile('-', (X1, Y1)));
        Y2 > Y1, YN < Y1, assert(tile('|', (X1, Y1)));
        Y2 < Y1, YN > Y1, assert(tile('|', (X1, Y1)));
        X2 > X1, YN > Y1, assert(tile('F', (X1, Y1)));
        Y2 > Y1, XN > X1, assert(tile('F', (X1, Y1)));
        X2 < X1, YN < Y1, assert(tile('J', (X1, Y1)));
        Y2 < Y1, XN < X1, assert(tile('J', (X1, Y1)));
        X2 < X1, YN > Y1, assert(tile('7', (X1, Y1)));
        Y2 > Y1, XN < X1, assert(tile('7', (X1, Y1)));
        X2 > X1, YN < Y1, assert(tile('L', (X1, Y1)));
        Y2 < Y1, XN > X1, assert(tile('L', (X1, Y1)))
    ).

% I know I have entered or exited the loop if I encounter |, L-7 or F-J.
entrances(Borders, 0) :-
    re_replace("\\||L\\-*7|F\\-*J", "", Borders, Borders).

entrances(Borders, N) :-
    re_replace("\\||L\\-*7|F\\-*J", "", Borders, NewBorders),
    Borders \= NewBorders,
    entrances(NewBorders, M),
    N is M + 1.