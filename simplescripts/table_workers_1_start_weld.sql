CREATE DEFINER=`admin`@`%` PROCEDURE `table_workers_1_start_weld`(
IN key_project_name varchar(255),
IN key_drawing_name varchar(255),
IN key_drawing_no varchar(255),
IN key_weld_no varchar(255),
IN key_worker_id int,
OUT key_result int
)
BEGIN
SELECT ProjectTableName1 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_frb;
SELECT ProjectTableName2 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_drawing_data;

SET @sql_text = concat('SET @key_DrawingID = (SELECT DrawingID FROM projects.',@key_tablename_drawing_data,' WHERE (DrawingNo=\"',key_drawing_name,'\") );');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
SET @sql_text = concat('SET @key_WeldID = (SELECT WeldID FROM projects.',@key_tablename_frb,' WHERE (DrawingNo=\"',key_drawing_no,'\" AND WeldNo=\"',key_weld_no,'\") );');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @current_weld_stage = "0";
IF (@key_WeldID IS NOT NULL) THEN
	SET @sql_text = concat('SET @current_weld_stage = (SELECT STAGE FROM projects.',@key_tablename_frb,' WHERE WeldID = @key_WeldID);');
	PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
	SET @sql_text = concat('SET @value_for_fitter_check = (SELECT Fitter2ID FROM projects.',@key_tablename_frb,' WHERE WeldID = @key_WeldID);');
	PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
END IF;

SET @worker_table_name = (SELECT TableName FROM workers.workers_data WHERE PersonID=key_worker_id);
SET @worker_profession = (SELECT Profession FROM workers.workers_data WHERE PersonID=key_worker_id);

IF @worker_table_name IS NOT NULL THEN 
	
    IF (@worker_profession="fitter" AND (@value_for_fitter_check IS NULL) AND (@current_weld_stage="2" OR @current_weld_stage="3")) 
		OR (@worker_profession="welder" AND @current_weld_stage="5") THEN

		SET @sql_text = concat('SET @key_JobID = (SELECT JobID FROM workers.',@worker_table_name,' WHERE (Project=\"',key_project_name,'\" AND DrawingNo=\"',key_drawing_no,'\" AND WeldNo=\"',key_weld_no,'\" AND accomplishDate IS NULL AND approveDate IS NULL AND declineDate IS NULL) );');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		
		IF @key_JobID IS NULL THEN
			SET @sql_text = concat('INSERT INTO workers.',@worker_table_name,' (
					Project,
					DrawingNo,
					DrawingID,
					WeldNo,
					WeldID,
					startDate
					) 
				VALUES (
					\"',key_project_name,'\",
					\"',key_drawing_no,'\",
					',@key_DrawingID,',
					\"',key_weld_no,'\",
					', @key_WeldID,',
					\"',now(),'\"
					);');
			PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		ELSE 
			SET @sql_text = concat('UPDATE workers.',@worker_table_name,' SET startDate= \"',now(),'\" WHERE JobID=',@key_JobID,';');
			PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		END IF;
		SET key_result = 1;
		COMMIT;
	ELSE
		SET key_result = 0;
	END IF;
ELSE 
	SET key_result = 0;
END IF;


END