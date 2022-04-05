# Geo-Distributed Corporate Messenger With YugabyteDB

Steps to reproduce the issue:

1. Open the project in Gitpod that will bootstrap the environment:

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/dmagda/corporate-messenger/tree/data-load-issue-reproducer)


2. Attempt to insert the messages with the country column `USA`:
    ```sql
    INSERT INTO Message (channel_id, sender_id, message, country) VALUES
    (1, 5, 'Dear Kafka community, what is the best way to learn Kafka?', 'USA');
    ```

    And you should get the error:

    ```sql
    ERROR:  no partition of relation "message" found for row
    DETAIL:  Partition key of the failing row contains (country) = (USA).
    ```

3. Interestingly, if you swap `USA` with `Canada` then the message will be added with no issues:
    ```sql
    INSERT INTO Message (channel_id, sender_id, message, country) VALUES
    (1, 5, 'Dear Kafka community, what is the best way to learn Kafka?', 'Canada');
    ```

The issue is somehow related to the data loading via the `ysqlsh -f` command. If you remove the following lines from the `.gitpod.yml` (and restart a gitpod project):

```shell
ysqlsh -f /workspace/corporate-messenger/data/geo_tablespaces.sql
ysqlsh -f /workspace/corporate-messenger/data/profile_service_schema.sql
ysqlsh -f /workspace/corporate-messenger/data/messaging_service_schema.sql
```

and load the scripts with the `\i` instead then you will add the `USA` record with no issues. 