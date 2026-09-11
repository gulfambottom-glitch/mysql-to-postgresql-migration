DROP PROCEDURE IF EXISTS public.sp_employees_mappedclient_get_by_employee_id(bigint, refcursor);

CREATE OR REPLACE PROCEDURE public.sp_employees_mappedclient_get_by_employee_id(
    IN _employeeid bigint,
    INOUT _result_cursor refcursor
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;
BEGIN

    OPEN _result_cursor FOR
    SELECT m.*
    FROM employeemappedclients m
    WHERE m.isactive = true
      AND m.employeeuid = _employeeid
    ORDER BY m.employeemappedclientsuid;

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
            'sp_employees_mappedclient_get_by_employee_id'::varchar,
            1,
            0,
            _result
        );

        RAISE EXCEPTION '%', _errortext;

END;
$procedure$;
