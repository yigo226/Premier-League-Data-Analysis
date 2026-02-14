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

# Intérrogeons les données maintenant


