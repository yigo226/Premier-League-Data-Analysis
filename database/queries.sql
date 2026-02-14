USE premier_league;

-- Création de la table principale contenant les statistiques des matchs
CREATE TABLE matches (
    
    -- Identifiant unique du match
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Date du match
    match_date DATE,
    
    -- Nom de l'équipe jouant à domicile
    home_team VARCHAR(100),
    
    -- Nom de l'équipe jouant à l'extérieur
    away_team VARCHAR(100),
    
    -- Nombre de buts marqués par l'équipe à domicile (score final)
    home_goals INT,
    
    -- Nombre de buts marqués par l'équipe à l'extérieur (score final)
    away_goals INT,
    
    -- Résultat final du match :
    -- H = Victoire domicile, A = Victoire extérieur, D = Match nul
    result CHAR(1),

    -- Buts marqués à la mi-temps par l'équipe à domicile
    ht_home_goals INT,
    
    -- Buts marqués à la mi-temps par l'équipe à l'extérieur
    ht_away_goals INT,
    
    -- Résultat à la mi-temps (H / A / D)
    ht_result CHAR(1),

    -- Nom de l'arbitre principal du match
    referee VARCHAR(100),

    -- Nombre total de tirs effectués par l'équipe à domicile
    home_shots INT,
    
    -- Nombre total de tirs effectués par l'équipe à l'extérieur
    away_shots INT,
    
    -- Nombre de tirs cadrés par l'équipe à domicile
    home_shots_target INT,
    
    -- Nombre de tirs cadrés par l'équipe à l'extérieur
    away_shots_target INT,

    -- Nombre total de fautes commises par l'équipe à domicile
    home_fouls INT,
    
    -- Nombre total de fautes commises par l'équipe à l'extérieur
    away_fouls INT,

    -- Nombre de corners obtenus par l'équipe à domicile
    home_corners INT,
    
    -- Nombre de corners obtenus par l'équipe à l'extérieur
    away_corners INT,

    -- Nombre de cartons jaunes reçus par l'équipe à domicile
    home_yellow INT,
    
    -- Nombre de cartons jaunes reçus par l'équipe à l'extérieur
    away_yellow INT,

    -- Nombre de cartons rouges reçus par l'équipe à domicile
    home_red INT,
    
    -- Nombre de cartons rouges reçus par l'équipe à l'extérieur
    away_red INT
);

-- Création de la table contenant le classement des équipes par semaine
CREATE TABLE weekly_rank (
    
    -- Identifiant unique de l'enregistrement
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Nom de l'équipe concernée par le classement hebdomadaire
    team VARCHAR(100),
    
    -- Différence de buts (buts marqués - buts encaissés)
    goal_difference INT,
    
    -- Nombre total de points accumulés par l'équipe à cette semaine
    -- (3 points victoire, 1 point nul, 0 point défaite)
    points INT,
    
    -- Position de l'équipe dans le classement pour la semaine donnée
    rank_position INT,
    
    -- Numéro de la semaine (journée de championnat)
    week INT
);

# -- Intérrogeons les données maintenant

# -- matches
-- Le nombre de match
SELECT COUNT(*) FROM matches;

-- Période couverte 
SELECT MIN(match_date), MAX(match_date) FROM matches;

-- Nombre d’équipes 
SELECT COUNT(DISTINCT home_team) FROM matches;

-- Évolution des buts

SELECT 
    YEAR(match_date) AS season_year,
    ROUND(AVG(home_goals + away_goals),2) AS avg_goals_per_match,
    SUM(home_goals + away_goals) AS total_goals
FROM matches
GROUP BY YEAR(match_date)
ORDER BY season_year;

--  Avantage à domicile
-- de chaque année
SELECT 
    YEAR(match_date) AS season_year,
    ROUND(AVG(home_goals), 2) AS avg_home_goals,
    ROUND(AVG(away_goals), 2) AS avg_away_goals
FROM matches
GROUP BY YEAR(match_date);
-- pour les deux ans
SELECT 
    ROUND(AVG(home_goals),2) AS avg_home_goals,
    ROUND(AVG(away_goals),2) AS avg_away_goals
FROM matches;


-- victoire domicile

SELECT 
    ROUND(
        SUM(CASE WHEN home_goals > away_goals THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 2
    ) AS home_win_percentage
FROM matches;


# Club les plus performants

SELECT team, SUM(goals) AS total_goals
FROM (
    SELECT home_team AS team, home_goals AS goals FROM matches
    UNION ALL
    SELECT away_team AS team, away_goals AS goals FROM matches
) t
GROUP BY team
ORDER BY total_goals DESC
LIMIT 5;


# Efficacite des tirs - buts
SELECT 
    ROUND(AVG(home_goals / NULLIF(home_shots_target,0)),3) AS home_efficiency,
    ROUND(AVG(away_goals / NULLIF(away_shots_target,0)),3) AS away_efficiency
FROM matches;

# SQL Avancée manip
-- Classement offensif avec RANK()
SELECT 
    team,
    total_goals,
    RANK() OVER (ORDER BY total_goals DESC) AS offensive_rank
FROM (
    SELECT team, SUM(goals) AS total_goals
    FROM (
        SELECT home_team AS team, home_goals AS goals FROM matches
        UNION ALL
        SELECT away_team AS team, away_goals AS goals FROM matches
    ) t
    GROUP BY team
) ranked;

-- Le nombre buts par match 
SELECT 
    home_team,
    match_date,
    (home_goals - away_goals) AS goal_difference
FROM matches
ORDER BY match_date;

-- Moyenne mobile (performance d'une équipe )
SELECT 
    home_team,       -- L'équipe qui joue à domicile
    match_date,      -- La date du match (essentielle pour l'ordre chronologique)
    home_goals,      -- Le nombre de buts marqués lors de ce match précis
    
    -- Calcul de la moyenne mobile (Rolling Average)
    AVG(home_goals) OVER (
        -- On regroupe les calculs par équipe (le compteur repart à zéro pour chaque équipe)
        PARTITION BY home_team 
        
        -- On classe les matchs du plus ancien au plus récent
        ORDER BY match_date 
        
        -- On définit la "fenêtre" de calcul : 
        -- Les 4 matchs précédents + le match actuel = total de 5 matchs
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS rolling_avg_last_5 -- Nom de la nouvelle colonne calculée
FROM matches;

# Jointure de matches et weekly_rank
-- Objectif : Savoir si les équipes en haut du classement plus de but

-- Jointure sur une équipe 
SELECT 
    rank_stats.team,
    rank_stats.avg_rank,
    goal_stats.total_goals_at_home
FROM (
    -- On calcule la moyenne de rang par équipe
    SELECT team, AVG(rank_position) AS avg_rank 
    FROM weekly_rank 
    GROUP BY team
) AS rank_stats
JOIN (
    -- On calcule le total de buts marqués/encaissés à domicile
    SELECT home_team, SUM(home_goals + away_goals) AS total_goals_at_home 
    FROM matches 
    GROUP BY home_team
) AS goal_stats 
ON rank_stats.team = goal_stats.home_team
ORDER BY rank_stats.avg_rank;


--  correlation simple classemnt - buts
SELECT 
    rank_stats.team,
    rank_stats.avg_rank,      -- Moyenne de la position au classement
    goal_stats.total_home_goals -- Total réel des buts à domicile
FROM (
    -- Sous-requête 1 : Calcul de la moyenne de rang (Table weekly_rank)
    SELECT team, AVG(rank_position) AS avg_rank 
    FROM weekly_rank 
    GROUP BY team
) AS rank_stats
JOIN (
    -- Sous-requête 2 : Calcul des buts réels (Table matches)
    SELECT home_team, SUM(home_goals) AS total_home_goals 
    FROM matches 
    GROUP BY home_team
) AS goal_stats 
ON rank_stats.team = goal_stats.home_team
	-- Optionnel : trier par performance
ORDER BY rank_stats.avg_rank; 





