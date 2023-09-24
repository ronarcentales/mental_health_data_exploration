-- Dataset at
-- https://www.kaggle.com/datasets/thedevastator/uncover-global-trends-in-mental-health-disorder

-- There are 4 tables within one CSV file. The original CSV file was split into four CSV files.
-- For more information about the contents of the tables:
-- https://www.kaggle.com/code/jankrol21/eda-global-mental-health-disorder/notebook

SELECT *
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages;

SELECT *
FROM mental_health.dbo.mental_health_disorder_share_per_sex_in_percentages;

SELECT *
FROM [mental_health].[dbo].[prevalence-depressive_disorders_per_100k];

SELECT *
FROM mental_health.dbo.suicide_and_depression_per_100k;




-- Which countries have the highest rates of depression?
SELECT Entity, Year, MAX(Depression) as Depression_Rate
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages
WHERE Code IS NOT NULL
GROUP BY Entity, Year
ORDER BY 3 DESC;
-- ***NOTE: Greenland appears to have the highest rates of depression




-- Which countries have the lowest rates of depression?
SELECT Entity, Year, MAX(Depression) as Depression_Rate
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages
WHERE Code IS NOT NULL
GROUP BY Entity, Year
ORDER BY Depression_Rate;
-- ***NOTE: Colombia and Albania appear to have the lowest rates of depression



SELECT DISTINCT(Entity)
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages
WHERE Code IS NULL;
-- There appears to be data for vague locations such as "High-income Asia Pacific"

SELECT DISTINCT(Entity)
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages
WHERE Entity NOT IN ('High SDI', 'High-income','High-income Asia Pacific', 'High-middle SDI', 'Low SDI', 'Low-middle SDI', 'Middle SDI','Northern Ireland')


SELECT *
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages
WHERE Entity NOT IN ('High SDI', 'High-income','High-income Asia Pacific', 'High-middle SDI', 'Low SDI', 'Low-middle SDI', 'Middle SDI','Northern Ireland')
-- This query excludes vague locations such as "High-income"




SELECT *
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages AS disorders
JOIN mental_health.dbo.suicide_and_depression_per_100k AS population
    ON disorders.Entity = population.Entity
    AND disorders.Year = population.Year;

SELECT disorders.Entity,disorders.Code, disorders.Year, disorders.Depression, population.Population, CONVERT(INT, ((Depression/100)*Population)) AS Depressed_Population
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages AS disorders
JOIN mental_health.dbo.suicide_and_depression_per_100k AS population
    ON disorders.Entity = population.Entity
    AND disorders.Year = population.Year
WHERE disorders.Entity NOT IN ('High SDI', 'High-income','High-income Asia Pacific', 'High-middle SDI', 'Low SDI', 'Low-middle SDI', 'Middle SDI','Northern Ireland')
ORDER BY Depressed_Population DESC, Year;
-- ***NOTE: In the year 2017, there are about 260 million people in the world who suffer from depression.
-- ***NOTE: In the years 2000-2017, China and India appear to have the highest depressed populations in the world.






SELECT disorders.Entity,disorders.Code, disorders.Year, population.Population,
       disorders.Schizophrenia,
       CONVERT(INT, ((disorders.Schizophrenia/100)*population.Population)) AS Schizophrenic_Population,
       disorders.Bipolar_disorder,
       CONVERT(INT, ((disorders.Bipolar_disorder/100)*population.Population)) AS Bipolar_Population,
       disorders.Eating_disorders,
       CONVERT(INT, ((disorders.Eating_disorders/100)*population.Population)) AS Eating_Disorder_Population,
       disorders.Anxiety_disorders,
       CONVERT(INT, ((disorders.Anxiety_disorders/100)*population.Population)) AS Anxiety_Population,
       disorders.Drug_use_disorders,
       CONVERT(INT, ((disorders.Drug_use_disorders/100)*population.Population)) AS Drug_Use_Disorder_Population,
       disorders.Depression, 
       CONVERT(INT, ((disorders.Depression/100)*population.Population)) AS Depressed_Population,
       disorders.Alcohol_use_disorders,
       CONVERT(INT, ((disorders.Alcohol_use_disorders/100)*population.Population)) AS Alcoholic_Population,
       population.Suicide_rate_deaths_per_100_000_individuals,
       CONVERT(INT, ((population.Suicide_rate_deaths_per_100_000_individuals/100000)*population.Population)) AS Suicide_Population
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages AS disorders
JOIN mental_health.dbo.suicide_and_depression_per_100k AS population
    ON disorders.Entity = population.Entity
    AND disorders.Year = population.Year
WHERE disorders.Entity NOT IN ('High SDI', 'High-income','High-income Asia Pacific', 'High-middle SDI', 'Low SDI', 'Low-middle SDI', 'Middle SDI','Northern Ireland')
ORDER BY Depressed_Population DESC, Year;
-- ***NOTE: This query contains population information for each type of disorder





WITH population_data (Entity, Code, Year, Population, Schizophrenia, Schizophrenic_Population, Bipolar_disorder, Bipolar_Population,
                      Eating_disorders, Eating_Disorder_Population, Anxiety_disorders, Anxiety_Population, Drug_use_disorders, 
                      Drug_Use_Disorder_Population, Depression, Depressed_Population, Alcohol_use_disorders, Alcoholic_Population,
                      Suicide_rate_deaths_per_100_000_individuals, Suicide_Population)
AS(
SELECT disorders.Entity,disorders.Code, disorders.Year, population.Population,
       disorders.Schizophrenia,
       CONVERT(INT, ((disorders.Schizophrenia/100)*population.Population)) AS Schizophrenic_Population,
       disorders.Bipolar_disorder,
       CONVERT(INT, ((disorders.Bipolar_disorder/100)*population.Population)) AS Bipolar_Population,
       disorders.Eating_disorders,
       CONVERT(INT, ((disorders.Eating_disorders/100)*population.Population)) AS Eating_Disorder_Population,
       disorders.Anxiety_disorders,
       CONVERT(INT, ((disorders.Anxiety_disorders/100)*population.Population)) AS Anxiety_Population,
       disorders.Drug_use_disorders,
       CONVERT(INT, ((disorders.Drug_use_disorders/100)*population.Population)) AS Drug_Use_Disorder_Population,
       disorders.Depression, 
       CONVERT(INT, ((disorders.Depression/100)*population.Population)) AS Depressed_Population,
       disorders.Alcohol_use_disorders,
       CONVERT(INT, ((disorders.Alcohol_use_disorders/100)*population.Population)) AS Alcoholic_Population,
       population.Suicide_rate_deaths_per_100_000_individuals,
       CONVERT(INT, ((population.Suicide_rate_deaths_per_100_000_individuals/100000)*population.Population)) AS Suicide_Population
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages AS disorders
JOIN mental_health.dbo.suicide_and_depression_per_100k AS population
    ON disorders.Entity = population.Entity
    AND disorders.Year = population.Year
WHERE disorders.Entity NOT IN ('High SDI', 'High-income','High-income Asia Pacific', 'High-middle SDI', 'Low SDI', 'Low-middle SDI', 'Middle SDI','Northern Ireland')
-- ORDER BY Depressed_Population DESC, Year
)
SELECT *, SUM(Suicide_Population) OVER (PARTITION BY Entity) AS Total_Suicide_Population_From_1990_to_2017
FROM population_data
ORDER BY Entity, Year;
-- ***NOTE: A Comomon Table Expression is used here to determine the total amount of that people that commited suicide from 1990 to 2017 for each country/location
-- on "Total_Suicide_Populaion_From_1990_to_2017" column





DROP TABLE IF EXISTS disorder_populations
CREATE TABLE disorder_populations
(
    Entity NVARCHAR(255),
    Code NVARCHAR(255),
    Year INT,
    Population FLOAT,
    Schizophrenia FLOAT,
    Schizophrenia_Population FLOAT,
    Bipolar_disorder FLOAT,
    Bipolar_Population FLOAT,
    Eating_disorders FLOAT,
    Eating_Disorder_Population FLOAT,
    Anxiety_disorders FLOAT,
    Anxiety_Population FLOAT,
    Drug_use_disorders FLOAT,
    Drug_Use_Disorder_Population FLOAT,
    Depression FLOAT,
    Depressed_Population FLOAT,
    Alcohol_use_disorders FLOAT,
    Alcoholic_Population FLOAT,
    Suicide_rate_deaths_per_100_000_individuals FLOAT,
    Suicide_Population FLOAT,
)
INSERT INTO disorder_populations
SELECT disorders.Entity,disorders.Code, disorders.Year, population.Population,
       disorders.Schizophrenia,
       CONVERT(INT, ((disorders.Schizophrenia/100)*population.Population)) AS Schizophrenic_Population,
       disorders.Bipolar_disorder,
       CONVERT(INT, ((disorders.Bipolar_disorder/100)*population.Population)) AS Bipolar_Population,
       disorders.Eating_disorders,
       CONVERT(INT, ((disorders.Eating_disorders/100)*population.Population)) AS Eating_Disorder_Population,
       disorders.Anxiety_disorders,
       CONVERT(INT, ((disorders.Anxiety_disorders/100)*population.Population)) AS Anxiety_Population,
       disorders.Drug_use_disorders,
       CONVERT(INT, ((disorders.Drug_use_disorders/100)*population.Population)) AS Drug_Use_Disorder_Population,
       disorders.Depression, 
       CONVERT(INT, ((disorders.Depression/100)*population.Population)) AS Depressed_Population,
       disorders.Alcohol_use_disorders,
       CONVERT(INT, ((disorders.Alcohol_use_disorders/100)*population.Population)) AS Alcoholic_Population,
       population.Suicide_rate_deaths_per_100_000_individuals,
       CONVERT(INT, ((population.Suicide_rate_deaths_per_100_000_individuals/100000)*population.Population)) AS Suicide_Population
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages AS disorders
JOIN mental_health.dbo.suicide_and_depression_per_100k AS population
    ON disorders.Entity = population.Entity
    AND disorders.Year = population.Year
WHERE disorders.Entity NOT IN ('High SDI', 'High-income','High-income Asia Pacific', 'High-middle SDI', 'Low SDI', 'Low-middle SDI', 'Middle SDI','Northern Ireland')
-- ORDER BY Depressed_Population DESC, Year
SELECT *, SUM(Suicide_Population) OVER (PARTITION BY CONVERT(VARCHAR(255), Entity) ORDER BY CONVERT(VARCHAR(255), Entity), Year) AS Rolling_Suicide_Population_Since_1990
FROM disorder_populations
ORDER BY Entity, Year;
-- ***NOTE: A temporary table is used to determine the cumulative sum of suicides for each year since 1990 in the "Rolling_Suicide_Population_Since_1990" column






CREATE VIEW disorders_and_suicide_populations AS
SELECT disorders.Entity,disorders.Code, disorders.Year, population.Population,
       disorders.Schizophrenia,
       CONVERT(INT, ((disorders.Schizophrenia/100)*population.Population)) AS Schizophrenic_Population,
       disorders.Bipolar_disorder,
       CONVERT(INT, ((disorders.Bipolar_disorder/100)*population.Population)) AS Bipolar_Population,
       disorders.Eating_disorders,
       CONVERT(INT, ((disorders.Eating_disorders/100)*population.Population)) AS Eating_Disorder_Population,
       disorders.Anxiety_disorders,
       CONVERT(INT, ((disorders.Anxiety_disorders/100)*population.Population)) AS Anxiety_Population,
       disorders.Drug_use_disorders,
       CONVERT(INT, ((disorders.Drug_use_disorders/100)*population.Population)) AS Drug_Use_Disorder_Population,
       disorders.Depression, 
       CONVERT(INT, ((disorders.Depression/100)*population.Population)) AS Depressed_Population,
       disorders.Alcohol_use_disorders,
       CONVERT(INT, ((disorders.Alcohol_use_disorders/100)*population.Population)) AS Alcoholic_Population,
       population.Suicide_rate_deaths_per_100_000_individuals,
       CONVERT(INT, ((population.Suicide_rate_deaths_per_100_000_individuals/100000)*population.Population)) AS Suicide_Population
FROM mental_health.dbo.mental_health_disorder_shares_in_percentages AS disorders
JOIN mental_health.dbo.suicide_and_depression_per_100k AS population
    ON disorders.Entity = population.Entity
    AND disorders.Year = population.Year
WHERE disorders.Entity NOT IN ('High SDI', 'High-income','High-income Asia Pacific', 'High-middle SDI', 'Low SDI', 'Low-middle SDI', 'Middle SDI','Northern Ireland');
-- ORDER BY Depressed_Population DESC, Year





CREATE VIEW population_data AS
SELECT *, SUM(Suicide_Population) OVER (PARTITION BY CONVERT(VARCHAR(255), Entity) ORDER BY CONVERT(VARCHAR(255), Entity), CONVERT(INT, Year)) AS Rolling_Suicide_Population_Since_1990
FROM disorders_and_suicide_populations;
-- ***NOTE: A View has been created to create other Views for possible later visualizations

SELECT DISTINCT(Entity)
FROM population_data
WHERE CODE IS NULL;


CREATE VIEW regional_data AS
SELECT *
FROM population_data
WHERE Entity IN ('Andean Latin America', 
                'Australasia', 
                'Caribbean', 
                'Central Asia', 
                'Central Europe',
                'Central Latin America',
                'Central Sub-Saharan Africa',
                'East Asia',
                'Eastern Europe',
                'Eastern Sub-Saharan Africa',
                'Latin America and Caribbean',
                'North Africa and Middle East',
                'North America',
                'Oceania',
                'South Asia',
                'Southeast Asia',
                'Southern Latina America',
                'Southern Sub-Saharan Africa',
                'Sub-Saharan Africa',
                'Tropical Latin America',
                'Western Europe',
                'Western Sub-Saharan Africa')
-- This View countains only regional data

CREATE VIEW country_data AS
SELECT *
FROM population_data
WHERE Entity NOT IN ('Andean Latin America', 
                'Australasia', 
                'Caribbean', 
                'Central Asia', 
                'Central Europe',
                'Central Europe, Eastern Europe, and Central Asia',
                'Central Latin America',
                'Central Sub-Saharan Africa',
                'East Asia',
                'Eastern Europe',
                'Eastern Sub-Saharan Africa',
                'Latin America and Caribbean',
                'North Africa and Middle East',
                'North America',
                'Oceania',
                'South Asia',
                'Southeast Asia',
                'Southeast Asia, East Asia, and Oceania',
                'Southern Latina America',
                'Southern Sub-Saharan Africa',
                'Sub-Saharan Africa',
                'Tropical Latin America',
                'Western Europe',
                'Western Sub-Saharan Africa');
-- This View contains only country data

CREATE VIEW world_data AS
SELECT *
FROM population_data
WHERE Entity IN ('World');
-- This view contains only world data
