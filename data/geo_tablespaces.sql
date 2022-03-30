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