DROP PROCEDURE IF EXISTS public.sp_email_templates_insupd(
    integer,
    varchar,
    varchar,
    bigint,
    INOUT varchar
);

CREATE OR REPLACE PROCEDURE public.sp_email_templates_insupd(
    IN _emailtemplateid integer,
    IN _templatename varchar,
    IN _sampletemplateurl varchar,
    IN _createdby bigint,
    INOUT _processingresult varchar
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

    _processingresult := '';

    IF NOT EXISTS (
        SELECT 1
        FROM email_templates
        WHERE emailtemplateid = _emailtemplateid
    ) THEN

        INSERT INTO email_templates (
            templatename,
            sampletemplateurl,
            createdon,
            createdby
        )
        VALUES (
            _templatename,
            _sampletemplateurl,
            timezone('utc', now()),
            _createdby
        );

        _processingresult := 'inserted';

    ELSE

        UPDATE email_templates
        SET
            templatename = _templatename,
            sampletemplateurl = _sampletemplateurl
        WHERE emailtemplateid = _emailtemplateid;

        _processingresult := 'updated';

    END IF;

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
        'sp_email_templates_insupd',
        1,
        0,
        _result
    );

    _processingresult := 'error';

END;
$procedure$;
