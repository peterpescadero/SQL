--hello
SELECT 
  PatientID, Street, Street2 FROM Registration WHERE Street2 is not null and SiteCode IN (select SiteCode from Associations where Name = 'YMCA of the Triangle') and Street2 not like '%Apt%' and Street2 not like '%Apart%' and Street2 not like '%Trailer%' and Street2 not like '%LOT%' and Street <> Street2
