
--------collect potential member waitlist data
---some are not members so data must be pulled from pre enrolment form answers
SELECT prg.NAME                      Program,
       r.patientid                   ID,
       (SELECT TOP 1 value
        FROM   cpdataanswers
        WHERE  preenrollmentformid = pef.id
               AND questionid = 46)  AS FirstName,
       (SELECT TOP 1 value
        FROM   cpdataanswers
        WHERE  preenrollmentformid = pef.id
               AND questionid = 47)  AS LastName,
      
	   (SELECT TOP 1 value
        FROM   cpdataanswers
        WHERE  preenrollmentformid = pef.id
               AND questionid = 111) AS DOB,
       (SELECT TOP 1 value
        FROM   cpdataanswers
        WHERE  preenrollmentformid = pef.id
               AND questionid = 164) AS MobilePhone,
       (SELECT TOP 1 value
        FROM   cpdataanswers
        WHERE  preenrollmentformid = pef.id
               AND questionid = 163) AS HomePhone,
       (SELECT TOP 1 value
        FROM   cpdataanswers
        WHERE  preenrollmentformid = pef.id
               AND questionid = 99)  AS Email,
       (SELECT TOP 1 value
        FROM   cpdataanswers
        WHERE  preenrollmentformid = pef.id
               AND questionid = 112) AS 'Address',
       (SELECT TOP 1 value
        FROM   cpdataanswers
        WHERE  preenrollmentformid = pef.id
               AND questionid = 136) AS Carrier,
       (SELECT TOP 1 value
        FROM   cpdataanswers
        WHERE  preenrollmentformid = pef.id
               AND questionid = 825) AS PolicyId
FROM   preenrollmentform pef
       LEFT JOIN program prg
              ON pef.programid = prg.id
       LEFT JOIN registration r
              ON r.patientid = pef.patientid
WHERE  pef.sitecode IN ( 'ARC' )
       AND status = 'waitlist' 
