-- drop schema public cascade;
-- create schema public;

-- Рейсы. Столбцы Canceled необходимы для ручного отключения возможности бронирования или покупки билетов
create table Flights
(
    FlightId            integer primary key,
    FlightTime          timestamp not null,
    PlaneId             integer   not null,
    reservationCanceled boolean   not null default false,
    purchaseCanceled    boolean   not null default false
);

-- Места, которые есть в самолётах
create table Seats
(
    PlaneId integer,
    SeatNo  varchar(4),
    primary key (PlaneId, SeatNo)
);

create index seats_planeid on Seats using hash (PlaneId);

-- Пользователи в системе
create table Users
(
    UserId   integer primary key,
    PassHash text not null
);

-- Купленные билеты на рейс
create table Tickets
(
    FlightId integer    not null references Flights (FlightId),
    SeatNo   varchar(4) not null,
    primary key (FlightId, SeatNo) deferrable
);

create index tickets_flightid on Tickets using hash (flightid);

-- Забронированные билеты на рейс
create table Reservations
(
    FlightId      integer    not null references Flights (FlightId),
    SeatNo        varchar(4) not null,
    UserId        integer    not null references Users (UserId),
    ReservedUntil timestamp  not null
);

create index reservations_flightid_seatno on Reservations using btree (flightid, seatno);
