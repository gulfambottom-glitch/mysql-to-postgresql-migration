DROP PROCEDURE IF EXISTS public.sp_employees_active_all(
    integer,
    integer,
    refcursor
);

CREATE OR REPLACE PROCEDURE public.sp_employees_active_all(
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
    _logresult VARCHAR;

    _date DATE;
    _financialyear bigint;
BEGIN

    _financialyear := 0;

    -- Convert year/month into date
    _date := to_date(
        concat(_year, '-', _month, '-01'),
        'YYYY-MM-DD'
    );

    -- Calculate financial year
    SELECT
        CASE
            WHEN _date >= to_date(
                    concat(
                        financialyear,
                        '-',
                        declarationstartmonth,
                        '-01'
                    ),
                    'YYYY-MM-DD'
                 )
             AND _date <= to_date(
                    concat(
                        financialyear + 1,
                        '-',
                        declarationendmonth,
                        '-01'
                    ),
                    'YYYY-MM-DD'
                 )
            THEN financialyear
            ELSE financialyear - 1
        END
    INTO _financialyear
    FROM company_setting
    WHERE isprimary = true;


    -- Open cursor with employee data
    OPEN _result_cursor FOR

        SELECT
            e.*,
            es.ctc,
            ed.employeecurrentregime,
            es.financialstartyear

        FROM employees e

        LEFT JOIN employee_salary_detail es
            ON es.employeeid = e.employeeuid

        LEFT JOIN employee_declaration ed
            ON ed.employeeid = e.employeeuid

        WHERE e.isactive = true
          AND es.financialstartyear = _financialyear
          AND ed.declarationfromyear = _financialyear
          AND es.ctc > 0;


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
        'sp_employees_active_all'::varchar,
        1,
        0,
        _logresult
    );

    RAISE EXCEPTION
        'Error in sp_employees_active_all: %',
        _message;

END;
$procedure$;
