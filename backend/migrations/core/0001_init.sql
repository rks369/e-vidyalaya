CREATE FUNCTION set_modify_ts() RETURNS trigger AS $$
BEGIN
    NEW.modify_ts = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION protect_institute_code() RETURNS trigger AS $$
BEGIN
    IF NEW.code <> OLD.code THEN
        RAISE EXCEPTION 'institute code cannot be changed';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE institute (
    id serial PRIMARY KEY,
    code varchar(30) NOT NULL UNIQUE CHECK (code ~ '^[A-Z0-9]{2,30}$'),
    schema_name varchar(63) GENERATED ALWAYS AS ('inst_' || id::text || '_' || lower(code)) STORED,
    name varchar(128) NOT NULL,
    domain varchar(30) NOT NULL UNIQUE,
    address varchar(255) NOT NULL,
    mobile varchar(15) NOT NULL,
    email varchar(128) NOT NULL,
    logo varchar(512) NOT NULL DEFAULT '',
    creation_ts timestamptz NOT NULL DEFAULT now(),
    modify_ts timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER institute_set_modify_ts
    BEFORE UPDATE ON institute
    FOR EACH ROW EXECUTE FUNCTION set_modify_ts();

CREATE TRIGGER institute_protect_code
    BEFORE UPDATE ON institute
    FOR EACH ROW EXECUTE FUNCTION protect_institute_code();

CREATE TABLE admin (
    id serial PRIMARY KEY,
    username varchar(64) NOT NULL UNIQUE CHECK (username ~ '^[a-z0-9._-]{3,64}$'),
    email varchar(128) NOT NULL UNIQUE CHECK (email = lower(email)),
    password varchar(255) NOT NULL,
    token_version integer NOT NULL DEFAULT 0,
    reset_code varchar(255),
    reset_expires timestamptz,
    reset_attempts integer NOT NULL DEFAULT 0,
    creation_ts timestamptz NOT NULL DEFAULT now(),
    modify_ts timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER admin_set_modify_ts
    BEFORE UPDATE ON admin
    FOR EACH ROW EXECUTE FUNCTION set_modify_ts();
