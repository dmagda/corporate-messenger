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
  replica_placement='{"num_replicas": 3, "placement_blocks":
  [{"cloud":"aws","region":"ap-south-1","zone":"ap-south-1a","min_num_replicas":1},
   {"cloud":"aws","region":"ap-south-1","zone":"ap-south-1b","min_num_replicas":1},
   {"cloud":"aws","region":"ap-south-1","zone":"ap-south-1c","min_num_replicas":1} 
  ]}'
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