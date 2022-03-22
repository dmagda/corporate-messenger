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

type Profile = {
    id: number,
    full_name: string,
    email: string,
    phone: string,
    country: string
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<Profile[] | string>
) {
  // open connection to the local YugabyteDB node
  const client = new Client(config);
  await client.connect();

  // query all Accounts stored in YugabyteDB
  await client.query('SELECT id, full_name, email, phone, country FROM Profile', 
    (err: Error, result: QueryResult<Profile>) => {
        if (err)
          res.status(500).json(err.message)

        res.status(200).json(result.rows)
  });
}
