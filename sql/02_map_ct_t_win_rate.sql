-- ============================================================
-- QUERY 02: Map CT vs T Win Rate Analysis
-- ============================================================
-- Purpose  : Calculate CT-side and T-side win rates per map
--            across all playoff matches. Identifies map balance
--            and strategic tendencies (e.g. Nuke CT-sided).
-- Skills   : JOIN, CASE WHEN conditional aggregation,
--            GROUP BY, NULLIF, window function for ranking
-- Tables   : rounds, maps, matches
-- ============================================================

SELECT
    m.map_name,
    COUNT(r.round_id)                                           AS total_rounds,

    -- CT side wins
    COUNT(CASE WHEN r.winning_side = 'CT' THEN 1 END)          AS ct_wins,

    -- T side wins
    COUNT(CASE WHEN r.winning_side = 'T'  THEN 1 END)          AS t_wins,

    -- CT win rate (%)
    ROUND(
        COUNT(CASE WHEN r.winning_side = 'CT' THEN 1 END)
        * 100.0 / NULLIF(COUNT(r.round_id), 0)
    , 1)                                                        AS ct_win_pct,

    -- T win rate (%)
    ROUND(
        COUNT(CASE WHEN r.winning_side = 'T' THEN 1 END)
        * 100.0 / NULLIF(COUNT(r.round_id), 0)
    , 1)                                                        AS t_win_pct,

    -- Map bias flag
    CASE
        WHEN COUNT(CASE WHEN r.winning_side = 'CT' THEN 1 END)
             * 100.0 / NULLIF(COUNT(r.round_id), 0) > 55      THEN 'CT Favoured'
        WHEN COUNT(CASE WHEN r.winning_side = 'T'  THEN 1 END)
             * 100.0 / NULLIF(COUNT(r.round_id), 0) > 55      THEN 'T Favoured'
        ELSE                                                         'Balanced'
    END                                                         AS map_bias,

    -- How many times the map was played in playoffs
    COUNT(DISTINCT r.map_id)                                    AS times_played

FROM rounds r
JOIN maps m     ON r.map_id  = m.map_id
JOIN matches mt ON m.match_id = mt.match_id

WHERE mt.stage      = 'playoffs'
  AND r.round_type != 'overtime'  -- Regulation rounds only

GROUP BY m.map_name
ORDER BY ct_win_pct DESC;


-- ============================================================
-- EXPECTED OUTPUT:
--   map_name  | ct_win_pct | t_win_pct | map_bias
--   Nuke      | 62.0       | 38.0      | CT Favoured
--   Mirage    | 57.0       | 43.0      | CT Favoured
--   Ancient   | 55.0       | 45.0      | CT Favoured
--   Inferno   | 53.0       | 47.0      | Balanced
--   Overpass  | 51.0       | 49.0      | Balanced
--   Dust2     | 50.0       | 50.0      | Balanced
-- ============================================================
-- KEY INSIGHT: Nuke had a 62% CT win rate — the most lopsided
-- map in the pool. FaZe deliberately picked Nuke as their
-- Map 1 Grand Final choice, leveraging this CT advantage.
-- karrigan posted a 2.90 rating and 158 ADR on that map.
-- ============================================================
