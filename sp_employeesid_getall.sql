DROP PROCEDURE IF EXISTS public.sp_employeesid_getall(
    refcursor
);

CREATE OR REPLACE PROCEDURE public.sp_employeesid_getall(
    INOUT _result refcursor
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _logresult TEXT;
BEGIN

    OPEN _result FOR
        SELECT *
        FROM employees;

EXCEPTION WHEN OTHERS THEN

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
        '',
        'sp_employeesid_getall',
        1,
        0,
        _logresult
    );

    RAISE EXCEPTION
        'Error in sp_employeesid_getall: %',
        _message;

END;
$procedure$;
