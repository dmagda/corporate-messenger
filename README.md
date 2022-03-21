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