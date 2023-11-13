-- Список студентов группы, отсортированный по имени студента
select studentname from students where groupid = :GroupId order by studentname;
-- Нужна возможность сортировки => btree. Чтобы не сортировать всех, а только студентов в конкретной группе, первый столбец индекс это groupId
create index students_groupId_studentName on students using btree (groupid, studentname);

-- Максимальная оценка по курсу среди всех студентов
select max(mark) from marks where courseid = :CourseId;
-- Чтобы искать максимум только в рамках заданного курса, но при этом среди всех студентов, первый столбец courseId. btree потому что max
create index marks_courseId_mark on marks using btree (courseid, mark);

-- Все курсы, которые ведёт лектор у группы
select courseid from plan where lecturerid = :LecturerId and groupid = :GroupId;
-- Не нужен поиск по префиксу и диапазоны => hash
create index plan_lectorId_groupId on plan using hash (lecturerid, groupid);
