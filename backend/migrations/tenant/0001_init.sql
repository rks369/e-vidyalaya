CREATE FUNCTION set_modify_ts() RETURNS trigger AS $$
BEGIN
    NEW.modify_ts = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE designation_type AS ENUM ('DIRECTOR', 'TEACHER', 'STUDENT');

CREATE TABLE users (
    id serial PRIMARY KEY,
    name varchar(128) NOT NULL,
    email varchar(128) NOT NULL,
    phone varchar(15) NOT NULL,
    password varchar(255) NOT NULL,
    username varchar(128) NOT NULL UNIQUE,
    designation designation_type NOT NULL,
    profile_picture varchar(512) NOT NULL DEFAULT '',
    current_class integer NOT NULL DEFAULT -1,
    reset_code varchar(255),
    reset_expires timestamptz,
    reset_attempts integer NOT NULL DEFAULT 0,
    creation_ts timestamptz NOT NULL DEFAULT now(),
    modify_ts timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_users_designation ON users (designation);
CREATE TRIGGER users_set_modify_ts
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_modify_ts();

CREATE TABLE class_list (
    class_id serial PRIMARY KEY,
    class_name varchar(64) NOT NULL,
    class_teacher_id integer NOT NULL REFERENCES users (id),
    creation_ts timestamptz NOT NULL DEFAULT now(),
    modify_ts timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_class_teacher ON class_list (class_teacher_id);
CREATE TRIGGER class_list_set_modify_ts
    BEFORE UPDATE ON class_list
    FOR EACH ROW EXECUTE FUNCTION set_modify_ts();

CREATE TABLE subject_list (
    subject_id serial PRIMARY KEY,
    subject_name varchar(64) NOT NULL,
    class_id integer NOT NULL REFERENCES class_list (class_id),
    subject_teacher_id integer NOT NULL REFERENCES users (id),
    creation_ts timestamptz NOT NULL DEFAULT now(),
    modify_ts timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_subject_class ON subject_list (class_id);
CREATE INDEX idx_subject_teacher ON subject_list (subject_teacher_id);
CREATE TRIGGER subject_list_set_modify_ts
    BEFORE UPDATE ON subject_list
    FOR EACH ROW EXECUTE FUNCTION set_modify_ts();

CREATE TABLE notes_list (
    note_id serial PRIMARY KEY,
    subject_id integer NOT NULL REFERENCES subject_list (subject_id),
    note_title varchar(255) NOT NULL,
    note_ext varchar(16) NOT NULL,
    note_url varchar(2048) NOT NULL,
    creation_ts timestamptz NOT NULL DEFAULT now(),
    modify_ts timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_notes_subject ON notes_list (subject_id);
CREATE TRIGGER notes_list_set_modify_ts
    BEFORE UPDATE ON notes_list
    FOR EACH ROW EXECUTE FUNCTION set_modify_ts();

CREATE TABLE messages (
    id serial PRIMARY KEY,
    chat_key varchar(64) NOT NULL,
    sender_id integer NOT NULL REFERENCES users (id),
    sender_name varchar(128) NOT NULL,
    body text NOT NULL,
    creation_ts timestamptz NOT NULL DEFAULT now(),
    modify_ts timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_messages_chat ON messages (chat_key, id);
CREATE INDEX idx_messages_sender ON messages (sender_id);
CREATE TRIGGER messages_set_modify_ts
    BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION set_modify_ts();
