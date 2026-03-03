# 🎯 CS2 Major Analytics — StarLadder Budapest 2025

> **An end-to-end esports data analytics project** using SQL and interactive dashboards to analyse team performance, player statistics, map balance, and economy patterns across the StarLadder Budapest Major 2025 — the fourth CS2 Major Championship.

---

## 📌 Project Overview

This project demonstrates core data analyst skills applied to a real-world esports dataset: data modelling, SQL querying, KPI analysis, and visual storytelling. It covers all 32 teams, 20 top players, 6 maps, and the complete Grand Final in detail.

**Business / Analytical Questions Answered:**
- Which players performed best across the full event — and does team success predict individual performance?
- How balanced is each map in the pool from a CT vs T win rate perspective?
- What economy strategies (Full Buy / Force Buy / Eco) win the most rounds?
- How far did each team progress through the Swiss stages, and what did they earn?
- What made Team Vitality's Grand Final run statistically dominant?

---

## 🏆 Tournament Summary

| | |
|---|---|
| **Event** | StarLadder Budapest Major 2025 |
| **Dates** | November 24 – December 14, 2025 |
| **Venue** | MVM Dome, Budapest, Hungary |
| **Teams** | 32 (directly invited via Valve Regional Standings) |
| **Prize Pool** | $1,250,000 USD |
| **Format** | 3× Swiss stages → 8-team single-elimination playoffs |
| **Grand Final** | First-ever Best-of-5 in Major history |
| **Champion** | **Team Vitality** (def. FaZe Clan 3–1) |
| **MVP** | ZywOo — his **3rd Major MVP**, the most in CS history |

---

## 📊 Key Findings

1. **Vitality — first back-to-back Major champions since Astralis 2019.** They won both the Austin 2025 and Budapest 2025 Majors in the same calendar year, matching Astralis's legendary single-season dominance.

2. **donk posted the highest rating (1.57) despite Spirit's semifinal exit.** This is a critical insight: individual performance does not guarantee team success, especially in a system where one bad map can end a run.

3. **ZywOo's historic third MVP came down to the tightest race in Major history.** His KPRW (kills per round win) of 1.17 edged out ropz (1.02) and mezii (0.92) — three Vitality players finished inside the top-4 rated at the event.

4. **ropz posted a 2.89 rating on Overpass in Map 4 of the Grand Final** — his career-best single-map performance. He recorded a 22-7 K-D, 144.1 ADR, and +18.78 Round Swing as Vitality closed out the title 13-2.

5. **Nuke had the highest CT win rate (62%) of any map in the pool.** FaZe deliberately selected it as their Map 1 Grand Final pick to leverage this advantage. karrigan posted a 2.90 rating there, securing FaZe's only map win.

6. **Vitality won 62.5% of pistol rounds in the Grand Final**, directly converting those into bonus-round sequences. Their 67.6% full buy win rate reflects dominant rifle-round execution.

7. **The top 4 teams earned 66.4% of the prize pool ($830K of $1.25M).** Eight Stage 1 teams left with nothing. The winner-take-most structure creates high-stakes pressure at every match.

---

## 🗂 Dataset Schema

The project uses a normalised relational schema designed for **PostgreSQL**, **Snowflake**, and **BigQuery** compatibility.

| Table | Description |
|---|---|
| `teams` | 32 teams — name, region, VRS seeding |
| `players` | Player profiles — team, country, role |
| `matches` | Match metadata — stage, format (BO1/BO3/BO5), date |
| `maps` | Individual maps within each match |
| `rounds` | Round-level data — winner, buy type, round number |
| `player_map_stats` | Per-player per-map stats — rating, kills, deaths, ADR, KAST |
| `team_stage_results` | Team W/L record per Swiss stage |
| `stages` | Stage definitions — Stage 1, 2, 3, Playoffs |
| `prizes` | Prize money per team placement |

**Key relationships:**
- `players` → `teams` via `team_id`
- `maps` → `matches` via `match_id`
- `rounds` → `maps` via `map_id`
- `player_map_stats` → `players` via `player_id` and `maps` via `map_id`
- `team_stage_results` → `teams` + `stages` via their respective IDs

---

## 🔍 SQL Techniques Demonstrated

| Query | Concepts Used |
|---|---|
| `01_player_rating_leaderboard.sql` | CTE, `AVG`, `COUNT`, `RANK()` window function, `HAVING`, `NULLIF` safe division |
| `02_map_ct_t_win_rate.sql` | `CASE WHEN` conditional aggregation, `GROUP BY`, ratio calculation, map bias classification |
| `03_economy_round_analysis.sql` | Multi-CTE pipeline, buy type classification, `SUM`, `ROUND`, performance labelling |
| `04_peak_map_performance.sql` | `ROW_NUMBER()` window function, `PARTITION BY`, computed K/D column, `JOIN` chain |
| `05_team_stage_progression.sql` | `LEFT JOIN`, `MAX` per group, `COALESCE`, prize pool share %, tier labelling |

---

## 🛠 Tools & Technologies

- **SQL** — PostgreSQL / Snowflake / BigQuery compatible syntax
- **Excel** — Full dataset across 6 sheets with conditional formatting and formulas
- **JavaScript / Chart.js** — Interactive dashboard with 5 tabs and live charts
- **HTML / CSS** — Dark-themed esports dashboard layout

---

## 📁 Project Files

```
cs2-budapest-major-2025/
├── README.md                              ← You are here
├── cs2_budapest_major_2025.html           ← Interactive dashboard (open in browser)
├── cs2_budapest_major_2025.xlsx           ← Full dataset across 6 sheets
└── sql/
    ├── 01_player_rating_leaderboard.sql
    ├── 02_map_ct_t_win_rate.sql
    ├── 03_economy_round_analysis.sql
    ├── 04_peak_map_performance.sql
    └── 05_team_stage_progression.sql
```

> 💡 **Tip for recruiters:** Open `cs2_budapest_major_2025.html` in any browser to explore the live dashboard — no setup or installation required.

---

## 📋 Excel Workbook — Sheet Guide

| Sheet | Contents |
|---|---|
| `KPI Dashboard` | 6 headline KPIs, Grand Final map scores, prize distribution table |
| `All 32 Teams` | Full standings — all 32 teams, stage reached, W/L record, prize money |
| `Player Stats` | Top 20 players — real HLTV Rating 3.0, K/D, ADR, maps played, awards |
| `Map Stats` | 6-map pool — CT/T win rates, pick frequency, average rounds, balance flag |
| `Grand Final Deep Dive` | Map-by-map scores, Vitality player stats, economy round breakdown |
| `Data Notes` | Source documentation — what is real vs estimated |

---

## 🚀 How to Run the SQL Queries

1. **Create the schema** using the table definitions in the schema section above
2. **Load data** from the Excel file into your SQL environment
3. **Recommended free tools:**
   - [BigQuery Sandbox](https://cloud.google.com/bigquery/docs/sandbox) — free, no credit card
   - [DB Fiddle](https://www.db-fiddle.com) — browser-based, no install
   - [Mode Analytics](https://mode.com) — great for sharing query results
4. **Run queries in order** — they build on each other conceptually

---

## 📝 Data Notes

| Type | Note |
|---|---|
| ✅ Real | All 32 team placements and prize money (Liquipedia, HLTV, BLAST.tv) |
| ✅ Real | Player ratings — HLTV Rating 3.0 from official event coverage |
| ✅ Real | Grand Final map scores (Nuke 6-13, Dust2 13-3, Inferno 13-9, Overpass 13-2) |
| ✅ Real | ZywOo MVP, ropz EVP, donk EVP — official award designations |
| ⚠️ Estimated | Round-by-round economy data (buy types, spend) — estimated from documented outcomes |
| ⚠️ Estimated | Player stats for teams outside top 16 where HLTV data is unavailable |

---

## 💡 Potential Extensions

- Connect to the **HLTV API or Liquipedia scraper** for live round-by-round data
- Build a **Tableau or Power BI** version of the dashboard
- Add a **predictive model** for team advancement probability based on Swiss stage seeding
- Extend to **multi-tournament analysis** (Copenhagen 2024 → Austin 2025 → Budapest 2025) to track player rating trends over time
- Create a **player comparison tool** — input two player names, output head-to-head career Major stats

---

## 👤 About

**Sergiu Serban**
Data Analyst | SQL · Excel · Dashboard Design · Esports Analytics

- 🔗 www.linkedin.com/in/sergiu-serban-48043313b(#)
- 🐙 https://github.com/serbansergiu-crypto(#)
- 📧 serban.sergiu@gmail.com

---

*Real tournament data sourced from HLTV.org, Liquipedia, and BLAST.tv. Some round-level economy figures are estimated. This project is for portfolio and educational purposes only.*
