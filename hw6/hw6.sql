-- ###########################################################
-- section Составьте запросы в терминах языков Datalog и SQL
--         для базы данных «Университет», позволяющие получать
-- ###########################################################
--
-- ####################################
-- subsection 1. Информацию о студентах
--
-- comment 1.1. С заданным ФИО
--              (StudentId, StudentName, GroupId по :StudentName)
--
-- set-var :StudentName = 'Иванов И.И.'
--
-- print-dl
-- r(StudentId, StudentName, GroupId) :-
--   Students(StudentId, StudentName, GroupId),
--   StudentName = :StudentName.

select StudentId, StudentName, GroupId
from Students
where StudentName = :StudentName;


-- comment 1.2. Учащихся в заданной группе
--              (StudentId, StudentName, GroupId по :GroupName)
--
-- set-var :GroupName = 'M3439'
--
-- print-dl
-- r(StudentId, StudentName, GroupId) :-
--   Students(StudentId, StudentName, GroupId),
--   Groups(GroupId, :GroupName).

select studentid, studentname, groupid
from students
where groupid in (select groupid from groups where groupname = :GroupName);


-- comment 1.3. C заданной оценкой по дисциплине,
--              заданной идентификатором
--              (StudentId, StudentName, GroupId по :Mark, :CourseId)
--
-- set-var :Mark = 5
--
-- set-var :CourseId = 1
--
-- print-dl
-- r(StudentId, StudentName, GroupId) :-
--   Students(StudentId, StudentName, GroupId),
--   Marks(StudentId, :CourseId, :Mark).

select s.studentid, studentname, groupid
from students s
where s.studentid in (select studentid from marks where mark = :Mark and courseid = :CourseId);


-- comment 1.4. C заданной оценкой по дисциплине,
--              заданной названием
--              (StudentId, StudentName, GroupId по :Mark, :CourseName)
--
-- set-var :Mark = 5
--
-- set-var :CourseName = 'Базы данных'

-- print-dl
-- r(StudentId, StudentName, GroupId) :-
--   Students(StudentId, StudentName, GroupId),
--   Marks(StudentId, CourseId, :Mark),
--   Courses(CourseId, :CourseName).

select studentid, studentname, groupid
from students
where studentid in (select studentid
                    from marks
                    where mark = :Mark
                      and courseid in (select courseid from courses where coursename = :CourseName));

-- ###########################################
-- subsection 2. Полную информацию о студентах

-- comment 2.1. Для всех студентов
--              (StudentId, StudentName, GroupName)
--
-- print-dl
-- r(StudentId, StudentName, GroupName) :-
--   Students(StudentId, StudentName, GroupId),
--   Groups(GroupId, GroupName).

select studentid, studentname, groupname
from students s,
     groups g
where s.groupid = g.groupid;


-- comment 2.2. Студентов, не имеющих оценки по дисциплине, заданной идентификатором
--              (StudentId, StudentName, GroupName по :CourseId)
--
-- set-var :CourseId = 1
--
-- print-dl
-- g(StudentId) :-
--   Marks(StudentId, :CourseId, _).
-- r(StudentId, StudentName, GroupName) :-
--   Students(StudentId, StudentName, GroupId),
--   Groups(GroupId, GroupName),
--   not g(StudentId).

select s.studentid, studentname, groupname
from students s,
     groups g
where s.groupid = g.groupid
  and s.studentid not in (select studentid from marks where courseid = :CourseId);


-- comment 2.3. Студентов, не имеющих оценки по дисциплине, заданной названием
--              (StudentId, StudentName, GroupName по :CourseName)
--
-- set-var :CourseName = 'Базы данных'
--
-- print-dl
-- g(StudentId) :-
--   Marks(StudentId, CourseId, _),
--   Courses(CourseId, :CourseName).
-- r(StudentId, StudentName, GroupName) :-
--   Students(StudentId, StudentName, GroupId),
--   Groups(GroupId, GroupName),
--   not g(StudentId).

select s.studentid, studentname, groupname
from students s,
     groups g
where s.groupid = g.groupid
  and s.studentid not in (select studentid
                          from marks m
                          where m.courseid in (select courseid from courses where coursename = :CourseName));


-- comment 2.4. Студентов, не имеющих оценки по дисциплине,
--              у которых есть эта дисциплина
--              (StudentId, StudentName, GroupName по :CourseId)
--
-- set-var :CourseId = 1
--
-- print-dl
-- g(StudentId, CourseId) :-
--   Marks(StudentId, CourseId, _).
-- r(StudentId, StudentName, GroupName) :-
--   Students(StudentId, StudentName, GroupId),
--   Groups(GroupId, GroupName),
--   Plan(GroupId, CourseId, _),
--   not g(StudentId, CourseId),
--   CourseId = :CourseId.

select distinct s.studentid, s.studentname, g.groupname
from students s,
     groups g,
     plan p
where s.groupid = g.groupid
  and g.groupid = p.groupid
  and p.courseid = :CourseId
  and s.studentid not in (select studentid
                          from marks m
                          where m.courseid = :CourseId);


-- comment 2.5. Студентов, не имеющих оценки по дисциплине,
--              у которых есть эта дисциплина
--              (StudentId, StudentName, GroupName по :CourseName)
--
-- set-var :CourseName = 'Базы данных'
--
-- g(StudentId, CourseName) :-
--   Marks(StudentId, CourseId, _),
--   Courses(CourseId, CourseName).
-- r(StudentId, StudentName, GroupName) :-
--   Students(StudentId, StudentName, GroupId),
--   Groups(GroupId, GroupName),
--   Plan(GroupId, CourseId, _),
--   Courses(CourseId, CourseName),
--   not g(StudentId, CourseName),
--   CourseName = :CourseName.

select distinct s.studentid, s.studentname, g.groupname
from students s,
     groups g,
     plan p
where s.groupid = g.groupid
  and g.groupid = p.groupid
  and courseid in (select courseid from courses where coursename = :CourseName)
  and studentid not in (select studentid
                        from marks m,
                             courses c
                        where m.courseid = c.courseid
                          and c.coursename = :CourseName);


-- #########################################################################
-- subsection 3. Студенты и дисциплины, такие что у студента была дисциплина
--               (по плану или есть оценка)
--
-- comment 3.1. Идентификаторы
--              (StudentId, CourseId)
--
-- print-dl
-- r(StudentId, CourseId) :-
--   Marks(StudentId, CourseId, _).
-- r(StudentId, CourseId) :-
--   Students(StudentId, _, GroupId),
--   Plan(GroupId, CourseId, _).

select studentid, courseid
from marks
union
select studentid, courseid
from students s,
     plan p
where s.groupid = p.groupid;


-- comment 3.2. Имя и название
--              (StudentName, CourseName)
--
-- print-dl
-- r(StudentName, CourseName) :-
--   Marks(StudentId, CourseId, _),
--   Students(StudentId, StudentName, _),
--   Courses(CourseId, CourseName).
-- r(StudentName, CourseName) :-
--   Students(StudentId, StudentName, GroupId),
--   Plan(GroupId, CourseId, _),
--   Courses(CourseId, CourseName).

select studentname, coursename
from Students s,
     Courses c,
     (select studentid, courseid
      from marks
      union
      select studentid, courseid
      from students s,
           plan p
      where s.groupid = p.groupid) as q
where c.courseid = q.courseid
  and s.studentid = q.studentid;


-- ##################################################
-- subsection 4. Студенты и дисциплины, такие что
--               дисциплина есть в его плане,
--               и у студента долг по этой дисциплине
--
-- comment 4.1. Долгом считается отсутствие оценки
--              (StudentName, CourseName)
--
-- print-dl
-- g(StudentId, CourseId) :-
--   Marks(StudentId, CourseId, _).
-- r(StudentName, CourseName) :-
--   Students(StudentId, StudentName, GroupId),
--   Courses(CourseId, CourseName),
--   Plan(GroupId, CourseId, _),
--   not g(StudentId, CourseId).

select StudentName, CourseName
from students s,
     courses c,
     (select distinct s.studentid, c.courseid
      from students s,
           courses c,
           plan p
      where s.groupid = p.groupid
        and c.courseid = p.courseid
        and not exists
          (select studentid, courseid from marks where studentid = s.studentid and courseid = c.courseid)) q
where q.studentid = s.studentid
  and q.courseid = c.courseid;


-- comment 4.2. Долгом считается оценка не выше 2
--              (StudentName, CourseName)
--
-- print-dl
-- g(StudentId, CourseId) :-
--   Marks(StudentId, CourseId, _).
-- r(StudentName, CourseName) :-
--   Students(StudentId, StudentName, GroupId),
--   Courses(CourseId, CourseName),
--   Plan(GroupId, CourseId, _),
--   Marks(StudentId, CourseId, Mark),
--   Mark <= 2.

select StudentName, CourseName
from students s,
     courses c,
     (select distinct s.studentid, c.courseid
      from students s,
           courses c,
           plan p,
           marks m
      where s.groupid = p.groupid
        and c.courseid = p.courseid
        and m.studentid = s.studentid
        and m.courseid = p.courseid
        and m.mark <= 2) q
where q.studentid = s.studentid
  and q.courseid = c.courseid;


-- comment 4.3. Долгом считается отсутствие оценки или оценка не выше 2
--              (StudentName, CourseName)
--
-- print-dl
-- g(StudentId, CourseId) :-
--   Marks(StudentId, CourseId, Mark),
--   Mark > 2.
-- r(StudentName, CourseName) :-
--   Students(StudentId, StudentName, GroupId),
--   Courses(CourseId, CourseName),
--   Plan(GroupId, CourseId, _),
--   not g(StudentId, CourseId).

select StudentName, CourseName
from students s,
     courses c,
     (select distinct s.studentid, c.courseid
      from students s,
           courses c,
           plan p
      where s.groupid = p.groupid
        and c.courseid = p.courseid
        and not exists
          (select studentid, courseid
           from marks
           where studentid = s.studentid
             and courseid = c.courseid
             and mark > 2)) q
where q.studentid = s.studentid
  and q.courseid = c.courseid;


-- #######################################################
-- subsection 5. Идентификаторы студентов по преподавателю
--
-- comment 5.1. Имеющих хотя бы одну оценку у преподавателя
--              (StudentId по :LecturerName)
--
-- set-var :LecturerName = 'Корнеев Г.А.'

-- print-dl
-- r(StudentId) :-
--   Students(StudentId, _, GroupId),
--   Plan(GroupId, CourseId, LecturerId),
--   Marks(StudentId, CourseId, _),
--   Lecturers(LecturerId, :LecturerName).

select distinct s.studentid
from students s,
     plan p,
     marks m
where s.groupid = p.groupid
  and p.courseid = m.courseid
  and m.studentid = s.studentid
  and p.lecturerid in (select lecturerid from lecturers where lecturername = :LecturerName);


-- comment 5.2. Не имеющих ни одной оценки у преподавателя
--              (StudentId по :LecturerName)
--
-- set-var :LecturerName = 'Корнеев Г.А.'

-- print-dl
-- g(StudentId, GroupId) :-
--   Plan(GroupId, CourseId, LecturerId),
--   Marks(StudentId, CourseId, _),
--   Lecturers(LecturerId, :LecturerName).
-- r(StudentId) :-
--   Students(StudentId, _, GroupId),
--   not g(StudentId, GroupId).

select s.studentid
from students s
where not exists(select studentid, groupid
                 from plan p,
                      marks m
                 where p.courseid = m.courseid
                   and p.groupid = s.groupid
                   and m.studentid = s.studentid
                   and p.lecturerid in (select lecturerid from lecturers where lecturername = :LecturerName));


-- comment 5.3. Имеющих оценки по всем дисциплинам преподавателя
--              (StudentId по :LecturerName)
--
-- set-var :LecturerName = 'Корнеев Г.А.'
--
-- print-dl
-- hasMark(StudentId, CourseId) :-
--   Marks(StudentId, CourseId, _).
-- NotEveryMark(StudentId) :-
--   Students(StudentId, _, _),
--   Plan(_, CourseId, LecturerId),
--   not hasMark(StudentId, CourseId),
--   Lecturers(LecturerId, :LecturerName).
-- r(StudentId) :-
--   Students(StudentId, _, _),
--   not NotEveryMark(StudentId).

select StudentId
from students s
where not exists(select studentid
                 from plan p
                 where p.lecturerid in (select lecturerid from lecturers where lecturername = :LecturerName)
                   and not exists(select studentid, courseid
                                  from marks m
                                  where m.courseid = p.courseid
                                    and s.studentid = m.studentid));


-- comment 5.4. Имеющих оценки по всем дисциплинам преподавателя,
--              которые он вёл у этого студента
--              (StudentId по :LecturerName)
--
-- set-var :LecturerName = 'Корнеев Г.А.'
--
-- print-dl
-- hasMark(StudentId, CourseId) :-
--   Marks(StudentId, CourseId, _).
-- NotEveryMark(StudentId, GroupId) :-
--   Students(StudentId, _, GroupId),
--   Plan(GroupId, CourseId, LecturerId),
--   not hasMark(StudentId, CourseId),
--   Lecturers(LecturerId, :LecturerName).
-- r(StudentId) :-
--   Students(StudentId, _, GroupId),
--   not NotEveryMark(StudentId, GroupId).

select StudentId
from students s
where not exists(select studentid
                 from plan p
                 where p.lecturerid in (select lecturerid from lecturers where lecturername = :LecturerName)
                   and not exists(select studentid, courseid
                                  from marks m
                                  where m.courseid = p.courseid
                                    and s.studentid = m.studentid)
                   and s.groupid = p.groupid);


-- ##########################################################
-- subsection 6. Группы и дисциплины, такие что
--               все студенты группы имеют оценку по предмету
--
-- comment 6.1. Идентификаторы
--              (GroupId, CourseId)
--
-- print-dl
-- hasMark(StudentId, CourseId) :-
--   Marks(StudentId, CourseId, _).
-- notEveryHasMark(GroupId, CourseId) :-
--   Students(StudentId, _, GroupId),
--   Courses(CourseId, _),
--   not hasMark(StudentId, CourseId).
-- r(GroupId, CourseId) :-
--   Groups(GroupId, _),
--   Courses(CourseId, _),
--   not notEveryHasMark(GroupId, CourseId).

select groupid, courseid
from groups g,
     courses c
where not exists(select groupid, courseid
                 from students s
                 where not exists(select studentid, courseid
                                  from marks m
                                  where m.studentid = s.studentid
                                    and m.courseid = c.courseid)
                   and s.groupid = g.groupid);


-- comment 6.2. Названия
--              (GroupName, CourseName)
--
-- print-dl
-- hasMark(StudentId, CourseId) :-
--   Marks(StudentId, CourseId, _).
-- notEveryHasMark(GroupId, CourseId) :-
--   Students(StudentId, _, GroupId),
--   Courses(CourseId, _),
--   not hasMark(StudentId, CourseId).
-- r(GroupName, CourseName) :-
--   Groups(GroupId, GroupName),
--   Courses(CourseId, CourseName),
--   not notEveryHasMark(GroupId, CourseId).

select groupname, coursename
from groups g,
     courses c
where not exists(select groupid, courseid
                 from students s
                 where not exists(select studentid, courseid
                                  from marks m
                                  where m.studentid = s.studentid
                                    and m.courseid = c.courseid)
                   and s.groupid = g.groupid);
