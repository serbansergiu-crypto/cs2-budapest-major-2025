-- ============================================================
-- QUERY 04: Peak Single-Map Performance Finder
-- ============================================================
-- Purpose  : Find each player's single best map rating at
--            the event. Highlights clutch performers and
--            peak moments (e.g. ropz 2.89 on Overpass).
-- Skills   : ROW_NUMBER() window function, PARTITION BY,
--            CTE, JOIN, computed K/D column
-- Tables   : player_map_stats, players, maps, matches
-- ============================================================

WITH peak_maps AS (

    SELECT
        p.player_name,
        p.team,
        p.country,
        m.map_name,
        mt.match_description,
        mt.stage,
        pm.hltv_rating,
        pm.kills,
        pm.deaths,
        pm.adr,
        pm.kast_pct,

        -- Rank each player's maps from best to worst rating
        ROW_NUMBER() OVER (
            PARTITION BY p.player_id
            ORDER BY pm.hltv_rating DESC
        )                                           AS map_rank

    FROM player_map_stats pm
    JOIN players p  ON pm.player_id = p.player_id
    JOIN maps m     ON pm.map_id    = m.map_id
    JOIN matches mt ON m.match_id   = mt.match_id

)

-- Only return each player's single best map (map_rank = 1)
SELECT
    RANK() OVER (ORDER BY hltv_rating DESC)     AS overall_rank,
    player_name,
    team,
    map_name,
    match_description,
    stage,
    hltv_rating                                 AS peak_rating,
    kills,
    deaths,

    -- Computed K/D for this specific map
    ROUND(kills * 1.0 / NULLIF(deaths, 0), 2)  AS kd_ratio,
    adr,
    kast_pct

FROM peak_maps
WHERE map_rank = 1
ORDER BY hltv_rating DESC
LIMIT 15;


-- ============================================================
-- EXPECTED OUTPUT (top rows):
--   player   | team          | map      | peak_rating | kd
--   ropz     | Team Vitality | Overpass | 2.89        | 3.14
--   karrigan | FaZe Clan     | Nuke     | 2.90        | 2.80
--   donk     | Team Spirit   | various  | 2.40+       | 3.00+
-- ============================================================
-- KEY INSIGHT: ropz posted a 2.89 rating on Overpass (GF Map 4)
-- with 22-7 K-D, 144.1 ADR, and an 11-1 T-half. This is one
-- of the highest-rated single map performances in Major history.
-- Vitality won that map 13-2 to clinch the championship.
-- ============================================================
