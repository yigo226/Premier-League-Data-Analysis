import os
import pandas as pd
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

# Je vérifie pour voir si les données brutes sont de qualité 
# A savoir - Doublons - Valeurs manquantes - Aberrations (ex: score de 10-0)

def run_health_check():
    # 1. Connexion à la base
    conn = mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )
    
    print("--- RAPPORT DE SANTÉ DES DONNÉES (Table: matches) ---\n")

    # 2. Vérification des Doublons
    query_doublons = """
    SELECT home_team, away_team, match_date, COUNT(*) as nb 
    FROM matches 
    GROUP BY home_team, away_team, match_date 
    HAVING nb > 1
    """
    doublons = pd.read_sql(query_doublons, conn)
    print(f"Matchs en double : {len(doublons)}")
    if not doublons.empty:
        print(doublons)

    # 3. Vérification des Valeurs Nulles (MISSING VALUES)
    query_nulls = "SELECT * FROM matches"
    df = pd.read_sql(query_nulls, conn)
    null_counts = df.isnull().sum()
    print("\nValeurs manquantes par colonne :")
    print(null_counts[null_counts > 0] if null_counts.any() else "Aucune valeur manquante.")

    # 4. Vérification des Aberrations (Outliers de scores)
    query_outliers = "SELECT * FROM matches WHERE home_goals > 9 OR away_goals > 9"
    outliers = pd.read_sql(query_outliers, conn)
    print(f"\nScores fleuves (>9 buts) détectés : {len(outliers)}")
    if not outliers.empty:
        print(outliers[['match_date', 'home_team', 'away_team', 'home_goals', 'away_goals']])

    # 5. Cohérence des Dates
    query_dates = "SELECT MIN(match_date) as debut, MAX(match_date) as fin FROM matches"
    dates = pd.read_sql(query_dates, conn)
    print(f"\nPériode couverte : du {dates['debut'][0]} au {dates['fin'][0]}")

    # 6. Statistiques rapides sur les colonnes numériques
    print("\nStatistiques descriptives (Vérification des échelles) :")
    print(df[['home_goals', 'away_goals', 'home_shots', 'away_shots']].describe().loc[['min', 'max', 'mean']])

    conn.close()
    print("\n--- FIN DU RAPPORT ---")

if __name__ == "__main__":
    run_health_check()
