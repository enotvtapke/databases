create table Groups
(
    id     bigserial primary key,
    course integer not null,
    code   char(6) not null
);

create table Students
(
    id   bigserial primary key,
    name varchar(64) not null,
    group_id bigint references Groups(id) not null
);

create table Teachers
(
    id   bigserial primary key,
    name varchar(64) not null
);

create table Subjects
(
    id   bigserial primary key,
    name varchar(128) not null
);

create table Lessons
(
    id bigserial primary key,
    type varchar(32) not null,
    location varchar(64) not null,
    week_day integer not null,
    time time(0) not null,
    group_id bigint references Groups (id) not null,
    teacher_id bigint references Teachers (id) not null,
    subject_id bigint references Subjects(id) not null
);

create table Scores
(
    points numeric(5, 2) not null,
    student_id bigint references Students (id) not null,
    subject_id bigint references Subjects(id) not null,
    primary key (student_id, subject_id)
);
