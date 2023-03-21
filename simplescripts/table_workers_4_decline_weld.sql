CREATE DEFINER=`admin`@`%` PROCEDURE `table_workers_4_decline_weld`(
IN key_project_name varchar(255),
IN key_drawing_no varchar(255),
IN key_weld_no varchar(255),
IN key_stage varchar(255),
IN key_reason varchar(255),
OUT key_result int
)
BEGIN
SELECT ProjectTableName1 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_frb;


SET @key_fitter_1_id = 0;
SET @key_fitter_2_id = 0;
SET @key_welder_id = 0;

IF (key_stage="3" OR key_stage="4") THEN

	SET @sql_text = concat('(SELECT Fitter1ID, Fitter2ID FROM projects.',@key_tablename_frb,' WHERE (DrawingNo=\"',key_drawing_no,'\" AND WeldNo=\"',key_weld_no,'\") INTO @key_fitter_1_id, @key_fitter_2_id);');
	PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
    SET @worker_table_name = (SELECT TableName FROM workers.workers_data WHERE PersonID=@key_fitter_1_id);
    SET @sql_text = concat('SET @key_JobID = (SELECT JobID FROM workers.',@worker_table_name,' WHERE (Project=\"',key_project_name,'\" AND DrawingNo=\"',key_drawing_no,'\" AND WeldNo=\"',key_weld_no,'\" AND accomplishDate IS NOT NULL AND approveDate IS NULL AND declineDate IS NULL) );');
	PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
    IF @key_JobID IS NOT NULL THEN
		SET @sql_text = concat('UPDATE workers.',@worker_table_name,' SET declineDate= \"',now(),'\", declineReason=\"',key_reason,'\" WHERE JobID=',@key_JobID,';');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
	END IF;
    
    IF @key_fitter_2_id IS NOT NULL THEN
		SET @worker_table_name = (SELECT TableName FROM workers.workers_data WHERE PersonID=@key_fitter_2_id);
		SET @sql_text = concat('SET @key_JobID = (SELECT JobID FROM workers.',@worker_table_name,' WHERE (Project=\"',key_project_name,'\" AND DrawingNo=\"',key_drawing_no,'\" AND WeldNo=\"',key_weld_no,'\" AND accomplishDate IS NOT NULL AND approveDate IS NULL AND declineDate IS NULL) );');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		IF @key_JobID IS NOT NULL THEN
			SET @sql_text = concat('UPDATE workers.',@worker_table_name,' SET declineDate= \"',now(),'\", declineReason=\"',key_reason,'\" WHERE JobID=',@key_JobID,';');
			PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		END IF;
    END IF;
    SET key_result = 1;
    COMMIT;

ELSEIF (key_stage="6" OR key_stage="7" OR key_stage="8") THEN
	SET @sql_text = concat('(SELECT WelderID FROM projects.',@key_tablename_frb,' WHERE (DrawingNo=\"',key_drawing_no,'\" AND WeldNo=\"',key_weld_no,'\") INTO @key_welder_id);');
	PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
    SET @worker_table_name = (SELECT TableName FROM workers.workers_data WHERE PersonID=@key_welder_id);
 
	SET @sql_text = concat('SET @key_JobID = (SELECT JobID FROM workers.',@worker_table_name,' WHERE (Project=\"',key_project_name,'\" AND DrawingNo=\"',key_drawing_no,'\" AND WeldNo=\"',key_weld_no,'\" AND accomplishDate IS NOT NULL AND declineDate IS NULL) );');
	PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
    
    IF @key_JobID IS NOT NULL THEN
		SET @sql_text = concat('UPDATE workers.',@worker_table_name,' SET declineDate= \"',now(),'\", declineReason=\"',key_reason,'\", approveDate=NULL WHERE JobID=',@key_JobID,';');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
        SET key_result = 1;
		COMMIT;
    ELSE
		SET key_result = 0;
    END IF;
ELSE 
	SET key_result = 0;
END IF;


END