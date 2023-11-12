-- comment 6.2.  Добавьте проверку того, что все студенты каждой группы
--               имею оценку по одному и тому же набору дисциплин (SameMarks).
--               (StudentId)
-- postgres:15.2

create function same_marks() returns trigger
as
$same_marks$
begin
    if exists(select s1.studentid
              from students s1
              where exists(select studentid
                           from students s2
                           where s1.groupid = s2.groupid
                             and exists(select courseid
                                        from marks m1
                                        where studentid = s1.studentid
                                          and courseid not in (select courseid
                                                               from marks m2
                                                               where studentid = s2.studentid))))
    then
        raise 'Students in the same group have different sets of courses for which they have marks';
    end if;
    return null;
end ;
$same_marks$
    language plpgsql;

create trigger SameMarksOnModifyMarks
    after update or insert or delete
    on marks
    for each statement
execute function same_marks();

create trigger SameMarksOnModifyStudents
    after update or insert
    on students
    for each statement
execute function same_marks();
