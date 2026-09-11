DROP PROCEDURE IF EXISTS public.sp_employeelogin_auth(
    bigint,
    varchar,
    varchar,
    integer,
    integer,
    refcursor,
    refcursor,
    refcursor,
    refcursor,
    refcursor,
    refcursor,
    refcursor,
    refcursor
);

CREATE OR REPLACE PROCEDURE public.sp_employeelogin_auth(
    IN _userid bigint,
    IN _mobileno varchar,
    IN _emailid varchar,
    IN _usertypeid integer,
    IN _pagesize integer,

    INOUT _employee_result refcursor,
    INOUT _menu_result refcursor,
    INOUT _employee_list_result refcursor,
    INOUT _department_result refcursor,
    INOUT _hierarchy_result refcursor,
    INOUT _company_result refcursor,
    INOUT _layout_result refcursor,
    INOUT _logo_result refcursor
)
LANGUAGE plpgsql
AS $procedure$

DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result VARCHAR;

    _accesslevelid bigint;
    _currentfinancialyear bigint;
    _routeprefix TEXT;
    _companyid bigint;
    _employeeid bigint;

BEGIN

    _routeprefix := 'bot/ems';
    _accesslevelid := 0;
    _companyid := 0;
    _employeeid := 0;


    -- ==========================================
    -- GET EMPLOYEE LOGIN DETAILS
    -- ==========================================

    IF (_mobileno IS NOT NULL AND _mobileno != '') THEN

        SELECT
            employeeid,
            accesslevelid,
            companyid
        INTO
            _employeeid,
            _accesslevelid,
            _companyid
        FROM employeelogin
        WHERE email = _emailid
           OR mobile = _mobileno;

    ELSE

        SELECT
            employeeid,
            accesslevelid,
            companyid
        INTO
            _employeeid,
            _accesslevelid,
            _companyid
        FROM employeelogin
        WHERE email = _emailid;

    END IF;


    -- ==========================================
    -- CURRENT FINANCIAL YEAR
    -- ==========================================

    _currentfinancialyear := 0;

    SELECT financialyear
    INTO _currentfinancialyear
    FROM company_setting
    WHERE isprimary = true;


    -- ==========================================
    -- RESULT 1 : EMPLOYEE LOGIN DETAILS
    -- ==========================================

    OPEN _employee_result FOR

    SELECT
        e.employeeuid userid,
        e.firstname,
        e.lastname,
        'NA' address,
        e.email AS emailid,
        e.mobile,
        e.reportingmanagerid,

        (
            SELECT concat(firstname, ' ', lastname)
            FROM employees
            WHERE
                CASE
                    WHEN e.reportingmanagerid != 0
                    THEN employeeuid = e.reportingmanagerid
                    ELSE employeeuid = 1
                END
        ) managername,

        (
            SELECT email
            FROM employees
            WHERE
                CASE
                    WHEN e.reportingmanagerid != 0
                    THEN employeeuid = e.reportingmanagerid
                    ELSE employeeuid = 1
                END
        ) manageremailid,

        e.designationid,
        _accesslevelid roleid,
        _usertypeid usertypeid,
        l.organizationid,
        l.companyid,

        (
            SELECT employeecurrentregime
            FROM employee_declaration
            WHERE employeeid = e.employeeuid
              AND declarationfromyear = _currentfinancialyear
        ) AS employeecurrentregime,

        (
            SELECT dob
            FROM employeepersonaldetail
            WHERE employeeuid = e.employeeuid
        ) AS dob,

        e.updatedon,
        e.createdon,
        e.workshiftid

    FROM employees e

    INNER JOIN employeelogin l
        ON l.employeeid = e.employeeuid

    WHERE
        (e.email = _emailid OR e.mobile = _mobileno)
        AND e.isactive = true;


    -- ==========================================
    -- RESULT 2 : MENU
    -- ==========================================

    IF (_accesslevelid = 1) THEN

        OPEN _menu_result FOR

        SELECT
            rm.catagory,
            rm.childs,
            concat(_routeprefix, '/', rm.link) AS link,
            rm.icon,
            rm.badge,
            rm.badgetype,
            rm.accesscode,
            1 AS permission

        FROM rolesandmenu rm

        WHERE rm.catagory <> 'Home'
           OR rm.childs <> 'Home';

    ELSE

        OPEN _menu_result FOR

        SELECT
            rm.catagory,
            rm.childs,
            concat(_routeprefix, '/', rm.link) AS link,
            rm.icon,
            rm.badge,
            rm.badgetype,
            rm.accesscode,
            r.accessibilityid AS permission

        FROM rolesandmenu rm

        LEFT JOIN role_accessibility_mapping r
            ON r.accesscode = rm.accesscode

        WHERE r.accesslevelid = _accesslevelid
          AND r.accessibilityid > 0;

    END IF;


    -- ==========================================
    -- RESULT 3 : EMPLOYEE LIST
    -- ==========================================

    OPEN _employee_list_result FOR

    SELECT
        employeeuid AS i,
        concat(firstname, ' ', lastname) AS n,
        email AS e,
        designationid AS d

    FROM employees

    WHERE companyid = _companyid
      AND isactive = true

    ORDER BY updatedon DESC, createdon DESC

    LIMIT _pagesize;


    -- ==========================================
    -- RESULT 4 : DEPARTMENTS
    -- ==========================================

    OPEN _department_result FOR

    SELECT
        roleid AS departmentid,
        rolename AS departmentname

    FROM org_hierarchy

    WHERE isdepartment = true;


    -- ==========================================
    -- RESULT 5 : ORGANIZATION HIERARCHY
    -- ==========================================

    OPEN _hierarchy_result FOR

    SELECT *
    FROM org_hierarchy

    WHERE isdepartment = false
      AND isactive = true
      AND companyid = _companyid;


    -- ==========================================
    -- RESULT 6 : COMPANY
    -- ==========================================

    OPEN _company_result FOR

    SELECT
        c.*,
        cs.financialyear,
        cs.employeecodelength,
        cs.employeecodeprefix,
        cs.timezonename

    FROM company c

    INNER JOIN company_setting cs
        ON c.companyid = cs.companyid;


    -- ==========================================
    -- RESULT 7 : USER LAYOUT
    -- ==========================================

    OPEN _layout_result FOR

    SELECT *
    FROM user_layout_configuration

    WHERE employeeid = _employeeid;


    -- ==========================================
    -- RESULT 8 : COMPANY LOGO
    -- ==========================================

    OPEN _logo_result FOR

    SELECT *
    FROM company_files

    WHERE filerole = 'Company Primary Logo';


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
        'sp_employeelogin_auth',
        1,
        0,
        _result
    );

    RAISE EXCEPTION
        'Error in sp_employeelogin_auth: %',
        _message;

END;
$procedure$;
