CREATE DEFINER=`admin`@`%` PROCEDURE `common_4_check_api`(
IN key_login varbinary(255)
)
BEGIN
SELECT APIKey FROM workers.api_keys_for_workers WHERE Login = key_login;
END