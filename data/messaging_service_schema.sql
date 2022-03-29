CREATE SEQUENCE workspace_id_seq CACHE 100;
CREATE SEQUENCE channel_id_seq CACHE 100;
CREATE SEQUENCE message_id_seq CACHE 100;

CREATE TABLE Workspace(
    id integer NOT NULL DEFAULT nextval('workspace_id_seq'),
    name text NOT NULL,
    url text NOT NULL,
    country text NOT NULL,
    PRIMARY KEY(id, country)
) PARTITION BY LIST(country);

CREATE TABLE WorkspaceProfile(
    workspace_id integer NOT NULL,
    profile_id integer NOT NULL,
    workspace_country text NOT NULL,
    PRIMARY KEY(workspace_id, profile_id, workspace_country)
) PARTITION BY LIST(workspace_country);

CREATE TABLE Channel(
    id integer NOT NULL DEFAULT nextval('channel_id_seq'),
    name text NOT NULL,
    workspace_id integer NOT NULL,
    is_direct BOOLEAN DEFAULT false,
    direct_profile1_id integer,
    direct_profile2_id integer,
    country text NOT NULL,
    PRIMARY KEY(id, country)
) PARTITION BY LIST(country);


CREATE TABLE Message(
    id integer NOT NULL DEFAULT nextval('message_id_seq'),
    channel_id integer,
    sender_id integer NOT NULL,
    message text NOT NULL,
    sent_at TIMESTAMP(0) DEFAULT NOW(),
    country text NOT NULL,
    PRIMARY KEY(id, country)
) PARTITION BY LIST(country);


--Note, the tablespaces are created in the profile_service_schema.sql

CREATE TABLE Workspace_Americas
    PARTITION OF Workspace
    FOR VALUES IN ('USA', 'Canada', 'Mexico') TABLESPACE americas_tablespace;

CREATE TABLE Workspace_Europe
    PARTITION OF Workspace
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE Workspace_Asia
    PARTITION OF Workspace
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;



CREATE TABLE WorkspaceProfile_Americas
    PARTITION OF WorkspaceProfile
    FOR VALUES IN ('USA', 'Canada', 'Mexico') TABLESPACE americas_tablespace;

CREATE TABLE WorkspaceProfile_Europe
    PARTITION OF WorkspaceProfile
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE WorkspaceProfile_Asia
    PARTITION OF WorkspaceProfile
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;



CREATE TABLE Channel_Americas
    PARTITION OF Channel
    FOR VALUES IN ('USA', 'Canada', 'Mexico') TABLESPACE americas_tablespace;

CREATE TABLE Channel_Europe
    PARTITION OF Channel
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE Channel_Asia
    PARTITION OF Channel
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;


CREATE TABLE Message_Americas
    PARTITION OF Message
    FOR VALUES IN ('Canada', 'USA', 'Mexico') TABLESPACE americas_tablespace;

CREATE TABLE Message_Europe
    PARTITION OF Message
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE Message_Asia
    PARTITION OF Message
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;  


    -- Load sample data

INSERT INTO Workspace VALUES 
(1, 'Apache Software Foundation', 'https://apache.org', 'USA'),
(2, 'Shopify', 'https://shopify.com', 'Canada'),
(3, 'SAP', 'https://sap.com/', 'Germany'),
(4, 'TikTok', 'https://tiktok.com', 'China'),
(5, 'Tech Mahindra', 'https://techmahindra.com', 'India');

ALTER SEQUENCE workspace_id_seq RESTART WITH 6;

INSERT INTO Channel VALUES
(1, 'apache_kafka_support', 1, false, NULL, NULL, 'USA'),
(2, 'apache_ignite_security', 1, false, NULL, NULL, 'USA'),
(3, 'roadmap_suggestions', 2, false, NULL, NULL, 'Canada'),
(4, 'sap_hana_dev', 3, false, NULL, NULL, 'Germany'),
(5, 'vip_users_recognition', 4, false, NULL, NULL, 'China'),
(6, 'viral_videos_ideas', 4, false, NULL, NULL, 'China'),
(7, 'random', 5, false, NULL, NULL, 'India'),
(8, 'on_call_customer_support', 5, false, NULL, NULL, 'India');

ALTER SEQUENCE channel_id_seq RESTART WITH 9;

INSERT INTO WorkspaceProfile VALUES
(1, 1, 'USA'), (1, 5, 'USA'), -- ASF
(1, 8, 'USA'), (1, 9, 'USA'), -- ASF
(2, 2, 'Canada'), (2, 3, 'Canada'), -- Shopify
(3, 4, 'Germany'), -- SAP
(4, 6, 'China'), (4, 7, 'China'), -- TikTok
(5, 9, 'India'), (5, 10, 'India'); -- Tech Mahindra

