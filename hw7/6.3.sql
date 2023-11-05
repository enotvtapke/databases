-- comment 6.3.  Создайте триггер PreserveMarks,
--               не позволяющий уменьшить оценку студента по дисциплине.
--               При попытке такого изменения оценка изменяться не должна.
--               (StudentId)
-- postgres:15.2

create function preserve_marks() returns trigger
as
$$
begin
    return null;
end;
$$
    language plpgsql;

create trigger PreserveMarks
    before update
    on marks
    for each row
    when (new.courseid = old.courseid and new.studentid = old.studentid and new.mark < old.mark)
execute function preserve_marks();
