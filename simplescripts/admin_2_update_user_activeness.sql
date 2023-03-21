CREATE DEFINER=`admin`@`%` PROCEDURE `admin_2_update_user_activeness`(
IN key_1 int, 
IN key_2 int)
BEGIN
UPDATE usercreds.creds SET Active = key_1 WHERE PersonID = key_2;
COMMIT;
END