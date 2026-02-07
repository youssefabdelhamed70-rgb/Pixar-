--task 1
SELECT 
    b.film as title,
    ROUND(((b.box_office_worldwide - b.budget) / b.budget) * 100::numeric, 1) AS roi_percentage,
    EXTRACT(YEAR FROM p.release_date) as year,
    b.budget,
    b.box_office_worldwide
FROM 
    box_office as b
JOIN pixar_films as p
    ON b.film = p.film
WHERE 
    b.budget IS NOT NULL
    AND b.budget > 0
ORDER BY roi_percentage DESC;

--task2
SELECT
    film,
    COUNT(*) FILTER (WHERE status = 'Won') as awards_won,
    COUNT(*) FILTER (WHERE status IN ('Won', 'Nominated')) as total_nominations,
    ROUND(
        COUNT(*) FILTER (WHERE status = 'Won') * 100.0 /
        NULLIF(COUNT(*) FILTER (WHERE status IN ('Won', 'Nominated')), 0),
        1
    ) as won_percentage
FROM academy
WHERE status IN ('Won', 'Nominated')
GROUP BY film
HAVING COUNT(*) FILTER (WHERE status = 'Won') > 0
ORDER BY won_percentage DESC;

--task3
SELECT
    g.value as subgenre,
    ROUND(AVG(b.box_office_worldwide::numeric / sc.cnt), 1) as avg_gross_m,
    COUNT(DISTINCT g.film) as film_count
FROM genres g
JOIN (
    SELECT film, COUNT(*) as cnt
    FROM genres
    WHERE LOWER(category) = 'subgenre'
    GROUP BY film
) sc ON sc.film = g.film
JOIN box_office b ON b.film = g.film
WHERE LOWER(g.category) = 'subgenre'
    AND b.box_office_worldwide IS NOT NULL
GROUP BY g.value
HAVING COUNT(DISTINCT g.film) >= 3
ORDER BY avg_gross_m DESC
LIMIT 5;

--task4
SELECT
    pp.name as director,
    ROUND(AVG(REPLACE(pr.rotten_tomatoes_score, '%', '')::numeric), 1) as avg_rt_score,
    ROUND(AVG(bo.box_office_worldwide), 1) as avg_income_m,
    ROUND(AVG(pr.imdb_score), 1) as avg_imdb_score
FROM pixar_people pp
JOIN public_response pr ON pp.film = pr.film
JOIN box_office bo ON pp.film = bo.film
WHERE pp.role_type = 'Director'
GROUP BY pp.name
HAVING COUNT(DISTINCT pp.film) >= 2
ORDER BY avg_income_m DESC;

--task5
SELECT
    CASE
        WHEN f.film LIKE 'toy story%' THEN 'toy story'
        WHEN f.film LIKE 'cars%' THEN 'cars'
        WHEN f.film LIKE 'finding nemo%' OR f.film LIKE 'finding dory%' THEN 'finding nemo/dory'
    END as franchise,
    COUNT(*) as film_count,
    ROUND(SUM(b.box_office_worldwide), 1) as total_gross_m,
    ROUND(AVG(f.run_time), 1) as avg_runtime_min
FROM pixar_films f
JOIN box_office b ON b.film = f.film
WHERE f.film LIKE 'toy story%'
    OR f.film LIKE 'cars%'
    OR f.film LIKE 'finding nemo%'
    OR f.film LIKE 'finding dory%'
GROUP BY franchise
ORDER BY total_gross_m DESC;

--task6
WITH budget_stats AS (
    SELECT
        CASE
            WHEN b.budget < 100 THEN 'low'
            WHEN b.budget BETWEEN 100 AND 150 THEN 'medium'
            WHEN b.budget > 150 THEN 'high'
        END as budget_category,
        ROUND(AVG(REPLACE(pr.metacritic_score, '%', '')::numeric), 1) as avg_metacritic_score,
        ROUND(AVG(b.box_office_worldwide), 1) as avg_worldwide_gross_m,
        COUNT(*) as film_count
    FROM box_office b
    JOIN public_response pr ON pr.film = b.film
    WHERE b.budget IS NOT NULL
    GROUP BY
        CASE
            WHEN b.budget < 100 THEN 'low'
            WHEN b.budget BETWEEN 100 AND 150 THEN 'medium'
            WHEN b.budget > 150 THEN 'high'
        END
)
SELECT *
FROM budget_stats
ORDER BY
    CASE
        WHEN budget_category = 'high' THEN 1
        WHEN budget_category = 'medium' THEN 2
        ELSE 3
    END;

	