CREATE OR REPLACE FUNCTION create_user_if_not_exists(username NAME, password TEXT, database NAME) RETURNS TEXT AS
$$
BEGIN
    IF NOT EXISTS (SELECT * FROM pg_catalog.pg_user WHERE usename = username) THEN
        EXECUTE format('CREATE USER %I PASSWORD ''%s''', username, password);
        EXECUTE format('GRANT ALL PRIVILEGES ON DATABASE %I TO %I', database, username);
        RETURN 'CREATE USER';
    ELSE
        RETURN format('ROLE ''%I'' ALREADY EXISTS', username);
    END IF;
END;
$$
LANGUAGE plpgsql;

SELECT create_user_if_not_exists(:'grafana_usr', :'grafana_psw', 'grafana');
