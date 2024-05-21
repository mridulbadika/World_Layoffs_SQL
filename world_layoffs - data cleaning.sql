SELECT * FROM layoffs;

-- first thing we want to do is create a dummy table. This is the one we will work in and clean the data. 
-- We want a table with the raw data in case something happens

CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;

INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

SELECT * FROM layoffs_staging;

-- now we will clean the data and follow these steps
-- 1. check for duplicates and remove if any
-- 2. standardize data and fix errors
-- 3. Look at null values and make necessary changes 
-- 4. remove any columns and rows that are not necessary



-- 1.Delete Duplicates


SELECT * FROM layoffs_staging;


-- Identifying Duplicates
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;


WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
	FROM DELETE_CTE
) AND row_num > 1;


-- We will create a new table with a new column named row_num and delete the rows with row_num greater than 2 and then dropping that column altogether

ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;

SELECT * FROM world_layoffs.layoffs_staging;

CREATE TABLE `world_layoffs`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;
        
SELECT * FROM layoffs_staging2;

DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;



-- 2.Standardizing data


SELECT * FROM world_layoffs.layoffs_staging2;

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

SELECT * FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL OR industry = ''
ORDER BY industry;


-- Setting empty values to null for industry column

UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT * FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL OR industry = ''
ORDER BY industry;


-- Taking industry values from same company column

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * FROM world_layoffs.layoffs_staging2;


-- The industry column has multuple variations of crypto. We need to standardize that - let's say all to Crypto

SELECT DISTINCT industry FROM world_layoffs.layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

SELECT DISTINCT industry FROM world_layoffs.layoffs_staging2
ORDER BY industry;

SELECT * FROM world_layoffs.layoffs_staging2;


-- Country column also has 2 variations of United States, lets modify them to be same

SELECT DISTINCT country FROM world_layoffs.layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

SELECT DISTINCT country FROM world_layoffs.layoffs_staging2
ORDER BY country;


-- To do further analysis on data we need to have the date column in DATE format not in the text format which it is in

SELECT * FROM world_layoffs.layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT * FROM world_layoffs.layoffs_staging2;



-- 3,4 We have null values in total_laid_off, percentage_laid_off and funds_raised_millions columns, we will remove the rows
-- which have null values in both total_laid_off & percentage_laid_off otherwise we wont be able to do our analysis properly


SELECT * FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT * FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * FROM world_layoffs.layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * FROM world_layoffs.layoffs_staging2;



