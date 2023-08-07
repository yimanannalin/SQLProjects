/*
Video Games Sales Data Exploration

Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Data Cleaning

Kaggle dataset used: https://www.kaggle.com/datasets/gregorut/videogamesales
*/


/*
Questions we want to answer with this data:
	
	Which years had video games with the highest player ratings?

	Which years had video games with the highest critic ratings?

	How many video games were sold during these years?

*/

SELECT *
FROM portfolio1.dbo.gamesales

--------------------------------------------------------------------------------------------------------------------


-- CLEANING DATA
-- We want to populate or remove null values so they don't cause issues in our analysis later



-- Populate User/Critic Score if only one is null

SELECT COUNT(*) -- checking how many NULL values there are
FROM portfolio1.dbo.gamesales a
LEFT JOIN portfolio1.dbo.gamesales b ON a.Name = b.Name
WHERE a.Critic_Score IS NULL OR b.User_Score IS NULL;



-- Replace null Critic scores with respective User scores

Update a
SET Critic_Score = ISNULL(a.Critic_Score,b.User_score)
From portfolio1.dbo.gamesales a
JOIN portfolio1.dbo.gamesales b
	on a.Name = b.Name
Where a.Critic_Score IS NULL



-- Replace null User scores with respective Critic scores

Update a
SET User_Score = ISNULL(a.User_Score,b.Critic_score)
From portfolio1.dbo.gamesales a
JOIN portfolio1.dbo.gamesales b
	on a.Name = b.Name
Where a.User_Score IS NULL



-- Now, we delete colums where both Critic_Score and User_Score are both NULL

DELETE FROM portfolio1.dbo.gamesales
WHERE Critic_Score IS NULL



--------------------------------------------------------------------------------------------------------------------

-- FEEDBACK DATA ANALYSIS


-- First, we want to find the years with games most popular amongst critics

SELECT Year,
	   ROUND(AVG(Critic_Score),2) AS avg_critic_score,
	   COUNT(Name) AS num_of_games
FROM portfolio1.dbo.gamesales
GROUP BY Year
ORDER BY avg_critic_score DESC



-- We can see that some years only have around 1-2 games
-- Let's only consider years with 5+ games so we get a list that better reflects the best years for video game releases

SELECT Year,
	   ROUND(AVG(Critic_Score),2) AS avg_critic_score,
	   COUNT(Name) AS num_of_games
INTO avg_critic_scores_by_year  -- save into a temp table for later
FROM portfolio1.dbo.gamesales
GROUP BY Year
HAVING COUNT(Name) > 5



-- Now, we continue to find the years with games most popular amongst users/players

SELECT Year,
	   ROUND(AVG(User_Score),2) AS avg_user_score ,
	   COUNT(Name) AS num_of_games
INTO avg_user_scores_by_year
FROM portfolio1.dbo.gamesales
GROUP BY Year
HAVING COUNT(Name) > 5



-- Using our temp tables, lets compare the  results for the top 5 years for both Users and Critics

SELECT TOP 5 *
FROM avg_critic_scores_by_year
ORDER BY avg_critic_score DESC

-- From this query results we see that the 5 most popular years amongst critics were 1990, 1992, 2020, 1994, 2019


SELECT TOP 5 *
FROM avg_user_scores_by_year
ORDER BY avg_user_score DESC

-- From this query results we see that the 5 most popular years amongst users were 1990, 1991, 1992, 1994, 1993


-- We can see from these results that both users and critics agree that 1990, 1992, and 1994 were in the top 5 years
-- Thus, we could conclude that the early 1990s was likely the golden age of video games releases.



-- Furthermore, let's explore how many games were sold during these years

SELECT Year,
		SUM(Total_Shipped) As Amount_Sold
FROM portfolio1.dbo.gamesales 
WHERE Year = 1990
	  OR Year = 1992
	  OR Year = 1994
GROUP BY Year
ORDER BY Amount_Sold DESC

-- Ultimately, it seems that 1992 was the best andmost popular year for video games!
