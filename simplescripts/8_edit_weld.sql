CREATE DEFINER=`admin`@`%` PROCEDURE `8_edit_weld`(
IN key_project_name varchar(255),
IN key_DrawingNo varchar(255),
IN key_WeldNo_Old varchar(255),
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

SET @sql_text = concat('SELECT WeldID FROM projects.',@key_tablename_frb,' WHERE DrawingNo=\"',key_DrawingNo,'\" AND WeldNo=\"',key_WeldNo_Old,'\"  INTO @key_id_frb;');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @sql_text = concat('UPDATE projects.',@key_tablename_frb,' SET WeldNo= \"',key_WeldNo,'\", WeldType= \"',key_WeldType,'\", DiameterMetric= \"',key_DiameterMetric,'\", DiameterImperial = \'',key_DiameterImperial,'\', Calostyki= \"',key_Calostyki,'\", Thickness=\"',key_Thickness,'\", WeldTotalLength=\"',key_WeldTotalLength,'\", ParentMaterial=\"',key_ParentMaterial,'\", ConnectedPart1Position=\"',key_ConnectedPart1Position,'\", ConnectedPart1=\"',key_ConnectedPart1,'\", ConnectedPart2Position=\"',key_ConnectedPart2Position,'\", ConnectedPart2=\"',key_ConnectedPart2,'\" WHERE WeldID = @key_id_frb;');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

COMMIT;

END