-- p{StudentId}(
-- 	(p{StudentId}(Marks) cj
-- 	p{GroupId}(s{LecturerName = :LecturerName}(Plan nj Lecturers)) diff
-- 	p{StudentId, GroupId}(
-- 		p{StudentId}(Marks) cj
-- 		p{GroupId, CourseId}(s{LecturerName = :LecturerName}(Plan nj Lecturers)) diff
-- 		p{StudentId, CourseId}(Marks) nj
-- 		p{GroupId, CourseId}(s{LecturerName = :LecturerName}(Plan nj Lecturers))
-- 	)) nj Students
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

select StudentId, StudentName, GroupId
from Students
         natural join Marks
         natural join (select CourseId
                       from Plan
                                natural join Lecturers
                       where LecturerName = :LecturerName) Q
where Mark = :Mark