CREATE DEFINER=`admin`@`%` PROCEDURE `common_5_check_pass`(IN key_ varbinary(255))
BEGIN
SELECT Password, Salt, Active FROM usercreds.creds WHERE Login = key_;
END