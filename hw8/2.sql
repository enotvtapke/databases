select avg(cast(Mark as float))
from students
         natural join groups
         natural join marks
         natural join courses
where groupname = :GroupName
  and coursename = :CourseName;

-- Индекс поможет быстро найти группу с заданным названием. Так как
-- groupName сильно больше, чем groupId, стоит сделать индекс покрывающим.
-- Так не будет обращения в таблицу groups.
create unique index groups_groupName on groups using btree (groupname, groupid);

-- Индекс поможет быстро найти курс с заданным названием. Так как
-- courseName сильно больше, чем groupId, стоит сделать индекс покрывающим.
create unique index courses_courseName_courseId on courses using btree (coursename, courseid);

-- Индекс поможет сделать join таблиц students и marks по studentId.
-- Использован покрывающий индекс, чтобы не делать лишний запрос к marks.
-- Это спорное решение, которое было сделано из предположения, что mark
-- с большой вероятностью занимает мало места.
create index marks_studentId_mark on marks using btree (studentid, mark);
