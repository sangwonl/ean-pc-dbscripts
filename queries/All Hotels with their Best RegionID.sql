/*
** Query to get the best recomended Region for an Hotel
** it used the RegionID field of the hotel table, but check if the
** ParentRegion is of 'Multi-City (Vicinity) type to use that one instead.
*/
USE eanprod;
SELECT EANHotelID,Name,City,StateProvince,PostalCode,Country,
	-- if the parent is a Multi-City (Vicinity) show that info. instead
	IF(parentregiontype='Multi-City (Vicinity)',ParentRegionID,parentregionlist.RegionID) AS 'Best_Region_ID',
	IF(parentregiontype='Multi-City (Vicinity)',ParentRegionNameLong,RegionNameLong) AS 'Best_Region_Name',
    IF(parentregiontype='Multi-City (Vicinity)',ParentRegionType,RegionType) AS 'Region_Type',
	IF(parentregiontype='Multi-City (Vicinity)',HOTELS_IN_REGION_COUNT(ParentRegionID),HOTELS_IN_REGION_COUNT(parentregionlist.RegionID)) AS 'Best_Region_Count',
	BusinessModelMask
FROM activepropertybusinessmodel
-- show them all even if no RegionID
LEFT JOIN parentregionlist
ON activepropertybusinessmodel.RegionID = parentregionlist.RegionID
-- noe
ORDER BY Country,StateProvince,City
;
