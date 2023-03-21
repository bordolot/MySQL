CREATE DEFINER=`admin`@`%` PROCEDURE `admin_8_restet_workers_pass`(
IN key_id int,
IN key_password varbinary(255),
IN key_salt varbinary(255)
)
BEGIN
UPDATE usercreds.creds SET Password=key_password, Salt=key_salt WHERE PersonID=key_id;
SET @out_login = (SELECT Login FROM workers.workers_data WHERE PersonID=key_id);
SELECT @out_login;
COMMIT;

END