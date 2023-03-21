CREATE DEFINER=`admin`@`%` PROCEDURE `2_get_projects`(
IN key_type varchar(255)
)
BEGIN
FLUSH TABLES;
IF key_type = "finished" THEN
	select ProjectID,ProjectName,folders,DATE_FORMAT(startDate, '%d-%m-%Y') from _00_list_of_projects_and_folders WHERE (accomplishDate IS NOT NULL);
ELSEIF key_type = "active" THEN
	select ProjectID,ProjectName,folders,DATE_FORMAT(startDate, '%d-%m-%Y') from _00_list_of_projects_and_folders WHERE (accomplishDate IS NULL);
END IF;
END