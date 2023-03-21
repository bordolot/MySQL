CREATE DEFINER=`admin`@`%` PROCEDURE `7_put_weld_details`(
IN key_project_name varchar(255),
IN key_folder_name varchar(255),
IN key_drawing_name varchar(255),
IN key_weld_name varchar(255),
IN key_DrawingNo varchar(255),
IN key_FillerMaterial varchar(255),
IN key_WeldingMethod varchar(255),
IN key_WPSNo varchar(255),
IN key_WPSrev varchar(255),
IN key_WPSFileName varchar(255),
IN key_date varchar(255),
IN ndt_tests JSON,
IN key_is_pwht_req int,
IN ndt_tests_for_pwht JSON,
OUT key_result int
)
BEGIN
SELECT ProjectTableName1 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_frb;
SELECT ProjectTableName2 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_drawing_data;
SELECT ProjectTableName3 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_ndt;
SELECT ProjectTableName4 FROM projects._00_list_of_projects_and_folders WHERE ProjectName=key_project_name INTO @key_tablename_ndt_for_pwht;

SET @sql_text = concat('SELECT WeldID FROM projects.',@key_tablename_frb,' WHERE DrawingNo=\"',key_DrawingNo,'\" AND WeldNo=\"',key_weld_name,'\"  INTO @key_id_frb;');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @key_id_ndt = @key_id_frb;
SET @key_id_ndt_for_pwht = @key_id_frb;

SET @sql_text = concat('SELECT DrawingID FROM projects.',@key_tablename_drawing_data,' WHERE DrawingNo=\"',key_drawing_name,'\" AND Folder=\"',key_folder_name,'\"  INTO @key_id_drawing_data;');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

#Check stage
SET @sql_text = concat('SELECT STAGE FROM projects.',@key_tablename_frb,' WHERE WeldID=',@key_id_frb,' INTO @key_stage;');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

SET @do_weld_had_any_ndt_req = 0;
SET @do_weld_had_any_ndt_for_pwht_req = 0;
SET @do_weld_had_pwht_req_before = 0;

SET key_result = 0;

SET @sql_text = concat('SET @do_weld_had_pwht_req_before = (SELECT IsPWHTrequired FROM projects.',@key_tablename_frb,' WHERE WeldID=',@key_id_frb,');');
PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

IF @key_stage >=5 THEN
	 # you cannot edit weld in stage above and equal 5
	SET key_result = 0;
ELSE 
	SET key_result = 1;
	IF @key_stage >=2 AND @key_stage <5 THEN
		# check do_weld_had_any_ndt_for_pwht_req
		SET @sql_text = concat('SET @old_json = (SELECT requiredNDTforPWHT FROM projects.',@key_tablename_frb,' WHERE WeldID=',@key_id_frb,');');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		IF JSON_LENGTH(@old_json)!=0 THEN
			SET @do_weld_had_any_ndt_for_pwht_req = 1;
		END IF;
		#########
		
		SET @sql_text = concat('UPDATE projects.',@key_tablename_frb,' SET FillerMaterial= \"',key_FillerMaterial,'\", WeldingMethod= \"',key_WeldingMethod,'\", WPSNo = \"',key_WPSNo,'\", WPSrev= \"',key_WPSrev,'\", WPSFileName=\"',key_WPSFileName,'\", IsPWHTrequired=',key_is_pwht_req,', requiredNDT = \'',ndt_tests,'\', requiredNDTforPWHT = \'',ndt_tests_for_pwht,'\' WHERE WeldID = @key_id_frb;');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		
	ELSEIF @key_stage =1 THEN
		
		SET @sql_text = concat('UPDATE projects.',@key_tablename_frb,' SET FillerMaterial= \"',key_FillerMaterial,'\", WeldingMethod= \"',key_WeldingMethod,'\", WPSNo = \"',key_WPSNo,'\", WPSrev= \"',key_WPSrev,'\", WPSFileName=\"',key_WPSFileName,'\", IsPWHTrequired=',key_is_pwht_req,',  STAGE=2, requiredNDT = \'',ndt_tests,'\', requiredNDTforPWHT = \'',ndt_tests_for_pwht,'\' WHERE WeldID = @key_id_frb;');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

		# updating _nr_drawing_data
		# DrawingWeldsData
		
		# decreasing nr_of_part_welds
		SET @sql_text = concat('SET @old_value = (SELECT nr_of_part_welds FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,');');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		SET @new_value = cast((@old_value - 1) AS unsigned);
		SET @sql_text = concat('
		UPDATE projects.',@key_tablename_drawing_data,' SET nr_of_part_welds = ',@new_value,' WHERE DrawingID =',@key_id_drawing_data,';
		');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;


		# increasing nr_of_full_welds
		SET @sql_text = concat('SET @old_value = (SELECT nr_of_full_welds FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,');');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		SET @new_value = cast((@old_value + 1) AS unsigned);
		SET @sql_text = concat('
		UPDATE projects.',@key_tablename_drawing_data,' SET nr_of_full_welds = ',@new_value,' WHERE DrawingID =',@key_id_drawing_data,';');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		
		# increasing in_stage_2
		SET @sql_text = concat('SET @old_value = (SELECT in_stage_2 FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,');');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		SET @new_value = cast((@old_value + 1) AS unsigned);
		SET @sql_text = concat('UPDATE projects.',@key_tablename_drawing_data,' SET in_stage_2 = ',@new_value,' WHERE DrawingID =',@key_id_drawing_data,';');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
        
        SET @sql_text = concat('SELECT nr_of_welds,nr_of_full_welds FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,' INTO @key_nr_of_welds,@key_nr_of_full_welds ;');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
        
        
        IF @key_nr_of_welds = @key_nr_of_full_welds THEN
			SET @sql_text = concat('SELECT JSON_ARRAYAGG(WeldID) from projects.',@key_tablename_frb,' WHERE DrawingNo=\"',key_DrawingNo,'\" INTO @key_json_weld_ids');
			PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
            SET @i_val = 0;
            WHILE @i_val < JSON_LENGTH(@key_json_weld_ids) DO
				SET  @weld_id = ( SELECT JSON_EXTRACT(@key_json_weld_ids,CONCAT('$[',@i_val,']')) );
                SET @sql_text = concat('UPDATE projects.',@key_tablename_frb,' SET ReleaseDate= \"',key_date,'\" WHERE WeldID = ',@weld_id,';');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
                SELECT @i_val + 1 INTO @i_val;
			END WHILE;
            
        END IF;
	END IF;


	######################################################
	# in ndt
	# change is Ndt required
	IF @key_stage <5 THEN
		SET @i_val = 0;
		SET @ndt_val = "";
		SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt,' SET IsVTrequired=0, IsPTrequired=0, IsMTrequired=0, IsUTrequired=0, IsRTrequired=0, IsFerrytRequired=0, IsPMIrequired=0, IsHardnessRequired=0 WHERE WeldID = @key_id_ndt;');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

		WHILE @i_val < JSON_LENGTH(ndt_tests) DO
			SET  @ndt_val = ( SELECT JSON_EXTRACT(ndt_tests,CONCAT('$[',@i_val,']')) );
			
			IF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"VT")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt,' SET IsVTrequired= 1 WHERE WeldID = @key_id_ndt;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"PT")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt,' SET IsPTrequired= 1 WHERE WeldID = @key_id_ndt;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"MT")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt,' SET IsMTrequired= 1 WHERE WeldID = @key_id_ndt;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
            ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"UT")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt,' SET IsUTrequired= 1 WHERE WeldID = @key_id_ndt;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"RT")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt,' SET IsRTrequired= 1 WHERE WeldID = @key_id_ndt;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"Ferryt")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt,' SET IsFerrytRequired= 1 WHERE WeldID = @key_id_ndt;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"PMI")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt,' SET IsPMIrequired= 1 WHERE WeldID = @key_id_ndt;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"hardness")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt,' SET IsHardnessRequired= 1 WHERE WeldID = @key_id_ndt;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			END IF;
			SELECT @i_val + 1 INTO @i_val;
		END WHILE;
	END IF;


	######################################################
	######################################################
	# in ndt_for_pwht
	# change is Ndt required
	IF @key_stage <5 THEN
		SET @i_val = 0;
		SET @ndt_val = "";
		SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt_for_pwht,' SET IsVTrequired=0, IsPTrequired=0, IsMTrequired=0, IsUTrequired=0, IsRTrequired=0, IsFerrytRequired=0, IsPMIrequired=0, IsHardnessRequired=0 WHERE WeldID = @key_id_ndt_for_pwht;');
		PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;

		WHILE @i_val < JSON_LENGTH(ndt_tests_for_pwht) DO
			SET  @ndt_val = ( SELECT JSON_EXTRACT(ndt_tests_for_pwht,CONCAT('$[',@i_val,']')) );
			
			IF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"VT")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt_for_pwht,' SET IsVTrequired= 1 WHERE WeldID = @key_id_ndt_for_pwht;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"PT")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt_for_pwht,' SET IsPTrequired= 1 WHERE WeldID = @key_id_ndt_for_pwht;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"MT")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt_for_pwht,' SET IsMTrequired= 1 WHERE WeldID = @key_id_ndt_for_pwht;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
            ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"UT")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt_for_pwht,' SET IsUTrequired= 1 WHERE WeldID = @key_id_ndt_for_pwht;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"RT")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt_for_pwht,' SET IsRTrequired= 1 WHERE WeldID = @key_id_ndt_for_pwht;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"Ferryt")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt_for_pwht,' SET IsFerrytRequired= 1 WHERE WeldID = @key_id_ndt_for_pwht;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"PMI")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt_for_pwht,' SET IsPMIrequired= 1 WHERE WeldID = @key_id_ndt_for_pwht;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			ELSEIF STRCMP(TRIM(BOTH '"' FROM @ndt_val),"hardness")=0 THEN
				SET @sql_text = concat('UPDATE projects.',@key_tablename_ndt_for_pwht,' SET IsHardnessRequired= 1 WHERE WeldID = @key_id_ndt_for_pwht;');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			END IF;
			SELECT @i_val + 1 INTO @i_val;
		END WHILE;
	END IF;
    

	######################################################
	# in drawing data
	# change number of welds in pwht
	IF @key_stage =1 THEN
		IF key_is_pwht_req=1 THEN
			# increase number of welds in ndt
			SET @sql_text = concat('SET @old_value = (SELECT nr_pwht_welds FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,');');
			PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			SET @new_value = cast((@old_value + 1) AS unsigned);
			SET @sql_text = concat('UPDATE projects.',@key_tablename_drawing_data,' SET nr_pwht_welds = ',@new_value,' WHERE DrawingID =',@key_id_drawing_data,';');
			PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		END IF;
	ELSEIF @key_stage >=2 AND @key_stage <=6 THEN
		#do_weld_had_any_ndt_for_pwht_req

		IF key_is_pwht_req=0 THEN
			IF @do_weld_had_pwht_req_before=1 THEN
				# decrease number of welds in ndt
				SET @sql_text = concat('SET @old_value = (SELECT nr_pwht_welds FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,');');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
				SET @new_value = cast((@old_value - 1) AS unsigned);
				SET @sql_text = concat('UPDATE projects.',@key_tablename_drawing_data,' SET nr_pwht_welds = ',@new_value,' WHERE DrawingID =',@key_id_drawing_data,';');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			END IF;
		ELSE
			IF @do_weld_had_pwht_req_before=0 THEN
				# increase number of welds in ndt
				SET @sql_text = concat('SET @old_value = (SELECT nr_pwht_welds FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,');');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
				SET @new_value = cast((@old_value + 1) AS unsigned);
				SET @sql_text = concat('UPDATE projects.',@key_tablename_drawing_data,' SET nr_pwht_welds = ',@new_value,' WHERE DrawingID =',@key_id_drawing_data,';');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			END IF;
		END IF;
	END IF;
    

	/*
	######################################################
	# in drawing data
	# change number of welds in ndt 
	IF @key_stage =1 THEN
		IF JSON_LENGTH(ndt_tests)!=0 THEN
			# increase number of welds in ndt
			SET @sql_text = concat('SET @old_value = (SELECT nr_of_welds_in_ndt FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,');');
			PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			SET @new_value = cast((@old_value + 1) AS unsigned);
			SET @sql_text = concat('UPDATE projects.',@key_tablename_drawing_data,' SET nr_of_welds_in_ndt = ',@new_value,' WHERE DrawingID =',@key_id_drawing_data,';');
			PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
		END IF;
	ELSEIF @key_stage >=2 AND @key_stage <=6 THEN
		#do_weld_had_any_ndt_req
		IF JSON_LENGTH(ndt_tests)=0 THEN
			IF @do_weld_had_any_ndt_req=1 THEN
				# decrease number of welds in ndt
				SET @sql_text = concat('SET @old_value = (SELECT nr_of_welds_in_ndt FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,');');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
				SET @new_value = cast((@old_value - 1) AS unsigned);
				SET @sql_text = concat('UPDATE projects.',@key_tablename_drawing_data,' SET nr_of_welds_in_ndt = ',@new_value,' WHERE DrawingID =',@key_id_drawing_data,';');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			END IF;
		ELSE
			IF @do_weld_had_any_ndt_req=0 THEN
				# increase number of welds in ndt
				SET @sql_text = concat('SET @old_value = (SELECT nr_of_welds_in_ndt FROM projects.',@key_tablename_drawing_data,' WHERE DrawingID=',@key_id_drawing_data,');');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
				SET @new_value = cast((@old_value + 1) AS unsigned);
				SET @sql_text = concat('UPDATE projects.',@key_tablename_drawing_data,' SET nr_of_welds_in_ndt = ',@new_value,' WHERE DrawingID =',@key_id_drawing_data,';');
				PREPARE stmt FROM @sql_text;EXECUTE stmt;DEALLOCATE PREPARE stmt;
			END IF;
		END IF;
	END IF;
    */
    
    
END IF;


COMMIT;
END