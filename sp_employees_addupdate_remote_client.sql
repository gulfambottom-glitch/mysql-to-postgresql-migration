DROP PROCEDURE IF EXISTS public.sp_employees_addupdate_remote_client(
    bigint,
    bigint,
    bigint,
    numeric,
    numeric,
    numeric,
    bit,
    integer,
    integer,
    timestamp,
    timestamp,
    refcursor
);

CREATE OR REPLACE PROCEDURE public.sp_employees_addupdate_remote_client(
    IN _employeemappedclientsuid bigint,
    IN _employeeuid bigint,
    IN _clientuid bigint,
    IN _finalpackage numeric,
    IN _actualpackage numeric,
    IN _takehome numeric,
    IN _ispermanent bit,
    IN _billinghours integer,
    IN _daysperweek integer,
    IN _dateofleaving timestamp without time zone,
    IN _assignedate timestamp without time zone,
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

    _clientname TEXT;
    _empmappedid bigint;

BEGIN

    _clientname := '';

    -- Get client name
    SELECT clientname
    INTO _clientname
    FROM clients
    WHERE clientid = _clientuid;


    -- ==========================================
    -- UPDATE EXISTING RECORD
    -- ==========================================

    IF EXISTS (
        SELECT 1
        FROM employeemappedclients
        WHERE employeemappedclientsuid = _employeemappedclientsuid
    ) THEN

        IF (_dateofleaving IS NULL) THEN

            UPDATE employeemappedclients
            SET
                clientuid = _clientuid,
                clientname = _clientname,
                finalpackage = _finalpackage,
                actualpackage = _actualpackage,
                takehomebycandidate = _takehome,
                ispermanent = _ispermanent,
                billinghours = _billinghours,
                daysperweek = _daysperweek,
                assignedate = _assignedate
            WHERE employeemappedclientsuid = _employeemappedclientsuid;

        ELSE

            UPDATE employeemappedclients
            SET
                clientuid = _clientuid,
                clientname = _clientname,
                finalpackage = _finalpackage,
                actualpackage = _actualpackage,
                takehomebycandidate = _takehome,
                ispermanent = _ispermanent,
                billinghours = _billinghours,
                daysperweek = _daysperweek,
                dateofleaving = _dateofleaving,
                assignedate = _assignedate
            WHERE employeemappedclientsuid = _employeemappedclientsuid;

        END IF;


    -- ==========================================
    -- INSERT NEW RECORD
    -- ==========================================

    ELSE

        SELECT COALESCE(
            MAX(employeemappedclientsuid),
            0
        )
        INTO _empmappedid
        FROM employeemappedclients;

        _empmappedid := _empmappedid + 1;


        INSERT INTO employeemappedclients
        VALUES (
            _empmappedid,
            _employeeuid,
            _clientuid,
            _clientname,
            _finalpackage,
            _actualpackage,
            _takehome,
            _ispermanent,
            1,
            _billinghours,
            _daysperweek,
            timezone('utc', now()),
            NULL,
            _assignedate
        );

    END IF;


    -- ==========================================
    -- RETURN ACTIVE EMPLOYEE CLIENTS
    -- ==========================================

    OPEN _result_cursor FOR

        SELECT *
        FROM employeemappedclients
        WHERE employeeuid = _employeeuid
          AND isactive = 1;


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
        ''::varchar,
        'sp_employees_addupdate_remote_client'::varchar,
        1,
        0,
        _result
    );

    RAISE EXCEPTION
        'Error in sp_employees_addupdate_remote_client: %',
        _message;

END;
$procedure$;
