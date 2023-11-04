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