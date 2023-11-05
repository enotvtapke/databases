-- #############################################################
-- subsection 6. Целостность данных.
--               .
--               Обратите внимание, что задания из этого раздела
--               надо посылать в PCMS, но они будут проверяться
--               только вручную после окончания сдачи.
--               То есть в PCMS вы получите + за любое решение.
--               .
--               В комментарии перед запросом укажите версию
--               использованной СУБД.
--
-- comment 6.1.  Добавьте проверку того, что у студентов есть оценки
--               только по дисциплинам из их плана (NoExtraMarks)
--               (StudentId, CourseId)
-- postgres:15.2

CREATE FUNCTION no_extra_marks_on_modify_marks() RETURNS trigger
AS
$$
begin
    if new.courseid not in
       (select courseid from plan where groupid = (select groupid from students where studentid = new.studentid))
    then
        raise 'Cannot modify marks. Student with id `%` has no course with id `%` according to the plan.',
            new.studentid, new.courseid;
    end if;
    return new;
end;
$$
    LANGUAGE plpgsql;

CREATE FUNCTION no_extra_marks_on_delete_from_plan() RETURNS trigger
AS
$$
begin
    if exists
        (select courseid
         from marks
         where courseid = old.courseid
           and studentid in (select studentid from students where groupid = old.groupid))
    then
        raise 'Cannot delete from plan. There are students from group with id `%` who have marks for course with id `%`.',
            old.groupid, old.courseid;
    end if;
    return new;
end;
$$
    LANGUAGE plpgsql;

CREATE FUNCTION no_extra_marks_on_update_plan() RETURNS trigger
AS
$$
begin
    if (new.courseid <> old.courseid or new.groupid <> old.groupid) and exists
        (select courseid
         from marks
         where courseid = old.courseid
           and studentid in (select studentid from students where groupid = old.groupid))
    then
        raise 'Cannot update plan. There are students from group with id `%` who have marks for course with id `%`.',
            old.groupid, old.courseid;
    end if;
    return new;
end;
$$
    LANGUAGE plpgsql;

CREATE FUNCTION no_extra_marks_on_update_students() RETURNS trigger
AS
$$
begin
    if (new.groupid <> old.groupid) and exists
        (select courseid
         from marks
         where studentid = old.studentid
           and courseid in (select courseid from plan where groupid = old.groupid)
           and courseid not in (select courseid from plan where groupid = new.groupid))
    then
        raise 'Cannot update students. Student with id `%` has marks for courses which are not in the plan of the group with id `%`',
            old.studentid, new.groupid;
    end if;
    return new;
end;
$$
    LANGUAGE plpgsql;

create constraint trigger NoExtraMarksOnModifyMarks
    after UPDATE or INSERT
    on marks
    for each row
execute function no_extra_marks_on_modify_marks();

create constraint trigger NoExtraMarksOnDeleteFromPlan
    after DELETE
    on plan
    for each row
execute function no_extra_marks_on_delete_from_plan();

create constraint trigger NoExtraMarksOnUpdatePlan
    after UPDATE
    on plan
    for each row
execute function no_extra_marks_on_update_plan();

create constraint trigger NoExtraMarksOnUpdateStudents
    after UPDATE
    on students
    for each row
execute function no_extra_marks_on_update_students();
