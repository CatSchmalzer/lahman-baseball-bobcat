--Question 1
--What range of years does the provided database cover?

SELECT MIN(birthyear), MAX(deathyear)
FROM people;
--Answer 1820-2017

--or this? Use max and min? Then answer is 1871-2016
SELECT min(year), max(year)
FROM homegames

--Question 2
--Find the name and height of the shortest player in the database. 
	--Eddie Gaedel is shortest player in database. he was 43 inches tall or 3'7".
--How many games did he play in? What is the name of the team for which he played?
	-- He played one game for St. Louis Browns. 

--SELECT *
--FROM appearances
--LIMIT 5;

SELECT teams.name, g_all, namefirst, namelast, MIN(height) as shortest_player
FROM people
JOIN appearances on appearances.playerid = people.playerid
JOIN teams ON teams.teamid = appearances.teamid
GROUP BY teams.name, g_all, namefirst, namelast
ORDER BY shortest_player
LIMIT 1;

--polished by team/FINAL QUERY

SELECT concat(namefirst,' ', namelast) as full_name, MIN(height) as short_player_inches,  g_all as games_played, teams.name as team_name
FROM people as p
LEFT JOIN appearances as a on a.playerid = p.playerid
JOIN teams ON teams.teamid = a.teamid
GROUP BY teams.name, g_all, namefirst, namelast
ORDER BY short_player_inches
LIMIT 1;


--QUESTION 3
--Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. 
--Sort this list in descending order by the total salary earned. 
--Which Vanderbilt player earned the most money in the majors? David Price


--SELECT *
--FROM schools
--WHERE schoolname LIKE '%Vanderbilt%';
--schoolid is Vandy

--QUESTION 3 DONE!
WITH total_pro_salary AS (SELECT playerid, SUM(salary::text::money) as total_salary
						FROM salaries
						WHERE salary IS NOT null
						GROUP BY playerid
						ORDER BY total_salary DESC)		
SELECT DISTINCT concat(namefirst,' ', namelast) AS full_name, schoolid, total_salary
FROM people AS p
	JOIN collegeplaying AS c ON c.playerid = p.playerid
	JOIN total_pro_salary as t ON p.playerid = t.playerid
WHERE schoolid = 'vandy'
ORDER BY total_salary DESC;

--QUESTION 9
--Which managers have won the TSN Manager of the Year award 
--in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.

SELECT *
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%';

SELECT playerid, lgid, awardid, yearid
	FROM awardsmanagers
	WHERE awardid ILIKE '%TSN%' and yearid > 1985
	ORDER BY playerid;