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