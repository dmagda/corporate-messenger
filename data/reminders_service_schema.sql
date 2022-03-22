CREATE SEQUENCE reminder_id_seq CACHE 100;

CREATE TABLE Reminder(
    id integer NOT NULL DEFAULT nextval('reminder_id_seq'),
    profile_id integer,
    message_id integer NOT NULL,
    notify_at TIMESTAMP(0) NOT NULL,
    PRIMARY KEY(id)
);