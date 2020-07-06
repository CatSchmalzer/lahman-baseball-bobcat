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
--Which Vanderbilt player earned the most money in the majors? = David Price

--QUESTION 3 DONE!
WITH total_pro_salary AS (SELECT playerid, SUM(salary::text::money) as total_salary
						FROM salaries
						WHERE salary IS NOT null
						GROUP BY playerid
						ORDER BY total_salary DESC)		
SELECT DISTINCT concat(namefirst,' ', namelast) AS full_name, total_salary
FROM people AS p
	JOIN collegeplaying AS c ON c.playerid = p.playerid
	JOIN total_pro_salary as t ON p.playerid = t.playerid
WHERE schoolid = 'vandy'
ORDER BY total_salary DESC;


--Or Lori's code --different result, need to investigate
SELECT p.playerid, schoolname, namefirst, namelast, SUM(salary)::numeric::money as total_salary
FROM schools AS s
		JOIN collegeplaying AS cp USING(schoolid)  --LEFT and INNER JOIN also work for all joins.
		JOIN people AS p ON p.playerid = cp.playerid
		JOIN salaries as sal ON sal.playerid = p.playerid
	WHERE schoolname like '%Vanderbilt%'
		AND salary IS NOT NULL
GROUP BY p.playerid, schoolname, namefirst, namelast, namegiven
ORDER BY total_salary DESC;

--QUESTION 5 Diego
WITH decades as (	
	SELECT 	generate_series(1920,2010,10) as low_b,
			generate_series(1929,2019,10) as high_b)
			
SELECT 	low_b as decade,
		--SUM(so) as strikeouts,
		--SUM(g)/2 as games,  -- used last 2 lines to check that each step adds correctly
		ROUND(SUM(so::numeric)/(sum(g::numeric)/2),2) as SO_per_game,  -- note divide by 2, since games are played by 2 teams
		ROUND(SUM(hr::numeric)/(sum(g::numeric)/2),2) as hr_per_game
FROM decades LEFT JOIN teams
	ON yearid BETWEEN low_b AND high_b
GROUP BY decade
ORDER BY decade

--QUESTION 7 Diego, last part
WITH winners as	(	SELECT teamid as champ, yearid, w as champ_w
	  				FROM teams
	  				WHERE 	(wswin = 'Y')
				 			AND (yearid BETWEEN 1970 AND 2016) ),
							
max_wins as (	SELECT yearid, max(w) as maxw
	  			FROM teams
	  			WHERE yearid BETWEEN 1970 AND 2016
				GROUP BY yearid)
SELECT 	COUNT(*) AS all_years,
		COUNT(CASE WHEN champ_w = maxw THEN 'Yes' end) as max_wins_by_champ,
		to_char((COUNT(CASE WHEN champ_w = maxw THEN 'Yes' end)/(COUNT(*))::real)*100,'99.99%') as Percent
FROM 	winners LEFT JOIN max_wins
		USING(yearid)

--QUESTION 8 - Media's Code

--top 5 attendance
Select distinct ps.park_name, ts.name as team_name,  hg.attendance/hg.games as avg_attendance
from homegames as hg
left join parks as ps on hg.park = ps.park
left join teams as ts on hg.team = ts.teamid and ts.yearid = hg.year
where hg.year = 2016 and hg.games >= 10
order by avg_attendance desc
limit 5;

-- the lowest 5 average attendance
Select distinct ps.park_name, ts.name as team_name,  hg.attendance/hg.games as avg_attendance
from homegames as hg
left join parks as ps on hg.park = ps.park
left join teams as ts on hg.team = ts.teamid and ts.yearid = hg.year
where hg.year = 2016 and hg.games >= 10
order by avg_attendance asc
limit 5;


--QUESTION 9
--Which managers have won the TSN Manager of the Year award 
--in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.

SELECT *
FROM awardsmanagers
WHERE awardid ILIKE '%TSN%';
--i found johnsda02 and leylaji99 just by looking at list but need to sort/group
SELECT playerid, lgid, awardid, yearid
	FROM awardsmanagers
	WHERE awardid ILIKE '%TSN%' and yearid > 1985
	ORDER BY playerid;
	
--ANSWER FROM REVIEW
WITH nl AS  (SELECT * 
			FROM awardsmanagers
			WHERE awardid = 'TSN Manager of the Year'
			AND lgid = 'NL' )
SELECT concat(namefirst, ' ', namelast) as mgr_name, 
		nl.playerid, 
		nl.yearid, 
		nl.awardid, 
		am.playerid, 
		am.yearid, 
		am.lgid, 
		nl.lgid
FROM awardsmanagers AS am
INNER JOIN nl
USING(playerid)
inner join people using (playerid)
WHERE am.awardid = 'TSN Manager of the Year'
AND am.lgid = 'AL' 
	
	
	
--BONUS

--Analyze all the colleges in the state of Tennessee. 
--Which college has had the most success in the major leagues. 
--Use whatever metric for success you like - number of players, number of games, salaries, world series wins, etc.

--none in Hall of Fame

SELECT schoolname, g_all as pro_games_played, gp as all_star_games
FROM collegeplaying
JOIN schools USING (schoolid)
JOIN appearances USING (playerid)
JOIN allstarfull USING (playerid)
WHERE schoolstate = 'TN'
--GROUP BY schoolname, pro_games_played, all_star_games
ORDER BY pro_games_played DESC;