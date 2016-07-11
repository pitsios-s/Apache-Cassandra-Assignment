-- First of all, create the neccessary keyspace.
DROP KEYSPACE IF EXISTS assignment;
CREATE KEYSPACE IF NOT EXISTS assignment WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 3
};

USE assignment;




-- Q1. Find Users by name.
CREATE TYPE IF NOT EXISTS payment_information (
  payment_type text,
  card_number text,
  expires date,
  security_code text
);

CREATE TYPE IF NOT EXISTS address (
  street text,
  city text,
  state_or_province text,
  postal_code text,
  country text
);

CREATE TABLE IF NOT EXISTS users_by_name (
  user_name text PRIMARY KEY,
  address frozen<address>,
  payment_information map<text, frozen<payment_information>>
) WITH comment = 'Q1. Find users by name';

-- Insert some dummy data.
INSERT INTO users_by_name (user_name, address, payment_information) VALUES (
  'user1',
  {street: 's1', city: 'c1', state_or_province: 'p1', postal_code: 'pc1', country: 'Greece'},
  {'my card': {payment_type: 'VISA', card_number: '111-111', expires: '2020-01-01', security_code: '1234'}});

INSERT INTO users_by_name (user_name, address, payment_information) VALUES (
  'user2',
  {street: 's2', city: 'c2', state_or_province: 'p2', postal_code: 'pc2', country: 'Germany'},
  {'A card': {payment_type: 'Master Card', card_number: '111-222', expires: '2017-01-01', security_code: '8888'}});

-- Query
SELECT * FROM users_by_name WHERE user_name = 'user1';




-- Q2. Find songs by name.
CREATE TABLE IF NOT EXISTS song_by_name (
  song_name text,
  artist text,
  album text,
  year smallint,
  genre text,
  song_file blob,
  PRIMARY KEY((song_name), artist)
) WITH comment = 'Q2. Find songs by name';

-- Insert some dummy data.
INSERT INTO song_by_name (song_name, artist, album, year, genre) VALUES ('song1', 'artist1', 'album1', 2016, 'classic');
INSERT INTO song_by_name (song_name, artist, album, year, genre) VALUES ('song2', 'artist2', 'album2', 2016, 'pop');

-- Query
SELECT * FROM song_by_name WHERE song_name = 'song1';




-- Q3. Songs played by a user.
CREATE TABLE IF NOT EXISTS users_and_songs (
  user_name text,
  song_name text,
  artist text,
  album text,
  year smallint,
  genre text,
  played_on timestamp,
  PRIMARY KEY ((user_name), played_on)
) WITH comment = 'Q3. Find songs played by a user in reverse chronological order' AND CLUSTERING ORDER BY (played_on DESC);

-- Insert some dummy data.
INSERT INTO users_and_songs (user_name, song_name, artist, album, year, genre, played_on) VALUES ('user1', 'song1', 'artist1', 'album1', 2015, 'pop', '2016-07-09 16:00:00');
INSERT INTO users_and_songs (user_name, song_name, artist, album, year, genre, played_on) VALUES ('user1', 'song4', 'artist1', 'album1', 2015, 'pop', '2016-07-08 13:00:00');
INSERT INTO users_and_songs (user_name, song_name, artist, album, year, genre, played_on) VALUES ('user1', 'song15', 'artist2', 'album2', 2014, 'rock', '2014-07-09 16:00:00');
INSERT INTO users_and_songs (user_name, song_name, artist, album, year, genre, played_on) VALUES ('user1', 'song112', 'artist3', 'album4', 2015, 'classic', '2012-07-09 16:00:00');
INSERT INTO users_and_songs (user_name, song_name, artist, album, year, genre, played_on) VALUES ('user1', 'song56', 'artist1', 'album5', 2013, 'jazz', '2016-07-09 13:00:00');

-- Query
SELECT song_name, artist, album, year, genre, played_on FROM users_and_songs WHERE user_name = 'user1';




-- Q4. Find a playlist by its name.
CREATE TABLE IF NOT EXISTS playlist_by_name (
  playlist_name text PRIMARY KEY,
  description text,
  genre text,
  user_name text
) WITH comment = 'Q4. Find playlist by name';

-- Insert some dummy data.
INSERT INTO playlist_by_name (playlist_name, description, genre, user_name) VALUES ('playlist1', 'Party music', 'pop', 'user1');
INSERT INTO playlist_by_name (playlist_name, description, genre, user_name) VALUES ('playlist2', 'Classic music for studying', 'classic', 'user23');

-- Query
SELECT * FROM playlist_by_name WHERE playlist_name = 'playlist1';




-- Q5. Search for a playlist by its genre.
CREATE INDEX IF NOT EXISTS ON playlist_by_name (genre);

-- Query
SELECT * FROM playlist_by_name WHERE genre = 'classic';




-- Q6. Search for a playlist by its creator.
CREATE MATERIALIZED VIEW IF NOT EXISTS playlist_by_creator
AS SELECT playlist_name, description, genre, user_name
FROM playlist_by_name
WHERE playlist_name IS NOT NULL AND user_name IS NOT NULL
PRIMARY KEY ((user_name), playlist_name);

-- Query
SELECT * FROM playlist_by_creator WHERE user_name = 'user1';




-- Q7. Find all the followers of a specific playlist.
CREATE TABLE IF NOT EXISTS playlist_follower (
  playlist_name text,
  follower_name text,
  PRIMARY KEY((playlist_name), follower_name)
) WITH comment = 'Find the followers of a playlist';

-- Insert some dummy data.
INSERT INTO playlist_follower (playlist_name, follower_name) VALUES ('playlist1', 'user1');
INSERT INTO playlist_follower (playlist_name, follower_name) VALUES ('playlist1', 'user2');
INSERT INTO playlist_follower (playlist_name, follower_name) VALUES ('playlist1', 'user3');
INSERT INTO playlist_follower (playlist_name, follower_name) VALUES ('playlist2', 'user11');
INSERT INTO playlist_follower (playlist_name, follower_name) VALUES ('playlist2', 'user12');
INSERT INTO playlist_follower (playlist_name, follower_name) VALUES ('playlist3', 'user1');
INSERT INTO playlist_follower (playlist_name, follower_name) VALUES ('playlist3', 'user1');
INSERT INTO playlist_follower (playlist_name, follower_name) VALUES ('playlist3', 'user50');
INSERT INTO playlist_follower (playlist_name, follower_name) VALUES ('playlist3', 'user60');
INSERT INTO playlist_follower (playlist_name, follower_name) VALUES ('playlist5', 'user100');

-- Query
SELECT follower_name FROM playlist_follower WHERE playlist_name = 'playlist3';




-- Q8. Find all the followers of a user.
CREATE TABLE IF NOT EXISTS user_follower (
  user_name text,
  follower_name text,
  PRIMARY KEY ((user_name), follower_name)
) WITH comment = 'Q8. Find the followers of a user';

-- Insert some dummy data.
INSERT INTO user_follower (user_name, follower_name) VALUES ('user1', 'user2');
INSERT INTO user_follower (user_name, follower_name) VALUES ('user1', 'user3');
INSERT INTO user_follower (user_name, follower_name) VALUES ('user1', 'user4');
INSERT INTO user_follower (user_name, follower_name) VALUES ('user2', 'user1');
INSERT INTO user_follower (user_name, follower_name) VALUES ('user2', 'user3');
INSERT INTO user_follower (user_name, follower_name) VALUES ('user2', 'user4');
INSERT INTO user_follower (user_name, follower_name) VALUES ('user3', 'user2');
INSERT INTO user_follower (user_name, follower_name) VALUES ('user3', 'user20');
INSERT INTO user_follower (user_name, follower_name) VALUES ('user4', 'user25');
INSERT INTO user_follower (user_name, follower_name) VALUES ('user4', 'user26');

-- Query
SELECT follower_name FROM user_follower WHERE user_name = 'user3';




-- Q9. Find the songs contained in a playlist.
CREATE TABLE IF NOT EXISTS songs_by_playlist (
  playlist_name text,
  song_name text,
  artist text,
  album text,
  year smallint,
  genre text,
  PRIMARY KEY ((playlist_name), song_name, artist)
) WITH comment = 'Q9. Find songs in a playlist' AND CLUSTERING ORDER BY (song_name ASC, artist ASC);

-- Insert some dummy data.
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist1', 'song10', 'artist1', 'album1', 2015, 'pop');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist1', 'song4', 'artist2', 'album4', 2013, 'country');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist1', 'song2', 'artist2', 'album4', 2013, 'country');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist1', 'song27', 'artist5', 'album10', 2016, 'electro');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist1', 'song30', 'artist5', 'album10', 2016, 'electro');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist2', 'song10', 'artist1', 'album1', 2015, 'pop');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist27', 'song12', 'artist5', 'album10', 2016, 'electro');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist2', 'song13', 'artist8', 'album20', 2014, 'house');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist2', 'song14', 'artist8', 'album20', 2014, 'house');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist2', 'song15', 'artist8', 'album20', 2014, 'house');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist3', 'song5', 'artist2', 'album4', 2013, 'country');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist3', 'song7', 'artist20', 'album30', 2010, 'metal');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist3', 'song3', 'artist2', 'album4', 2013, 'country');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist3', 'song9', 'artist20', 'album30', 2010, 'metal');
INSERT INTO songs_by_playlist (playlist_name, song_name, artist, album, year, genre) VALUES ('playlist3', 'song1', 'artist21', 'album40', 2012, 'funk');

-- Query.
SELECT song_name, artist, album, year, genre FROM songs_by_playlist WHERE playlist_name = 'playlist3';




-- Q10. Find how many times a playlist has been played.
CREATE TABLE IF NOT EXISTS playlist_counter (
  playlist_name text PRIMARY KEY,
  played counter
) WITH comment = 'Q10. Number of times a playlist has been played.';

-- Insert some dummy data.
UPDATE playlist_counter SET played = played + 10 WHERE playlist_name = 'playlist1';
UPDATE playlist_counter SET played = played + 20 WHERE playlist_name = 'playlist1';
UPDATE playlist_counter SET played = played + 2 WHERE playlist_name = 'playlist3';
UPDATE playlist_counter SET played = played + 30 WHERE playlist_name = 'playlist1';
UPDATE playlist_counter SET played = played + 30 WHERE playlist_name = 'playlist2';
UPDATE playlist_counter SET played = played + 430 WHERE playlist_name = 'playlist4';
UPDATE playlist_counter SET played = played + 10230 WHERE playlist_name = 'playlist4';
UPDATE playlist_counter SET played = played + 35 WHERE playlist_name = 'playlist2';
UPDATE playlist_counter SET played = played + 999999 WHERE playlist_name = 'playlist8';
UPDATE playlist_counter SET played = played + 100000 WHERE playlist_name = 'playlist9';

-- Query
SELECT played FROM playlist_counter WHERE playlist_name = 'playlist1';




-- Q11. How many times a song has been played.
CREATE TABLE IF NOT EXISTS song_counter (
  song_name text PRIMARY KEY,
  played counter
) WITH comment = 'Q11. How many times a song has been played';

-- Insert some dummy data.
UPDATE song_counter SET played = played + 15 WHERE song_name = 'song1';
UPDATE song_counter SET played = played + 1000 WHERE song_name = 'song2';

-- Query
SELECT * FROM song_counter WHERE song_name = 'song1';




-- Q12. List playlists in decreasing popularity.
-- Problems
-- 1. Counter table
-- 2. cassandra limitations
-- 3. can not create MATERIALIZED
-- 4. new table and copt contents
-- 5. copied rows do not have ordering
-- 6. order by need where =  in primary KEY
-- 7. no wildcards
-- 8. no inner selects (need hive or spark sql-> http://stackoverflow.com/questions/27460129/nested-query-not-working-in-cassandra)
-- 9. Can not sort counter columns
-- 10. Data were splitted using playlist_name as key.
CREATE TABLE IF NOT EXISTS playlist_counter_2 (
  hash_prefix bigint,
  playlist_name text,
  played bigint,
  PRIMARY KEY ((hash_prefix), played, playlist_name)
) WITH comment = 'Q12. List playlists in decreasing popularity.' AND CLUSTERING ORDER BY (played DESC, playlist_name ASC);

-- Copy data from previous table.
-- COPY playlist_counter (playlist_name, played) TO 'temp.csv';
-- COPY playlist_counter_2 (playlist_name, played) FROM 'temp.csv';

INSERT INTO playlist_counter_2 (hash_prefix, playlist_name, played) VALUES (1, 'playlist2', 65);
INSERT INTO playlist_counter_2 (hash_prefix, playlist_name, played) VALUES (1, 'playlist4', 10660);
INSERT INTO playlist_counter_2 (hash_prefix, playlist_name, played) VALUES (1, 'playlist8', 999999);
INSERT INTO playlist_counter_2 (hash_prefix, playlist_name, played) VALUES (1, 'playlist9', 100000);
INSERT INTO playlist_counter_2 (hash_prefix, playlist_name, played) VALUES (1, 'playlist3', 2);
INSERT INTO playlist_counter_2 (hash_prefix, playlist_name, played) VALUES (1, 'playlist1', 60);

-- Query.
SELECT playlist_name, played FROM playlist_counter_2;




-- Q13. List Users in decreasing popularity.
CREATE TABLE IF NOT EXISTS user_follower_count (
  hash_prefix bigint,
  user_name text,
  followers bigint,
  PRIMARY KEY ((hash_prefix), followers, user_name)
) WITH comment = 'Q13. List users in decreasing popularity' AND CLUSTERING ORDER BY (followers DESC, user_name ASC);

-- Insert some dummy data.
INSERT INTO user_follower_count (hash_prefix, user_name, followers) VALUES (1, 'user1', 3);
INSERT INTO user_follower_count (hash_prefix, user_name, followers) VALUES (1, 'user2', 3);
INSERT INTO user_follower_count (hash_prefix, user_name, followers) VALUES (1, 'user3', 2);
INSERT INTO user_follower_count (hash_prefix, user_name, followers) VALUES (1, 'user4', 2);
INSERT INTO user_follower_count (hash_prefix, user_name, followers) VALUES (1, 'user5', 1);
INSERT INTO user_follower_count (hash_prefix, user_name, followers) VALUES (1, 'user10', 300);

-- Query
SELECT user_name, followers FROM user_follower_count;
