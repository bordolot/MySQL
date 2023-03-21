CREATE DEFINER=`admin`@`%` PROCEDURE `2_get_projects_ndt`(
IN key_project_name varchar(255)
)
BEGIN
SELECT ProjectTableName3 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_ndt;
SELECT ProjectTableName4 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_ndt_for_pwht;

SET @sql_text = concat('SELECT
	B.WeldID,
	B.VTReportNo,
	B.VTResult,
	B.VTNotes,
	B.PTReportNo,
	B.PTResult,
	B.PTNotes,
    B.MTReportNo,
	B.MTResult,
	B.MTNotes,
	B.UTReportNo,
	B.UTResult,
	B.UTNotes,
	B.RTReportNo,
	B.RTResult,
	B.RTNotes,
	B.FerrytReportNo,
	B.FerrytResult,
	B.FerrytNotes,
    B.PMIReportNo,
	B.PMIResult,
	B.PMINotes,
	B.HardnessReportNo,
	B.HardnessResult,
	B.HardnessNotes,
    
	C.VTReportNo,
	C.VTResult,
	C.VTNotes,
	C.PTReportNo,
	C.PTResult,
	C.PTNotes,
    C.MTReportNo,
	C.MTResult,
	C.MTNotes,
	C.UTReportNo,
	C.UTResult,
	C.UTNotes,
	C.RTReportNo,
	C.RTResult,
	C.RTNotes,
	C.FerrytReportNo,
	C.FerrytResult,
	C.FerrytNotes,
    C.PMIReportNo,
	C.PMIResult,
	C.PMINotes,
	C.HardnessReportNo,
	C.HardnessResult,
	C.HardnessNotes
	FROM projects.',@key_tablename_ndt,' B LEFT JOIN projects.',@key_tablename_ndt_for_pwht,' C ON B.WeldID=C.WeldID;');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

END