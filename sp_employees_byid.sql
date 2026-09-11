DROP PROCEDURE IF EXISTS public.sp_employees_byid(
    integer,
    integer,
    refcursor
);

CREATE OR REPLACE PROCEDURE public.sp_employees_byid(
    IN _employeeid integer,
    IN _isactive integer,
    INOUT _result_cursor refcursor
)
LANGUAGE plpgsql
AS $procedure$
BEGIN

    IF (_isactive = 1) THEN

        OPEN _result_cursor FOR
        SELECT
            e.employeeuid,
            l.organizationid,
            e.firstname,
            e.lastname,
            e.mobile,
            e.email,
            e.leaveplanid,
            e.payrollgroupid,
            e.salarygroupid,
            e.companyid,
            e.noticeperiodid,
            ep.secondarymobile,
            ep.gender,
            ep.fathername,
            ep.dob,
            ep.address,
            ep.ispermanent,
            ep.actualpackage,
            ep.finalpackage,
            ep.takehomebycandidate,
            epro.empprofdetailuid,
            epro.exprienceinyear,
            epro.specification,
            epro.panno,
            epro.aadharno,
            epro.accountnumber,
            epro.bankname,
            epro.branchname,
            epro.domain,
            epro.ifsccode,
            epro.lastcompanyname,
            l.accesslevelid,
            l.usertypeid,
            e.createdon,
            epf.employeepfdetailid,
            epf.pfnumber,
            epf.universalaccountnumber AS uan,
            epf.pfjoindate AS pfaccountcreationdate,
            pfs.pfenable AS ispfenable,
            CAST(epro.professionaldetail_json AS varchar)
                AS professionaldetail_json

        FROM employees e

        INNER JOIN employeelogin l
            ON l.employeeid = e.employeeuid

        LEFT JOIN employeepersonaldetail ep
            ON e.employeeuid = ep.employeeuid

        LEFT JOIN employeeprofessiondetail epro
            ON e.employeeuid = epro.employeeuid

        LEFT JOIN employee_pf_detail epf
            ON e.employeeuid = epf.employeeid

        LEFT JOIN pf_esi_setting pfs
            ON pfs.companyid = e.companyid

        WHERE e.employeeuid = _employeeid;


    ELSIF (_isactive = 0) THEN

        OPEN _result_cursor FOR
        SELECT
            e.employeeuid,
            NULL::integer AS organizationid,
            e.firstname,
            e.lastname,
            e.mobile,
            e.email,
            NULL::integer AS leaveplanid,
            NULL::integer AS payrollgroupid,
            NULL::integer AS salarygroupid,
            NULL::integer AS companyid,
            NULL::integer AS noticeperiodid,
            ep.secondarymobile,
            ep.gender,
            ep.fathername,
            ep.dob,
            ep.address,
            ep.ispermanent,
            ep.actualpackage,
            ep.finalpackage,
            ep.takehomebycandidate,
            NULL::bigint AS empprofdetailuid,
            epro.exprienceinyear,
            epro.specification,
            epro.panno,
            epro.aadharno,
            epro.accountnumber,
            epro.bankname,
            epro.branchname,
            epro.domain,
            epro.ifsccode,
            epro.lastcompanyname,
            l.accesslevelid,
            l.usertypeid,
            e.createdon,
            epf.employeepfdetailid,
            epf.pfnumber,
            epf.universalaccountnumber AS uan,
            epf.pfjoindate AS pfaccountcreationdate,
            pfs.pfenable AS ispfenable,
            CAST(epro.professionaldetail_json AS varchar)
                AS professionaldetail_json

        FROM employee_archive e

        INNER JOIN employeelogin l
            ON l.employeeid = e.employeeuid

        LEFT JOIN employeepersonaldetail_archive ep
            ON e.employeeuid = ep.employeeuid

        LEFT JOIN employeeprofessiondetail_archive epro
            ON e.employeeuid = epro.employeeuid

        LEFT JOIN employee_pf_detail epf
            ON e.employeeuid = epf.employeeid

        LEFT JOIN pf_esi_setting pfs
            ON pfs.companyid = e.companyid

        WHERE e.employeeuid = _employeeid;


    ELSE

        OPEN _result_cursor FOR
        SELECT
            e.employeeuid,
            NULL::integer AS organizationid,
            e.firstname,
            e.lastname,
            e.mobile,
            e.email,
            NULL::integer AS leaveplanid,
            NULL::integer AS payrollgroupid,
            NULL::integer AS salarygroupid,
            NULL::integer AS companyid,
            NULL::integer AS noticeperiodid,
            ep.secondarymobile,
            ep.gender,
            ep.fathername,
            ep.dob,
            ep.address,
            ep.ispermanent,
            ep.actualpackage,
            ep.finalpackage,
            ep.takehomebycandidate,
            NULL::bigint AS empprofdetailuid,
            epro.exprienceinyear,
            epro.specification,
            epro.panno,
            epro.aadharno,
            epro.accountnumber,
            epro.bankname,
            epro.branchname,
            epro.domain,
            epro.ifsccode,
            epro.lastcompanyname,
            l.accesslevelid,
            l.usertypeid,
            e.createdon,
            epf.employeepfdetailid,
            epf.pfnumber,
            epf.universalaccountnumber AS uan,
            epf.pfjoindate AS pfaccountcreationdate,
            pfs.pfenable AS ispfenable,
            CAST(epro.professionaldetail_json AS varchar)
                AS professionaldetail_json

        FROM (
            SELECT *
            FROM employees

            UNION

            SELECT *
            FROM employee_archive
        ) e

        INNER JOIN employeelogin l
            ON l.employeeid = e.employeeuid

        LEFT JOIN employeepersonaldetail_archive ep
            ON e.employeeuid = ep.employeeuid

        LEFT JOIN employeeprofessiondetail_archive epro
            ON e.employeeuid = epro.employeeuid

        LEFT JOIN employee_pf_detail epf
            ON e.employeeuid = epf.employeeid

        LEFT JOIN pf_esi_setting pfs
            ON pfs.companyid = e.companyid

        WHERE e.employeeuid = _employeeid;

    END IF;

END;
$procedure$;
