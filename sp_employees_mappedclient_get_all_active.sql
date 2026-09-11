DROP PROCEDURE IF EXISTS public.sp_employees_mappedclient_get_all_active(refcursor);

CREATE OR REPLACE PROCEDURE public.sp_employees_mappedclient_get_all_active(
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
            'sp_employees_mappedclient_get_all_active'::varchar,
            1,
            0,
            _result
        );

        RAISE EXCEPTION '%', _errortext;

END;
$procedure$;
