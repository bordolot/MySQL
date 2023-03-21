CREATE DEFINER=`admin`@`%` PROCEDURE `3_add_folder`(
IN key_project_name varchar(255),
IN key_foldername_name varchar(255),
IN key_position INT
)
BEGIN
SELECT ProjectID FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_id;
SET @empty_array = '{}';
SET @input_1 = CONCAT('$.\"',key_foldername_name,'\"');
UPDATE projects._00_list_of_projects_and_folders SET 
folders = JSON_SET(folders, @input_1,  CAST(@empty_array as JSON)) WHERE ProjectID = @key_id;
COMMIT;
END