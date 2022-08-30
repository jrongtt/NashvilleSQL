SELECT * FROM Nashville.nashville2;


ALTER TABLE Nashville.nashville2
ADD COLUMN SaleDate2 varchar(40);





-- Standardize Date Format:

SET SQL_SAFE_UPDATES = 0;

UPDATE Nashville.nashville2
SET SaleDate = SaleDate2;


UPDATE Nashville.nashville2
SET SaleDate2 = SUBSTRING(SaleDate, 0, 2);

SELECT SaleDate2 FROM Nashville.nashville2;

SET SQL_SAFE_UPDATES = 1;




-- SELECT SaleDate, CONVERT(date, SaleDate)
-- FROM Nashville.nashville2;



-- 107
-- CONVERT(data_type(length), expression,
