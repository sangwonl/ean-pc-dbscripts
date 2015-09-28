### Script to extract the amount of hotels per model
###
use eanmap;
SELECT DISTINCT BusinessModelMask, COUNT(BusinessModelMask) AS 'count_per_model',
                SUM(if(GiataID > 0, 1, 0)) AS 'matched_to_giata'
FROM ActivePropertyGiata GROUP BY BusinessModelMask

