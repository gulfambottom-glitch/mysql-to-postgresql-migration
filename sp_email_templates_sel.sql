DROP PROCEDURE IF EXISTS public.sp_email_templates_sel(
    varchar,
    integer,
    integer,
    refcursor
);

CREATE OR REPLACE PROCEDURE public.sp_email_templates_sel(
    IN _templatename varchar,
    IN _pagenumber integer,
    IN _pagesize integer,
    INOUT _result refcursor
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _offset integer;
BEGIN

    -- Calculate the offset for pagination
    _offset := (_pagenumber - 1) * _pagesize;

    OPEN _result FOR
        SELECT
            e.emailtemplateid,
            e.templatename,
            e.sampletemplateurl,
            e.createdon,
            e.createdby
        FROM email_templates e
        WHERE (
            _templatename IS NULL
            OR e.templatename ILIKE CONCAT('%', _templatename, '%')
        )
        ORDER BY e.emailtemplateid DESC
        LIMIT _pagesize
        OFFSET _offset;

END;
$procedure$;
