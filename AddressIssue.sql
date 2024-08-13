--Users were sometimes entering two different addresses in Street and Street2 fields. Street2 was intended to be used for additional address information such as apartment or lot number.
--We believe this was happening when the address needed to be updated. This is the query created to find these examples. 
SELECT 
  PatientID, 
  Street, 
  Street2 
FROM 
    Registration 
WHERE 
  Street2 is not null 
  and SiteCode IN (select SiteCode from Associations where Name = 'Northern Association') 
  and Street2 not like '%Apt%' 
  and Street2 not like '%Apart%' 
  and Street2 not like '%Trailer%' 
  and Street2 not like '%LOT%' 
  and Street <> Street2
