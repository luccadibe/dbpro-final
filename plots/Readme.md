# TPC-H Query Performance Analysis
## Performance Categories
1. Very Fast (< 0.5s): Q2, Q4, Q6, Q11, Q12, Q14, Q16, Q18
2. Fast (0.5s - 1s): Q3, Q5, Q10, Q15, Q19
3. Moderate (1s - 3s): Q1, Q7, Q8, Q13, Q21
4. Slow (3s - 10s): Q9
5. Very Slow (> 10s): Q17, Q20, Q22

## Query Characteristics And Performance Analysis

### Simple queries with light aggregation
The queries Q2,Q4,Q6,Q11,Q12,Q14,Q16,Q18 use light aggregations and operate on tables with less rows. On queries involving larger tables `limit` clause is used. Hence, they perform consistently the best.

### Complex Joins
The queries Q7, Q8 and Q9 have higher join complexities but perform well.

### Heavy Aggregation and High Data Volume Impact
The queries with the worst performance (Q17, Q20, Q22) all involve complex/multiple subqueries, heavy aggregation and full table scans on largest table `Lineitem`

## Conclusion

Join complexity alone doesn't necessarily lead to poor performance, suggesting that other factors like aggregation, data volume and subquery complexity play crucial roles.
