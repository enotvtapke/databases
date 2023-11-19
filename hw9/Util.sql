create procedure register_user(user_id integer, pass varchar(72))
as
$register_user$
begin
    insert into users (userid, passhash) values (user_id, crypt(pass, gen_salt('bf')));
end;
$register_user$
    language plpgsql;

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
