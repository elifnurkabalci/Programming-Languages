% Elifnur Kabalcı
% 1801042617

:- style_check(-singleton).

% PART 1 %
% Room-> ID, capacity, alltime (8-17)
% Course-> ID, instructor, capacity, course time 
% Instructor-> ID, courses
% Student-> ID, listof course, health situation

% expert->can add a new student, course or room

%facts
room(Idr, C, T). % I am not sure 
course(Idc, ins, C, cT).
student(Ids, [courses], H).

%rules
program(Idr, Idc, IDs) :-
    where(Idc, Idr). % course in room
    when(Idc, T). % course's time
    add(Ids, Idc). % student in room

conflict_room(X, Y) :-
    where(X, CX).
    where(Y, CY).
    X \== Y. % students are not same but courses are same, its conflict
    CX == CY.        

conflict_time(X,Y) :-
    where(X, TX).
    where(Y, TY).
    X \== Y. % students are not same but course times are same, its conflict
    TX == TY.

all_conf(X,Y) :-
    conflict_room(X,Y), % for testing everything
    conflict_time(X,Y).

add_student(Id):-
    conflict_room(Id, Y). % test the room and add
    room(Id, C, T).
    conflict_time(Id, Y). % test the time and add
    course(Idc, ins, C, cT).
    student(Ids, [courses], H). % write the healty situation and courses and id's
    % I didnt know details, so I make like this.

% PART 2 %
%knowledge base.
%flight(X,Y): this exist a flight and cost.

flight(canakkale, erzincan, 6). % definitons in pdf
flight(erzincan, antalya, 3).
flight(antalya, diyarbakir, 4).
flight(antalya, izmir, 2).
flight(diyarbakir, ankara, 8).
flight(izmir, ankara, 6).
flight(izmir, istanbul, 2).
flight(ankara, istanbul, 1).
flight(istanbul, rize, 4).
flight(ankara, rize, 5).
flight(ankara, van, 4).
flight(van, gaziantep, 3).

%rules
route(X,Y,C) :- flight(X,Y,C). % routes are two dimentional , if x goes to y, y can go to x
route(X,Y,C) :- flight(Y,X,C).

%find all the routes
route(X, Y, Routes) :- findall(A, find_route(X, Y, [X], A, C), Routes). 


%for find the routes 
find_route(X, Y, P, [Y|P], C) :- route(X,Y,C).

find_route(X, Y, R, A, C) :- route(X, Z, C1), not(Z==Y), not(is_in(Z, R)), find_route(Z, Y, [Z|R], A, C2), C is C1+C2.
% if z isnt y and r is not in the z -> this means that we need to transfering to another path, because of we cant find direct flight


is_in(list, [list:Rest]). % is resting data in the list
is_in(list, [Ignore|Rest]) :- is_in(list, Rest).


