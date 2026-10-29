UPDATE notes_list
SET note_url = regexp_replace(note_url, '^(https?://[^/]+)?/uploads/', '/assets/')
WHERE note_url ~ '^(https?://[^/]+)?/uploads/';
