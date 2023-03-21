CREATE DEFINER=`admin`@`%` PROCEDURE `admin_5_update_manager`(
IN key_p_name varchar(255),
IN key_manager_f_name varchar(255),
IN key_manager_s_name varchar(255),
IN key_manager_id varchar(255),
IN key_date varchar(255)
)
BEGIN
SET @key_id = (SELECT ProjectID FROM list_of_projects_and_folders WHERE ProjectName = key_p_name);
SET @var_json = (SELECT manager from list_of_projects_and_folders WHERE ProjectName = key_p_name);
SET @var_bool = JSON_EXTRACT(@var_json, '$[0]');
IF @var_bool IS NULL THEN
	SET @var_1 = CONCAT('["', key_manager_f_name,'","', key_manager_s_name,'","', key_manager_id,'"]');
	UPDATE list_of_projects_and_folders SET manager = CAST(@var_1 AS JSON) WHERE ProjectID = @key_id;
    UPDATE list_of_projects_and_folders SET manager_work_start = CAST(key_date AS DATE) WHERE ProjectID = @key_id;
ELSE
	SET @old_fname= (SELECT JSON_UNQUOTE(JSON_EXTRACT(@var_json,CONCAT('$[0]'))));
    SET @old_sname= (SELECT JSON_UNQUOTE(JSON_EXTRACT(@var_json,CONCAT('$[1]'))));
    SET @old_id= (SELECT JSON_UNQUOTE(JSON_EXTRACT(@var_json,CONCAT('$[2]'))));
    SET @old_start_work= (SELECT manager_work_start from list_of_projects_and_folders WHERE ProjectName = key_p_name);
    SET @input = CONCAT('[\"',@old_fname,'\",\"',@old_sname,'\",\"', @old_id,'\",\"',@old_start_work,'\",\"',key_date,'\"]');
    SET @var = (SELECT previous_managers FROM projects.list_of_projects_and_folders WHERE ProjectID = @key_id);
    SET @key_order = JSON_LENGTH(@var);
    UPDATE list_of_projects_and_folders SET previous_managers = JSON_INSERT(previous_managers,CONCAT('$[',@key_order,']'), CAST(@input AS JSON) ) WHERE ProjectID = @key_id;
	SET @var_1 = CONCAT('["', key_manager_f_name,'","', key_manager_s_name,'","', key_manager_id,'","', key_date,'"]');
	UPDATE list_of_projects_and_folders SET manager = CAST(@var_1 AS JSON) WHERE ProjectID = @key_id;
    UPDATE list_of_projects_and_folders SET manager_work_start = CAST(key_date AS DATE) WHERE ProjectID = @key_id;
END IF;

# put data into workers specific manager
#SET @key_manager_login = (SELECT Login FROM workers.workers_data WHERE PersonID = key_manager_id);
#SET @table_name_for_worker = CONCAT('workers._',key_manager_id,'_',@key_welder_login);
#SET @sql_text = concat('INSERT INTO ',@table_name_for_worker,' (Project, NumberOfElementsDone) VALUES (\"',key_project_name,'\",0)');
#PREPARE stmt FROM @sql_text;
#EXECUTE stmt;
#DEALLOCATE PREPARE stmt;

COMMIT;
END