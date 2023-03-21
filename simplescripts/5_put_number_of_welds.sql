CREATE DEFINER=`admin`@`%` PROCEDURE `5_put_number_of_welds`(
IN key_project_name varchar(255),
IN key_drawing_name varchar(255),
IN key_number_of_welds int,
OUT key_result int
)
BEGIN
SELECT ProjectTableName2 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename;
SET @sql_text = concat('SELECT nr_of_part_welds FROM projects.',@key_tablename,'
	WHERE DrawingNo=\"',key_drawing_name,'\" INTO @key_number_partially_registered;');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;


IF key_number_of_welds < @key_number_partially_registered THEN
	SET key_result:=1000;
ELSE
	SET @sql_text = concat('SELECT DrawingID FROM projects.',@key_tablename,'
		WHERE DrawingNo=\"',key_drawing_name,'\" INTO @key_id;');
    PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
    
    SET @sql_text = concat('UPDATE projects.',@key_tablename,' SET nr_of_welds= ',key_number_of_welds,'
	WHERE DrawingID=\"',@key_id,'\";');
	PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

	SET key_result:=33;
    COMMIT;
END IF;
END