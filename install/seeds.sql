INSERT INTO users (id, username, verified, role, email)
		VALUES (100, 'jadga', true, 'admin', 'contact@snap.berkeley.edu')
	ON CONFLICT DO NOTHING;

DELETE FROM collections;

INSERT INTO collections (id, name, creator_id, created_at, updated_at, description, published, published_at, shared, shared_at, thumbnail_id, editor_ids)
VALUES
		(1, 'Flagged', 519956, NOW(), NOW(), '', 'f', NULL, 'f', NULL, NULL, '{}'),
		(2, 'Grade 5', 100, NOW(), NOW(), 'Puzzles for grade 5', 't', NOW(), 't', NOW(), NULL, '{}'),
		(3, 'Grade 6', 100, NOW(), NOW(), 'Puzzles for grade 6', 't', NOW(), 't', NOW(), NULL, '{}')
	ON CONFLICT DO NOTHING;

ALTER view active_projects owner to cloud
ALTER view active_users owner to cloud
ALTER view count_recent_projects owner to cloud
ALTER view deleted_projects owner to cloud
ALTER view deleted_users owner to cloud
ALTER view pg_stat_statements owner to cloud
ALTER view pg_stat_statements_info owner to cloud
ALTER view recent_projects_2_days owner to cloud

