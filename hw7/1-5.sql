-- ####################################################
-- section Реализуйте указанные запросы, представления,
--         проверки и триггеры на языке SQL.
-- ####################################################
--
-- ###################################################
-- subsection 1. Напишите запросы, удаляющие студентов
--
-- comment 1.1.  Учащихся в группе, заданной идентификатором
--               (GroupId)
--
-- set-var :GroupId = 1

delete
from students
where groupid = :GroupId;


-- comment 1.2.  Учащихся в группе, заданной названием
--               (GroupName)
--
-- set-var :GroupName = 'M3439'

delete
from students
where groupid in (select groupid from groups where groupname = :GroupName);


-- comment 1.3.  Без оценок

delete
from students
where studentid not in (select studentid from marks);


-- comment 1.4.  Имеющих 3 и более оценки

delete
from students
where studentid in (select studentid from marks group by studentid having count(mark) > 2);


-- comment 1.5.  Имеющих 3 и менее оценки

delete
from students
where studentid not in (select studentid from marks group by studentid having count(mark) > 3);

-- comment 1.6.  Студентов, c долгами (здесь и далее — по отсутствию оценки)

delete
from students
where studentid in (select studentid
                    from students
                             natural join plan
                             natural left join marks
                    where mark is null);


-- comment 1.7.  Студентов, имеющих 2 и более долга

delete
from students
where studentid in (select studentid
                    from students
                             natural join plan
                             natural left join marks
                    where mark is null
                    group by studentid
                    having count(distinct courseid) >= 2);


-- comment 1.8.  Студентов, имеющих не более 2 долгов

delete
from students
where studentid not in (select studentid
                        from students
                                 natural join plan
                                 natural left join marks
                        where mark is null
                        group by studentid
                        having count(distinct courseid) > 2);


-- ############################################################
-- subsection 2. Напишите запросы, обновляющие данные студентов
--
-- comment 2.1.  Изменение имени студента
--               (StudentId, StudentName)
--
-- set-var :StudentId = 1
--
-- set-var :StudentName = 'Иванов И.И.'

update students
set studentname = :StudentName
where studentid = :StudentId;


-- comment 2.2.  Перевод студента из группы в группу по индентификаторам
--               (StudentId, GroupId, FromGroupId)
--
-- set-var :StudentId = 1
--
-- set-var :GroupId = 1
--
-- set-var :FromGroupId = 1

update students
set groupid = :GroupId
where studentid = :StudentId
  and groupid = :FromGroupId;


-- comment 2.3.  Перевод всех студентов из группы в группу по идентификаторам
--               (GroupId, FromGroupId)
--
-- set-var :GroupId = 1
--
-- set-var :FromGroupId = 1

update students
set groupid = :GroupId
where groupid = :FromGroupId;


-- comment 2.4.  Перевод студента из группы в группу по названиям
--               (GroupName, FromGroupName)
--
-- set-var :GroupName = 'M3439'
--
-- set-var :FromGroupName = 'M3435'

update students
set groupid = (select groupid from groups where groupname = :GroupName)
where groupid in (select groupid from groups where groupname = :FromGroupName);

-- comment 2.5.  Перевод всех студентов из группы в группу,
--               только если целевая группа существует
--               (GroupName, FromGroupName)
--
-- set-var :GroupName = 'M3439'
--
-- set-var :FromGroupName = 'M3435'

update students
set groupid = (select groupid from groups where groupname = :GroupName)
where groupid in (select groupid from groups where groupname = :FromGroupName)
  and (select groupid from groups where groupname = :GroupName) is not null;


-- ######################################################################
-- subsection 3. Напишите запросы, подсчитывающие статистику по студентам
--
-- comment 3.1.  Число оценок студента
--               (столбец Students.Marks)
--               (StudentId)
--
-- set-var :StudentId = 1

update students
set Marks = (select count(mark) from marks where studentid = :StudentId)
where studentid = :StudentId;


-- comment 3.2.  Число оценок каждого студента
--               (столбец Students.Marks)

update students
set marks = (select count(mark) from marks where students.studentid = marks.studentid)
where true;


-- comment 3.3.  Пересчет числа оценок каждого студента
--               по данным из таблицы NewMarks
--               (столбец Students.Marks)

update students
set marks = marks + (select count(mark) from NewMarks where students.studentid = NewMarks.studentid)
where true;


-- comment 3.4.  Число сданных дисциплин каждого студента
--               (столбец Students.Marks)

update students
set marks = (select count(distinct courseid) from marks where students.studentid = marks.studentid)
where true;


-- comment 3.5.  Число долгов студента
--               (столбец Students.Debts)
--               (StudentId)
--
-- set-var :StudentId = 1

update students
set Debts = (select count(distinct courseid)
             from plan
             where plan.courseid not in (select courseid from marks where marks.studentid = :StudentId)
               and students.groupid = plan.groupid)
where studentid = :StudentId;


-- comment 3.6.  Число долгов каждого студента
--               (столбец Students.Debts)

update students
set Debts = (select count(distinct courseid)
             from plan
             where plan.courseid not in (select courseid from marks where marks.studentid = students.studentid)
               and students.groupid = plan.groupid)
where true;

-- comment 3.7.  Число долгов каждого студента группы (столбец Students.Debts)
--               (GroupName)
--
-- set-var :GroupName = 'M3439'

update students
set Debts = (select count(distinct courseid)
             from plan
             where plan.courseid not in (select courseid from marks where marks.studentid = students.studentid)
               and students.groupid = plan.groupid)
where groupid in (select groupid from groups where groupname = :GroupName);


-- comment 3.8.  Число оценок и долгов каждого студента
--               (столбцы Students.Marks, Students.Debts)

update students
set Debts = (select count(distinct courseid)
             from plan
             where plan.courseid not in (select courseid from marks where marks.studentid = students.studentid)
               and students.groupid = plan.groupid),
    Marks = (select count(mark) from marks where marks.studentid = students.studentid)
where true;

-- ###########################################################
-- subsection 4. Напишите запросы, обновляющие оценки,
--               с учетом данных из таблицы NewMarks,
--               имеющей такую же структуру, как таблица Marks
--
-- comment 4.1.  Проставляющий новую оценку только если ранее оценки не было

-- insert into marks (studentid, courseid, mark)
-- select studentid, courseid, mark
-- from newmarks where true
-- on conflict (studentid, courseid) do nothing;

insert into marks (studentid, courseid, mark)
select studentid, courseid, mark
from newmarks
where not exists(select mark
                 from marks
                 where marks.studentid = newmarks.studentid
                   and marks.courseid = newmarks.courseid);


-- comment 4.2.  Проставляющий новую оценку только если ранее оценка была

update marks
set Mark = (select mark
            from newmarks
            where marks.studentid = newmarks.studentid
              and marks.courseid = newmarks.courseid)
where exists(select mark
             from newmarks
             where marks.studentid = newmarks.studentid
               and marks.courseid = newmarks.courseid);


-- comment 4.3.  Проставляющий максимум из старой и новой оценки
--               только если ранее оценка была

update marks
set Mark = (select mark
            from newmarks
            where marks.studentid = newmarks.studentid
              and marks.courseid = newmarks.courseid)
where mark < (select mark
              from newmarks
              where marks.studentid = newmarks.studentid
                and marks.courseid = newmarks.courseid);


-- comment 4.4.  Проставляющий максимум из старой и новой оценки
--               (если ранее оценки не было, то новую оценку)

merge into marks
using newmarks
on marks.studentid = newmarks.studentid and marks.courseid = newmarks.courseid
when matched and newmarks.mark > marks.mark then
    update
    set mark = newmarks.mark
when not matched then
    insert (studentid, courseid, mark)
    values (newmarks.studentid, newmarks.courseid, newmarks.mark);


-- ######################################
-- subsection 5. Работа с представлениями
--
-- comment 5.1.  Создайте представление StudentMarks в котором
--               для каждого студента указано число оценок
--               (StudentId, Marks)

create view StudentMarks as
select studentid, count(mark) as marks
from students
         natural left join marks
group by studentid;


-- comment 5.2.  Создайте представление AllMarks в котором
--               для каждого студента указано число оценок,
--               включая оценки из таблицы NewMarks
--               (StudentId, Marks)

-- create view AllMarks as
-- select students.studentid, count(marks.mark) + count(newmarks.mark) as marks
-- from students
--          natural left join marks
--          left join newmarks on students.studentid = newmarks.studentid, marks
-- group by students.studentid;

create view AllMarks as
select studentid, count(mark) as marks
from students
         natural left join (select studentid, mark
                            from marks
                            union all
                            select studentid, mark
                            from newmarks) as s
group by studentid;


-- comment 5.3.  Создайте представление Debts в котором для каждого
--               студента, имеющего долги указано их число
--               (StudentId, Debts)

create view Debts as
select studentid as StudentId, count(distinct courseid) as Debts
from students
         natural join plan
         natural left join marks
where mark is null
group by studentid;


-- comment 5.4.  Создайте представление StudentDebts в котором
--               для каждого студента указано число долгов
--               (StudentId, Debts)

create view StudentDebts as
select students.studentid, coalesce(s.Debts, 0) as Debts
from students
         left join (select studentid, count(distinct courseid) as Debts
                    from students
                             natural join plan
                             natural left join marks
                    where mark is null
                    group by studentid) as s on students.studentid = s.studentid;
