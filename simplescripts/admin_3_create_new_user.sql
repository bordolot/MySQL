CREATE DEFINER=`admin`@`%` PROCEDURE `admin_3_create_new_user`(
IN key_login varbinary(255), 
IN key_password varbinary(255), 
IN key_salt varbinary(255),
IN key_role int,
IN key_fname varchar(255),
IN key_sname varchar(255),
IN key_prof varchar(255),
IN key_SpecTypes JSON,
IN key_SpecAuthNumbers JSON,
IN key_email varchar(255),
IN key_date date)
BEGIN
INSERT INTO usercreds.creds (Login,Password,Salt,Active,isLoggedIn) VALUES (key_login, key_password, key_salt, 1, 0);
INSERT INTO workers.api_keys_for_workers (Login,APIKey,Role) VALUES (key_login,123456789,key_role);

SET @user_id = (SELECT COUNT(*) FROM workers.workers_data) + 1;
SET @new_table_name = CONCAT('_',@user_id,'_',key_login);

INSERT INTO workers.workers_data (Login,TableName,FirstName,SecondName,Profession,Competences,LicenceNo,Email,RegisterDate,jobs) 
VALUES (key_login,@new_table_name,key_fname,key_sname,key_prof,CAST(key_SpecTypes AS JSON),CAST(key_SpecAuthNumbers AS JSON),key_email,key_date,CAST("[]" AS JSON));


IF key_prof = 'manager' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (ProjectID int NOT NULL PRIMARY KEY auto_increment, Project varchar(255) NOT NULL,NumberOfElementsDone int NOT NULL,canceled boolean, accomplishDate date);');
ELSEIF key_prof = 'welder' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (JobID int NOT NULL PRIMARY KEY auto_increment, Project varchar(255) NOT NULL, DrawingNo varchar(255) NOT NULL, DrawingID int NOT NULL, WeldNo varchar(255) NOT NULL, WeldID int NOT NULL,startDate datetime, accomplishDate datetime, approveDate datetime, declineDate datetime, declineReason varchar(255));');

ELSEIF key_prof = 'fitter' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (JobID int NOT NULL PRIMARY KEY auto_increment, Project varchar(255) NOT NULL, DrawingNo varchar(255) NOT NULL, DrawingID int NOT NULL, WeldNo varchar(255) NOT NULL, WeldID int NOT NULL,startDate datetime, accomplishDate datetime, approveDate datetime, declineDate datetime, declineReason varchar(255));');

ELSEIF key_prof = 'painter' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (JobID int NOT NULL PRIMARY KEY auto_increment, Project varchar(255) NOT NULL, DrawingNo varchar(255) NOT NULL, DrawingID int NOT NULL, WeldNo varchar(255) NOT NULL, numberOfTries int NOT NULL,accomplishDate date, Notes JSON NOT NULL);');

ELSEIF key_prof = 'foreman' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (JobID int NOT NULL PRIMARY KEY auto_increment, Project varchar(255) NOT NULL, DrawingNo varchar(255) NOT NULL, DrawingID int NOT NULL, WeldNo varchar(255) NOT NULL, stage int NOT NULL, Notes JSON NOT NULL);');

ELSEIF key_prof = 'NDT_operator' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (JobID int NOT NULL PRIMARY KEY auto_increment, Project varchar(255) NOT NULL, DrawingNo varchar(255) NOT NULL, DrawingID int NOT NULL, WeldNo varchar(255) NOT NULL, method varchar(255), Notes JSON NOT NULL);');

ELSEIF key_prof = 'quality_inspector' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (JobID int NOT NULL PRIMARY KEY auto_increment, Project varchar(255) NOT NULL, DrawingNo varchar(255) NOT NULL, DrawingID int NOT NULL, WeldNo varchar(255) NOT NULL, Stage5 int, Stage5Date date,Stage8 int, Stage8Date date,Stage11 int, Stage11Date date, Notes JSON NOT NULL);');

ELSEIF key_prof = 'technologist' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (JobID int NOT NULL PRIMARY KEY auto_increment, Project varchar(255) NOT NULL, DrawingNo varchar(255) NOT NULL, DrawingID int NOT NULL, WeldNo varchar(255) NOT NULL, Notes JSON NOT NULL);');

ELSEIF key_prof = 'welding_engineer' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (JobID int NOT NULL PRIMARY KEY auto_increment, Project varchar(255) NOT NULL, DrawingNo varchar(255) NOT NULL, DrawingID int NOT NULL, WeldNo varchar(255) NOT NULL, Notes JSON NOT NULL);');

ELSEIF key_prof = 'PWHT_technician' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (JobID int NOT NULL PRIMARY KEY auto_increment, Project varchar(255) NOT NULL, DrawingNo varchar(255) NOT NULL, DrawingID int NOT NULL, WeldNo varchar(255) NOT NULL, Notes JSON NOT NULL);');




/*
ELSEIF key_prof = 'admin' THEN
	SET @sql_text = concat('create table workers.',@new_table_name,' (ProjectID int NOT NULL PRIMARY KEY auto_increment);');
*/
END IF;
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
COMMIT;

END