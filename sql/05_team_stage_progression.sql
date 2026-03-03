-- ============================================================
-- QUERY 05: Team Stage Progression & Prize Analysis
-- ============================================================
-- Purpose  : Summarise how far each team progressed through
--            the three Swiss stages and playoffs, along with
--            their prize earnings and win rate at each stage.
--            Useful for identifying consistent performers vs
--            one-tournament wonders.
-- Skills   : LEFT JOIN, GROUP BY, CASE WHEN, window functions,
--            SUM, ROUND, percentage of total prize pool
-- Tables   : teams, team_stage_results, stages, prizes
-- ============================================================

WITH stage_records AS (

    SELECT
        t.team_name,
        t.region,
        s.stage_name,
        s.stage_order,
        tsr.wins,
        tsr.losses,
        tsr.maps_won,
        tsr.maps_lost,
        tsr.eliminated,
        p.prize_usd

    FROM teams t
    JOIN team_stage_results tsr ON t.team_id    = tsr.team_id
    JOIN stages s               ON tsr.stage_id = s.stage_id
    LEFT JOIN prizes p          ON t.team_id    = p.team_id

),

-- Total wins and losses per team across all stages
team_totals AS (

    SELECT
        team_name,
        region,
        MAX(prize_usd)                                  AS prize_usd,
        SUM(wins)                                       AS total_wins,
        SUM(losses)                                     AS total_losses,
        SUM(maps_won)                                   AS total_maps_won,
        SUM(maps_lost)                                  AS total_maps_lost,

        -- Furthest stage reached
        MAX(CASE WHEN eliminated = FALSE
                 THEN stage_order ELSE 0 END)           AS furthest_stage_order,

        -- Match win rate across entire event
        ROUND(
            SUM(wins) * 100.0
            / NULLIF(SUM(wins) + SUM(losses), 0)
        , 1)                                            AS match_win_rate_pct,

        -- Map win rate across entire event
        ROUND(
            SUM(maps_won) * 100.0
            / NULLIF(SUM(maps_won) + SUM(maps_lost), 0)
        , 1)                                            AS map_win_rate_pct

    FROM stage_records
    GROUP BY team_name, region

)

SELECT
    -- Final placement rank by prize (highest prize = best finish)
    RANK() OVER (ORDER BY COALESCE(prize_usd, 0) DESC,
                          total_wins DESC)              AS placement,
    team_name,
    region,

    CASE furthest_stage_order
        WHEN 4 THEN 'Playoffs'
        WHEN 3 THEN 'Stage 3'
        WHEN 2 THEN 'Stage 2'
        WHEN 1 THEN 'Stage 1'
        ELSE        'Unknown'
    END                                                 AS stage_reached,

    total_wins,
    total_losses,
    match_win_rate_pct,
    total_maps_won,
    total_maps_lost,
    map_win_rate_pct,

    -- Prize formatting
    COALESCE(prize_usd, 0)                              AS prize_usd,

    -- Prize as % of total pool ($1,250,000)
    ROUND(COALESCE(prize_usd, 0) * 100.0 / 1250000, 1) AS prize_pool_share_pct,

    -- Tier label based on stage
    CASE
        WHEN prize_usd >= 80000  THEN 'Top 4'
        WHEN prize_usd >= 20000  THEN 'Quarter / Top 16'
        WHEN prize_usd >= 10000  THEN 'Stage 2 Exit'
        WHEN prize_usd  > 0      THEN 'Stage 1 Exit (Paid)'
        ELSE                          'Stage 1 Exit (No Prize)'
    END                                                 AS tier

FROM team_totals
ORDER BY COALESCE(prize_usd, 0) DESC, total_wins DESC;


-- ============================================================
-- EXPECTED OUTPUT (top rows):
--   placement | team_name     | stage    | win_rate | prize
--   1         | Team Vitality | Playoffs | 86.7%    | $500,000
--   2         | FaZe Clan     | Playoffs | 73.3%    | $170,000
--   3         | Team Spirit   | Playoffs | 75.0%    | $80,000
--   4         | NAVI          | Playoffs | 66.7%    | $80,000
-- ============================================================
-- KEY INSIGHT: The top 4 teams combined earned $830,000 of
-- the $1.25M prize pool (66.4%). The 8 teams eliminated in
-- Stage 1 left with nothing, highlighting the high-stakes
-- winner-take-most structure of Major tournaments.
-- ============================================================
