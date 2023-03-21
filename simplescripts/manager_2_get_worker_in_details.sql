CREATE DEFINER=`admin`@`%` PROCEDURE `manager_2_get_worker_in_details`(
IN key_project_name varchar(255),
IN key_worker_id int
)
BEGIN
FLUSH TABLES;
SET @tablename_worker = (SELECT TableName FROM workers.workers_data WHERE PersonID=key_worker_id);

SET @number_of_welds = 0;
SET @number_of_welds_waiting_for_approval = 0;
SET @number_of_welds_approved = 0;
SET @number_of_welds_declined_by_foreman = 0;
SET @number_of_welds_declined_by_quality = 0;
SET @number_of_welds_declined_by_ndt = 0;
SET @average_work_time = 0;

SET @sql_text = concat('SET @number_of_welds = (SELECT COUNT(*) from workers.',@tablename_worker,' WHERE Project=\"',key_project_name,'\" AND (accomplishDate IS NOT NULL OR approveDate IS NOT NULL OR declineDate IS NOT NULL ) );');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @sql_text = concat('SET @number_of_welds_waiting_for_approval = (SELECT COUNT(*) from workers.',@tablename_worker,' WHERE Project=\"',key_project_name,'\" AND (accomplishDate IS NOT NULL AND approveDate IS NULL AND  declineDate IS NULL) );');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @sql_text = concat('SET @number_of_welds_approved = (SELECT COUNT(*) from workers.',@tablename_worker,' WHERE Project=\"',key_project_name,'\" AND (approveDate IS NOT NULL ) );');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @sql_text = concat('SET @number_of_welds_declined_by_foreman = (SELECT COUNT(*) from workers.',@tablename_worker,' WHERE Project=\"',key_project_name,'\" AND (declineDate IS NOT NULL AND declineReason="FOREMAN") );');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @sql_text = concat('SET @number_of_welds_declined_by_quality = (SELECT COUNT(*) from workers.',@tablename_worker,' WHERE Project=\"',key_project_name,'\" AND (declineDate IS NOT NULL AND declineReason="QUALITY") );');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @sql_text = concat('SET @number_of_welds_declined_by_ndt = (SELECT COUNT(*) from workers.',@tablename_worker,' WHERE Project=\"',key_project_name,'\" AND (declineDate IS NOT NULL AND declineReason="NDT") );');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

IF @number_of_welds != 0 THEN
	SET @sql_text = concat('SET @average_work_time =  FORMAT(FLOOR((SELECT SUM( TIMESTAMPDIFF(MINUTE, startDate, accomplishDate))/',@number_of_welds,' FROM workers.',@tablename_worker,' )), 0);');
    PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
END IF;


SELECT @number_of_welds,@number_of_welds_waiting_for_approval,@number_of_welds_approved,@number_of_welds_declined_by_foreman,@number_of_welds_declined_by_quality,@number_of_welds_declined_by_ndt,@average_work_time;


END