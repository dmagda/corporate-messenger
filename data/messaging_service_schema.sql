CREATE SEQUENCE profile_id_seq CACHE 100 START WITH 10;
CREATE SEQUENCE workspace_id_seq CACHE 100 START WITH 10;
CREATE SEQUENCE channel_id_seq CACHE 100 START WITH 10;
CREATE SEQUENCE message_id_seq CACHE 100 START WITH 15;

CREATE TABLE Profile(
    id integer NOT NULL DEFAULT nextval('profile_id_seq'),
    full_name text NOT NULL,
    email text NOT NULL,
    phone text,
    country text NOT NULL,
    PRIMARY KEY(id, email, country)
) PARTITION BY LIST(country);

CREATE TABLE Workspace(
    id integer NOT NULL DEFAULT nextval('workspace_id_seq'),
    name text NOT NULL,
    url text NOT NULL,
    country text NOT NULL,
    PRIMARY KEY(id, country)
) PARTITION BY LIST(country);

CREATE TABLE WorkspaceProfile(
    workspace_id integer NOT NULL,
    profile_email text NOT NULL,
    country text NOT NULL,
    PRIMARY KEY(workspace_id, profile_email, country)
) PARTITION BY LIST(country);

CREATE TABLE Channel(
    id integer NOT NULL DEFAULT nextval('channel_id_seq'),
    name text NOT NULL,
    workspace_id integer NOT NULL,
    is_direct BOOLEAN DEFAULT false,
    direct_profile1_email text,
    direct_profile2_email text,
    country text NOT NULL,
    PRIMARY KEY(id, country)
) PARTITION BY LIST(country);


CREATE TABLE Message(
    id integer NOT NULL DEFAULT nextval('message_id_seq'),
    channel_id integer,
    sender_email text,
    message text NOT NULL,
    sent_at TIMESTAMP(0) DEFAULT NOW(),
    country text NOT NULL,
    PRIMARY KEY(id, country)
) PARTITION BY LIST(country);


CREATE TABLESPACE americas_tablespace WITH (
  replica_placement='{"num_replicas": 1, "placement_blocks":
  [{"cloud":"gcp","region":"us-central1","zone":"us-central1-a","min_num_replicas":1}]}'
);

CREATE TABLESPACE europe_tablespace WITH (
  replica_placement='{"num_replicas": 1, "placement_blocks":
  [{"cloud":"gcp","region":"europe-west3","zone":"europe-west3-a","min_num_replicas":1}]}'
);

CREATE TABLESPACE asia_tablespace WITH (
  replica_placement='{"num_replicas": 1, "placement_blocks":
  [{"cloud":"gcp","region":"asia-east1","zone":"asia-east1-a","min_num_replicas":1}]}'
);


CREATE TABLE Profile_Americas
    PARTITION OF Profile
    FOR VALUES IN ('USA', 'Canada', 'Mexico', 'Brazil') TABLESPACE americas_tablespace;

CREATE TABLE Profile_Europe
    PARTITION OF Profile
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE Profile_Asia
    PARTITION OF Profile
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;



CREATE TABLE Workspace_Americas
    PARTITION OF Workspace
    FOR VALUES IN ('USA', 'Canada', 'Mexico', 'Brazil') TABLESPACE americas_tablespace;

CREATE TABLE Workspace_Europe
    PARTITION OF Workspace
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE Workspace_Asia
    PARTITION OF Workspace
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;



CREATE TABLE WorkspaceProfile_Americas
    PARTITION OF WorkspaceProfile
    FOR VALUES IN ('USA', 'Canada', 'Mexico', 'Brazil') TABLESPACE americas_tablespace;

CREATE TABLE WorkspaceProfile_Europe
    PARTITION OF WorkspaceProfile
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE WorkspaceProfile_Asia
    PARTITION OF WorkspaceProfile
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;



CREATE TABLE Channel_Americas
    PARTITION OF Channel
    FOR VALUES IN ('USA', 'Canada', 'Mexico', 'Brazil') TABLESPACE americas_tablespace;

CREATE TABLE Channel_Europe
    PARTITION OF Channel
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE Channel_Asia
    PARTITION OF Channel
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;



CREATE TABLE Message_Americas
    PARTITION OF Message
    FOR VALUES IN ('USA', 'Canada', 'Mexico', 'Brazil') TABLESPACE americas_tablespace;

CREATE TABLE Message_Europe
    PARTITION OF Message
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE Message_Asia
    PARTITION OF Message
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;  