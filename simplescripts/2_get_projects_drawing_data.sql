CREATE DEFINER=`admin`@`%` PROCEDURE `2_get_projects_drawing_data`(
IN key_project_name varchar(255)
)
BEGIN
SELECT ProjectTableName2 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_drawing_data;

SET @sql_text = concat('SELECT * FROM projects.',@key_tablename_drawing_data,';');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

END