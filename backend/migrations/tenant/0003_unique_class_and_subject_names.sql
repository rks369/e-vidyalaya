UPDATE class_list c
SET class_name = left(c.class_name, 50) || ' (' || c.class_id || ')'
WHERE EXISTS (
    SELECT 1 FROM class_list o
    WHERE lower(o.class_name) = lower(c.class_name) AND o.class_id < c.class_id
);

UPDATE subject_list s
SET subject_name = left(s.subject_name, 50) || ' (' || s.subject_id || ')'
WHERE EXISTS (
    SELECT 1 FROM subject_list o
    WHERE o.class_id = s.class_id
      AND lower(o.subject_name) = lower(s.subject_name)
      AND o.subject_id < s.subject_id
);

CREATE UNIQUE INDEX uq_class_name ON class_list (lower(class_name));
CREATE UNIQUE INDEX uq_subject_name_per_class ON subject_list (class_id, lower(subject_name));
