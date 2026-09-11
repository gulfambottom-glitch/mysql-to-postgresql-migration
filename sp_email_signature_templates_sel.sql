DROP PROCEDURE IF EXISTS public.sp_email_signature_templates_sel(
    varchar,
    integer,
    integer,
    refcursor
);

CREATE OR REPLACE PROCEDURE public.sp_email_signature_templates_sel(
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

    _offset := (_pagenumber - 1) * _pagesize;

    OPEN _result FOR
        SELECT
            emailsignaturetemplateid,
            templatename,
            signaturetemplateurl,
            createdon,
            createdby
        FROM email_signature_templates
        WHERE
            (
                _templatename IS NULL
                OR templatename LIKE CONCAT('%', _templatename, '%')
            )
        ORDER BY emailsignaturetemplateid DESC
        LIMIT _pagesize
        OFFSET _offset;

END;
$procedure$;
