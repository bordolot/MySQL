CREATE DEFINER=`admin`@`%` PROCEDURE `table_workers_2_accomplish_weld`(
IN key_project_name varchar(255),
IN key_drawing_name varchar(255),
IN key_drawing_no varchar(255),
IN key_weld_no varchar(255),
IN key_worker_id int,
OUT key_result int
)
BEGIN

SET @worker_table_name = (SELECT TableName FROM workers.workers_data WHERE PersonID=key_worker_id);

SET @sql_text = concat('SET @key_JobID = (SELECT JobID FROM workers.',@worker_table_name,' WHERE (Project=\"',key_project_name,'\" AND DrawingNo=\"',key_drawing_no,'\" AND WeldNo=\"',key_weld_no,'\" AND accomplishDate IS NULL AND declineDate IS NULL) );');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

IF @key_JobID IS NOT NULL THEN 
	SET @sql_text = concat('UPDATE workers.',@worker_table_name,' SET accomplishDate= \"',now(),'\" WHERE JobID=',@key_JobID,';');
	PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
	SET key_result = 1;
    COMMIT;
ELSE
	SET key_result = 0;
END IF;

END