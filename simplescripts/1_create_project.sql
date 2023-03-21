CREATE DEFINER=`admin`@`%` PROCEDURE `1_create_project`(
IN key_project_name varchar(255),
IN key_date date,
OUT key_result int
)
BEGIN
SELECT EXISTS(SELECT * FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name) INTO @boolvar;
IF @boolvar THEN
	SET key_result:=1000;
ELSE 

	##### creating new table for new project #######
    SET @project_id = (SELECT COUNT(*) FROM projects._00_list_of_projects_and_folders)+1;
    SET @new_table_name = CONCAT('_',@project_id,'_','frb');
    SET @new_table_name_2 = CONCAT('_',@project_id,'_','drawing_data');
    SET @new_table_name_3 = CONCAT('_',@project_id,'_','ndt');
    SET @new_table_name_4 = CONCAT('_',@project_id,'_','ndt_after_pwht');
    SET @sql_text = concat('create table ',@new_table_name,
		'(
        WeldID int NOT NULL PRIMARY KEY auto_increment,
        DrawingNo varchar(255),
        Rev varchar(255),
        WeldNo varchar(255),
        WeldType varchar(255),
        DiameterMetric varchar(255),
        DiameterImperial varchar(255),
        Calostyki varchar(255),
        Thickness varchar(255),
        WeldTotalLength varchar(255),
        Fitter1 varchar(255),
        Fitter1ID int,
        Fitter2 varchar(255),
        Fitter2ID int,
        ReleaseDate varchar(255),
        AssemblyDate varchar(255),
        Welder varchar(255),
        WelderLicence varchar(255),
        WelderID int,
        WeldingEndedDate varchar(255),
        FillerMaterial varchar(255),
        ParentMaterial varchar(255),
        IsReadyToCheckTrace int,
        TraceabilityResult varchar(255),
		TraceabilityNotes varchar(255),
        ConnectedPart1Position varchar(255),
        ConnectedPart1 varchar(255),
        ConnectedPart1Heat varchar(255),
        ConnectedPart2Position varchar(255),
        ConnectedPart2 varchar(255),
        ConnectedPart2Heat varchar(255),
        WeldingMethod varchar(255),
        WPSNo varchar(255),
        WPSrev varchar(255),
        WPSFileName varchar(255),
        NDTGroup varchar(255),
        PreWeldingInspectionDate varchar(255),
        PreWeldingInspectionResult varchar(255),
        PreWeldingInspectionNotes varchar(255),
        DimensionsCheckDate varchar(255),
        DimensionsCheckResult varchar(255),
        DimensionsCheckNotes varchar(255),
        IsPWHTrequired int,
        PWHTCheckDate varchar(255),
        PWHTCheckResult varchar(255),
        PWHTCheckNotes varchar(255),
        PaintQCResult varchar(255),
        PaintQCNotes varchar(255),
        FinalResult varchar(255),
        FinalResultDate varchar(255),
        Notes varchar(255),
        STAGE varchar(255),
        requiredNDT JSON,
        requiredNDTforPWHT JSON
        );');
	PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
	
    SET @sql_text_2 = concat('create table ',@new_table_name_2,'(
		DrawingID int NOT NULL PRIMARY KEY auto_increment,
        DrawingNo varchar(255),
        Folder varchar(255),
        Rev varchar(255),
        nr_of_welds int,
        nr_of_part_welds int,
        nr_of_full_welds int,
        nr_pwht_welds int,
        in_stage_2 int,
        in_stage_3 int,
        in_stage_4 int,
        nr_of_fitted_welds int,
        in_stage_6 int,
        in_stage_7 int,
        nr_of_welds_in_ndt int,
        nr_of_welded_welds int,
        in_stage_10 int,
        in_stage_11 int,
        in_ndt_after_heat_treat int,
        heat_treated_welds int,
        in_stage_14 int,
        in_stage_15 int,
        nr_of_painted_welds int,
        nr_of_finished_welds int
        );');
    PREPARE stmt FROM @sql_text_2;EXECUTE stmt;DEALLOCATE PREPARE stmt;
    
	SET @sql_text_3 = concat('create table ',@new_table_name_3,
		'(
        WeldID int NOT NULL PRIMARY KEY auto_increment, 
        DrawingNo varchar(255),
        WeldNo varchar(255),
        
        IsVTrequired int,
        VTReportNo varchar(255),
        VTResult varchar(255),
        VTNotes varchar(255),
        
        IsPTrequired int,
        PTReportNo varchar(255),
        PTResult varchar(255),
        PTNotes varchar(255),
        
        IsMTrequired int,
        MTReportNo varchar(255),
        MTResult varchar(255),
        MTNotes varchar(255),
        
        IsUTrequired int,
        UTReportNo varchar(255),
        UTResult varchar(255),
        UTNotes varchar(255),
        
        IsRTrequired int,
        RTReportNo varchar(255),
        RTResult varchar(255),
        RTNotes varchar(255),
        
        IsFerrytRequired int,
        FerrytReportNo varchar(255),
        FerrytResult varchar(255),
        FerrytNotes varchar(255),
        
        IsPMIrequired int,
        PMIReportNo varchar(255),
        PMIResult varchar(255),
        PMINotes varchar(255),
        
        IsHardnessRequired int,
        HardnessReportNo varchar(255),
        HardnessResult varchar(255),
        HardnessNotes varchar(255)
        );');
	PREPARE stmt FROM @sql_text_3;EXECUTE stmt;DEALLOCATE PREPARE stmt;
    
	SET @sql_text_4 = concat('create table ',@new_table_name_4,
		'(
        WeldID int NOT NULL PRIMARY KEY auto_increment, 
        DrawingNo varchar(255),
        WeldNo varchar(255),
        
        IsVTrequired int,
        VTReportNo varchar(255),
        VTResult varchar(255),
        VTNotes varchar(255),
        
        IsPTrequired int,
        PTReportNo varchar(255),
        PTResult varchar(255),
        PTNotes varchar(255),
        
        IsMTrequired int,
        MTReportNo varchar(255),
        MTResult varchar(255),
        MTNotes varchar(255),
        
        IsUTrequired int,
        UTReportNo varchar(255),
        UTResult varchar(255),
        UTNotes varchar(255),
        
        IsRTrequired int,
        RTReportNo varchar(255),
        RTResult varchar(255),
        RTNotes varchar(255),
        
        IsFerrytRequired int,
        FerrytReportNo varchar(255),
        FerrytResult varchar(255),
        FerrytNotes varchar(255),
        
        IsPMIrequired int,
        PMIReportNo varchar(255),
        PMIResult varchar(255),
        PMINotes varchar(255),
        
        IsHardnessRequired int,
        HardnessReportNo varchar(255),
        HardnessResult varchar(255),
        HardnessNotes varchar(255)
        );');
	PREPARE stmt FROM @sql_text_4;EXECUTE stmt;DEALLOCATE PREPARE stmt;
    
    
    ##### inserting data into _00_list_of_projects_and_folders #######
    INSERT INTO _00_list_of_projects_and_folders (
		ProjectTableName1,
        ProjectTableName2,
        ProjectTableName3,
        ProjectTableName4,
		ProjectName,
        folders,
        startDate) 
	VALUES (
		@new_table_name,
        @new_table_name_2,
        @new_table_name_3,
        @new_table_name_4,
		key_project_name,
        CAST("{}" AS JSON),
        key_date);
	SET key_result:=33;
    COMMIT;
END IF;
END