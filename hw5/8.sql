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

-- select GroupName, sum(Mark) as SumMark
-- from Groups g
--          left join Students s on g.GroupId = s.GroupId
--          natural join Marks
-- group by g.GroupId, GroupName;