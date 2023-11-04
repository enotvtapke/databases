create table Schedule
(
    id          int primary key,
    course_id   int,
    group_id    int,
    lecturer_id int,
    constraint schedule_index unique (course_id, group_id)
);

create table Groups
(
    id          int primary key,
    name        int unique,
    schedule_id int,
    constraint group_schedule foreign key (schedule_id) references Schedule (id)
);

create table Students
(
    id       int primary key,
    name     varchar(64),
    group_id int,
    constraint student_group foreign key (group_id) references Groups (id)
);

create table Courses
(
    id          int primary key,
    name        varchar(64),
    schedule_id int,
    constraint course_schedule foreign key (schedule_id) references Schedule (id)
);

create table Lecturers
(
    id          int primary key,
    name        varchar(64),
    schedule_id int,
    constraint course_schedule foreign key (schedule_id) references Schedule (id)
);

create table Mark
(
    id         int primary key,
    student_id int,
    course_id  int,
    constraint mark_index unique (student_id, course_id),
    constraint mark_student foreign key (student_id) references Students (id),
    constraint mark_course foreign key (course_id) references Courses (id)
);
