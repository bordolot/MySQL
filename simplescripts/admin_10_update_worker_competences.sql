CREATE DEFINER=`admin`@`%` PROCEDURE `admin_10_update_worker_competences`(
IN key_worker_id int,
IN key_SpecTypes JSON,
IN key_SpecAuthNumbers JSON
)
BEGIN
UPDATE workers.workers_data SET Competences = key_SpecTypes, LicenceNo =key_SpecAuthNumbers WHERE PersonID = key_worker_id;
END