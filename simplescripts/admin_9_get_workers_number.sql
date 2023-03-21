CREATE DEFINER=`admin`@`%` PROCEDURE `admin_9_get_workers_number`()
BEGIN
SET @user_id = (SELECT COUNT(*) FROM workers.workers_data)+1;
SELECT @user_id;
END