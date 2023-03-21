CREATE DEFINER=`admin`@`%` PROCEDURE `manager_1_get_workers_in_project`(
IN key_project_name varchar(255)
)
BEGIN
SELECT ProjectTableName1 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_frb;

SET @all_fitters_data = JSON_ARRAY();
SET @all_welders_data = JSON_ARRAY();

SET @sql_text = concat('SET @all_fitters_id_array = (SELECT JSON_ARRAYAGG(value) AS json_array
FROM (
  SELECT DISTINCT Fitter1ID AS value FROM projects._1_frb WHERE Fitter1ID IS NOT NULL
  UNION
  SELECT DISTINCT Fitter2ID AS value FROM projects._1_frb WHERE Fitter2ID IS NOT NULL
) t);');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

#SET @sql_text = concat('SET @all_welders_id_array = (SELECT DISTINCT JSON_ARRAYAGG(WelderID) FROM projects._1_frb WHERE WelderID IS NOT NULL);');
SET @sql_text = concat('SET @all_welders_id_array = (SELECT JSON_ARRAYAGG(value) AS json_array
FROM (
  SELECT DISTINCT WelderID AS value FROM projects._1_frb WHERE WelderID IS NOT NULL
) t);');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @i_val = 0;
SET @fitter_id = 0;

WHILE @i_val < JSON_LENGTH(@all_fitters_id_array) DO
	SET  @fitter_id = ( SELECT JSON_EXTRACT(@all_fitters_id_array,CONCAT('$[',@i_val,']')) );
	IF @fitter_id != "null" THEN
		SET @FirstName = (SELECT FirstName FROM workers.workers_data WHERE PersonID=@fitter_id);
        SET @SecondName = (SELECT SecondName FROM workers.workers_data WHERE PersonID=@fitter_id);
		SET @fitter_data = JSON_ARRAY(@fitter_id,@FirstName,@SecondName);
        SET @all_fitters_data = (SELECT JSON_ARRAY_APPEND(@all_fitters_data, '$', CAST(@fitter_data as JSON) ));
	END IF;
	SELECT @i_val + 1 INTO @i_val;
END WHILE;

SET @i_val = 0;
SET @welder_id = 0;

WHILE @i_val < JSON_LENGTH(@all_fitters_id_array) DO
	SET  @welder_id = ( SELECT JSON_EXTRACT(@all_welders_id_array,CONCAT('$[',@i_val,']')) );
	IF @welder_id != "null" THEN
		SET @FirstName = (SELECT FirstName FROM workers.workers_data WHERE PersonID=@welder_id);
        SET @SecondName = (SELECT SecondName FROM workers.workers_data WHERE PersonID=@welder_id);
		SET @welder_data = JSON_ARRAY(@welder_id,@FirstName,@SecondName);
        SET @all_welders_data = (SELECT JSON_ARRAY_APPEND(@all_welders_data, '$', CAST(@welder_data as JSON) ));
	END IF;
	SELECT @i_val + 1 INTO @i_val;
END WHILE;

SELECT @all_fitters_data, @all_welders_data;

END