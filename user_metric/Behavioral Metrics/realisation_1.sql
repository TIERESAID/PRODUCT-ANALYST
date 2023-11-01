/* 
Calculating DAU of newcomers
Yura comes to you again and asks to see how many new users join the product each day. The product team is planning a newcomer survey and they need to know how many days it will take to get the right number of respondents. 
Calculate the DAU for new users only. A new user can be defined as a user who sent an analytics event of type pageOpen on the day of first use of the product
*/

SELECT log_date, COUNT(DISTINCT user_id) AS uniques
FROM events_log
WHERE name = 'pageOpen' AND install_date = log_date
GROUP BY log_date;
