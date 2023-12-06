main :-
    read_file_to_string("day6_input.txt", Content, []),
    split_string(Content, "\n", "", [Line1, Line2]),
    split_string(Line1, " ", "", [_ | TimesStr]),
    split_string(Line2, " ", "", [_ | DistancesStr]),
    strings_to_number(TimesStr, Time),
    strings_to_number(DistancesStr, Distance),
    ways_to_beat_record(Time, Distance, Result),
    write(Result). 

ways_to_beat_record(Time, RecordDistance, NumberOfWays) :-
    % find roots of polinomial - p^2 + t*p - r:
    % (p: time pressed, t: total time, r: record distance).
    Root1 is (Time + sqrt(Time ** 2 - 4 * RecordDistance)) / 2,
    Root2 is (Time - sqrt(Time ** 2 - 4 * RecordDistance)) / 2,
    % as it has negative concavity, the values above 0 are between the roots.
    NumberOfWays is truncate(Root1 - Root2).

strings_to_number(Strings, N) :-
    string_list_concat(Strings, String),
    number_string(N, String).

string_list_concat([], "").
string_list_concat([X | Xs], String) :-
    string_list_concat(Xs, String2),
    string_concat(X, String2, String).