create database ctd;

create table Groups (
                        group_id int,
                        group_no char(6)
);

create table Students (
                          student_id int,
                          name varchar(30),
                          group_id int
);

insert into Groups (group_id, group_no) values (1, 'M31351'), (2, 'M32391');

select group_id, group_no from Groups;

update Groups set group_no = 'M34361' where group_id = 1;
update Groups set group_no = 'M34391' where group_id = 2;

select group_id, group_no from Groups;

insert into Students (student_id, name, group_id) VALUES (1, 'Konstantin Bats', 1);
insert into Students (student_id, name, group_id) VALUES (2, 'Andrey Solodovnikov', 1);
insert into Students (student_id, name, group_id) VALUES (3, 'Maksim Alzhanov', 2);

select * from Students;

select group_no, name from Groups natural join Students;
select * from Groups inner join Students on Groups.group_id = Students.group_id;

-- Do not use * in production code

insert into Groups (group_id, group_no) VALUES (2, 'M34381'); -- Now there is a row in the table with non-unique id

update groups set group_id = 3 where group_no = 'M34381';

alter table groups add constraint group_id_uniq unique (group_id);

insert into Groups (group_id, group_no) VALUES (2, 'M34381'); -- Now this query fails

alter table groups add constraint group_no_uniq unique (group_no);

update students set group_id = 5 where student_id = 3;

update students set group_id = 3 where student_id = 3;

alter table students add constraint group_id_fk foreign key (group_id) references Groups(group_id);

update students set group_id = 5 where student_id = 3; -- Now this query does not work

insert into Groups (group_id, group_no) VALUES (4, 'я русс'); -- Now this query fails

select * from Groups;

/*
 Homework
    Project:
        1 At least 5 entities. Reasonable amount of links.
        2 It is better to start thinking about project right now.
        3 You should come up with area (like bank). Competitive programming, internet shop and study related topics are banned.

 */
