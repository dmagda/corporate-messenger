# Geo-distributed Corporate Messenger With YugabyteDB

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/dmagda/corporate-messenger)

Building a Slack-like corporate messenger with YugabyteDB. The application comprises the following microservices:

<table>
    <thead>
        <tr>
            <th>Microservice</th>
            <th>Description</th>
            <th>Service Tier</th>
            <th>Data Distribution</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><b>Profile</b></td>
            <td>Stores and manages user profiles.</td>
            <td>Tier 1</td>
            <td>Row-level geo-distribution</td>
        </tr>
        <tr>
            <td><b>Messaging</b</td>
            <td>
                Enables key messaging capabilities. 
                Manages workspaces, channels, messages.
            </td>
            <td>Tier 1</td>
            <td>Row-level geo-distribution</td>
        </tr>
        <tr>
            <td><b>Reminders</b></td>
            <td>
                Creates reminders bound to specific messages.
                For instance, "remind me about this message tomorrow at 9am."
            </td>
            <td>Tier 2</td>
            <td>
                Primary region for writes and read-replicas for 
                fast reads from other supported regions.
            </td>
        </tr>
        <tr>
            <td><b>Status</b></td>
            <td>
                Allows users change their profiles status to 'busy', 
                'on vacation', 'available' and more.
            </td>
            <td>Tier 3</td>
            <td>
                Standalone clusters in every supported region with async replication.
                A user's status is stored in his home region and replicated 
                asynchronously to other regions.
            </td>
        </tr>
    </tbody>
</table>

## Query Geo-Distributed Cluster

The Profile and Messaging services use the same geo-distributed cluster comprised of three nodes. Each node is placed in a different cloud region. See the `Geo Distributed Cluster` task in the `.gitpod.yml` file for details.

Navigate to the `Cluster#1 Shell: ysqlsh` terminal tab that is opened automatically and execute queries from the following sections.

### Load Sample Data

Create the schema for the Profile and Messaging microservice as well as cloud-region specific tablespaces:
```sql
\i /workspace/corporate-messenger/data/profile_service_schema.sql
\i /workspace/corporate-messenger/data/messaging_service_schema.sql
```

### Task 1: Geo-Based Data Distribution

```sql
SELECT * FROM Workspace_Americas;
SELECT * FROM Workspace_Europe;
SELECT * FROM Workspace_Asia;
SELECT * FROM Workspace; 
```

### Task 2: Get Profiles from Specific Region

```sql
SELECT w.name, p.full_name, p.email FROM Workspace_Asia as w
JOIN WorkspaceProfile_Asia as wp ON w.id = wp.workspace_id
JOIN Profile_Asia as p ON p.id = wp.profile_id; 
```

### Taks 3: Send Messages Within Regional Boundaries

* Exchnage two messages in the `on_call_customer_support` channel of the `TechMahindra` workspace. Note, that the messages are added through the `Message` table:
    ```sql
    INSERT INTO Message (channel_id, sender_id, message, country) VALUES
    (8, 9, 'Prachi, the customer has a production outage. Could you join the line?', 'India');

    INSERT INTO Message (channel_id, sender_id, message, country) VALUES
    (8, 10, 'Sure, give me a minute!', 'India');
    ```

* Confirm the messages are stored in the `Message_Asia` table:
    ```sql
    SELECT c.name, p.full_name, m.message FROM Message_Asia as m
    JOIN Channel_Asia as c ON m.channel_id = c.id
    JOIN Profile_Asia as p ON m.sender_id = p.id
    WHERE c.id = 8;
    ```

* Double check the messages' replica are not stored in other regional tables such as `Message_Americas`:
    ```sql
    SELECT c.name, p.full_name, m.message FROM Message_Americas as m
    JOIN Channel_Americas as c ON m.channel_id = c.id
    JOIN Profile_Americas as p ON m.sender_id = p.id
    WHERE c.id = 8;
    ```

### Task 4: Cross-Regional Queries

It can be the case that a profile is stored in one geo-region but still be able to join a workspace and send messages from another region.

Query profiles belonging to the Apache Software Foundation (ASF) workspace:

* Get all the ASF profiles using a search within the `Americas` region:
    ```sql
    SELECT w.name, wp.profile_id, p.full_name, p.email FROM Workspace_Americas as w
    JOIN WorkspaceProfile_Americas as wp ON w.id = wp.workspace_id
    LEFT JOIN Profile_Americas as p ON p.id = wp.profile_id
    WHERE w.id = 1; 
    ```
* The `full_name` and `email` columns is empty for two profiles because the profiles are stored in a region differen from `Profile_Americas`:
    ```sql
                name            | profile_id |  full_name   |         email         
    ----------------------------+------------+--------------+-----------------------
    Apache Software Foundation |          1 | Mark Smith   | msmith@apache.org
    Apache Software Foundation |          8 | Shoi-ming Li | shoimingli@apache.org
    Apache Software Foundation |          5 |              | 
    Apache Software Foundation |          9 |              | 
    ```
* To get missing profile's data we need to do a cross-region search by doing a join with the `Profile` table:
    ```sql
    SELECT w.name, wp.profile_id, p.full_name, p.email FROM Workspace_Americas as w
    JOIN WorkspaceProfile_Americas as wp ON w.id = wp.workspace_id
    LEFT JOIN Profile as p ON p.id = wp.profile_id
    WHERE w.id = 1; 
    ```
* The output is as follows:
    ```sql
                name            | profile_id |   full_name   |          email           
    ----------------------------+------------+---------------+--------------------------
    Apache Software Foundation |          9 | Venkat Sharma | vsharma@techmahindra.com
    Apache Software Foundation |          1 | Mark Smith    | msmith@apache.org
    Apache Software Foundation |          8 | Shoi-ming Li  | shoimingli@apache.org
    Apache Software Foundation |          5 | Jonas Fischer | jonas_fischer@gmail.com
    ```

Send a few messages to the 'apache_kafka_support' channel and read them back:

* Insert the messages:
    ```sql
    INSERT INTO Message (channel_id, sender_id, message, country) VALUES
    (1, 5, 'Dear Kafka community, what is the best way to learn Kafka?', 'USA');

    INSERT INTO Message (channel_id, sender_id, message, country) VALUES
    (1, 8, 'Hi, Jonas! Have you checked Kafka 101 course? The best way to get started.', 'USA');

    INSERT INTO Message (channel_id, sender_id, message, country) VALUES
    (1, 1, '+1, start with Kafka 101', 'USA');
    ```

* Read the messages back:
    ```sql
    SELECT * FROM Message_Americas WHERE channel_id = 1 ORDER BY sent_at ASC;

    SELECT c.name, c.country as channel_country, p.full_name, p.country as profile_country, m.message, m.sent_at
    FROM Message_Americas as m
    JOIN Channel_Americas as c ON m.channel_id = c.id
    JOIN Profile as p ON m.sender_id = p.id -- Global search across all Profiles
    WHERE m.channel_id = 1;
    ```

## Query Cluster With Read Replicas

Check the cluster config:

```shell
curl -s http://127.0.0.10:7000/cluster-config
```