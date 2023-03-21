CREATE DEFINER=`admin`@`%` PROCEDURE `admin_7_change_workers_email`(
IN key_id int,
IN key_email varchar(255)
)
BEGIN
UPDATE workers.workers_data SET Email = key_email WHERE PersonID = key_id;
COMMIT;
END