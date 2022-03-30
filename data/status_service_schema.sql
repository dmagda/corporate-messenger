CREATE TYPE profile_status AS ENUM ('Active', 'Busy', 'In a Meeting', 'Vacationing', 'Out Sick');

CREATE TABLE Status (
    profile_id integer PRIMARY KEY,
    status profile_status NOT NULL DEFAULT 'Active',
    set_at TIMESTAMP(0) NOT NULL DEFAULT NOW()
);