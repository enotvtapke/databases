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
