insert into Groups (id, course, code)
values (1, 4, 'M34351'),
       (2, 4, 'M34391');

insert into Students (id, name, group_id)
values (1, 'Максим Зенков', 1),
       (2, 'Матвей Колесов', 2),
       (3, 'Надежда Шевелева', 1);

insert into Teachers (id, name)
values (1, 'Павел Скаков'),
       (2, 'Петр Трифонов'),
       (3, 'Иван Иванов');

insert into Subjects (id, name)
values (1, 'Ассемблер'),
       (2, 'Теория кодирования'),
       (3, 'Сложный предмет');

insert into Lessons (type, location, week_day, time, group_id, teacher_id, subject_id)
VALUES ('lecture', '100', 6, '15:20:00', 1, 1, 1),
       ('practice', '100', 6, '17:00:00', 1, 1, 1),
       ('lecture', '100', 6, '15:20:00', 2, 1, 1),
       ('practice', '100', 6, '17:00:00', 2, 1, 1),
       ('lecture', '1157', 5, '13:30:00', 1, 2, 2),
       ('lecture', '1157', 5, '13:30:00', 2, 2, 2),
       ('lecture', '1157', 7, '08:20:00', 2, 3, 3);

insert into Scores(points, student_id, subject_id)
VALUES (85.5, 1, 1),
       (100, 2, 2);