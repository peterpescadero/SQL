--Member Management Report
SELECT reg.PatientID,
       reg.PolicyID	As 'Medicaid ID',
	   cast(PEF.dateadded as date)                                           AS
       'Referral Date',
       PEF.sitecode                                            AS 'Location',
       cast(ProgInst.startdate as DATE)                                      AS
       'Program Start Date',
       cast(ProgInst.enddate as date)                                        AS
       'Program End Date',
       --start sessions attended
	   --number of sessions with answers minus session with attended = no
	   (SELECT Count(DISTINCT scheduledateendtimeutc)
        FROM   programinstanceitem PII
               LEFT OUTER JOIN cpdataanswers cpda
                            ON PII.id = cpda.programinstanceitemid
        WHERE  programinstanceid = ProgInst.id
               AND value IS NOT NULL) - (SELECT Count(*)
                                         FROM   programinstanceitem PII
                                                LEFT OUTER JOIN
                                                cpdataanswers cpda
                                                             ON
       PII.id = cpda.programinstanceitemid
                                         WHERE  programinstanceid = ProgInst.id
                                                AND questionid = 37
                                                AND value = 2) AS
       'Sessions Attended',
       (SELECT Max(DISTINCT scheduledateendtimeutc)
        FROM   programinstanceitem PII
               LEFT OUTER JOIN cpdataanswers cpda
                            ON PII.id = cpda.programinstanceitemid
        WHERE  programinstanceid = ProgInst.id
               AND value IS NOT NULL
               AND ( questionid = 37
			   --1 is attendad
                     AND value = 1 ))                          AS
       'Last Interaction',
	--start weight loss %
	--((first weight-last weight)/first weight)*100
	FLOOR(
		(
			(
				CAST(
					(select TOP 1 Value from ProgramInstanceItem PII left outer join CPDataAnswers cpda on PII.Id = cpda.ProgramInstanceItemId where ProgramInstanceId = ProgInst.id and QuestionId = 168 and Value is not null order by ScheduleDateEndTimeUtc asc) 
					as INT
					)
				-
				CAST(
					(select TOP 1 Value from ProgramInstanceItem PII left outer join CPDataAnswers cpda on PII.Id = cpda.ProgramInstanceItemId where ProgramInstanceId = ProgInst.id and QuestionId = 168 and Value is not null order by ScheduleDateEndTimeUtc desc)
					as INT
					)
			)
		/
			(
				CAST(
					(select TOP 1 Value from ProgramInstanceItem PII left outer join CPDataAnswers cpda on PII.Id = cpda.ProgramInstanceItemId where ProgramInstanceId = ProgInst.id and QuestionId = 168 and Value is not null order by ScheduleDateEndTimeUtc asc) 
					as DECIMAL
					)
			)
			*100
	)
	) as 'Weight Loss %'
	,
	--start a1c change

	(select
	case
		--if no a1c assesment answer set to zero
		when (select max(value) from ProgramInstanceItem PII left outer join CPDataAnswers cpda on PII.Id = cpda.ProgramInstanceItemId where ProgramInstanceId = ProgInst.id and Title like '%A1C%') is null then 0
		--otherwise pre enrollment form a1c - session a1c
		else (
				--casting start to dec
				cast(
					(SELECT Value
					FROM   cpdataplans cp
						   INNER JOIN preenrollmentform pre
								   ON cp.id = pre.careplanid
							INNER JOIN CPDataAnswers da
								on	pre.Id = da.PreEnrollmentFormId

					WHERE  pre.source = 'Wellcare'
						   AND description LIKE '%dpp%'
						   and QuestionId = 504
						   and PatientId = reg.PatientID) as decimal
				)
				-
				cast(
					(select max(value) from ProgramInstanceItem PII left outer join CPDataAnswers cpda on PII.Id = cpda.ProgramInstanceItemId where ProgramInstanceId = PII.Id and Title like '%A1C%')
					as decimal
					)

		)
				
	end as A1C_Change)
	as 'A1C Change'
FROM   preenrollmentform PEF
       LEFT OUTER JOIN registration reg
                    ON PEF.patientid = reg.patientid
       LEFT OUTER JOIN programinstance ProgInst
                    ON PEF.patientid = ProgInst.patientid
WHERE  source = 'Wellcare'
       AND status = 'Enrolled'
       AND careplanid = '108' 
