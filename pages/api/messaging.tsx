import type { NextApiRequest, NextApiResponse } from 'next'
import { Client, ClientConfig, Query, QueryArrayResult, QueryResult, QueryResultRow } from 'pg'

// Connection config for YugabyteDB
const config: ClientConfig = {
    host: '127.0.0.1',
    port: 5433,
    database: 'yugabyte',
    user: 'yugabyte',
    password: 'yugabyte',
};

type Message = {
    id: number,
    channel_id: number,
    sender_id: number,
    message: string,
    sent_at: Date,
    country: string
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<Message[] | string>
) {
  // open connection to the local YugabyteDB node
  const client = new Client(config);
  await client.connect();

  // query all Accounts stored in YugabyteDB
  await client.query('SELECT * FROM Message', 
    (err: Error, result: QueryResult<Message>) => {
        if (err)
          res.status(500).json(err.message)

        res.status(200).json(result.rows)
  });
}
