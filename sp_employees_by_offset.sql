CREATE OR REPLACE PROCEDURE public.sp_employees_by_offset(
    IN _pagesize integer,
    IN _offsetsize integer,
    INOUT _result_cursor refcursor
)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Convert page/offset value
    _offsetsize := _offsetsize - 1;

    OPEN _result_cursor FOR
    SELECT *
    FROM employees e
    WHERE e.isactive = true
    ORDER BY e.employeeuid
    LIMIT _pagesize
    OFFSET _offsetsize;

EXCEPTION
    WHEN OTHERS THEN
        CALL sp_logexception(
            SQLERRM,
            'sp_employees_by_offset'
        );

        RAISE EXCEPTION '%', SQLERRM;
END;
$procedure$;
