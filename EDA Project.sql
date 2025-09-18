-- EXPLORATIRY DATA ANALYSIS PROJECT

SELECT * FROM layoffs_staging2;

-- Max layoffs at a company in a single date
SELECT MAX(total_laid_off), MAX(percentage_laid_off) FROM layoffs_staging2;

-- Shows every column where 100% of employees from a company was laid off, ordered by max number of layoffs descending
SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Shows the absolute total amount of layoffs per company ordered by max total descending
SELECT company, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Shows the earliest and latest date in the dataset
SELECT MIN(`date`), MAX(`date`) FROM layoffs_staging2;

-- Shows the absolute total amount of layoffs per country ordered by max total descending
SELECT country, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Shows the year only from the date column and the total amount of layoffs in that year ordered by the latest year to earliest year in dataset
SELECT YEAR(`date`), SUM(total_laid_off) FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Shows layoff stage and the total amount of layoofs per stage ordered by total layoffs desc
SELECT stage, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Shows company and percentage laid off ordered by percentage desc
SELECT company, SUM(percentage_laid_off) FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Extracts the date as yyyy-mm from the date column, and the total amount of layoffs per that year-month, excluding rows where the 
-- date is null and ordered by earliest date to latest
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Created a CTE from ^ to show a rolling total of layoffs. 
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_cut FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `Month`, total_cut, SUM(total_cut) OVER(ORDER BY `MONTH`) -- this specifically creates the rolling total
FROM Rolling_Total;

-- Shows the companies that had the highest amount of layoffs in the entire dataset ordered by total laid off descending
SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Shows the company and year that had the highest amount of layoffs ordered by total descending
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Created 2 CTEs , 1st one is ^. Second CTE shows each company starting with the first year (2020), and their layoff rank desc, then goes to the next year and so on
-- The full query only grabs the top 5 highest layoffs by company for each year, but orders them by ranking per year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
 FROM Company_Year
 WHERE years IS NOT NULL
 )
 SELECT * FROM Company_Year_Rank
 WHERE Ranking <= 5
 ORDER BY Ranking ASC; 