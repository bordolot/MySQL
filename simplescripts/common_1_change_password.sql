CREATE DEFINER=`admin`@`%` PROCEDURE `common_1_change_password`(
IN key_login varbinary(255),
IN key_api_number varbinary(255),
IN key_password varbinary(255), 
IN key_salt varbinary(255)
)
BEGIN
SET @key_id = (SELECT PersonID FROM usercreds.creds WHERE Login=key_login);
SET @key_role = (SELECT Role FROM workers.api_keys_for_workers WHERE Login=key_login);
SET @api_key = (SELECT APIKey FROM workers.api_keys_for_workers WHERE Login=key_login);

IF @api_key = key_api_number THEN
	UPDATE usercreds.creds SET Password=key_password WHERE PersonID=@key_id;
	UPDATE usercreds.creds SET Salt=key_salt WHERE PersonID=@key_id;
	SET @key_result = 'You\'ve just changed password.';
ELSE 
	SET @key_result = 'You\'ve passed wrong login';
END IF;

COMMIT;
SELECT @key_result;
END