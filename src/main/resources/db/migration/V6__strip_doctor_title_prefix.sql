-- Doctor names must be stored bare (no "Dr." prefix) — every template that
-- displays a doctor's name prepends its own "Dr. ", so a name that already
-- includes the honorific renders as "Dr. Dr. Jane Doe". Normalize any
-- existing rows written before this was enforced at the application layer.
UPDATE doctors
SET name = TRIM(REGEXP_REPLACE(name, '^([Dd][Rr]\\.?\\s+)+', ''))
WHERE name REGEXP '^[Dd][Rr]\\.?[ \\t]';
