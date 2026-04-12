-- One-time cleanup and integrity hardening for room_allocation.
-- Run on an existing DB once:
--   docker exec -i smart-hostel-mysql mysql -uroot -prootpass hostel_management < infra/sql/migrations/20260412_room_allocation_integrity.sql

START TRANSACTION;

-- Keep only the most recent Approved allocation per student.
DELETE ra
FROM room_allocation ra
JOIN room_allocation newer
  ON newer.student_id = ra.student_id
 AND newer.status = 'Approved'
 AND ra.status = 'Approved'
 AND newer.allocation_id > ra.allocation_id;

-- Keep only the most recent Pending allocation per student.
DELETE ra
FROM room_allocation ra
JOIN room_allocation newer
  ON newer.student_id = ra.student_id
 AND newer.status = 'Pending'
 AND ra.status = 'Pending'
 AND newer.allocation_id > ra.allocation_id;

COMMIT;

SET @has_idx_room_status := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'room_allocation'
    AND index_name = 'idx_ra_room_status'
);
SET @sql := IF(
  @has_idx_room_status = 0,
  'CREATE INDEX idx_ra_room_status ON room_allocation (room_id, status)',
  'SELECT ''idx_ra_room_status already exists'''
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_idx_student_status := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'room_allocation'
    AND index_name = 'idx_ra_student_status'
);
SET @sql := IF(
  @has_idx_student_status = 0,
  'CREATE INDEX idx_ra_student_status ON room_allocation (student_id, status)',
  'SELECT ''idx_ra_student_status already exists'''
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_uq_approved := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'room_allocation'
    AND index_name = 'uq_ra_single_approved_per_student'
);
SET @sql := IF(
  @has_uq_approved = 0,
  'CREATE UNIQUE INDEX uq_ra_single_approved_per_student ON room_allocation ((CASE WHEN status=''Approved'' THEN student_id ELSE NULL END))',
  'SELECT ''uq_ra_single_approved_per_student already exists'''
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_uq_pending := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'room_allocation'
    AND index_name = 'uq_ra_single_pending_per_student'
);
SET @sql := IF(
  @has_uq_pending = 0,
  'CREATE UNIQUE INDEX uq_ra_single_pending_per_student ON room_allocation ((CASE WHEN status=''Pending'' THEN student_id ELSE NULL END))',
  'SELECT ''uq_ra_single_pending_per_student already exists'''
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;