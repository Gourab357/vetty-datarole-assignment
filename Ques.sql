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
