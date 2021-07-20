#Data Cleaning
DELETE FROM neededdata 
WHERE
    TIMESTAMPDIFF(SECOND,
    started_at,
    ended_at) < 0;

#Duration for each ride
SELECT 
    ride_id, TIMEDIFF(ended_at, started_at) AS duration
FROM
    2020data; 

#Get the day of the week for each ride
SELECT 
    ride_id, DAYNAME(started_at)
FROM
    2020data;

#Get the season for each ride
SELECT 
    ride_id,
    started_at,
    ended_at,
    member_casual,
    rideable_type,
    CASE
        WHEN MONTH(started_at) IN (3 , 4, 5) THEN 'Spring'
        WHEN MONTH(started_at) IN (6 , 7, 8) THEN 'Summer'
        WHEN MONTH(started_at) IN (9 , 10, 11) THEN 'Autumn'
        WHEN MONTH(started_at) IN (12 , 1, 2) THEN 'Winter'
    END AS season
FROM
    neededdata;

#Data i need
SELECT 
    ride_id, rideable_type, started_at, ended_at, member_casual
FROM
    2020data;

#Create table with the data i needed
CREATE TABLE neededdata (
    ride_id VARCHAR(255),
    rideable_type VARCHAR(255),
    started_at DATETIME,
    ended_at DATETIME,
    member_casual VARCHAR(255)
);

#Insert the data i needed into table i needed
insert into neededdata
select ride_id, rideable_type, started_at, ended_at, member_casual from 2020data;

#Calculate the average ride length for members and casual riders
SELECT 
    member_casual,
    ROUND(AVG(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))),
            2) AS average_ride_length
FROM
    neededdata
GROUP BY member_casual;

#Calculate the average ride_length for users by day_of_week
SELECT 
    DAYNAME(started_at) AS day_of_week,
    member_casual AS member_or_casual,
    rideable_type AS type_of_ride,
    COUNT(ride_id) AS number_of_trips,
    ROUND(SUM(TIMESTAMPDIFF(MINUTE,
                started_at,
                ended_at)),
            2) AS total_ride_length_in_minutes,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,
                started_at,
                ended_at)),
            2) AS average_ride_length_in_minutes
FROM
    (SELECT 
        ride_id,
            rideable_type,
            DAYNAME(started_at),
            ended_at,
            started_at,
            member_casual
    FROM
        neededdata) a
GROUP BY day_of_week , member_casual , rideable_type
ORDER BY DAYOFWEEK(started_at) , member_casual , rideable_type;

#Different season data exploration
SELECT 
    season,
    member_casual AS member_or_casual,
    rideable_type AS type_of_ride,
    COUNT(ride_id) AS number_of_rides,
    ROUND(SUM(TIMESTAMPDIFF(MINUTE,
                started_at,
                ended_at)),
            2) AS total_ride_length_in_minutes,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,
                started_at,
                ended_at)),
            2) AS average_ride_length_in_minutes
FROM
    (SELECT 
        ride_id,
            started_at,
            ended_at,
            member_casual,
            rideable_type,
            CASE
                WHEN MONTH(started_at) IN (3 , 4, 5) THEN 'Spring'
                WHEN MONTH(started_at) IN (6 , 7, 8) THEN 'Summer'
                WHEN MONTH(started_at) IN (9 , 10, 11) THEN 'Autumn'
                WHEN MONTH(started_at) IN (12 , 1, 2) THEN 'Winter'
            END AS season
    FROM
        neededdata) t1
GROUP BY season , member_casual , rideable_type
ORDER BY CASE
    WHEN season = 'Spring' THEN 1
    WHEN season = 'Summer' THEN 2
    WHEN season = 'Autumn' THEN 3
    WHEN season = 'Winter' THEN 4
END , member_casual ASC , rideable_type ASC;



#Table before adding new bikes
SELECT 
    member_casual AS member_or_casual,
    rideable_type AS type_of_ride,
    COUNT(ride_id) AS number_of_rides,
    ROUND(SUM(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))),
            2) AS total_ride_length_in_minutes,
    ROUND(AVG(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))),
            2) AS average_ride_length_in_minutes
FROM
    neededdata
WHERE
    started_at < '2020-07-13'
GROUP BY member_casual , rideable_type
ORDER BY member_casual ASC;
#Table after adding new bikes
SELECT 
    member_casual AS member_or_casual,
    rideable_type AS type_of_ride,
    COUNT(ride_id) AS number_of_rides,
    ROUND(SUM(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))),
            2) AS total_ride_length_in_minutes,
    ROUND(AVG(TIME_TO_SEC(TIMEDIFF(ended_at, started_at))),
            2) AS average_ride_length_in_minutes
FROM
    neededdata
WHERE
    started_at > '2020-07-13'
GROUP BY member_casual , rideable_type
ORDER BY member_casual ASC;


