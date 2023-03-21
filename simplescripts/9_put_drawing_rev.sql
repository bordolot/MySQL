CREATE DEFINER=`admin`@`%` PROCEDURE `9_put_drawing_rev`(
IN key_project_name varchar(255),
IN key_folder_name varchar(255),
IN key_drawing_name varchar(255),
IN key_drawing_no varchar(255),
IN key_rev_name varchar(255)
)
BEGIN
SELECT ProjectTableName1 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_frb;
SELECT ProjectTableName2 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_drawing_data;
SELECT ProjectID FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_ProjectID;


SET @sql_text = concat('SELECT DrawingID FROM projects.',@key_tablename_drawing_data,' WHERE (DrawingNo=\"',key_drawing_name,'\") INTO @key_DrawingID;');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
SET @sql_text = concat('SELECT JSON_ARRAYAGG(WeldID) FROM projects.',@key_tablename_frb,' WHERE (DrawingNo=\"',key_drawing_no,'\") INTO @key_WeldID_set;');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @sql_text = concat('UPDATE projects.',@key_tablename_drawing_data,' SET Rev=\"',key_rev_name,'\" WHERE DrawingID=',@key_DrawingID,';');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @i_val = 0;
SET @weld_id_val = "";
WHILE @i_val < JSON_LENGTH(@key_WeldID_set) DO
	SET  @weld_id_val = ( SELECT JSON_EXTRACT(@key_WeldID_set,CONCAT('$[',@i_val,']')) );
    SET @sql_text = concat('UPDATE projects.',@key_tablename_frb,' SET Rev=\"',key_rev_name,'\" WHERE (WeldID=',@weld_id_val,');');
	PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
	SELECT @i_val + 1 INTO @i_val;
END WHILE;

UPDATE projects._00_list_of_projects_and_folders SET folders = JSON_REPLACE(folders,CONCAT('$.\"',key_folder_name,'\".\"',key_drawing_name,'\"'), key_rev_name ) WHERE ProjectID = @key_ProjectID;

COMMIT;
END