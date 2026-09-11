DROP PROCEDURE IF EXISTS public.sp_employeebilldetail_byid(
    bigint,
    bigint,
    bigint,
    integer,
    timestamp,
    timestamp,
    integer,
    refcursor
);

CREATE OR REPLACE PROCEDURE public.sp_employeebilldetail_byid(
    IN _employeeid bigint,
    IN _clientid bigint,
    IN _fileid bigint,
    IN _foryear integer,
    IN _firstdate timestamp without time zone,
    IN _lastdate timestamp without time zone,
    IN _companyid integer,
    INOUT _result refcursor
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _financialyear bigint;
BEGIN

    OPEN _result FOR
        SELECT b.*
        FROM billdetail b
        WHERE b.employeeuid = _employeeid
          AND b.clientid = _clientid
          AND b.filedetailid = _fileid;

    _financialyear := 0;

    SELECT financialyear
    INTO _financialyear
    FROM company_setting
    WHERE isprimary = true;

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

    RAISE EXCEPTION
        'Error in sp_employeebilldetail_byid: %',
        _message;

END;
$procedure$;
