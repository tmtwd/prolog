tem(graph([timisoara,
           zerind,
           sibiu,
           oradea],
           [e(arad, zerind, 75),
            e(arad, sibiu, 140),
            e(arad, timisoara, 118),
            e(zerind, oradea, 71),
            e(oradea, sibiu, 151),
            e(sibiu, rimnicu, 80),
            e(sibiu, fagaras, 99),
            e(timisoara, logoj, 111),
            e(logoj, mehadia, 70),
            e(mehadia, dobreta, 120),
            e(dobreta, craiova, 120),
            e(craiova, rimnicu, 146),
            e(craiova, pitesti, 138),
            e(pitesti, bucharest, 101),
            e(pitesti, rimnicu, 97),
            e(fagaras, bucharest, 211),
            e(bucharest, giurgiu, 90),
            e(bucharest, urziceni, 85),
            e(urziceni, vaslui, 142),
            e(vaslui, lasi, 92),
            e(lasi, neamt, 87),
            e(urziceni, hirsova, 98),
            e(hirsova, eforie, 86)])).

% distance of each city to bucharest as the crow flies
h(arad, 366).
h(bucharest, 0).
h(craiova, 160).
h(dobreta, 242).

adjacent(X,Y,graph(_,E)):-
  member(e(X,Y,_), E)
  ;
  member(e(Y,X,_), E).

adjacent_cost(X,Y, graph(_,E), Cost):-
  adjacent(X,Y, graph(_,E)),
  member(e(X,Y,Cost), E)
  ;
  adjacent(X,Y, graph(_,E)),
  member(e(Y,X,Cost), E).

adjacent_cost_without_a_city(X,Y, Exclusion, graph(_,E), Cost):-
  adjacent(X,Y, graph(_,E)),
  member(e(X,Y,Cost), E),
  Y \= Exclusion
  ;
  adjacent(X,Y, graph(_,E)),
  member(e(Y,X,Cost), E),
  Y \= Exclusion.

adjacent_cost_without_cities(X,Y, Exclusions, graph(_,E), Cost):-
  adjacent(X,Y, graph(_,E)),
  member(e(X,Y,Cost), E),
  \+ member(Y, Exclusions)
  ;
  adjacent(X,Y, graph(_,E)),
  member(e(Y,X,Cost), E),
  \+ member(Y, Exclusions).

closest_neighbor(X, ClosestNeighbor, Cost):-
  tem(Graph),
  aggregate(min(Cost, ClosestNeighbor), adjacent_cost(X,ClosestNeighbor, Graph, Cost), min(Cost,ClosestNeighbor)).

closest_neighbor_with_exclusion(X, Exclusion, ClosestNeighbor, Cost):-
  tem(Graph),
  aggregate(min(Cost, ClosestNeighbor), adjacent_cost_without_a_city(X,ClosestNeighbor, Exclusion, Graph, Cost), min(Cost,ClosestNeighbor)).

closest_neighbor_with_exclusions(X, Exclusions, ClosestNeighbor, Cost):-
  tem(Graph),
  aggregate(min(Cost, ClosestNeighbor), adjacent_cost_without_cities(X,ClosestNeighbor, Exclusions, Graph, Cost), min(Cost,ClosestNeighbor)).


closest_to_bucharest(City) :-
  aggregate(min(Distance,City), h(City,Distance), min(_, City)).

take_shortest_neighbor(Dest, Dest, _, 0):- !.

take_shortest_neighbor(Start, Dest, PrevCity, TotalCost):-
  closest_neighbor_with_exclusion(Start, PrevCity, CN, Cost),
  write('walk to '),
  write(CN),
  nl,
  take_shortest_neighbor(CN, Dest, Start, NextCost),
  TotalCost is NextCost + Cost.

uniform_search(Dest, Dest, _, 0, _):- !.

uniform_search(Start, Dest, PrevCity, TotalCost, CurrentCost):-
  closest_neighbor_with_exclusion(Start, PrevCity, CN, Cost),
  NextCurrentCost is CurrentCost + Cost,
  write('walk to '),
  write(CN),
  nl,
  write(CurrentCost),
  nl,
  uniform_search(CN, Dest, Start, NextCost, NextCurrentCost),
  TotalCost is NextCost + Cost.


% bfs(Start, Start).
% bfs(Start, Goal):-
%   tem(X),
%   findall(Neighbor, adjacent(Start, Neighbor, X), Z).

consed(A,B,[B|A]).

solve(Start, Goal, Solution):-
  breadthfirst([[Start]], Goal, Solution).

breadthfirst([[Node|Path]|_], Goal, [Node|Path]):-
  Goal == Node.

breadthfirst([Path|Paths], Goal, Solution):-
  extend(Path, NewPaths),
  append(Paths, NewPaths, Paths1),
  breadthfirst(Paths1, Goal, Solution).

extend([Node|Path], NewPaths):-
  tem(X),
  findall([NewNode, Node|Path],
          (adjacent(Node, NewNode, X), \+(member(NewNode, [Node|Path]))),
          NewPaths),
  !.

% extend([Node|Path], NewPaths):-
%   tem(X),
%   findall([NewNode, Node|Path],
%           (adjacent(Node, NewNode, X)),
%           not(member(NewNode, [Node|Path])),
%           NewPaths),
%   !.

bfs(Goal, [[Goal|Visited]|_], Path):-
  reverse([Goal|Visited], Path).

bfs(Goal, [Visited|Rest], Path) :-                     % take one from front
    tem(G),
    Visited = [Start|_],
    Start \== Goal,
    findall(Neighbor, (adjacent(Neighbor, Start, G), \+ member(X, Visited)), [T|Extend]),
    % findall(X,
    %     (connected2(X,Start,_),not(member(X,Visited))),
    %     [T|Extend]),
    maplist( consed(Visited), [T|Extend], VisitedExtended),      % make many
    append(Rest, VisitedExtended, UpdatedQueue),       % put them at the end
    bfs( Goal, UpdatedQueue, Path ).

is_man(john).
is_man(alex).

%elems(city([H])):-
