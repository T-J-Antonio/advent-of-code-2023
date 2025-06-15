% I'm not really proud of this one...
% Using DFS capped at a length of 8, all of the components besides 2 of them
% are placed in either group (using group_from/2). Those 2 remaining ones
% are each connected to 3 of 1 group and 1 of the other, so by definition
% both must be from the group they're most connected to.
% From my input and the call to process_groups one group has size
% 725 and the other 799; so the answer is 726 * 800.

main :-
    read_file_to_string("day25_input.txt", Content, []),
    split_string(Content, "\n", "", Lines),
    maplist(assert_data_from_line, Lines),
    remove_duplicate_components,
    process_groups. 

:- dynamic component/1.
:- dynamic wire/2.

assert_data_from_line(Line) :-
    split_string(Line, ":", "", [Component, Rest]),
    split_string(Rest, " ", " ", Rests),
    assert(component(Component)),
    maplist(assert_data_from_pair(Component), Rests).

assert_data_from_pair(Component1, Component2) :-
    assert(component(Component2)),
    assert(wire(Component1, Component2)).

remove_duplicate_components :-
    findall(Component, component(Component), Components),
    list_to_set(Components, ComponentsWithoutDups),
    retractall(component(_)),
    assert_all_components(ComponentsWithoutDups).

assert_all_components([]).
assert_all_components([X | Xs]) :-
    assert(component(X)),
    assert_all_components(Xs).

directly_connected(Component1, Component2) :- wire(Component1, Component2).
directly_connected(Component1, Component2) :- wire(Component2, Component1).

path_aux(Component1, Component2, WiresPassed, _, [(Component1, Component2)]) :-
    directly_connected(Component1, Component2),
    \+ member((Component1, Component2), WiresPassed),
    \+ member((Component2, Component1), WiresPassed).

path_aux(Component1, Component2, WiresPassed, ComponentsPassed, [(Component1, Intermediate) | PrevResult]) :-
    directly_connected(Component1, Intermediate),
    Intermediate \= Component2,
    \+ member(Intermediate, ComponentsPassed),
    \+ member((Component1, Intermediate), WiresPassed),
    \+ member((Intermediate, Component1), WiresPassed),
    length(ComponentsPassed, L),
    L < 8, % path_aux/5 uses DFS capped at 7 steps
    path_aux(
        Intermediate,
        Component2,
        [(Component1, Intermediate) | WiresPassed],
        [Intermediate | ComponentsPassed],
        PrevResult
    ).

path(Component1, Component2, WiresToAvoid, Path) :-
    path_aux(Component1, Component2, WiresToAvoid, [Component1], Path).

belong_to_same_group(Component1, Component2) :-
    path(Component1, Component2, [], Path),
    path(Component1, Component2, Path, Path2),
    append(Path, Path2, Accumulated),
    path(Component1, Component2, Accumulated, Path3),
    append(Accumulated, Path3, FinalAccumulated),
    path(Component1, Component2, FinalAccumulated, _).

process_groups :-
    findall(Component, component(Component), AllComponents),
    process(AllComponents).

:- dynamic together/2.

% end early if all components are together with some other one
process(_) :-
    forall(component(Component), (together(Component, _); together(_, Component))).

process([]).

process([Component | Components]) :-
    forall(directly_connected(Component, C),
    (writeln((Component, C)), process_groups_aux(Component, C))),
    process(Components).

process_groups_aux(Component1, Component2) :-
    belong_to_same_group(Component1, Component2),
    assert(together(Component1, Component2)),
    !.

process_groups_aux(Component1, Component2) :-
    \+ belong_to_same_group(Component1, Component2).

together_bidirectional(Component1, Component2) :- together(Component1, Component2).
together_bidirectional(Component1, Component2) :- together(Component2, Component1).

together_with(AlreadyFound, AlreadyFound) :-
    \+ (member(AF, AlreadyFound), together_bidirectional(AF, C), \+ member(C, AlreadyFound)).

together_with(AlreadyFound, Partners) :-
    findall(C, (member(AF, AlreadyFound), together_bidirectional(AF, C), \+ member(C, AlreadyFound)), NewPartners),
    list_to_set(NewPartners, NewPartnersSet),
    append(AlreadyFound, NewPartnersSet, NextAlreadyFound),
    together_with(NextAlreadyFound, Partners).

group_from(Component, Group) :- once(together_with([Component], Group)).
