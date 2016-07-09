-- First of all, create the neccessary keyspace.
CREATE KEYSPACE assignment WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 1
};

USE assignment;




-- Q1. Find Users by name.
CREATE TYPE payment_information (
  payment_type text,
  card_number text,
  expires date,
  security_code text
);

CREATE TYPE address (
  street text,
  city text,
  state_or_province text,
  postal_code text,
  country text
);

CREATE TABLE users_by_name (
  name text PRIMARY KEY,
  address frozen<address>,
  payment_information map<text, frozen<payment_information>>,
  song_history set<text>,
  following set<text>
) WITH comment = 'Q1. Find users by name.';

-- Insert some dummy data.
INSERT INTO users_by_name (name, address, payment_information, song_history, following) VALUES (
  'user1',
  {street: 's1', city: 'c1', state_or_province: 'p1', postal_code: 'pc1', country: 'Greece'},
  {'my card': {payment_type: 'VISA', card_number: '111-111', expires: '2020-01-01', security_code: '1234'}},
  {'song1', 'song2', 'song3'},
  {'user11', 'user20'});

INSERT INTO users_by_name (name, address, payment_information, song_history, following) VALUES (
  'user2',
  {street: 's2', city: 'c2', state_or_province: 'p2', postal_code: 'pc2', country: 'Germany'},
  {'A card': {payment_type: 'Master Card', card_number: '111-222', expires: '2017-01-01', security_code: '8888'}},
  {'song100', 'song25', 'song31'},
  {'user1', 'user5'});

-- Query
SELECT * FROM users_by_name WHERE name = 'user1';




-- Q2. Find songs by name.
CREATE TABLE song (
  name text PRIMARY KEY,
  artist text,
  album text,
  year smallint,
  genre text,
  song_file blob
) WITH comment = 'Q2. Find songs by name.';

CREATE TABLE song_counter (
  name text PRIMARY KEY,
  playcount counter
);

-- Insert some dummy data.
INSERT INTO song (name, artist, album, year, genre) VALUES ('song1', 'artist1', 'album1', 2016, 'classic');
UPDATE song_counter SET playcount = playcount + 15 WHERE name = 'song1';

INSERT INTO song (name, artist, album, year, genre) VALUES ('song2', 'artist2', 'album2', 2016, 'pop');
UPDATE song_counter SET playcount = playcount + 1000 WHERE name = 'song2';

-- Query
SELECT * FROM song, song_counter WHERE name = 'song1';
SELECT * FROM song_counter WHERE name = 'song1';




-- Q3. Songs played by a user.
CREATE TABLE users_and_songs (
  user_name text,
  song_name text,
  played_on timestamp,
  PRIMARY KEY (user_name, played_on)
) WITH comment = 'Q3. Find songs played by a user in reverse chronological order.' AND CLUSTERING ORDER BY (played_on DESC);

-- Insert some dummy data.
INSERT INTO users_and_songs (user_name, song_name, played_on) VALUES ('user1', 'song1', '2016-07-09 16:00:00');
INSERT INTO users_and_songs (user_name, song_name, played_on) VALUES ('user1', 'song4', '2016-07-08 13:00:00');
INSERT INTO users_and_songs (user_name, song_name, played_on) VALUES ('user1', 'song15', '2014-07-09 16:00:00');
INSERT INTO users_and_songs (user_name, song_name, played_on) VALUES ('user1', 'song112', '2012-07-09 16:00:00');
INSERT INTO users_and_songs (user_name, song_name, played_on) VALUES ('user1', 'song56', '2016-07-09 13:00:00');

-- Query
SELECT * FROM users_and_songs WHERE user_name = 'user1';
