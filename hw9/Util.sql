create or replace procedure add_user(user_id integer, pass varchar(72))
as
$add_user$
begin
    insert into users (userid, passhash) values (user_id, crypt(pass, gen_salt('bf')));
end;
$add_user$
    language plpgsql;

create or replace function auth(user_id integer, pass varchar(72)) returns boolean
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

create function in_future(flight_id integer) returns boolean
as
$Auth$
begin
    return now() < (select flighttime from flights where flightid = flight_id);

end;
$Auth$
    language plpgsql;
