create database student_brainrot;

use student_brainrot;

CREATE TABLE student_behavior (
    student_id INT PRIMARY KEY,
    country VARCHAR(50),
    development_level VARCHAR(30),
    poverty_rate_percent DECIMAL(8,2),
    internet_infrastructure_index DECIMAL(8,2),
    average_internet_speed_mbps DECIMAL(10,2),
    age INT,
    gender VARCHAR(20),
    urban_rural VARCHAR(20),
    family_income_level VARCHAR(20),
    device_access VARCHAR(30),
    internet_access_hours DECIMAL(8,2),

    education_level VARCHAR(30),
    field_of_study VARCHAR(50),
    academic_motivation DECIMAL(8,2),
    online_learning_hours DECIMAL(8,2),
    social_media_hours DECIMAL(8,2),
    sessions_per_day DECIMAL(8,2),
    average_session_length_minutes DECIMAL(10,2),
    late_night_usage VARCHAR(20),
    education_content_hours DECIMAL(8,2),
    short_video_hours DECIMAL(8,2),
    entertainment_content_hours DECIMAL(8,2),
    news_content_hours DECIMAL(8,2),
    likes_given_per_day DECIMAL(10,2),
    comments_written_per_day DECIMAL(10,2),
    posts_created_per_week DECIMAL(10,2),
    late_night_score DECIMAL(8,2),
    brain_rot_index DECIMAL(10,2),

    brain_rot_level VARCHAR(30),
    attention_span_minutes DECIMAL(10,2),
    study_hours_per_week DECIMAL(10,2),
    class_attendance_rate DECIMAL(8,2),
    productivity_score DECIMAL(8,2),
    sleep_hours DECIMAL(8,2),
    stress_level DECIMAL(8,2),
    anxiety_score DECIMAL(8,2),
    depression_score DECIMAL(8,2),
    ads_viewed_per_day DECIMAL(10,2),
    ads_clicked_per_week DECIMAL(10,2),
    impulse_purchase_score DECIMAL(8,2),
    digital_spending_per_month DECIMAL(10,2),

    cyberbullying_exposure VARCHAR(10),
    adult_content_exposure VARCHAR(10),
    digital_addiction_score DECIMAL(10,2),
    wellbeing_index DECIMAL(10,2),
    academic_risk_score DECIMAL(10,2),
    financial_risk_score DECIMAL(10,2)
);

truncate table student_behavior;

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE "C:/Users/ELCOT/OneDrive/Desktop/Data Analysis/Datasets/global_student_digital_behavior_dataset.csv"
INTO TABLE student_behavior
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from student_behavior
limit 10;

select count(*) as total_records from student_behavior;

-- DATA CLEANING AND PREPARING

-- 1) duplicate check table

select student_id,
       count(*) as total_count
from student_behavior
group by student_id
having total_count > 1;

/* ANSWER
No rows returned so no duplicates */

-- 2) checking for null / blanks

SET SESSION group_concat_max_len = 1000000;


SELECT GROUP_CONCAT(
    CONCAT(
        'SUM(CASE WHEN `', COLUMN_NAME,
        '` IS NULL OR TRIM(`', COLUMN_NAME,
        '`) = '''' THEN 1 ELSE 0 END) AS `',
        COLUMN_NAME, '_missing`'
    )
    ORDER BY ORDINAL_POSITION
    SEPARATOR ', '
)
INTO @sql
FROM information_schema.columns
WHERE table_schema = 'student_brainrot'
  AND table_name = 'student_behavior';

SET @sql = CONCAT(
    'SELECT ', @sql,
    ' FROM student_brainrot.student_behavior'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


     

/* ANSWER

found 6262  null / blank from brain_rot_level*/

select brain_rot_index from student_behavior;

select count(*) from student_behavior
where brain_rot_level is null;            -- no nulls found

SELECT COUNT(*) AS empty_count
FROM student_brainrot.student_behavior
WHERE brain_rot_level = '';              -- 6262 empties



select min(brain_rot_index)as minimum,
       max(brain_rot_index) as maximum  from student_behavior;
       
set sql_safe_updates = 0;

update student_behavior
set brain_rot_level =
    case
        when brain_rot_index <= 19 then 'Low'
        when brain_rot_index <= 39 then 'Medium'
        when brain_rot_index <= 59 then 'High'
    end;      
    
  
 SELECT COUNT(*) AS empty_count
FROM student_brainrot.student_behavior
WHERE brain_rot_level = '';   

SELECT COUNT(*) AS space_count
FROM student_brainrot.student_behavior
WHERE TRIM(brain_rot_level) = '';

SELECT COUNT(*) AS null_count
FROM student_brainrot.student_behavior
WHERE brain_rot_level IS NULL;

------------------------------------------------------------------------------------------------------------------------------------------

-- 1) What is the overall distribution of students by country, gender, age, and development level?

select country,count(*) as total_students 
from student_behavior
group by country;

select gender,
       count(*) as total_students
from student_behavior
group by gender;

select age,count(*) as total_students
from student_behavior
group by age;  

select development_level,count(*) as total_students
from student_behavior
group by development_level;


-- 2) Which countries have the highest number of students in the dataset?

select country,count(*) as total_students
from student_behavior
group by country
order by total_students desc
limit 1;

/* ANSWER

Cambodia has the highest total student counts */

-- 3)  How does device usage differ across students based on their demographic characteristics?

select urban_rural,count(*) as total_students
from student_behavior
group by urban_rural
order by total_students desc;

/* ANSWER

The students in Urban area has tha highest usage */



--  4) How much time do students spend on social media, online learning, entertainment, and short-form video content?

select round(avg(online_learning_hours)) as avg_online_learning,
       round(avg(social_media_hours)) as avg_socialmedia_hrs,
       round(avg(entertainment_content_hours)) as avg_entertainment_hrs,
       round(avg(short_video_hours)) as avg_shortvideo_hrs
from student_behavior;       


--  5) Which digital activity consumes the most average time per student?

select
  case
  when avg(social_media_hours) >= greatest(avg(online_learning_hours),
                                           avg(entertainment_content_hours),
                                           avg(short_video_hours),
                                           avg(education_content_hours)) 
  then "SOCIAL MEDIA"
  
  when avg(online_learning_hours) >= greatest(avg(social_media_hours),
                                           avg(entertainment_content_hours),
                                           avg(short_video_hours),
                                           avg(education_content_hours)) 
 then "ONLINE LEARNING"
 
 when avg(entertainment_content_hours) >= greatest(avg(social_media_hours),
                                           avg(online_learning_hours),
                                           avg(short_video_hours),
                                           avg(education_content_hours))
 then "ENTERTAINMENT"
 
 when avg(short_video_hours) >= greatest(avg(social_media_hours),
                                           avg(online_learning_hours),
                                           avg(entertainment_content_hours),
                                           avg(education_content_hours))
 then "SHORT VIDEOS"
 
else "EDUCATION CONTENT"
end as dominant_activity
 from student_behavior;
 
 -- 6) How does digital behavior vary across different income levels?
 
 select family_income_level,
        count(student_id) as total_students
from student_behavior
group by family_income_level
order by total_students desc;

/* Middle income level people spend more screentime
   low income level people is in second place 
   And High income level people in third */
   
-- 7) What proportion of students fall into each brain rot level? 

select brain_rot_level,
       count(*) as student_count,
       round(count(*) * 100 / (select count(*) from student_behavior),2) as proportion_percentage
from student_behavior       
group by brain_rot_level
order by proportion_percentage desc;   

-- 8) How does social media usage relate to the brain rot index?

select 
   round(social_media_hours,1) as social_media_hours1,
   count(*) as student_count,
   round(avg(brain_rot_index),1) as avg_brainrot_index
from student_behavior
group by social_media_hours1
order by social_media_hours1;

/* as social media hours increases brain_rot_index also increases */

-- 9) Is short-form video consumption associated with higher brain rot levels?

select brain_rot_level,
       count(*) as students_count,
       round(avg(short_video_hours),2) as avg_shortvideo_hours
from student_behavior
group by brain_rot_level
order by avg_shortvideo_hours desc;  

-- 10) late night digital usage across students

select 
       late_night_usage,
       count(*) as total_students
from student_behavior
group by late_night_usage
order by total_students desc;

/* ANSWER 

*/

-- 11) How does academic motivation vary across brain rot levels?   

select brain_rot_level,
       round(avg(academic_motivation),1) as avg_academic_motivation
from student_behavior
group by brain_rot_level
order by avg_academic_motivation desc;   

/* ANSWER
Academic motivation is slightly high where brain rot level is low */

-- 12) Is higher digital addiction associated with lower productivity?

select min(digital_addiction_score),
       max(digital_addiction_score) from student_behavior;
       
alter  table student_behavior
add column digital_addiction_level varchar(20);

update student_behavior
set digital_addiction_level = 
case
  when digital_addiction_score <= 14 then "Low"
  when digital_addiction_score <= 28 then "Moderate"
  else "High"
  end;
  
select * from student_behavior 
limit 10;  

select digital_addiction_level
from student_behavior 
where digital_addiction_level is null; 

select digital_addiction_level,
       round(avg(productivity_score),1) as avg_productivity_score
from student_behavior
group by digital_addiction_level
order by avg_productivity_score desc;       

/* ANSWER

  Students with high digital addiction has low productivity */
  
--  13) Top 3 countries in brainrot level within each development level  

with country_avg as(
select country,
       development_level,
       round(avg(brain_rot_index),1) as avg_brainrot
from student_behavior
group by development_level,country),

ranked_countries as (
   select country,
          development_level,
          avg_brainrot,
       dense_rank() over(partition by development_level
                   order by avg_brainrot desc) as rnk
from country_avg)

select country,
       development_level,
       rnk
from ranked_countries
where rnk <= 3
order by development_level,rnk; 

-- 14) How does digital spending vary across income levels?

select family_income_level,
       round(avg(digital_spending_per_month),1) as avg_digital_spending
from student_behavior  
group by family_income_level
order by avg_digital_spending desc; 

/* ANSWER

High family income leads to high digital spending
Middle income level has moderate spending
And Low income leads to low spending */

-- 15) state whether adult content is high or low

select adult_content_exposure,
       count(*) as student_count
from student_behavior
group by adult_content_exposure
order by student_count;

/* ANSWER 
Apparently adult content exposure is very low */

       

    

       



















 

















