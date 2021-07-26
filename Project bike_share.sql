-- Create database
create database project_bike_share;
use project_bike_share;
SET SQL_SAFE_UPDATES = 0;

-- Create datatable
CREATE TABLE bike_share_data (
ride_id VARCHAR(255),
    rideable_type VARCHAR(255),
    started_at DATETIME,
    ended_at DATETIME,
    start_station_name VARCHAR(255),
    start_station_id VARCHAR(255),
    end_station_name VARCHAR(255),
    end_station_id VARCHAR(255),
    member_casual VARCHAR(255)
);

-- Import CSV into bike_share_data table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DATA.csv'
INTO TABLE main_data 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Data Cleaning
alter table main_data add column started_at_new datetime;

alter table main_data add column ended_at_new datetime;

UPDATE main_data 
SET 
    started_at_new = CASE
        WHEN started_at > ended_at THEN ended_at
        ELSE started_at
    END;
UPDATE main_data 
SET 
    ended_at_new = CASE
        WHEN started_at > ended_at THEN started_at
        ELSE ended_at
    END;

alter table main_data drop column started_at, drop column ended_at;

DELETE FROM main_data 
WHERE
    started_at_new IS NULL;

SELECT 
    ride_id,
    started_at_new,
    ended_at_new,
    TIMESTAMPDIFF(MINUTE,
        started_at_new,
        ended_at_new) AS t
FROM
    main_data
ORDER BY t DESC;
                
DELETE FROM main_data 
WHERE
    TIMESTAMPDIFF(MINUTE,
    started_at_new,
    ended_at_new) > 300;
UPDATE main_data 
SET 
    rideable_type = CASE
        WHEN rideable_type = 'docked_type' THEN 'docked_bike'
        ELSE rideable_type
    END;
    
-- Total number of trips based on casual or member
SELECT 
    member_casual AS member_or_casual,
    COUNT(ride_id) AS number_of_trips,
    ROUND((COUNT(ride_id) / (SELECT 
                    COUNT(ride_id)
                FROM
                    main_data) * 100),
            2) AS percentage_of_total_trips
FROM
    main_data
GROUP BY member_casual;

#Calculate the average ride_length for users by day_of_week
SELECT 
    DAYNAME(started_at_new) AS day_of_week,
    member_casual AS member_or_casual,
    rideable_type AS type_of_ride,
    COUNT(ride_id) AS number_of_trips,
    ROUND(SUM(TIMESTAMPDIFF(MINUTE,
                started_at_new,
                ended_at_new)),
            2) AS total_ride_length_in_minutes,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,
                started_at_new,
                ended_at_new)),
            2) AS average_ride_length_in_minutes
FROM
    (SELECT 
        ride_id,
            rideable_type,
            DAYNAME(started_at_new),
            ended_at_new,
            started_at_new,
            member_casual
    FROM
        main_data) a
GROUP BY day_of_week , member_casual , rideable_type
ORDER BY DAYOFWEEK(started_at_new) , member_casual , rideable_type
LIMIT 1 , 100;

#Different season data exploration
SELECT 
    season,
    member_casual AS member_or_casual,
    rideable_type AS type_of_ride,
    COUNT(ride_id) AS number_of_rides,
    ROUND(SUM(TIMESTAMPDIFF(MINUTE,
                started_at_new,
                ended_at_new)),
            2) AS total_ride_length_in_minutes,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,
                started_at_new,
                ended_at_new)),
            2) AS average_ride_length_in_minutes
FROM
    (SELECT 
        ride_id,
            started_at_new,
            ended_at_new,
            member_casual,
            rideable_type,
            CASE
                WHEN MONTH(started_at_new) IN (3 , 4, 5) THEN 'Spring'
                WHEN MONTH(started_at_new) IN (6 , 7, 8) THEN 'Summer'
                WHEN MONTH(started_at_new) IN (9 , 10, 11) THEN 'Autumn'
                WHEN MONTH(started_at_new) IN (12 , 1, 2) THEN 'Winter'
            END AS season
    FROM
        main_data) t1
GROUP BY season , member_casual , rideable_type
ORDER BY CASE
    WHEN season = 'Spring' THEN 1
    WHEN season = 'Summer' THEN 2
    WHEN season = 'Autumn' THEN 3
    WHEN season = 'Winter' THEN 4
END , member_casual ASC , rideable_type ASC
LIMIT 1 , 100;

-- Most common starting and ending station
SELECT 
    member_casual AS member_or_casual,
    start_station_name,
    COUNT(start_station_name)
FROM
    main_data
WHERE
    start_station_name != '0'
GROUP BY member_or_casual , start_station_name
ORDER BY member_casual , COUNT(start_station_name) DESC;
SELECT 
    member_casual AS member_or_casual,
    end_station_name,
    COUNT(end_station_name)
FROM
    main_data
WHERE
    end_station_name != '0'
GROUP BY member_or_casual , end_station_name
ORDER BY member_casual , COUNT(end_station_name) DESC;

-- Total and Average Ride Length based on member or casual
SELECT 
    member_casual AS member_or_casual,
    ROUND(SUM(TIMESTAMPDIFF(MINUTE,
                started_at_new,
                ended_at_new)),
            2) AS total_ride_length_in_minutes,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,
                started_at_new,
                ended_at_new)),
            2) AS average_ride_length_in_minutes
FROM
    main_data
GROUP BY member_casual
ORDER BY total_ride_length_in_minutes DESC;
            

