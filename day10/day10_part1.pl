main :-
    read_file_to_string("day10_input.txt", Content, []),
    split_string(Content, "\n", "", Lines),
    findall(CharList, (member(Line, Lines), string_chars(Line, CharList)), Matrix),
    assert_info(Matrix),
    tile('S', StartPos),
    points_at(StartPos, SecondPos),
    points_at(SecondPos, StartPos),
    loop(StartPos, SecondPos, N),
    FarthestStep is N / 2,
    write(FarthestStep),
    !.

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

loop(PrevPos, CurrPos, 2) :-
    points_at(CurrPos, NextPos),
    points_at(NextPos, CurrPos),
    NextPos \= PrevPos,
    tile('S', NextPos).

loop(PrevPos, CurrPos, N) :-
    points_at(CurrPos, NextPos),
    points_at(NextPos, CurrPos),
    NextPos \= PrevPos,
    loop(CurrPos, NextPos, M),
    N is M + 1.