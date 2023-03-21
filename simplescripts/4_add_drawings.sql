CREATE DEFINER=`admin`@`%` PROCEDURE `4_add_drawings`(
IN key_project_name varchar(255),
IN key_foldername_name varchar(255),
IN key_drawing_name varchar(255)
)
BEGIN
SELECT ProjectID FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_id;
#SET @input_position = JSON_LENGTH((SELECT JSON_EXTRACT(folders, CONCAT('$.\"',key_foldername_name,'\"')) FROM projects._00_list_of_projects_and_folders WHERE ProjectID = @key_id));
SET @input_1 = CONCAT('$.\"',key_foldername_name,'\".\"',key_drawing_name,'\"');
UPDATE projects._00_list_of_projects_and_folders SET folders = JSON_INSERT(folders, @input_1, 0) WHERE ProjectID = @key_id;

#SET @drawing_no = SUBSTRING(key_drawing_name, 1, LENGTH(key_drawing_name)-4);
SELECT ProjectTableName2 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_table_name;
SET @sql_text = concat('INSERT INTO projects.',@key_table_name,' (
	DrawingNo,
    Folder,
    Rev,
    nr_of_welds,
    nr_of_part_welds,
    nr_of_full_welds,
    nr_pwht_welds,
    in_stage_2,
    in_stage_3,
    in_stage_4,
    nr_of_fitted_welds,
    in_stage_6,
    in_stage_7,
    nr_of_welds_in_ndt,
    nr_of_welded_welds,
    in_stage_10,
    in_stage_11,
    in_ndt_after_heat_treat,
    heat_treated_welds,
    in_stage_14,
    in_stage_15,
    nr_of_painted_welds,
    nr_of_finished_welds
    ) VALUES (\"',key_drawing_name,'\",\"',key_foldername_name,'\",\"0\",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

COMMIT;
END