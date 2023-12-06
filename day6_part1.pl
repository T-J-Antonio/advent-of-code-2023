main :-
    read_file_to_string("day6_input.txt", Content, []),
    split_string(Content, "\n", "", [Line1, Line2]),
    split_string(Line1, " ", "", [_ | TimesStr]),
    split_string(Line2, " ", "", [_ | DistancesStr]),
    list_numbers(TimesStr, Times),
    list_numbers(DistancesStr, Distances),
    zip(Times, Distances, Pairs),
    findall(Ways, (
        member((Time, Distance), Pairs),
        ways_to_beat_record(Time, Distance, Ways)
    ), WaysList),
    product_list(WaysList, Result),
    write(Result). 

list_numbers(List, Numbers) :-
    findall(N, (member(Str, List), number_string(N, Str)), Numbers).

zip([], [], []).
zip([X | Xs], [Y | Ys], [(X, Y) | Zs]) :- zip(Xs, Ys, Zs).

product_list([], 1).
product_list([X | Xs], N) :-
    product_list(Xs, M),
    N is M * X.

beats_record(Time, RecordDistance, TimeButtonPressed) :-
    TimeTraveling is Time - TimeButtonPressed,
    TimeTraveling * TimeButtonPressed > RecordDistance.

ways_to_beat_record(Time, RecordDistance, NumberOfWays) :-
    findall(TimeButtonPressed,
        (between(1, Time, TimeButtonPressed), beats_record(Time, RecordDistance, TimeButtonPressed)),
        Times    
    ),
    length(Times, NumberOfWays).
