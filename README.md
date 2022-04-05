# Geo-Distributed Corporate Messenger With YugabyteDB

Steps to reproduce the issue:

1. Open the project in Gitpod that will bootstrap the environment:

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/dmagda/corporate-messenger/tree/data-load-issue-reproducer)


2. Attempt to insert the messages with the country column `USA`:
    ```sql
    INSERT INTO Message (channel_id, sender_id, message, country) VALUES
    (1, 5, 'Dear Kafka community, what is the best way to learn Kafka?', 'USA');
    ```