-- Необходимо для хэширования пароля
create extension if not exists pgcrypto;

-- Создание нового пользователя
create procedure register_user(user_id integer, pass varchar(72))
as
$register_user$
begin
    insert into users (userid, passhash) values (user_id, crypt(pass, gen_salt('bf')));
end;
$register_user$
    language plpgsql;

-- Авторизация пользователя
create function auth(user_id integer, pass varchar(72)) returns boolean
as
$auth$
begin
    return exists(select userid
                  from users
                  where userid = user_id
                    and passhash = crypt(pass, passhash));
end;
$auth$
    language plpgsql;

-- Проверка доступности бронирования места на рейс
create function reservation_available(flight_id integer) returns boolean
as
$reservation_available$
begin
    return (select not reservationcanceled and now() < flighttime - interval '3 days'
            from flights
            where flightid = flight_id);
end;
$reservation_available$
    language plpgsql;

-- Проверка доступности покупки билетов на рейс
create function purchase_available(flight_id integer) returns boolean
as
$purchase_available$
begin
    return (select not purchasecanceled and now() < flighttime - interval '3 hours'
            from flights
            where flightid = flight_id);
end;
$purchase_available$
    language plpgsql;

-- Даёт список мест, которые не куплены и не забронированы
create function free_seats(FlightId integer)
    returns setof varchar(4)
as
$free_seats$
select s.seatno
from flights f
         natural join seats s
where f.flightid = free_seats.FlightId
except
(select t.seatno
 from tickets t
 where t.flightid = free_seats.FlightId
 union
 select r.seatno
 from reservations r
 where r.flightid = free_seats.FlightId
   and r.reserveduntil > now());
$free_seats$
    language sql;
