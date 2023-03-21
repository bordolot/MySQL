CREATE DEFINER=`admin`@`%` PROCEDURE `admin_6_close_project`(
IN key_project_name varchar(255),
IN key_date DATE
)
BEGIN
SET @project_id = (SELECT ProjectID FROM projects.list_of_projects_and_folders WHERE ProjectName = key_project_name);
UPDATE projects.list_of_projects_and_folders SET accomplishDate = key_date WHERE ProjectID = @project_id;
COMMIT;
END