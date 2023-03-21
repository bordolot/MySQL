CREATE DEFINER=`admin`@`%` PROCEDURE `6_put_new_weld`(
IN key_project_name varchar(255),
IN key_folder_name varchar(255),
IN key_drawing_name varchar(255),
IN key_DrawingNo varchar(255),
IN key_Rev varchar(255),
IN key_WeldNo varchar(255),
IN key_WeldType varchar(255),
IN key_DiameterMetric varchar(255),
IN key_DiameterImperial varchar(255),
IN key_Calostyki varchar(255),
IN key_Thickness varchar(255),
IN key_WeldTotalLength varchar(255),
IN key_ParentMaterial varchar(255),
IN key_ConnectedPart1Position varchar(255),
IN key_ConnectedPart1 varchar(255),
IN key_ConnectedPart2Position varchar(255),
IN key_ConnectedPart2 varchar(255)

)
BEGIN
SELECT ProjectTableName1 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_frb;
SELECT ProjectTableName2 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_drawing_data;
SELECT ProjectTableName3 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_ndt;
SELECT ProjectTableName4 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_ndt_for_pwht;

SET @sql_text = concat('
INSERT INTO projects.',@key_tablename_frb,' (
		DrawingNo,
        Rev,
		WeldNo,
        WeldType,
        DiameterMetric,
        DiameterImperial,
        Calostyki,
        Thickness,
        WeldTotalLength,
        ParentMaterial,
        ConnectedPart1Position,
        ConnectedPart1,
        ConnectedPart2Position,
        ConnectedPart2,
        STAGE,
        requiredNDT,
        requiredNDTforPWHT
        ) 
	VALUES (
		\"',key_DrawingNo,'\",
        \"',key_Rev,'\",
        \"',key_WeldNo,'\",
        \"',key_WeldType,'\",
        \"',key_DiameterMetric,'\",
        \'',key_DiameterImperial,'\',
        \"',key_Calostyki,'\",
        \"',key_Thickness,'\",
        \"',key_WeldTotalLength,'\",
        \"',key_ParentMaterial,'\",
        \"',key_ConnectedPart1Position,'\",
        \"',key_ConnectedPart1,'\",
        \"',key_ConnectedPart2Position,'\",
        \"',key_ConnectedPart2,'\",
        1,
        CAST(\"[]\" as JSON),
        CAST(\"[]\" as JSON)
        );
');

PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @sql_text_2 = concat('INSERT INTO projects.',@key_tablename_ndt,' (
	DrawingNo,
    WeldNo
    ) VALUES (\"',key_drawing_name,'\",\"',key_WeldNo,'\");');
PREPARE stmt FROM @sql_text_2;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @sql_text_3 = concat('INSERT INTO projects.',@key_tablename_ndt_for_pwht,' (
	DrawingNo,
    WeldNo
    ) VALUES (\"',key_drawing_name,'\",\"',key_WeldNo,'\");');
PREPARE stmt FROM @sql_text_3;EXECUTE stmt;DEALLOCATE PREPARE stmt;

################
# updating _nr_drawing_data
# DrawingWeldsData
SET @sql_text = concat('
SELECT DrawingID FROM projects.',@key_tablename_drawing_data,' WHERE DrawingNo=\"',key_drawing_name,'\" AND Folder=\"',key_folder_name,'\"  INTO @key_id_drawing_data;
');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
SET @sql_text = concat('
SET @old_value = (SELECT nr_of_part_welds FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,');
');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
SET @new_value = cast((@old_value + 1) AS unsigned);
SET @sql_text = concat('
UPDATE projects.',@key_tablename_drawing_data,' SET nr_of_part_welds =',@new_value,' WHERE DrawingID =',@key_id_drawing_data,';
');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

COMMIT;
END