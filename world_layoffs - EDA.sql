-- Exploratory Data Analysis(EDA)

SELECT * FROM world_layoffs.layoffs_staging2;


-- Checking how much percentage of employees were laid off
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;
-- So there were companies which got rid of 100% of their employees too


-- Checking sum of how many employees were laid off from a certain company
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


-- Most layoffs on a single day
SELECT company, total_laid_off, `date`
FROM world_layoffs.layoffs_staging
ORDER BY 2 DESC;


-- By location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC;


-- By country
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


-- By year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;


-- By industry
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


-- By stage
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- By Month
SELECT SUBSTRING(`date`,1,7) as `Month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY `Month`
ORDER BY `Month` ASC;


-- Rolling total in respect to months
WITH rolling_total AS 
(
SELECT SUBSTRING(`date`,1,7) as `Month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY `Month`
ORDER BY `Month` ASC
)
SELECT `Month`, total_off, SUM(total_off) OVER (ORDER BY `Month` ASC) as rolling_total_layoffs
FROM rolling_total
ORDER BY `Month` ASC;


-- Top 5 company layoffs by year
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 5
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;



