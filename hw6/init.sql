create table Students
(
    StudentId   int,
    StudentName varchar,
    GroupId     int
);
insert into Students
values (1, 'Иванов И.И.', 1),
       (2, 'Петров П.П.', 1),
       (3, 'Петров П.П.', 2),
       (4, 'Сидров С.С.', 2),
       (5, 'Неизвестный Н.Н.', 3),
       (6, 'Безымянный Б.Б', 4);

create table Groups
(
    GroupId   int,
    GroupName varchar
);
insert into Groups
values (1, 'M3435'),
       (2, 'M3439'),
       (3, 'M3238'),
       (4, 'M3239');

create table Courses
(
    CourseId   int,
    CourseName varchar
);
insert into Courses
values (1, 'Базы данных'),
       (2, 'Управление проектами'),
       (3, 'ППО'),
       (4, 'Теория информации'),
       (6, 'Математический анализ'),
       (7, 'Технологии Java');

create table Lecturers
(
    LecturerId   int,
    LecturerName varchar
);
insert into Lecturers
values (1, 'Корнеев Г.А.'),
       (2, 'Будин Н.А.'),
       (3, 'Кузнецова Е.М.'),
       (4, 'Киракозов А.Х.'),
       (6, 'Трофимюк Г.А.'),
       (7, 'Беляев Е.А.'),
       (8, 'Кохась К.П.');

create table Plan
(
    GroupId    int,
    CourseId   int,
    LecturerId int
);
insert into Plan
values (1, 1, 2),
       (2, 1, 1),
       (1, 2, 3),
       (1, 3, 4),
       (2, 3, 4),
       (2, 4, 6),
       (1, 4, 7),
       (2, 4, 7),
       (4, 6, 8),
       (1, 7, 1),
       (2, 7, 1),
       (3, 7, 1),
       (4, 7, 1);

create table Marks
(
    StudentId int,
    CourseId  int,
    Mark      int
);
insert into Marks
values (1, 1, 5),
       (2, 1, 4),
       (3, 1, 3),
       (2, 2, 3),
       (3, 2, 4),
       (4, 2, 5),
       (7, 1, 5),
       (8, 1, 5),
       (7, 7, 5),
       (8, 7, 5),
       (5, 7, 5),
       (6, 7, 5),
       (3, 3, 3);
