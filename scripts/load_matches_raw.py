import os
import pandas as pd
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

# Connection avec la base de données MySQL
conn = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)
# Créer un curseur pour exécuter les requêtes SQL
cursor = conn.cursor()

# Lire le fichier soccer.csv
df = pd.read_csv("data/raw/soccer21-22.csv")

#  Sélection et renommons les colonnes du DataFrame pour correspondre à MySQL
df = df[['Date', 'HomeTeam', 'AwayTeam', 'FTHG', 'FTAG', 'FTR', 
         'HTHG', 'HTAG', 'HTR', 'Referee', 'HS', 'AS', 'HST', 
         'AST', 'HF', 'AF', 'HC', 'AC', 'HY', 'AY', 'HR', 'AR']]

#  TABLE
df.columns = [
    'match_date', 'home_team', 'away_team', 'home_goals', 'away_goals', 'result',
    'ht_home_goals', 'ht_away_goals', 'ht_result', 'referee', 'home_shots', 
    'away_shots', 'home_shots_target', 'away_shots_target', 'home_fouls', 
    'away_fouls', 'home_corners', 'away_corners', 'home_yellow', 'away_yellow', 
    'home_red', 'away_red'
]

# Conversion de la date (Format CSV "dd/mm/yyyy" -> Format MySQL "yyyy-mm-dd")
df['match_date'] = pd.to_datetime(df['match_date'], dayfirst=True).dt.strftime('%Y-%m-%d')

# Remplacer les NaN
df = df.where(pd.notnull(df), None)

# Préparer la requête SQL avec les nouveaux noms 
# pour éviter les conflits avec les mots réservés de MySQL (ex: AS, Date, Referee)
sql = """
INSERT INTO matches 
(match_date, home_team, away_team, home_goals, away_goals, result,
 ht_home_goals, ht_away_goals, ht_result, referee, home_shots, 
 away_shots, home_shots_target, away_shots_target, home_fouls, 
 away_fouls, home_corners, away_corners, home_yellow, away_yellow, 
 home_red, away_red)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
"""

values = [tuple(row) for row in df.values]

cursor.executemany(sql, values)
conn.commit()
# # Remplacer NaN par None (important pour MySQL)
# df = df.where(pd.notnull(df), None)

# sql = """
# INSERT INTO matches
# (Date, HomeTeam, AwayTeam, FTHG, FTAG, FTR,
#  HTHG, HTAG, HTR, Referee,
#  HS, `AS`, HST, AST, HF, AF,
#  HC, AC, HY, AY, HR, AR)
# VALUES (%s, %s, %s, %s, %s, %s,
#         %s, %s, %s, %s,
#         %s, %s, %s, %s, %s, %s,
#         %s, %s, %s, %s, %s, %s)
# """

# values = [tuple(row) for row in df.values]

# cursor.executemany(sql, values)
# conn.commit()

cursor.close()
conn.close()

print(" Données brutes des matchs sont insérées.")
