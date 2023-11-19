insert into flights (flightid, flighttime, planeid)
values (1, '2024-01-17T12:50', 1),
       (2, '2024-01-17T13:30', 2),
       (3, '2024-01-20T17:18', 1);

insert into flights (flightid, flighttime, planeid, reservationcanceled, purchasecanceled)
values (4, '2024-01-02T23:45', 2, true, true);

insert into seats (planeid, seatno)
values (1, '122A'),
       (1, '122B'),
       (1, '122C'),
       (1, '123A'),
       (1, '123B'),
       (1, '123C'),
       (1, '124A'),
       (1, '124B'),
       (1, '125A'),
       (1, '125B'),
       (2, '123A'),
       (2, '123B'),
       (2, '123C');

insert into tickets (flightid, seatno)
values (1, '122B'),
       (1, '123A'),
       (1, '123B'),
       (2, '123A'),
       (3, '123A');

call register_user(1, 'pass1');
call register_user(2, 'pass2');
call register_user(3, 'pass3');
call register_user(4, 'pass4');

insert into reservations (flightid, seatno, userid, reserveduntil)
values (1, '124A', 1, '2023-11-20 13:43:27.175607'),
       (1, '125B', 1, '2023-11-20 13:43:27.175607'),
       (1, '124B', 2, '2023-11-20 13:43:37.917177');
