# Geo-Distributed Corporate Messenger With YugabyteDB

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/dmagda/corporate-messenger)

Multi-region deployments of distributed databases are becoming commonplace. There are several reasons for that - compliance with data residency requirements, faster performance (and lower latency) for users across various geographies, tolerance to region-level outages. However, there are multipled multi-region deployment options. With this project, we review several options while designing a distributed data layer for a Slack-like corporate messenger.   

<!-- vscode-markdown-toc -->

- [Geo-Distributed Corporate Messenger With YugabyteDB](#geo-distributed-corporate-messenger-with-yugabytedb)
  - [Application Architecture](#application-architecture)
  - [Profile and Messaging Service: Geo-Distributed Cluster](#profile-and-messaging-service-geo-distributed-cluster)
  - [Reminders Service: Read Replica Clusters](#reminders-service-read-replica-clusters)
  - [Status Service: xCluster Replication](#status-service-xcluster-replication)

<!-- vscode-markdown-toc-config
    numbering=false
    autoSave=true
    /vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## Application Architecture

The corporate messenger consists of the following microservices:

<table>
    <thead>
        <tr>
            <th>Microservice</th>
            <th>Description</th>
            <th>Service Tier</th>
            <th>Data Layer Deployment Option</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><b>Profile</b></td>
            <td>The microservice stores and manages user profiles.</td>
            <td>Tier 1</td>
            <td>
              The service uses a <a href="https://docs.yugabyte.com/latest/explore/multi-region-deployments/row-level-geo-partitioning/">geo-distributed cluster</a> across multiple regions. User data is stored in a region the user's country belongs to - for instance, data from France or Italy will
                be stored in and served from an European region.
            </td>
        </tr>
        <tr>
            <td><b>Messaging</b</td>
            <td>
                The key microservice that provides basic messaging capabilities. 
                The service manages workspaces, channels, messages.
            </td>
            <td>Tier 1</td>
            <td>
                The same cluster that is used for the Profile service.
            </td>
        </tr>
        <tr>
            <td><b>Reminders</b></td>
            <td>
                Users can creates reminders bound to specific messages.
                For instance, "remind me about this message tomorrow at 9am."
            </td>
            <td>Tier 2</td>
            <td>
                There is a primary cluster in one region and <a href="https://docs.yugabyte.com/latest/deploy/multi-dc/read-replica-clusters/#root">read replicas</a> in other regions.
                All writes are served by the primary cluster while reads can be served from the closest region (primary or read-replica).
            </td>
        </tr>
        <tr>
            <td><b>Status</b></td>
            <td>
                Users can change their statuses to such as 'Active', 
                'Busy', 'Vacationing' and others.
            </td>
            <td>Tier 3</td>
            <td>
                Standalone clusters in different regions with <a href="https://docs.yugabyte.com/latest/deploy/multi-dc/async-replication/">bi-directional async replication</a>.
                A user changes the status in a cluster with the closest region and then the status gets replicated to other clusters in remote regions.
            </td>
        </tr>
    </tbody>
</table>

The service tiers definition:
* `Tier 1` - a mission-critical service. Its downtime significantly impacts a company reputation and revenue. The service must be highly-available, strongly consistent and, in case of an outage, restored immediately.
* `Tier 2` - a service that provides an important function. Its downtime impacts customer experience and can increase a customer churn rate. The service has to be restored within 2 hours.
* `Tier 3` - a service that provides a useful capability. Its downtime impacts customer experience but insignificantly. The service has to be restored within 4 hours.

## Profile and Messaging Service: Geo-Distributed Cluster

The Profile and Messaging services use the same geo-distributed cluster comprised of multiple nodes. Each node is placed in a different cloud region - America, Europe and Asia/Pacific (see the `Deployment#1 (Geo-Distributed)` section in the `.gitpod.yml` file). See the `Deployment#1 (Geo-Distributed)` task in the `.gitpod.yml` file.

In a terminal, execute the command below to see the nodes placement across the regions:
```shell
curl -s http://127.0.0.1:7000/cluster-config
```

Follow the steps below to experience the multi-region [geo-distributed](https://docs.yugabyte.com/latest/explore/multi-region-deployments/row-level-geo-partitioning/) deployment option.

### Step 1: Load Sample Data

Create the schema for the Profile and Messaging microservice as well as cloud region specific tablespaces:
```sql
ysqlsh -h 127.0.0.1
\i /workspace/corporate-messenger/data/geo_tablespaces.sql
\i /workspace/corporate-messenger/data/profile_service_schema.sql
\i /workspace/corporate-messenger/data/messaging_service_schema.sql
```

### Step 2: Geo-Based Data Distribution

```sql
SELECT * FROM Workspace_Americas;
SELECT * FROM Workspace_Europe;
SELECT * FROM Workspace_Asia;
SELECT * FROM Workspace; 
```

### Step 3: Get Profiles from Specific Region

```sql
SELECT w.name, p.full_name, p.email FROM Workspace_Asia as w
JOIN WorkspaceProfile_Asia as wp ON w.id = wp.workspace_id
JOIN Profile_Asia as p ON p.id = wp.profile_id; 
```

### Step 4: Send Messages Within Regional Boundaries

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

### Step 5: Cross-Regional Queries

It can be the case that a profile is stored in one cloud region but still be able to join a workspace and send messages from another region.

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

## Reminders Service: Read Replica Clusters

The Reminders service uses a primary cluster deployed in one region and several read replica clusters in other regions (see the `Deployment#2 (Read Replica)` section in the `.gitpod.yml` file). Whenever a user requests to create or update a reminder, the service goes to the primary cluster that serves all the write regardless of the user's location. But reads can be served from a read replica region that is closes to the user:

* The primary cluster is deployed in the US region - `us-west-1`.
* The read replica nodes are located in Europe (`eu-west-1`) and Asia/Pacific (`ap-south-1`).

In a terminal, execute the command below to see the nodes placement across the regions:
```shell
curl -s http://127.0.0.4:7000/cluster-config
```

Next, follow the steps below to test the read replica type deployment:

### Load Schema

* Connect to the primary cluster `127.0.0.4` and load the service schema:
    ```shell
    ysqlsh -h 127.0.0.4
    \i /workspace/corporate-messenger/data/reminders_service_schema.sql 
    \d
    \q
    ```

* Confirm the schema was replicate to the European read replica:
    ```shell
    ysqlsh -h 127.0.0.5
    \d
    \q
    ```
* And to to the Asia/Pacific read replica:
    ```shell
    ysqlsh -h 127.0.0.6
    \d
    \q
    ```

### Add a Reminder

* Create a new reminder on the primary cluster (`127.0.0.4`):
    ```sql
    ysqlsh -h 127.0.0.4

    INSERT INTO Reminder (profile_id, message_id, notify_at)
    VALUES (5, 1, now() + interval '1 day');

    SELECT * FROM Reminder;

    \q
    ```
* Confirm the reminder was replicated to the European read replica:
    ```sql
    ysqlsh -h 127.0.0.5
    SELECT * FROM Reminder;
    \q
    ```
* And to the Asia/Pacific read replica:
    ```sql
    ysqlsh -h 127.0.0.6
    SELECT * FROM Reminder;
    \q
    ```

## Status Service: xCluster Replication

The Status service uses two separate clusters with each deployed in a unique cloud region (see the `Deployment#3 (xCluster Replication)` section in the `.gitpod.yml` file):

* The first single-node cluster with node `127.0.0.7` is located in the USA region - `us-west-1`
* The second single-node cluster with node `127.0.0.8` is in Europe - `eu-west-1`
* There is a [bi-directional asynchronous replication](https://docs.yugabyte.com/latest/deploy/multi-dc/async-replication/) between the clusters.

In a terminal, execute the command below to see the clusters' configuration:
```shell
curl -s http://127.0.0.7:7000/cluster-config

curl -s http://127.0.0.7:7000/cluster-config
```

Follow the steps below to finish the replication set up and to test the replication.

### Create Schema

1. Open a terminal window and load the Status service schema to the first single-node cluster:
    ```shell
    ysqlsh -h 127.0.0.7
    \i /workspace/corporate-messenger/data/status_service_schema.sql
    \q
    ```
2. Load the service schema to the second single-node cluster:
    ```shell
    ysqlsh -h 127.0.0.8
    \i /workspace/corporate-messenger/data/status_service_schema.sql
    \q
    ```

### Set Up Bi-directional Replication Between Clusters

1. Find the Status table's ID (the ID will be the same for both clusters):
    ```shell
    yb-admin -master_addresses 127.0.0.7:7100 list_tables include_table_id | grep status
    ```

2. Find the Universe UUID for the first cluster with node `127.0.0.7`:
    * Open the `Deployment#3 (xCluster replication)` terminal tab
    * Find the `Universe UUID` value in the `yugabyted` status table for node `127.0.0.7` 

3. Set up the replication from the first cluster to the second/target cluster with node `127.0.0.8`:
    ```shell
    yb-admin -master_addresses <target_universe_master_addesses> \
        setup_universe_replication <source_universe_uuid> \
        <source_universe_master_addresses> \
        <status_table_id>
    ```

    As an example, a final command can look as follows:

    ```shell
    yb-admin -master_addresses 127.0.0.8:7100 \
        setup_universe_replication a65775d0-4e56-4a20-9dbd-88ecf52022b3 \
        127.0.0.7:7100 \
        000033e100003000800000000000400b
    ```

4. Find the Universe UUID for the second cluster with node `127.0.0.8`:
    * Open the `Deployment#3 (xCluster replication)` terminal tab
    * Find the `Universe UUID` value in the `yugabyted` status table for node `127.0.0.8` 

5. Set up the replication from the second cluster to the first/target cluster with node `127.0.0.7`:
    The final command might look as follows:

    ```shell
    yb-admin -master_addresses 127.0.0.7:7100 \
        setup_universe_replication f4c36279-1575-400f-834e-5ad1b465caea   \
        127.0.0.8:7100 \
        000033e100003000800000000000400b
    ```
6. Congrats! You've set up a bi-directional replication between clusters.

## Test the Status Service With Replication

1. Connect to the first cluster and confirm the Status table is empty:
```shell
ysqlsh -h 127.0.0.7
SELECT * FROM Status;
```

2. In another terminal window, connect to the second cluster and confirm the same:
```shell
ysqlsh -h 127.0.0.8
SELECT * FROM Status;
```

3. Add a new Status to the second cluster:
```sql
INSERT INTO Status (profile_id, status) 
VALUES (3, 'Busy');
```

4. Confirm the status was added:
```sql
SELECT * FROM Status;

 profile_id | status |       set_at        
------------+--------+---------------------
          3 | Busy   | 2022-03-30 15:10:26
(1 row)
```

5. Go to the terminal of the first cluster and confirm the record was replicated:
```sql
SELECT * FROM Status;

 profile_id | status |       set_at        
------------+--------+---------------------
          3 | Busy   | 2022-03-30 15:10:26
(1 row)
```

6. Now, update the status of this record on the first cluster end:
```sql
UPDATE Status SET status = 'Active' WHERE profile_id = 3;
```

7. Check the status was updated for both clusters:
```sql
SELECT * FROM Status;

 profile_id | status |       set_at        
------------+--------+---------------------
          3 | Active | 2022-03-30 15:10:26
(1 row)
```
