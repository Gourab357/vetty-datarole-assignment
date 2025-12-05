-- Q1: purchases per month excluding refunded purchases
SELECT
  date_trunc('month', purchase_time) AS month_start,
  COUNT(*) AS purchases_count
FROM transactions
WHERE refund_time IS NULL
GROUP BY date_trunc('month', purchase_time)
ORDER BY month_start;
