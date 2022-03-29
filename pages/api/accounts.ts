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

type Account = {
    name: string,
    age: number,
    country: string,
    balance: number
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<Account[] | string>
) {
  // open connection to the local YugabyteDB node
  const client = new Client(config);
  await client.connect();

  // query all Accounts stored in YugabyteDB
  await client.query('SELECT name, age, country, balance FROM Account', 
    (err: Error, result: QueryResult<Account>) => {
        if (err)
          res.status(500).json(err.message)

        res.status(200).json(result.rows)
  });
}
