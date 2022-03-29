CREATE SEQUENCE profile_id_seq CACHE 100;

CREATE TABLE Profile(
    id integer NOT NULL DEFAULT nextval('profile_id_seq'),
    full_name text NOT NULL,
    email text NOT NULL,
    phone text,
    country text NOT NULL,
    main_profile_id integer NOT NULL,
    PRIMARY KEY(id, country)
) PARTITION BY LIST(country);

CREATE TABLESPACE americas_tablespace WITH (
  replica_placement='{"num_replicas": 1, "placement_blocks":
  [{"cloud":"aws","region":"us-west-1","zone":"us-west-1a","min_num_replicas":1}]}'
);

CREATE TABLESPACE europe_tablespace WITH (
  replica_placement='{"num_replicas": 1, "placement_blocks":
  [{"cloud":"aws","region":"eu-west-1","zone":"eu-west-1a","min_num_replicas":1}]}'
);

CREATE TABLESPACE asia_tablespace WITH (
  replica_placement='{"num_replicas": 1, "placement_blocks":
  [{"cloud":"aws","region":"ap-south-1","zone":"ap-south-1a","min_num_replicas":1}]}'
);

CREATE TABLE Profile_Americas
    PARTITION OF Profile
    FOR VALUES IN ('USA', 'Canada', 'Mexico') TABLESPACE americas_tablespace;

CREATE TABLE Profile_Europe
    PARTITION OF Profile
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE Profile_Asia
    PARTITION OF Profile
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;  

INSERT INTO Profile VALUES
(1, 'Mark Smith', 'msmith@apache.org', '6502304532', 'USA', 1),
(2, 'Mark Smith', 'msmith@shopify.com', '6502304532', 'Canada', 1),
(3, 'Jessica Brown', 'jbrown@shopify.com', '453234542', 'Canada', 3),
(4, 'Jonas Fischer', 'jfischer@sap.com', '2123452345', 'Germany', 4),
(5, 'Jonas Fischer', 'jonas_fischer@gmail.com', '2123452345', 'Germany', 4),
(6, 'Ah Lam', 'ahlam@tiktok.com', '3212343212', 'China', 6),
(7, 'Shoi-ming Li', 'shoimingli@tiktok.com', '324223453', 'China', 7),
(8, 'Shoi-ming Li', 'shoimingli@apache.org', '324223453', 'USA', 7),
(9, 'Venkat Sharma', 'vsharma@techmahindra.com', '748234323', 'India', 9),
(10, 'Prachi Garg', 'pgarg@techmahindra.com', '3823427434', 'India', 10);

ALTER SEQUENCE profile_id_seq START WITH 11;

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
    FOR VALUES IN ('USA', 'Canada', 'Mexico') TABLESPACE americas_tablespace;

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

