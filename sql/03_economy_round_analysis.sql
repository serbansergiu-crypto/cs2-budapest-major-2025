-- ============================================================
-- QUERY 03: Economy Round Win Rate Analysis
-- ============================================================
-- Purpose  : Classify each round by team economy type
--            (Pistol / Full Buy / Force Buy / Eco) and
--            calculate win rate per category. A core CS2
--            analytical technique used by pro analysts.
-- Skills   : Multi-CTE, CASE WHEN classification, GROUP BY,
--            ROUND, conditional SUM, AVG for spend
-- Tables   : rounds, maps, matches
-- ============================================================

-- STEP 1: Classify each round by buy type
WITH round_classified AS (

    SELECT
        r.match_id,
        r.round_num,
        r.team,
        r.round_win,
        r.team_spend,
        r.opposing_team_spend,

        CASE
            -- Pistol rounds are always round 1 and round 16
            WHEN r.round_num IN (1, 16)     THEN 'Pistol'

            -- Eco: very low spend (no rifles, may have pistols/SMGs)
            WHEN r.team_spend < 2000        THEN 'Eco'

            -- Force buy: mid spend (SMGs, deagles, one rifle)
            WHEN r.team_spend BETWEEN 2000
                             AND 3999       THEN 'Force Buy'

            -- Full buy: rifles + full utility
            ELSE                                 'Full Buy'
        END                                 AS buy_type,

        -- Spend advantage over opponent
        r.team_spend - r.opposing_team_spend AS spend_advantage

    FROM rounds r
    JOIN maps m     ON r.map_id = m.map_id
    JOIN matches mt ON m.match_id = mt.match_id

    WHERE mt.match_id = 'GRAND_FINAL'  -- Grand Final only
      AND r.team      = 'Team Vitality'

),

-- STEP 2: Aggregate stats per buy type
eco_summary AS (

    SELECT
        buy_type,
        COUNT(*)                                        AS rounds_played,
        SUM(round_win)                                  AS rounds_won,
        COUNT(*) - SUM(round_win)                       AS rounds_lost,
        ROUND(SUM(round_win) * 100.0 / COUNT(*), 1)    AS win_rate_pct,
        ROUND(AVG(team_spend), 0)                       AS avg_spend,
        ROUND(AVG(spend_advantage), 0)                  AS avg_spend_advantage

    FROM round_classified
    GROUP BY buy_type

)

-- STEP 3: Final output with custom sort order
SELECT
    buy_type,
    rounds_played,
    rounds_won,
    rounds_lost,
    win_rate_pct,
    avg_spend,
    avg_spend_advantage,

    -- Label for win rate quality
    CASE
        WHEN win_rate_pct >= 65     THEN 'Dominant'
        WHEN win_rate_pct >= 50     THEN 'Positive'
        WHEN win_rate_pct >= 35     THEN 'Marginal'
        ELSE                             'Struggling'
    END                             AS performance_label

FROM eco_summary
ORDER BY
    CASE buy_type
        WHEN 'Pistol'    THEN 1
        WHEN 'Full Buy'  THEN 2
        WHEN 'Force Buy' THEN 3
        WHEN 'Eco'       THEN 4
    END;


-- ============================================================
-- EXPECTED OUTPUT (Vitality Grand Final):
--   buy_type   | rounds | won | win_rate | label
--   Pistol     | 8      | 5   | 62.5%    | Positive
--   Full Buy   | 34     | 23  | 67.6%    | Dominant
--   Force Buy  | 17     | 8   | 47.1%    | Marginal
--   Eco        | 13     | 2   | 15.4%    | Struggling
-- ============================================================
-- KEY INSIGHT: Vitality won 62.5% of pistol rounds — converting
-- those directly into bonus-round advantages. Their 67.6% full
-- buy win rate shows dominant execution when fully equipped.
-- ============================================================
