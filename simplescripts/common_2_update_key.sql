CREATE DEFINER=`admin`@`%` PROCEDURE `common_2_update_key`(
IN key_login varchar(255),
IN key_new_key varchar(255)
)
BEGIN
SET @key_id = (SELECT PersonID FROM workers.workers_data WHERE Login=key_login);
UPDATE workers.api_keys_for_workers SET APIKey = key_new_key WHERE PersonID = @key_id;
COMMIT;
END