Select * from layoffs;

#create a copy
CREATE TABLE layoff
LIKE layoffs;

INSERT layoff
SELECT * FROM layoffs;

Select * from layoff;

-------------------------------------------- duplicates---------------------------------------------------------
#checking for duplicates

with dup_cte as
	(select *, row_number() over(partition by company, location, industry, total_laid_off, 
    percentage_laid_off, `date`, stage, country, funds_raised_millions) as dupe
from layoff) 

select *
from dup_cte
where dupe > 1;

#we want to remove one of the rows each
#creating a table layoff2 and then deleting rows with dupe = 2

CREATE TABLE `layoff2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoff2;

insert into layoff2
select *, row_number() over(partition by company, location, industry, total_laid_off, 
    percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoff;

delete from layoff2
where row_num > 1;

------------------------------------------ cleaning data ---------------------------------------------------------
#trimming white space from the company name

select company, trim(company)
from layoff2;

update layoff2
set company = trim(company);

#location
select distinct(location)
from layoff2
order by 1;

update layoff2
set location = 
	case
		when location = 'DÃ¼sseldorf' then 'Düsseldorf'
        when location = 'FlorianÃ³polis' then 'Florianópolis' 
        when location = 'MalmÃ¶' then 'Malmö' 
        else location
	end;

#cleaning industry column
select distinct(industry)
from layoff2
order by 1;

select * 
from layoff2
where industry like 'Crypto%';

update layoff2
set industry = 'Crypto'
where industry like 'Crypto%';
 
#stage
select distinct(stage)
from layoff2
order by 1;

#country
select distinct(country)
from layoff2
order by 1;

#we have 2 united states
update layoff2
set country = 'United States'
where country = 'United States.';

--------- OR ------------
select distinct(country), trim(trailing '.' from country)
from layoff2;

update layoff2
set country = trim(trailing '.' from country)
where country like 'United States%';

#date
select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoff2;

update layoff2
set `date` = str_to_date(`date`, '%m/%d/%Y');

#changing the datatype of date column
alter table layoff2
modify column `date` DATE;


------------------------------------------- null values ---------------------------------------------------------
select *
from layoff2
where total_laid_off is null;

select *
from layoff2
where industry = '' or industry is null;

select *
from layoff2
where company = 'Airbnb';

-- Airbnb - Travel
-- Carvana - Transportation
-- Juul - Consumer

-------- manual
-- update layoff2
-- set industry = 
-- 	case
-- 		when company = 'Airbnb' then 'Travel'
-- 		when company = 'Carvana' then 'Transportation'
--         when company = 'Juul' then 'Consumer'
--         else industry
-- 	end;
    
-- better approach
#changing blanks to null to perform operations

update layoff2
set industry = null
where industry = '';

select t1.industry, t2.industry
from layoff2 t1
join layoff2 t2
	on t1.company = t2.company
where t1.industry is null or t1.industry = ''
and t2.industry is not null;

update layoff2 t1
join layoff2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;


select *
from layoff2
where total_laid_off is null and percentage_laid_off is null;

delete 
from layoff2
where total_laid_off is null and percentage_laid_off is null;

alter table layoff2
drop column row_num;

select *
from layoff2;

