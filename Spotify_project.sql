-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

--EDA
select count(*) from spotify;

select * from spotify;

select distinct(artist) from spotify;

select max(duration_min) from spotify;

select min(duration_min) from spotify;

delete from spotify
where duration_min =0;

select distinct(channel) from spotify;

select distinct(most_played_on) from spotify;

-----------------------------------------------
--EASY LEVEL--
-----------------------------------------------
/*
Q1.Retrieve the names of all tracks that have more than 1 billion streams.
Q2.List all albums along with their respective artists.
Q3.Get the total number of comments for tracks where licensed = TRUE.
Q4.Find all tracks that belong to the album type single.
Q5.Count the total number of tracks by each artist.
*/

--Q1.Retrieve the names of all tracks that have more than 1 billion streams.
select track,
	   stream
from spotify
where stream >1000000000;


--Q2.List all albums along with their respective artists.
select album,
       artist
from spotify
group by 1,2;

--Q3.Get the total number of comments for tracks where licensed = TRUE.
select sum(comments)  as total_comments
from spotify
where licensed = 'true';

--Q4.Find all tracks that belong to the album type single.
select track
from spotify
where album_type ='single';

--Q5.Count the total number of tracks by each artist.
select artist,
       count(*) as Total_tracks
from spotify
group by artist;

---------------------------------------------------------------
--Medium Level--
---------------------------------------------------------------
/*
6.Calculate the average danceability of tracks in each album.
7.Find the top 5 tracks with the highest energy values.
8.List all tracks along with their views and likes where official_video = TRUE.
9.For each album, calculate the total views of all associated tracks.
10.Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

--6.Calculate the average danceability of tracks in each album.
select album,
       avg(danceability) as avg_danceability
from spotify
group by 1;

--7.Find the top 5 tracks with the highest energy values.
select track,
       energy
from spotify
order by energy desc
limit 5;

--8.List all tracks along with their views and likes where official_video = TRUE.
select track,
 	   sum(views) as total_views,
	   sum(likes) as total_likes
from spotify
where official_video = 'true'
group by 1;

--9.For each album, calculate the total views of all associated tracks.
select album,
       sum(views) as total_views
from spotify
group by 1;

--10.Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from 
(select track,
      coalesce(sum(case when most_played_on ='Spotify' then stream end ),0)as Spotify_streams,
	  coalesce(sum(case when most_played_on ='Youtube' then stream end ),0)as Youtube_streams
from spotify
group by 1) as t1
where Spotify_streams > Youtube_streams ;

/*Advanced Level
11.Find the top 3 most-viewed tracks for each artist using window functions.
12.Write a query to find tracks where the liveness score is above the average.
13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/


--11.Find the top 3 most-viewed tracks for each artist using window functions.
with artist_ranking as
 (select artist,
	   track,
	   sum(views) as Total_views,
	   dense_rank() over(partition by artist order by sum(views) desc) as ranking
from spotify
group by 1,2)
select * 
    from artist_ranking
  where ranking <=3;


--12.Write a query to find tracks where the liveness score is above the average.

select track,
       artist,
	   liveness
from spotify
where liveness > (select avg(liveness) from spotify);

--13.Use a WITH clause to calculate the difference between the highest
--and lowest energy values for tracks in each album.

with cte 
as
(select album ,
	   max(energy) as max_energy,
	   min(energy) as min_energy
from spotify
group by 1)
select album,
       max_energy - min_energy as energy_diff 
from cte
order by 2 desc; 

--14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
select track,
	   energy,
	   liveness
from spotify
where energy/liveness >1.2;


--15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

select track,likes,
sum(likes) over (partition by track order by likes asc) as cumilative_likes
from spotify
order by 1;


--query optimization--

Explain analyze
select artist,
	   track,
	   views
from spotify
where artist = 'Gorillaz' and most_played_on = 'Youtube'
order by stream desc
limit 25;

create index artist_index on spotify(artist);