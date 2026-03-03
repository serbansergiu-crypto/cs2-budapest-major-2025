-- ============================================================
-- QUERY 01: Player Rating Leaderboard
-- ============================================================
-- Purpose  : Rank all players by average HLTV Rating 3.0
--            across all maps played, with K/D and ADR context.
--            Reveals top performers and MVP/EVP candidates.
-- Skills   : CTE, AVG, COUNT, SUM, RANK() window function,
--            HAVING filter, NULLIF for safe division
-- Tables   : players, player_map_stats, maps
-- ============================================================

WITH player_aggregated AS (

    SELECT
        p.player_id,
        p.player_name,
        p.team,
        p.country,

        COUNT(pm.map_id)                                        AS maps_played,
        ROUND(AVG(pm.hltv_rating), 2)                          AS avg_rating,

        -- Safe K/D: avoid division by zero with NULLIF
        ROUND(SUM(pm.kills) * 1.0 / NULLIF(SUM(pm.deaths), 0), 2)
                                                                AS kd_ratio,
        ROUND(AVG(pm.adr), 1)                                  AS avg_adr,
        ROUND(AVG(pm.kast_pct), 1)                             AS avg_kast_pct,
        SUM(pm.kills) - SUM(pm.deaths)                         AS kd_diff

    FROM players p
    JOIN player_map_stats pm ON p.player_id = pm.player_id
    JOIN maps m               ON pm.map_id = m.map_id

    -- All maps, all stages
    GROUP BY p.player_id, p.player_name, p.team, p.country

    -- Minimum 3 maps for a meaningful average
    HAVING COUNT(pm.map_id) >= 3

)
SELECT
    RANK() OVER (ORDER BY avg_rating DESC)  AS rank,
    player_name,
    team,
    country,
    maps_played,
    avg_rating,
    kd_ratio,
    avg_adr,
    avg_kast_pct,
    kd_diff

FROM player_aggregated
ORDER BY avg_rating DESC
LIMIT 20;


-- ============================================================
-- EXPECTED OUTPUT (top rows):
--   rank | player  | team          | avg_rating | kd_ratio
--   1    | donk    | Team Spirit   | 1.57       | 2.18
--   2    | ZywOo   | Team Vitality | 1.38       | 1.71
--   3    | ropz    | Team Vitality | 1.37       | 1.59
-- ============================================================
-- KEY INSIGHT: donk (Spirit) was the highest rated player
-- despite Spirit being eliminated in the semifinals. This
-- illustrates that team results ≠ individual performance.
-- ============================================================
