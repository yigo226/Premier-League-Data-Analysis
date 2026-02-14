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

# Charger les données
df_rank = pd.read_csv("data/raw/weeklyrank.csv")

# Sélection et Renommons pour coller au SQL 
# CSV colonnes ['Team', 'GD', 'Points', 'Rank', 'Week']
df_rank = df_rank[['Team', 'GD', 'Points', 'Rank', 'Week']]

df_rank.columns = ['team', 'goal_difference', 'points', 'rank_position', 'week']

# Nettoyer les NaN
df_rank = df_rank.where(pd.notnull(df_rank), None)

# Requête SQL pour insérer les données dans la table weekly_rank
sql_rank = """
INSERT INTO weekly_rank 
(team, goal_difference, points, rank_position, week) 
VALUES (%s, %s, %s, %s, %s)
"""

# Conversion en liste de tuples et insertion
values_rank = [tuple(row) for row in df_rank.values]

try:
    cursor.executemany(sql_rank, values_rank)
    conn.commit()
    print(f"Succès : {cursor.rowcount} lignes de classement insérées.")
except mysql.connector.Error as err:
    print(f"Erreur lors de l'insertion : {err}")
finally:
    cursor.close()
    conn.close()


print("Données brutes de classement hebdomadaire sont insérées.")
