### Script to extract the amount of hotels per model
###
use eanprod;
SELECT DISTINCT BusinessModelMask, COUNT(BusinessModelMask) AS 'count_per_model'
FROM activepropertybusinessmodel GROUP BY BusinessModelMask

