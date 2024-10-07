
----DROP TABLE NashvilleHousing
/***********************************************************************/
/*******************************************************/
/* Cleaning data in SQL queries																   */
/*******************************************************/
--SELECT PropertyAddress										
--FROM NashvilleHousing
--ORDER BY PropertyAddress
;

/*******************************************************/
/* Standardize date format	 																	   */
/* SaleDate is already in Date format, does not need to reformat */
/*******************************************************/
--SELECT SaleDate
--FROM NashvilleHousing
;
/*******************************************************/
/* Populate property address data                                                          */
/*******************************************************/
/*Property address~~~~~~*/
--#1 Begin *****************************/
--WITH ParcelCnt  --Pull Parcel Id with more than 1 count
--AS 
--(
--SELECT 
-- COUNT(*) AS Cnt
--,ParcelID
--FROM NashvilleHousing
--GROUP BY ParcelID--, PropertyAddress
--HAVING COUNT(*) > 1
--),
--NullPropetyAddress --Pull Parcel Id with NULL address
--AS
--(
--SELECT nh.ParcelID, nh.PropertyAddress
--FROM NashvilleHousing nh
--INNER JOIN ParcelCnt pc ON nh.ParcelID = pc.ParcelID
--WHERE 1 = 1
--AND nh.PropertyAddress IS NULL
--),
--GetProperyAddress
--AS
--(
--SELECT 
-- nh.UniqueID
-- ,nh.ParcelID
--,nh.PropertyAddress
--,MAX(nh.PropertyAddress) OVER (PARTITION BY nh.ParcelId ORDER BY nh.ParcelId) AS TmpPropertyAddress
--FROM NashvilleHousing nh
--INNER JOIN NullPropetyAddress na ON nh.ParcelID = na.ParcelID 
--)

--SELECT nh.UniqueID, nh.ParcelID, nh.PropertyAddress, ga.TmpPropertyAddress
--FROM NashvilleHousing nh
--INNER JOIN GetProperyAddress ga ON nh.ParcelID = ga.ParcelID 
--																	AND nh.UniqueID = ga.UniqueID
--WHERE 1 = 1
--AND nh.PropertyAddress IS NULL
;
----UPDATE nh SET PropertyAddress = ga.TmpPropertyAddress
----FROM NashvilleHousing nh
----INNER JOIN GetProperyAddress ga ON nh.ParcelID = ga.ParcelID 
----																	AND nh.UniqueID = ga.UniqueID
----WHERE 1 = 1
----AND nh.PropertyAddress IS NULL
;
--#1 End *******************************/

--#2 Begin *****************************/
--Property address
--SELECT  
-- nh.ParcelID
--,nh.PropertyAddress
--,nh1.ParcelID
--,nh1.PropertyAddress
--FROM NashvilleHousing nh
--INNER JOIN NashvilleHousing nh1 ON nh.ParcelID = nh1.ParcelID
--																AND nh.UniqueID <> nh1.UniqueID
--WHERE 1 = 1
--AND nh.PropertyAddress IS NULL
--ORDER BY nh.ParcelID
;
----UPDATE nh SET PropertyAddress = ISNULL(nh.PropertyAddress, nh1.PropertyAddress)
----FROM NashvilleHousing nh
----INNER JOIN NashvilleHousing nh1 ON nh.ParcelID = nh1.ParcelID
----																AND nh.UniqueID <> nh1.UniqueID
----WHERE 1 = 1
----AND nh.PropertyAddress IS NULL
;
--#2 END *******************************/

/*******************************************************/
/* Breaking out address into individaul columns									*/
/* (Address, City, States)																				*/
/*******************************************************/
/*Split property address~~~~~~*/
--SELECT 
----ROW_NUMBER() OVER (PARTITION BY ParcelId ORDER BY ParcelId, PropertyAddress) AS RNbr
-- PropertyAddress
--,CHARINDEX(',', PropertyAddress) AS FirstComma
--,SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address
--,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)-CHARINDEX(',', PropertyAddress)) AS City
--FROM NashvilleHousing
;
--ALTER TABLE NashvilleHousing
--ADD  PropertySplitAddress NVARCHAR(255),
--		   PropertySplitCity NVARCHAR(255);

--UPDATE NashvilleHousing SET 
-- PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) 
--,PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)-CHARINDEX(',', PropertyAddress)) 														
--;


/*Split Owner address~~~~~~*/
--#1 Begin Begin *****************************/
--SELECT  
-- nh.ParcelID
--,nh.OwnerAddress
--,PARSENAME(REPLACE(nh.OwnerAddress,',','.'),1) AS State
--,PARSENAME(REPLACE(nh.OwnerAddress,',','.'),2) AS City
--,PARSENAME(REPLACE(nh.OwnerAddress,',','.'),3) AS Address
--FROM NashvilleHousing nh
----INNER JOIN NashvilleHousing nh1 ON nh.ParcelID = nh1.ParcelID
----																AND nh.UniqueID <> nh1.UniqueID
--WHERE 1 = 1
--AND nh.OwnerAddress IS NOT NULL
----AND nh.OwnerName IS NULL
--ORDER BY nh.ParcelID

;
--ALTER TABLE NashvilleHousing
--ADD  OwnerSplitAddress NVARCHAR(255),
--		   OwnerSplitCity NVARCHAR(255),
--		   OwnerSplitState NVARCHAR(2); --For some reason the size is too small to insert 
;
--ALTER TABLE NashvilleHousing
--DROP COLUMN OwnerSplitState;
;
--ALTER TABLE NashvilleHousing
--ADD OwnerSplitState NVARCHAR(255);
;
----UPDATE NashvilleHousing SET
---- OwnerSplitAddress = PARSENAME(REPLACE(LTRIM(RTRIM(OwnerAddress)),',','.'),3) 
----,OwnerSplitCity = PARSENAME(REPLACE(LTRIM(RTRIM(OwnerAddress)),',','.'),2) 
----,OwnerSplitState = PARSENAME(REPLACE(LTRIM(RTRIM(OwnerAddress)),',','.'),1)
----WHERE 1 = 1
----AND OwnerAddress IS NOT NULL
;
--#3 END *******************************/

/*******************************************************/
/*Change Y and N to Yes and No in 'Sold as Vacant' field					*/
/*******************************************************/
--The table is having 0 and 1
--I do not want to change this to Yes or No
;
/*******************************************************/
/* Remove Duplicates																					*/
/*******************************************************/
--WITH RowNumCTE
--AS
--(
--SELECT 
-- ROW_NUMBER() OVER (PARTITION BY ParcelId, SaleDate, SalePrice, LegalReference ORDER BY ParcelId) AS RowNbr
--,*
--FROM NashvilleHousing
----ORDER BY ParcelID
--)
--SELECT * 
------DELETE
--FROM RowNumCTE
--WHERE 1 = 1
--AND RowNbr > 1
;
/*******************************************************/
/* Delete unused columns																			*/
/*******************************************************/
--ALTER TABLE NashvilleHousing
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;
;
/***********************************************************************/

SELECT * --DISTINCT SoldAsVacant
FROM NashvilleHousing
ORDER BY ParcelID
;
/***********************************************************************/

