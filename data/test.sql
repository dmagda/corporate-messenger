CREATE SEQUENCE message_id_seq CACHE 100;

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

CREATE TABLE Message(
    id integer NOT NULL DEFAULT nextval('message_id_seq'),
    channel_id integer,
    sender_id integer NOT NULL,
    message text NOT NULL,
    sent_at TIMESTAMP(0) DEFAULT NOW(),
    country text NOT NULL,
    PRIMARY KEY(id, country)
) PARTITION BY LIST(country);

CREATE TABLE Message_Americas
    PARTITION OF Message
    FOR VALUES IN ('USA', 'Canada', 'Mexico') TABLESPACE americas_tablespace;

CREATE TABLE Message_Europe
    PARTITION OF Message
    FOR VALUES IN ('United Kingdom', 'France', 'Germany', 'Spain') TABLESPACE europe_tablespace;

CREATE TABLE Message_Asia
    PARTITION OF Message
    FOR VALUES IN ('India', 'China', 'Japan', 'Australia') TABLESPACE asia_tablespace;  

insert into message VALUES(1,1,1,'bla bla bla', now(), 'USA');
