CREATE DEFINER=`admin`@`%` PROCEDURE `common_3_get_role`(
IN key_1 VARBINARY(255)
)
BEGIN
SET @out_role = (SELECT Role FROM workers.api_keys_for_workers WHERE Login = key_1);
SET @out_id = (SELECT PersonID FROM workers.api_keys_for_workers WHERE Login = key_1);
SET @out_f_name = (SELECT FirstName FROM workers.workers_data WHERE Login = key_1);
SET @out_s_name = (SELECT SecondName FROM workers.workers_data WHERE Login = key_1);
SET @out_competencies = (SELECT Competences FROM workers.workers_data WHERE Login = key_1);
SET @out_licence_numbers = (SELECT LicenceNo FROM workers.workers_data WHERE Login = key_1);
SELECT @out_role,@out_id,@out_f_name,@out_s_name,@out_competencies,@out_licence_numbers;
END