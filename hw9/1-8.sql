-- 1. FreeSeats(FlightId) — список мест, доступных для продажи и для бронирования.

create function FreeSeats(FlightId integer)
    returns setof varchar(4)
as
$FreeSeats$
select free_seats(FreeSeats.FlightId)
where purchase_available(FreeSeats.FlightId)
  and reservation_available(FreeSeats.FlightId);
$FreeSeats$
    language sql;


-- 2. Reserve(UserId, Pass, FlightId, SeatNo) — пытается забронировать место на трое суток начиная с момента бронирования. Возвращает истину, если удалось и ложь — в противном случае.

create function Reserve(UserId integer, Pass varchar(72), FlightId integer, SeatNo char(4)) returns boolean
as
$Reserve$
begin
    if reservation_available(FlightId) and
       auth(UserId, Pass) and
       SeatNo in (select free_seats(FlightId))
    then
        insert into reservations (flightid, seatno, userid, reserveduntil)
        values (Reserve.FlightId, Reserve.SeatNo, Reserve.UserId, now() + interval '3 day');
        return true;
    end if;
    return false;
end;
$Reserve$
    language plpgsql;


-- 3. ExtendReservation(UserId, Pass, FlightId, SeatNo) — пытается продлить бронь места на трое суток начиная с момента продления. Возвращает истину, если удалось и ложь — в противном случае.

create function ExtendReservation(UserId integer, Pass varchar(72), FlightId integer, SeatNo char(4)) returns boolean
as
$ExtendReservation$
begin
    if reservation_available(FlightId) and
       auth(UserId, Pass) and
       exists(select r.flightid
              from reservations r
              where r.flightid = ExtendReservation.FlightId
                and r.seatno = ExtendReservation.SeatNo
                and r.userid = ExtendReservation.UserId
                and r.reserveduntil > now())
    then
        update reservations r
        set reserveduntil = now() + interval '3 day'
        where r.flightid = ExtendReservation.FlightId
          and r.seatno = ExtendReservation.SeatNo;
        return true;
    end if;
    return false;
end;
$ExtendReservation$
    language plpgsql;


-- 4. BuyFree(FlightId, SeatNo) — пытается купить свободное место. Возвращает истину, если удалось и ложь — в противном случае.

create function BuyFree(FlightId integer, SeatNo char(4)) returns boolean
as
$BuyFree$
begin
    if purchase_available(FlightId) and
       SeatNo in (select free_seats(FlightId))
    then
        insert into tickets (flightid, seatno) values (BuyFree.FlightId, BuyFree.SeatNo);
        return true;
    end if;
    return false;
end;
$BuyFree$
    language plpgsql;


-- 5. BuyReserved(UserId, Pass, FlightId, SeatNo) — пытается выкупить забронированное место (пользователи должны совпадать). Возвращает истину, если удалось и ложь — в противном случае.

create function BuyReserved(UserId integer, Pass varchar(72), FlightId integer, SeatNo char(4)) returns boolean
as
$BuyReserved$
begin
    if purchase_available(FlightId) and
       auth(UserId, Pass) and
       exists(select r.flightid
              from reservations r
              where r.flightid = BuyReserved.FlightId
                and r.seatno = BuyReserved.SeatNo
                and r.userid = BuyReserved.UserId
                and r.reserveduntil > now())
    then
        insert into tickets (flightid, seatno) values (BuyReserved.FlightId, BuyReserved.SeatNo);
        delete from reservations r where r.flightid = BuyReserved.FlightId and r.seatno = BuyReserved.SeatNo;
        return true;
    end if;
    return false;
end;
$BuyReserved$
    language plpgsql;


-- 6. FlightsStatistics(UserId, Pass) — статистика по рейсам: возможность бронирования и покупки, число свободных, забронированных и проданных мест.

create function FlightsStatistics(UserId integer, Pass varchar(72))
    returns table
            (
                flight_id   integer,
                sold        bigint,
                reserved    bigint,
                free        bigint,
                can_reserve boolean,
                can_buy     boolean
            )
as
$FlightsStatistics$
declare
begin
    if not auth(UserId, Pass) then
        return;
    end if;
    return query (select f.flightid                                           as flight_id,
                         count(t.flightid)                                    as sold,
                         count(r.flightid)                                    as reserved,
                         count(*) - count(t.flightid) - count(r.flightid)     as free,
                         reservation_available(f.flightid) and
                         count(*) - count(t.flightid) - count(r.flightid) > 0 as can_reserve,
                         purchase_available(f.flightid) and
                         count(*) - count(t.flightid) - count(r.flightid) > 0 as can_buy
                  from flights f
                           natural join seats s
                           left join tickets t on f.flightid = t.flightid and s.seatno = t.seatno
                           left join (select r.flightid, r.seatno from reservations r where reserveduntil > now()) r
                                     on f.flightid = r.flightid and s.seatno = r.seatno
                  group by f.flightid);
end;
$FlightsStatistics$
    language plpgsql;


-- 7. FlightStat(UserId, Pass, FlightId) — статистика по рейсу: возможность бронирования и покупки, число свободных, забронированных и проданных мест.

create function FlightStat(UserId integer, Pass varchar(72), FlightId integer)
    returns table
            (
                sold        bigint,
                reserved    bigint,
                free        bigint,
                can_reserve boolean,
                can_buy     boolean
            )
as
$FlightsStatistics$
declare
begin
    if not auth(UserId, Pass) then
        return;
    end if;
    return query (select count(t.flightid)                                    as sold,
                         count(r.flightid)                                    as reserved,
                         count(*) - count(t.flightid) - count(r.flightid)     as free,
                         reservation_available(FlightStat.FlightId) and
                         count(*) - count(t.flightid) - count(r.flightid) > 0 as can_reserve,
                         purchase_available(FlightStat.FlightId) and
                         count(*) - count(t.flightid) - count(r.flightid) > 0 as can_buy
                  from flights f
                           natural join seats s
                           left join tickets t on f.flightid = t.flightid and s.seatno = t.seatno
                           left join (select r.flightid, r.seatno from reservations r where reserveduntil > now()) r
                                     on f.flightid = r.flightid and s.seatno = r.seatno
                  where f.flightid = FlightStat.FlightId);
end;
$FlightsStatistics$
    language plpgsql;


-- 8. CompressSeats(FlightId) — оптимизирует занятость мест в самолете. В результате оптимизации, в начале самолета должны быть купленные места, затем — забронированные, а в конце — свободные. Примечание: клиенты, которые уже выкупили билеты также должны быть пересажены.

create procedure CompressSeats(FlightId integer)
as
$CompressSeats$
declare
    seat char(4);
    seats cursor for select s.seatno
                     from seats s
                     where s.planeid =
                           (select f.planeid from flights f where f.flightid = CompressSeats.FLightId)
                     order by s.seatno;
    sold cursor for select t.seatno
                    from tickets t
                    where t.flightid = CompressSeats.FLightId for update;
    reserved cursor for select r.seatno
                        from reservations r
                        where r.flightid = CompressSeats.FLightId for update;
begin
    set constraints tickets_pkey deferred;
    open seats;
    for _ in sold
        loop
            fetch seats into seat;
            update tickets set seatno = seat where current of sold;
        end loop;
    for _ in reserved
        loop
            fetch seats into seat;
            update reservations set seatno = seat where current of reserved;
        end loop;
end;
$CompressSeats$
    language plpgsql;
