CREATE DEFINER=`admin`@`%` PROCEDURE `2_get_projects_frb`(
IN key_project_name varchar(255)
)
BEGIN
SELECT ProjectTableName1 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_frb;
SELECT ProjectTableName3 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_ndt;

SET @sql_text = concat('SELECT 
	A.WeldID, 
	A.DrawingNo,
	A.Rev,
	A.WeldNo,
	A.WeldType,
	A.DiameterMetric,
	A.DiameterImperial,
	A.Calostyki,
	A.Thickness,
	A.WeldTotalLength,
	A.Fitter1,
	A.Fitter2,
    A.ReleaseDate,
	A.AssemblyDate,
	A.Welder,
    A.WelderLicence,
	A.WeldingEndedDate,
	A.FillerMaterial,
	A.ParentMaterial,
	A.TraceabilityResult,
	A.TraceabilityNotes,
	A.ConnectedPart1Position,
	A.ConnectedPart1,
	A.ConnectedPart1Heat,
	A.ConnectedPart2Position,
	A.ConnectedPart2,
	A.ConnectedPart2Heat,
	A.WeldingMethod,
	A.WPSNo,
	A.WPSrev,
	A.NDTGroup,
	A.PreWeldingInspectionDate,
	A.PreWeldingInspectionResult,
	A.PreWeldingInspectionNotes,
	A.DimensionsCheckDate,
	A.DimensionsCheckResult,
	A.DimensionsCheckNotes,
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
    A.IsPWHTrequired,
	A.PWHTCheckDate,
	A.PWHTCheckResult,
	A.PWHTCheckNotes,
	A.PaintQCResult,
	A.PaintQCNotes,
	A.FinalResult,
	A.FinalResultDate,
	A.Notes,
	A.STAGE,
	A.requiredNDT,
    A.requiredNDTforPWHT,
    A.WPSFileName
	FROM projects.',@key_tablename_frb,' A LEFT JOIN projects.',@key_tablename_ndt,' B ON A.WeldID=B.WeldID;');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

END