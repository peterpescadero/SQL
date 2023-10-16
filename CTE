--get pii for ps with makeup date
with withMakeupDate as(
	select 
	
		pii1.*,
		--in a program instance if the session type question has makeup date set value to MakeupDate feild fo all itmes in the pii
		(select top 1 value from ProgramInstanceItem pii2 left join CPDataAnswers cpda on cpda.ProgramInstanceItemId=pii2.id where ProgramInstanceId=pi.Id and QuestionId=637 and Value is not null and pii2.ScheduleDateUtc = pii1.scheduledateutc) 
			as MakeupDate
	from 
	
		ProgramInstanceItem pii1
		left join ProgramInstance pi on pi.Id=pii1.ProgramInstanceId
		left join programschedule ps on ps.id=pi.programscheduleid
		left join ProgramTemplate pt on pt.id=pi.ProgramTemplateId 
		left join Program p on p.Id=pt.ProgramId
	where 
		--if we have have the ps id(cohort) then use that /otherwise get ps id's using sitecode
		ps.id = 604
		--ps.id in (select ps.id from ProgramSchedule ps left join ProgramTemplate pt on pt.Id=ps.ProgramTemplateId left join Program p on p.id=pt.ProgramId where sitecode in ('ARC') and p.Name = 'Diabetes Prevention')
		--i think they want the inactive ones also
		--and pi.active = 1
)

,
--if no makeup date real date is scheddate otherwise makeupdate is real date
withRealDate as(
	select 
		*,
		case
			when MakeupDate is not null then MakeupDate
			else ScheduleDateUtc
		end as realDate
	from withMakeupDate
),
--add session number to pii
pii_withSessionNumber as(
	select 
		--order each pi in pii by real date to get session number using rank 
		*,
		DENSE_RANK() over (partition by ProgramInstanceid order by realDate) as sessionNumber 
	from withRealDate
)

select 
	
	pt.Id programtemplateid,
	patientid,
	per.firstname + ' '+per.lastname as Coach,
	ps.SiteCode as Location,
	p.name as Program,
	pt.Title ProgramTemplate,
	pii.title Assessment,
	pii.CarePlanId as AId,
	cpda.QuestionId qId,
	pii.ProgramInstanceId ProgramInstance,
	pi.startdate as PI_Start,
	pi.enddate as PI_End,
	pti.weeknumber as Week,
	pti.dayofweeknumber as Day,
	s.integrationid,
	s.state,
	pii.iscomplete as Attended,
	cast(pii.scheduledateutc as DATE) as ScheduleDate,
	cpda.value as Answer,
	cast(cpda.answered as DATE) as AnsweredOn,
	pii.id as pii_id,
	pii.sessionNumber
from 
	pii_withSessionNumber pii 
	left join CPDataAnswers cpda on pii.Id = cpda.ProgramInstanceItemId
	left join ProgramInstance pi on pi.Id=pii.ProgramInstanceId
	left join programschedule ps on ps.id=pi.programscheduleid
	left join personnel per on per.id=ps.Providerid
	left join ProgramTemplate pt on pt.id=ps.ProgramTemplateId
	left join program p on p.id=pt.programid
	left join ProgramTemplateItem pti on pti.id=pii.ProgramTemplateItemId
	left join Sites s on s.sitecode=ps.sitecode
	left join CPDataQuestions cpdq on cpdq.QuestionId=cpda.Id
	left join cpsetupquestions cpsq on cpsq.id=cpda.questionid 
	left join cpdataplans cpdp on cpdp.id=cpdq.CPId 

where 
	cpda.questionid in (31,168) 
	and value is not null 




