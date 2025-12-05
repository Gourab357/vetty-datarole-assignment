-- Q1: purchases per month excluding refunded purchases
SELECT
  date_trunc('month', purchase_time) AS month_start,
  COUNT(*) AS purchases_count
FROM transactions
WHERE refund_time IS NULL
GROUP BY date_trunc('month', purchase_time)
ORDER BY month_start;

-- Q2: number of stores with at least 5 transactions in October 2020

WITH oct_tx AS (
  SELECT store_id
  FROM transactions
  WHERE date_part('year', purchase_time) = 2020
    AND date_part('month', purchase_time) = 10
)
SELECT COUNT(*) AS stores_with_5_or_more_orders
FROM (
  SELECT store_id, COUNT(*) AS cnt
  FROM oct_tx
  GROUP BY store_id
  HAVING COUNT(*) >= 5
) t;


-- Q3: shortest interval (minutes) from purchase to refund per store

SELECT
  store_id,
  MIN(EXTRACT(EPOCH FROM (refund_time - purchase_time)) / 60.0) AS shortest_refund_interval_minutes
FROM transactions
WHERE refund_time IS NOT NULL 
  -- optionally exclude negative durations if data has refund_time < purchase_time:
-- AND refund_time >= purchase_time
GROUP BY store_id
ORDER BY store_id;

-- Q4: gross_transaction_value of each store's first order

WITH ranked AS (
  SELECT
    store_id,
    gross_transaction_value,
    purchase_time,
    ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY purchase_time ASC) AS rn
  FROM transactions
)
SELECT store_id, gross_transaction_value, purchase_time
FROM ranked
WHERE rn = 1
ORDER BY store_id;

-- Q5: most popular item_name on buyers' first purchase
WITH first_purchase_per_buyer AS (
  SELECT
    t.buyer_id,
    t.item_id
  FROM (
    SELECT
      buyer_id,
      item_id,
      ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) AS rn
    FROM transactions
  ) t
  WHERE t.rn = 1
)
SELECT i.item_name,
       COUNT(*) AS first_purchase_count
FROM first_purchase_per_buyer f
JOIN items i ON i.item_id = f.item_id
GROUP BY i.item_name
ORDER BY first_purchase_count DESC
LIMIT 1;

-- Q6: mark whether refund can be processed (within 72 hours)
SELECT
  buyer_id,
  purchase_time,
  refund_time,
  store_id,
  item_id,
  gross_transaction_value,
  CASE
    WHEN refund_time IS NOT NULL
         AND refund_time <= purchase_time + INTERVAL '72 hours'
      THEN TRUE
    WHEN refund_time IS NOT NULL
      THEN FALSE
    ELSE NULL -- no refund requested
  END AS refund_processable
FROM transactions;

-- Q7: second purchase per buyer (ignoring refunds)
WITH ranked_nonrefunded AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) AS rn
  FROM transactions
  WHERE refund_time IS NULL  -- ignore refunded purchases
)
SELECT *
FROM ranked_nonrefunded
WHERE rn = 2;

-- Q8: second transaction time per buyer (using row_number)
SELECT buyer_id, purchase_time AS second_purchase_time
FROM (
  SELECT
    buyer_id,
    purchase_time,
    ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) AS rn
  FROM transactions
) t
WHERE rn = 2
ORDER BY buyer_id;

