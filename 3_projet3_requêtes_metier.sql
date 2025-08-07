-- projet 3 OCR  requête métier

-- 1.  Nombre total d’appartements vendus au 1er semestre 2020.
SELECT COUNT(sale_id) as nbr_appartement_sale
FROM projet3_ocr_immo.sales as s
LEFT JOIN projet3_ocr_immo.properties as p
USING(property_id)
WHERE p.property_type LIKE "Appartement"
	AND MONTH(date_date) BETWEEN 1 AND 6
	AND YEAR(date_date) = 2020;
    
    
 -- 2.  Le nombre de ventes d’appartement par région pour le 1er semestre
WITH sales_info2 AS (
	SELECT 
		s.sale_id,
		s.date_date,
		p.property_type,
		r.reg_name
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id 
        )
    
SELECT 
	COUNT(sale_id) as nbr_appartement_sale
	, reg_name
FROM sales_info2
WHERE property_type LIKE "Appartement"
	AND MONTH(date_date) BETWEEN 1 AND 6
	AND YEAR(date_date) = 2020
GROUP BY reg_name
ORDER BY COUNT(sale_id) DESC;


-- 3 Proportion des ventes d’appartements par le nombre de pièces.
-- vue des infos des sales
WITH sales_info3 AS (
	SELECT
		s.sale_id,
		p.property_type,
		p.number_main_rooms
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id )

SELECT 
    number_main_rooms,
    COUNT(sale_id) AS nbr_appartement_sale,
    -- Windows function sur le total de sale pour l'utiliser sur le calcul de la proportion 
    ROUND(COUNT(sale_id) / SUM(COUNT(sale_id)) OVER () * 100.0 , 2) AS proportion_percent
FROM sales_info3
WHERE property_type LIKE "Appartement"
GROUP BY number_main_rooms
ORDER BY proportion_percent DESC;    


-- 4  Liste des 10 départements où le prix du mètre carré est le plus élevé.
WITH sales_info4 AS(
	SELECT
		s.sale_id,
		s.property_value,
		p.surface_carrez,
		d.dep_name
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id )

SELECT 
  dep_name,
 ROUND(AVG(property_value / surface_carrez),0) as avg_price_m2
FROM sales_info4
GROUP BY dep_name
ORDER BY AVG(property_value / surface_carrez)  DESC
LIMIT 10;    


-- 5  Prix moyen du mètre carré d’une maison en Île-de-France.

WITH sales_info5 AS(
	SELECT
		s.sale_id,
		s.property_value,
		p.property_type,
		p.surface_carrez,
		r.reg_name
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id)

SELECT 
	ROUND(AVG(property_value / surface_carrez),0) as avg_price_m2_IDF_House
FROM sales_info5
WHERE reg_name LIKE "Ile-de-France"
	AND property_type LIKE "Maison" ;


-- 6  Liste des 10 appartements les plus chers avec la région et le nombre de mètres carrés.

WITH sales_info6 AS (
	SELECT
		s.sale_id,
        s.property_id,
		s.property_value,
		p.property_type,
		p.surface_carrez,
		r.reg_name
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id )

SELECT 
	property_id,
    property_value,
    reg_name,
    surface_carrez
FROM sales_info6
WHERE property_type LIKE "Appartement"
ORDER BY property_value DESC
LIMIT 10;



-- 7  Taux d’évolution du nombre de ventes entre le premier et le second trimestre de 2020
WITH sales_info7 AS (
	SELECT 
		s.sale_id,
		s.date_date,
		p.property_type,
		r.reg_name
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id),

 first_trimestre_sales AS (
	SELECT COUNT(sale_id) as nbr_sale_first_trimestre
	FROM sales_info7
	WHERE MONTH(date_date) BETWEEN 1 AND 3
		AND YEAR(date_date) = 2020),
        
second_trimestre_sales AS (
	SELECT COUNT(sale_id) as nbr_sale_second_trimestre
	FROM sales_info7
	WHERE MONTH(date_date) BETWEEN 4 AND 6
		AND YEAR(date_date) = 2020
        )

SELECT 
	round (
		(nbr_sale_second_trimestre - nbr_sale_first_trimestre) / nbr_sale_second_trimestre * 100 , 2
        )AS evol_sales_first_second_trimestre
    FROM first_trimestre_sales
		JOIN second_trimestre_sales

-- Je n'ai pas de donnée sur le second semestre 2020, c'est pour cela que le résultat est null. J'ai vérifié cela dans les raw_data


--  8   Le classement des régions par rapport au prix au mètre carré des appartement de plus de 4 pièces.
WITH sales_info8 AS (
	SELECT
		s.sale_id,
		s.property_value,
		p.property_type,
		p.surface_carrez,
		r.reg_name,
		p.number_main_rooms
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id )

SELECT 
	reg_name,
	ROUND(AVG(property_value / surface_carrez),0) as avg_price_m2
FROM sales_info8
WHERE number_main_rooms > 4
	AND property_type LIKE "Appartement" 
GROUP BY reg_name
ORDER BY ROUND(AVG(property_value / surface_carrez),0) DESC;



-- 9   Liste des communes ayant eu au moins 50 ventes au 1er trimestre
WITH sales_info9 AS(
	SELECT
		s.sale_id,
		c.com_name,
		s.date_date
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id)

SELECT 
	com_name,
	COUNT(sale_id) as nbr_sale_first_semestre
FROM sales_info9
WHERE MONTH(date_date) BETWEEN 1 AND 6
	AND YEAR(date_date) = 2020
GROUP BY com_name
HAVING COUNT(sale_id) > 50
ORDER BY COUNT(sale_id) DESC ;       


-- 10  Différence en pourcentage du prix au mètre carré entre un appartement de 2 pièces et un appartement de 3 pièces.

WITH sales_info10 AS (
	SELECT 
		p.number_main_rooms,
		s.sale_id,
		s.property_value,
		p.property_type,
		p.surface_carrez
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id )

, pricem2_room2 AS (
	SELECT ROUND(AVG(property_value / surface_carrez),0) as avg_price_m2_rooms2
	FROM sales_info10
	WHERE number_main_rooms = 2
		AND property_type LIKE "Appartement"
        )
        
, pricem2_room3 AS (
	SELECT ROUND(AVG(property_value / surface_carrez),0) as avg_price_m2_rooms3
	FROM sales_info10
	WHERE number_main_rooms IN (3,2)
		AND property_type LIKE "Appartement"
        )

SELECT 
  ROUND(
    ((avg_price_m2_rooms2 - avg_price_m2_rooms3) / avg_price_m2_rooms2) * 100,
    2
  ) AS diff_price_room2_3_percent
FROM pricem2_room2 CROSS JOIN pricem2_room3;
-- pas sure du cross join : ne fonctionne que parce qu'il y en a deux



-- 11  Les moyennes de valeurs foncières pour le top 3 des communes des départements 6, 13, 33, 59 et 69.

WITH sales_info11 AS (
	SELECT 
		s.sale_id,
		s.property_value,
		c.com_name,
		d.dep_id
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id 
        )

, avg_value_com AS (
	SELECT
		ROUND(AVG(property_value),0) as avg_property_value,
		com_name,
		dep_id
	FROM sales_info11
		WHERE dep_id IN (6, 13, 33, 59, 69)
		GROUP BY com_name, dep_id
		)
-- j'ajoute un rank pour connaitre les plus importantes
, rank_com AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY dep_id ORDER BY avg_property_value DESC) AS rank_dep
    FROM avg_value_com
	)

SELECT 
    dep_id,
    com_name,
    rank_dep,
    avg_property_value
FROM rank_com
WHERE rank_dep <= 3
ORDER BY dep_id, avg_property_value DESC;

-- 12 Les 20 communes avec le plus de transactions pour 1000 habitants 

WITH sales_info12 AS (
	SELECT 
		s.sale_id,
		c.com_name,
		d.dep_id,
		c.pop_total
	FROM projet3_ocr_immo.sales AS s
	JOIN projet3_ocr_immo.properties AS p 
		ON s.property_id = p.property_id
	JOIN projet3_ocr_immo.communes AS c 
		ON p.com_id = c.com_id
	JOIN projet3_ocr_immo.departements AS d 
		ON c.dep_id = d.dep_id
	JOIN projet3_ocr_immo.regions AS r 
		ON d.reg_id = r.reg_id
	)

,transactions_per_com AS (
    SELECT 
		com_name,
        COUNT(sale_id) AS nbr_sales,
        MAX(pop_total) AS population
   FROM sales_info12
   GROUP BY com_name
)

SELECT 
	com_name,
	ROUND(nbr_sales / population * 1000, 2) AS sales_per_1000
FROM transactions_per_com
ORDER BY sales_per_1000 DESC
LIMIT 20;
