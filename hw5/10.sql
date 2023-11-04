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

select CourseId, GroupId
from (select CourseId
      from Marks) MarkCourses
         cross join (select GroupId
                     from Students) StudentsGroups
except
select CourseId, GroupId
from (select CourseId, StudentId, GroupId
      from (select CourseId
            from Marks) MarkCourses
               cross join (select GroupId, StudentId
                           from Students) StudentsInfo
      except
      select CourseId, StudentId, GroupId
      from (
               Marks
                   natural join Students
               ) StudentsMark) DividerStudents;