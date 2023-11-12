-- #########################################################
-- section Составьте выражения реляционной алгебры и
--         соответствующие SQL-запросы, позволяющие получать
-- #########################################################
--
-- #####################################
-- subsection 01. Информацию о студентах
--
-- comment 01.1. С заданным идентификатором
--               (StudentId, StudentName, GroupId по :StudentId)
--
-- set-var :StudentId = 1
--
-- s{StudentId = :StudentId}(Students)

select StudentId, StudentName, GroupId
from Students
where StudentId = :StudentId;


-- comment 01.2. С заданным ФИО
--               (StudentId, StudentName, GroupId по :StudentName)
--
-- set-var :StudentName = 'Иванов И.И.'
--
-- s{StudentName = :StudentName}(Students)

select StudentId, StudentName, GroupId
from Students
where StudentName = :StudentName;


-- ############################################
-- subsection 02. Полную информацию о студентах
--
-- comment 02.1. С заданным идентификатором
--               (StudentId, StudentName, GroupName по :StudentId)
--
-- set-var :StudentId = 1
--
-- pi{StudentId, StudentName, GroupName}(s{StudentId = :StudentId}(Students nj Groups))

select StudentId, StudentName, GroupName
from Students
         natural join Groups
where StudentId = :StudentId;


-- comment 02.2. С заданным ФИО
--               (StudentId, StudentName, GroupName по :StudentName)
--
-- set-var :StudentName = 'Иванов И.И.'
--
-- pi{StudentId, StudentName, GroupName}(s{StudentName = :StudentName}(Students nj Groups))

select StudentId, StudentName, GroupName
from Students
         natural join Groups
where StudentName = :StudentName;


-- ######################################################################
-- subsection 03. Информацию о студентах с заданной оценкой по дисциплине
--
-- comment 03.1. С заданным идентификатором
--               (StudentId, StudentName, GroupId по :Mark, :CourseId)
--
-- set-var :Mark = 5
--
-- set-var :CourseId = 1
--
-- pi{StudentId, StudentName, GroupId}(s{CourseId = :CourseId && Mark = :Mark}(Students nj Marks))

select StudentId, StudentName, GroupId
from Students
         natural join Marks
where CourseId = :CourseId
  and Mark = :Mark;


-- comment 03.2. С заданным названием
--               (StudentId, StudentName, GroupId по :Mark, :CourseName)
--
-- set-var :Mark = 5
--
-- set-var :CourseName = 'Базы данных'
--
-- pi{StudentId, StudentName, GroupId}(s{CourseName = :CourseName && Mark = :Mark}(Students nj Marks nj Courses))

select StudentId, StudentName, GroupId
from Students
         natural join Marks
         natural join Courses
where CourseName = :CourseName
  and Mark = :Mark;


-- comment 03.3. Которую у него вёл лектор заданный идентификатором
--               (StudentId, StudentName, GroupId по :Mark, :LecturerId)
--
-- set-var :Mark = 5
--
-- set-var :LecturerId = 1
--
-- pi{StudentId, StudentName, GroupId}(s{LecturerId = :LecturerId && Mark = :Mark}(Students nj Plan nj Marks))

select StudentId, StudentName, GroupId
from Students
         natural join Plan
         natural join Marks
where LecturerId = :LecturerId
  and Mark = :Mark;


-- comment 03.4. Которую у него вёл лектор, заданный ФИО
--               (StudentId, StudentName, GroupId по :Mark, :LecturerName)
--
-- set-var :Mark = 5
--
-- set-var :LecturerName = 'Корнеев Г.А.'
--
-- pi{StudentId, StudentName, GroupId}(s{LecturerName = :LecturerName && Mark = :Mark}(Students nj Plan nj Marks nj Lecturers))

select StudentId, StudentName, GroupId
from Students
         natural join Plan
         natural join Marks
         natural join Lecturers
where LecturerName = :LecturerName
  and Mark = :Mark;


-- comment 03.5. Которую вёл лектор, заданный идентификатором
--               (StudentId, StudentName, GroupId по :Mark, :LecturerId)
--
-- set-var :Mark = 5
--
-- set-var :LecturerId = 1
--
--     p{StudentId, StudentName, GroupId}(s{Mark = :Mark && LecturerId = :LecturerId}(Students nj Marks nj p{LecturerId, CourseId}(Plan)))

select S.StudentId, S.StudentName, S.GroupId
from Marks m
         inner join Plan p on m.CourseId = p.CourseId
         inner join Students s on m.StudentId = s.StudentId
where LecturerId = :LecturerId
  and Mark = :Mark;


-- comment 03.6. Которую вёл лектор, заданный ФИО
--               (StudentId, StudentName, GroupId по :Mark, :LecturerName)
--
-- set-var :Mark = 5
--
-- set-var :LecturerName = 'Корнеев Г.А.'
--
-- p{StudentId, StudentName, GroupId}(
--     s{Mark = :Mark && LecturerName = :LecturerName}(
--         Students nj Marks nj p{LecturerId, CourseId}(Plan) nj Lecturers
--     )
-- )

select StudentId, StudentName, GroupId
from Students
         natural join Marks
         natural join (select CourseId
                       from Plan
                                natural join Lecturers
                       where LecturerName = :LecturerName) Q
where Mark = :Mark;


-- #####################################################################
-- subsection 04. Информацию о студентах не имеющих оценки по дисциплине
--
-- comment 04.1. Среди всех студентов
--               (StudentId, StudentName, GroupId по :CourseName)
--
-- set-var :CourseName = 'Базы данных'
--
-- Students diff p{StudentId, StudentName, GroupId}(s{CourseName = :CourseName}(Students nj Marks nj Courses))

select StudentId, StudentName, GroupId
from Students
except
select StudentId, StudentName, GroupId
from Students
         natural join Marks
         natural join Courses
where CourseName = :CourseName;


-- comment 04.2. Среди студентов, у которых есть эта дисциплина
--               (StudentId, StudentName, GroupId по :CourseName)
--
-- set-var :CourseName = 'Базы данных'
--
-- p{StudentId, StudentName, GroupId}(
--     s{CourseName = :CourseName}(Students nj Plan nj Courses)
-- )
-- diff
-- p{StudentId, StudentName, GroupId}(
--     s{CourseName = :CourseName}(Students nj Marks nj Courses)
-- )

select StudentId, StudentName, GroupId
from Students
         natural join Plan
         natural join Courses
where CourseName = :CourseName
except
select StudentId, StudentName, GroupId
from Students
         natural join Marks
         natural join Courses
where CourseName = :CourseName;


-- ############################################################
-- subsection 05. Для каждого студента ФИО и названия дисциплин
--
-- comment 05.1. Которые у него есть по плану
--               (StudentName, CourseName)
--
-- p{StudentName, CourseName}(Students nj Plan nj Courses)

select StudentName, CourseName
from (select distinct StudentId, StudentName, CourseName
      from Plan
               natural join Courses
               natural join Students) q;


-- comment 05.2. Есть, но у него нет оценки
--               (StudentName, CourseName)
--
-- p{StudentName, CourseName}(
--     (
--         p{StudentId, CourseId}(Students nj Plan)
--         diff
--         p{StudentId, CourseId}(Students nj Marks)
--     )
--     nj Students
--     nj Courses
-- )

select StudentName, CourseName
from (select distinct StudentId, StudentName, CourseName
      from Students
               natural join Plan
               natural join Courses
      except
      select StudentId, StudentName, CourseName
      from Students
               natural join Marks
               natural join Courses) q3;


-- comment 05.3. Есть, но у него не 4 или 5
--               (StudentName, CourseName)
--
-- p{StudentName, CourseName}(
--     (
--         p{StudentId, CourseId}(Students nj Plan)
--         diff
--         p{StudentId, CourseId}(s{Mark = 4 || Mark = 5}(Students nj Marks))
--     )
--     nj Students nj Courses
-- )

select StudentName, CourseName
from (select distinct StudentId, StudentName, CourseName
      from Students
               natural join Plan
               natural join Courses
      except
      select StudentId, StudentName, CourseName
      from Students
               natural join Marks
               natural join Courses
      where Mark = 4
         or Mark = 5) q3;


-- ########################################################
-- subsection 06. Идентификаторы студентов по преподавателю
--
-- comment 06.1. Имеющих хотя бы одну оценку у преподавателя
--               (StudentId по :LecturerName)
--
-- set-var :LecturerName = 'Корнеев Г.А.'
--
-- p{StudentId}(s{LecturerName = :LecturerName}(Students nj Marks nj Lecturers nj Plan))

select distinct StudentId
from Students
         natural join Marks
         natural join Lecturers
         natural join Plan
where LecturerName = :LecturerName;


-- comment 06.2. Не имеющих ни одной оценки у преподавателя
--               (StudentId по :LecturerName)
--
-- set-var :LecturerName = 'Корнеев Г.А.'
--
-- p{StudentId}(Students) diff p{StudentId}(s{LecturerName = :LecturerName}(Students nj Marks nj Lecturers nj Plan))

select StudentId
from Students
except
select StudentId
from Students
         natural join Marks
         natural join Lecturers
         natural join Plan
where LecturerName = :LecturerName;


-- comment 06.3. Имеющих оценки по всем дисциплинам преподавателя
--               (StudentId по :LecturerName)
--
-- set-var :LecturerName = 'Корнеев Г.А.'
--
-- p{StudentId, CourseId}(Marks) div p{CourseId}(s{LecturerName = :LecturerName}(Plan nj Lecturers))

select StudentId
from Marks
except
select StudentId
from (select StudentId, CourseId
      from (select StudentId from Marks) q1
               cross join (select CourseId
                           from Plan
                                    natural join Lecturers
                           where LecturerName = :LecturerName) q2
      except
      select StudentId, CourseId
      from Marks) q3;


-- comment 06.4. Имеющих оценки по всем дисциплинам преподавателя,
--               которые он вёл у этого студента
--               (StudentId по :LecturerName)
--
-- set-var :LecturerName = 'Корнеев Г.А.'
--
-- p{StudentId}(
--     p{StudentId, CourseId}(Marks) gdiv p{GroupId, CourseId}(s{LecturerName = :LecturerName}(Plan nj Lecturers)) nj Students
-- )

select StudentId
from (select StudentId, GroupId
      from Marks
               cross join
           (select GroupId
            from Plan
                     natural join Lecturers
            where LecturerName = :LecturerName) as PLGI
      except
      select StudentId, GroupId
      from (select StudentId, GroupId, GICI.CourseId
            from Marks
                     cross join (select GroupId, CourseId
                                 from Plan
                                          natural join Lecturers
                                 where LecturerName = :LecturerName) as GICI
            except
            select StudentId, GroupId, CourseId
            from Marks
                     natural join
                 (select GroupId, CourseId
                  from Plan
                           natural join Lecturers
                  where LecturerName = :LecturerName) as G) as SIGICISIGICI) as SIGISIGI
         natural join Students;


-- #################################################################################################
-- subsection 07. Группы и дисциплины, такие что все студенты группы имеют оценку по этой дисциплине
--
-- comment 07.1. Идентификаторы
--               (GroupId, CourseId)
--
-- p{CourseId}(Marks) cj p{GroupId}(Students) diff p{CourseId, GroupId}(
-- 	p{CourseId}(Marks) cj p{StudentId, GroupId}(Students)
-- 	diff
-- 	p{CourseId, StudentId}(Marks) nj p{StudentId, GroupId}(Students)
-- )

select CourseId, GroupId
from Marks
         cross join Students
except
select CourseId, GroupId
from (select CourseId, Students.StudentId, GroupId
      from Marks
               cross join Students
      except
      select CourseId, StudentId, GroupId
      from MArks
               natural join Students) as CISIGICISIGI;


-- comment 07.2. Названия
--               (GroupName, CourseName)
--
-- p{GroupName, CourseName}(
-- 	p{StudentId, CourseId}(Marks) gdiv p{StudentId, GroupId}(Students) nj Groups nj Courses
-- )

select GroupName, CourseName
from (select CourseId, GroupId
      from Marks
               cross join Students
      except
      select CourseId, GroupId
      from (select CourseId, Students.StudentId, GroupId
            from Marks
                     cross join Students
            except
            select CourseId, StudentId, GroupId
            from MArks
                     natural join Students) as CISIGICISIGI) as CIGICIGI
         natural join Courses
         natural join Groups;


-- ###################################################
-- section Составьте SQL-запросы, позволяющие получать
-- ###################################################
--
-- #############################
-- subsection 08. Суммарный балл
--
-- comment 08.1. Одного студента
--               (SumMark по :StudentId)
--
-- set-var :StudentId = 1

select sum(Mark) as SumMark
from Marks
where StudentId = :StudentId;


-- comment 08.2. Каждого студента
--               (StudentName, SumMark)

select StudentName, sum(Mark) as SumMark
from Students s
         left join Marks m on s.StudentId = m.StudentId
group by s.StudentId, StudentName;


-- comment 08.3. Каждой группы
--               (GroupName, SumMark)

select GroupName, sum(Mark) as SumMark
from Groups g
         left join (select GroupId, Mark
                    from Students
                             natural join Marks) as gm on g.GroupId = gm.GroupId
group by g.GroupId, GroupName;


-- ###########################
-- subsection 09. Средний балл
--
-- comment 09.1. Одного студента
--               (AvgMark по :StudentId)

-- set-var :StudentId = 1

select avg(cast(Mark as float)) as AvgMark
from Marks
where StudentId = :StudentId;


-- comment 09.2. Каждого студента
--               (StudentName, AvgMark)

select StudentName, avg(cast(Mark as float)) as AvgMark
from Students s
         left join Marks m on s.StudentId = m.StudentId
group by s.StudentId, StudentName;


-- comment 09.3. Каждой группы
--               (GroupName, AvgMark)

select GroupName, avg(cast(Mark as float)) as AvgMark
from Groups g
         left join (select GroupId, Mark
                    from Students
                             natural join Marks) as gm on g.GroupId = gm.GroupId
group by g.GroupId, GroupName;


-- comment 09.4. Средний балл средних баллов студентов каждой группы
--               (GroupName, AvgAvgMark)

select GroupName, avg(AvgMark) as AvgAvgMark
from Groups g
         left join (select GroupId, avg(cast(Mark as float)) as AvgMark
                    from Students
                             natural join Marks
                    group by StudentId, GroupId) as gm on g.GroupId = gm.GroupId
group by g.GroupId, GroupName;


-- comment 10. Для каждого студента:
--             число дисциплин, которые у него были,
--             число сданных дисциплин и
--             число несданных дисциплин
--             (StudentId, Total, Passed, Failed)

select s.StudentId
     , coalesce(count(distinct p.CourseId), 0)                              as Total
     , coalesce(count(distinct m.CourseId), 0)                              as Passed
     , coalesce(count(distinct p.CourseId) - count(distinct m.CourseId), 0) as Failed
from Students s
         left join Plan p on s.GroupId = p.GroupId
         left join Marks m on s.StudentId = m.StudentId and p.CourseId = m.CourseId
group by s.StudentId;
