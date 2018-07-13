SELECT tab.*, db.ds_label, dir.dir_node_label, muser.user_name AS member_user_name, strategy.strategy_time
FROM dacp_meta_tab tab
	LEFT JOIN dacp_meta_datasource db ON tab.ds_name = db.ds_name
	LEFT JOIN (
		SELECT x.mobj_id, t.dir_node_label
		FROM dacp_directory_metaobj x
			LEFT JOIN dacp_directory_node t
			ON x.dir_id = t.dir_id
				AND x.dir_node_id = t.dir_node_id
			LEFT JOIN dacp_directory_def d ON d.dir_id = x.dir_id
		WHERE d.dir_type = 'dataAsset'
	) dir
	ON dir.mobj_id = tab.tab_id
	LEFT JOIN dacp_meta_user muser ON muser.user_id = tab.create_user
	LEFT JOIN (
		SELECT MAX(strategy_time) AS strategy_time, tab_id
		FROM (
			SELECT tab_id, strategy_time
			FROM dacp_dge_data_storage_rule
			WHERE strategy_type = 0
		) m
		GROUP BY tab_id
	) strategy
	ON strategy.tab_id = tab.tab_id
WHERE tab.tab_id IN (
	SELECT DISTINCT tab.tab_id AS selectedTabs
	FROM dacp_meta_tab tab
	WHERE tab.tab_id NOT IN (
			SELECT mobj.mobj_id
			FROM dacp_directory_metaobj mobj
				LEFT JOIN dacp_directory_node node
				ON mobj.dir_id = node.dir_id
					AND mobj.dir_node_id = node.dir_node_id
				LEFT JOIN dacp_directory_def def ON def.dir_id = mobj.dir_id
			WHERE def.dir_type = 'dataAsset'
		)
		AND (EXISTS (
				SELECT 1
				FROM (
					SELECT field_name, field_label, tab_id
					FROM dacp_meta_tab_field
				) tabfield
				WHERE tabfield.tab_id = tab.tab_id
					AND (tabfield.field_name LIKE '%用%'
						OR tabfield.field_label LIKE '%用%')
			)
			AND EXISTS (
				SELECT 1
				FROM (
					SELECT field_name, field_label, tab_id
					FROM dacp_meta_tab_field
				) tabfield
				WHERE tabfield.tab_id = tab.tab_id
					AND (tabfield.field_name LIKE '%户%'
						OR tabfield.field_label LIKE '%户%')
			))
		OR (EXISTS (
				SELECT 1
				FROM (
					SELECT field_name, field_label, tab_id
					FROM dacp_meta_tab_field
				) tabfield
				WHERE tabfield.tab_id = tab.tab_id
					AND (tabfield.field_name LIKE '%用%'
						OR tabfield.field_label LIKE '%用%')
			)
			AND EXISTS (
				SELECT 1
				FROM (
					SELECT field_name, field_label, tab_id
					FROM dacp_meta_tab_field
				) tabfield
				WHERE tabfield.tab_id = tab.tab_id
					AND (tabfield.field_name LIKE '%户%'
						OR tabfield.field_label LIKE '%户%')
			))
)