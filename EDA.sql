select * from practice.layoff2;

select max(total_laid_off)
from layoff2;


-- company with the highest number of layoff
select *
from layoff2
where total_laid_off =
	(select max(total_laid_off)
		from layoff2);

-- companies not in business anymore
select distinct company
from layoff2
where percentage_laid_off = 1;

-- top 10 companies which raised tons of money and still not in business anymore
select company, funds_raised_millions
from layoff2
where percentage_laid_off = 1
order by funds_raised_millions desc
limit 10;

-- industries most affected
select distinct industry, count(*) as 'count'
from layoff2
group by industry
order by count(*) desc;
#industry where most layoffs occured (even if not in terms of employee count)

-- industries with most total layoffs
select industry, sum(total_laid_off)
from layoff2
group by industry
order by sum(total_laid_off) desc;
# this is in terms of employee count

-- company with the highest layoff in a single go
select company, total_laid_off
from layoff2
where total_laid_off in
		(select total_laid_off 
		 from layoff2)
order by total_laid_off desc;

-- companies with most total layoff
select company, sum(total_laid_off) as `total`
from layoff2
group by company
order by 2 desc
limit 10;

-- by location
select location, sum(total_laid_off) as `total`
from layoff2
group by location
order by 2 desc
limit 10;

-- country
select country, sum(total_laid_off) as `total`
from layoff2
group by country
order by 2 desc
limit 10;

-- year
select year(date), sum(total_laid_off) as `total`
from layoff2
where date is not null
group by year(date)
order by 2 desc;

-- by stage
select stage, SUM(total_laid_off)
from layoff2
group by stage
order by 2 desc;

-- top 3 companies each year
with company_yr as
(select company, sum(total_laid_off) as total_laid_off, year(date) as `years`
from layoff2
where year(date) is not null
group by company, year(date)),
company_yr_rank as
(select company, `years`, total_laid_off,
dense_rank() over(partition by years order by total_laid_off desc) as `rank`
from company_yr)

select company, years, total_laid_off, `rank`
from company_yr_rank
where `rank` <= 3;

-- rolling total
with date_cte as
(select concat(year(date), '-', month(date)) as dates, sum(total_laid_off) as `total_laid_off`
from layoff2
where month(date) is not null and total_laid_off is not null
group by dates
order by dates)
select dates, sum(total_laid_off) over(order by dates) as rolling_total
from date_cte
order by rolling_total desc;
