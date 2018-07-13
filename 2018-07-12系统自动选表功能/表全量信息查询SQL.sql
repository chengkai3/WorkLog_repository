SELECT *, db.ds_label, dir.dir_node_label, muser.user_name AS member_user_name, strategy.strategy_time
FROM dacp_meta_tab tab
	LEFT JOIN dacp_meta_datasource db ON tab.ds_name = db.ds_name
	LEFT JOIN (
		SELECT x.mobj_id, t.dir_node_label
		FROM dacp_directory_metaobj x
			LEFT JOIN dacp_directory_node t
			ON x.dir_id = t.dir_id
				AND x.dir_node_id = t.dir_node_id
		WHERE x.dir_id = 'assetCatalog'
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
	ON strategy.tab_id = tab.tab_id;