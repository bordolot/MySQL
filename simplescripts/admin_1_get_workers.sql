CREATE DEFINER=`admin`@`%` PROCEDURE `admin_1_get_workers`(
IN key_type varchar(255)
)
BEGIN
IF key_type = "all" THEN
	SELECT A.FirstName,A.SecondName,A.Profession,A.PersonID,B.Active,A.Email,A.Competences,A.LicenceNo FROM workers.workers_data A LEFT JOIN usercreds.creds B ON A.PersonID = B.PersonID;
ELSEIF key_type = "managers" THEN
	SELECT A.FirstName,A.SecondName,A.PersonID FROM workers.workers_data A LEFT JOIN usercreds.creds B ON A.PersonID = B.PersonID
	WHERE (B.Active=1 AND A.Profession="manager");
ELSEIF key_type = "active_emails" THEN
	SELECT A.Email FROM workers.workers_data A LEFT JOIN usercreds.creds B ON A.PersonID = B.PersonID
	WHERE B.Active=1;
END IF;

END