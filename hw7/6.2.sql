-- comment 6.2.  Добавьте проверку того, что все студенты каждой группы
--               имею оценку по одному и тому же набору дисциплин (SameMarks).
--               (StudentId)
-- postgres:15.2

create function same_marks_modify_marks() returns trigger
as
$same_marks_modify_marks$
declare
    courses_ids_prev integer[];
    courses_ids      integer[];
    group_id         students.groupid%TYPE;
    student_id       students.studentid%TYPE;
begin
    for group_id in select groupid from students
        loop
            courses_ids_prev := null;
            for student_id in select studentid from students where groupid = group_id
                loop
                    select array_agg(courseid) into courses_ids from marks where studentid = student_id;
                    if courses_ids_prev is not null and
                       not (courses_ids <@ courses_ids_prev and courses_ids_prev <@ courses_ids) then
                        raise $$Sets of courses for which students from group with id `%` have marks are different:
                            %
                            and
                            %$$, group_id, courses_ids_prev, courses_ids;
                    end if;
                    courses_ids_prev := courses_ids;
                end loop;
        end loop;
    return null;
end ;
$same_marks_modify_marks$
    language plpgsql;

create constraint trigger SameMarks
    after update or insert or delete
    on marks
    for each row
execute function same_marks_modify_marks();
