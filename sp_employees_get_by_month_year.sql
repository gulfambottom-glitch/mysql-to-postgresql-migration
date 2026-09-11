DROP PROCEDURE IF EXISTS public.sp_employees_get_by_month_year(integer, integer, refcursor);

CREATE OR REPLACE PROCEDURE public.sp_employees_get_by_month_year(
    IN _year integer,
    IN _month integer,
    INOUT _result_cursor refcursor
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
BEGIN

    OPEN _result_cursor FOR
    SELECT e.*
    FROM employees e
    LEFT JOIN employee_notice_period en
        ON en.employeeid = e.employeeuid
    WHERE (
        e.isactive = true
        OR (
            e.isactive = false
            AND (
                EXTRACT(YEAR FROM en.officiallastworkingday) * 100
                + EXTRACT(MONTH FROM en.officiallastworkingday)
            ) >= (_year * 100 + _month)
        )
    );

EXCEPTION
    WHEN OTHERS THEN

        _sqlstate := SQLSTATE;
        _errortext := SQLERRM;
        _errorno := SQLSTATE;

        _message := concat(
            'ERROR ',
            _errorno,
            ' (',
            _sqlstate,
            '): ',
            _errortext
        );

        CALL sp_logexception(
            _message,
            ''::varchar,
            'sp_employees_get_by_month_year'::varchar,
            1,
            0,
            _result
        );

        RAISE EXCEPTION '%', _errortext;

END;
$procedure$;
