SELECT opi.OrderID, cc.Name as CustomerName, opi.Part, j.JobType, opi.Multiplier, opi.SideCount,
(case when JobType = 0 then opi.ItemDesc else (case when j.JobComment is null then dsj.Name else j.JobComment end) end) as ItemDesc,
(case when JobType = 0 then wo.Comment else (case when j.JobComment is null then dsj.Name else j.JobComment end) end) as Comment,
opi.ProductOut as ItemProductOut,
(select sum(DATEDIFF(minute, ISNULL(jsum.FactStartDate, jsum.PlanStartDate), ISNULL(jsum.FactFinishDate, jsum.PlanFinishDate))) from Job jsum where jsum.ItemID = opi.ItemID) as ItemDuration,
(case when j.FactFinishDate is null or j.FactProductOut is null then
(case
when opi.SplitMode1 = 1 and (j.SplitPart2 is null or (opi.SplitMode2 = 2 and j.SplitPart2 is not null and j.SplitPart3 is null)) then
cast(opi.ProductOut / opi.Multiplier as int)
when opi.SplitMode1 = 1 and opi.SplitMode2 = 0 and j.SplitPart2 is not null and j.SplitPart3 is null then
dbo.SplitCount(opi.ProductOut / opi.Multiplier - (select ISNULL(sum(ISNULL(FactProductOut, 0)), 0) from Job j4 where j4.ItemID = opi.ItemID and j4.SplitPart1 = j.SplitPart1 and j4.FactStartDate is not null and j4.FactFinishDate is not null),
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j2.FactStartDate, j2.PlanStartDate), COALESCE(j2.FactFinishDate, j2.PlanFinishDate))) from Job j2 where j2.ItemID = opi.ItemID and j2.SplitPart1 = j.SplitPart1)
- (select ISNULL(sum(datediff(second, j5.FactStartDate, j5.FactFinishDate)), 0) from Job j5 where j5.ItemID = opi.ItemID and j5.SplitPart1 = j.SplitPart1
 and j5.FactStartDate is not null and j5.FactFinishDate is not null and j5.FactProductOut is not null))
when opi.SplitMode1 = 1 and opi.SplitMode2 = 0 and j.SplitPart2 is not null and opi.SplitMode3 = 2 and j.SplitPart3 is not null then
dbo.SplitCount(opi.ProductOut / opi.Multiplier - (select ISNULL(sum(ISNULL(FactProductOut, 0)), 0) from Job j4 where j4.ItemID = opi.ItemID and j4.SplitPart1 = j.SplitPart1 and j4.SplitPart2 = j.SplitPart2 and j4.FactStartDate is not null and j4.FactFinishDate is not null),
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j2.FactStartDate, j2.PlanStartDate), COALESCE(j2.FactFinishDate, j2.PlanFinishDate))) from Job j2 where j2.ItemID = opi.ItemID and j2.SplitPart1 = j.SplitPart1 and j2.SplitPart2 = j.SplitPart2)
 - (select ISNULL(sum(datediff(second, j5.FactStartDate, j5.FactFinishDate)), 0) from Job j5 where j5.ItemID = opi.ItemID and j5.SplitPart1 = j.SplitPart1 and j5.SplitPart2 = j.SplitPart2
 and j5.FactStartDate is not null and j5.FactFinishDate is not null and j5.FactProductOut is not null))
when opi.SplitMode1 = 0 and j.SplitPart2 is null then
dbo.SplitCount(opi.ProductOut - (select ISNULL(sum(ISNULL(FactProductOut, 0)), 0) from Job j4 where j4.ItemID = opi.ItemID and j4.FactStartDate is not null and j4.FactFinishDate is not null),
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j2.FactStartDate, j2.PlanStartDate), COALESCE(j2.FactFinishDate, j2.PlanFinishDate))) from Job j2 where j2.ItemID = opi.ItemID)
 - (select ISNULL(sum(datediff(second, j5.FactStartDate, j5.FactFinishDate)), 0) from Job j5 where j5.ItemID = opi.ItemID and j5.FactStartDate is not null and j5.FactFinishDate is not null and j5.FactProductOut is not null))
when opi.SplitMode1 = 0 and opi.SplitMode2 = 1 and j.SplitPart2 is not null and j.SplitPart3 is null then
dbo.SplitCount(opi.ProductOut - (select ISNULL(sum(ISNULL(FactProductOut, 0)), 0) from Job j4 where j4.ItemID = opi.ItemID and j4.SplitPart1 = j.SplitPart1 and j4.FactStartDate is not null and j4.FactFinishDate is not null),
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j2.FactStartDate, j2.PlanStartDate), COALESCE(j2.FactFinishDate, j2.PlanFinishDate))) from Job j2 where j2.ItemID = opi.ItemID)
 - (select ISNULL(sum(datediff(second, j5.FactStartDate, j5.FactFinishDate)), 0) from Job j5 where j5.ItemID = opi.ItemID and j5.SplitPart1 = j.SplitPart1
 and j5.FactStartDate is not null and j5.FactFinishDate is not null and j5.FactProductOut is not null))
when opi.SplitMode1 = 0 and opi.SplitMode2 = 2 and j.SplitPart2 is not null and j.SplitPart3 is null then
dbo.SplitCount(opi.ProductOut - (select ISNULL(sum(ISNULL(FactProductOut, 0)), 0) from Job j4 where j4.ItemID = opi.ItemID and j4.FactStartDate is not null and j4.FactFinishDate is not null),
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j2.FactStartDate, j2.PlanStartDate), COALESCE(j2.FactFinishDate, j2.PlanFinishDate))) from Job j2 where j2.ItemID = opi.ItemID)
 - (select ISNULL(sum(datediff(second, j5.FactStartDate, j5.FactFinishDate)), 0) from Job j5 where j5.ItemID = opi.ItemID and j5.FactStartDate is not null and j5.FactFinishDate is not null and j5.FactProductOut is not null))
when opi.SplitMode1 = 1 and j.SplitPart1 is not null and opi.SplitMode2 = 2 and j.SplitPart2 is not null and opi.SplitMode3 = 0 and j.SplitPart3 is not null then
dbo.SplitCount(opi.ProductOut / opi.Multiplier - (select ISNULL(sum(ISNULL(FactProductOut, 0)), 0) from Job j6 where j6.ItemID = opi.ItemID and j6.SplitPart1 = j.SplitPart1 and j6.SplitPart2 = j.SplitPart2 and j6.FactStartDate is not null and j6.FactFinishDate is not null),
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j7.FactStartDate, j7.PlanStartDate), COALESCE(j7.FactFinishDate, j7.PlanFinishDate))) from Job j7 where j7.ItemID = opi.ItemID and j7.SplitPart1 = j.SplitPart1 and j7.SplitPart2 = j.SplitPart2)
- (select ISNULL(sum(datediff(second, j8.FactStartDate, j8.FactFinishDate)), 0) from Job j8 where j8.ItemID = opi.ItemID and j8.SplitPart1 = j.SplitPart1 and j8.SplitPart2 = j.SplitPart2
 and j8.FactStartDate is not null and j8.FactFinishDate is not null and j8.FactProductOut is not null))
when opi.SplitMode1 = 2 and j.SplitPart1 is not null and opi.SplitMode2 = 0 and j.SplitPart2 is not null and j.SplitPart3 is null then
dbo.SplitCount(opi.ProductOut - (select ISNULL(sum(ISNULL(FactProductOut, 0)), 0) from Job j9 where j9.ItemID = opi.ItemID and j9.SplitPart1 = j.SplitPart1 and j9.FactStartDate is not null and j9.FactFinishDate is not null),
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j10.FactStartDate, j10.PlanStartDate), COALESCE(j10.FactFinishDate, j10.PlanFinishDate))) from Job j10 where j10.ItemID = opi.ItemID and j10.SplitPart1 = j.SplitPart1)
- (select ISNULL(sum(datediff(second, j11.FactStartDate, j11.FactFinishDate)), 0) from Job j11 where j11.ItemID = opi.ItemID and j11.SplitPart1 = j.SplitPart1
 and j11.FactStartDate is not null and j11.FactFinishDate is not null and j11.FactProductOut is not null))
else
opi.ProductOut
end)
else FactProductOut
end) as ProductOut
,
(case
when opi.SplitMode1 = 1 and (j.SplitPart2 is null or (opi.SplitMode2 = 2 and j.SplitPart2 is not null and j.SplitPart3 is null)) then
cast(opi.ProductIn / opi.Multiplier as int)
when opi.SplitMode1 = 1 and opi.SplitMode2 = 0 and j.SplitPart2 is not null and j.SplitPart3 is null then
dbo.SplitCount(opi.ProductIn / opi.Multiplier,
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j2.FactStartDate, j2.PlanStartDate), COALESCE(j2.FactFinishDate, j2.PlanFinishDate))) from Job j2 where j2.ItemID = opi.ItemID and j2.SplitPart1 = j.SplitPart1)
)
when opi.SplitMode1 = 1 and opi.SplitMode2 = 0 and j.SplitPart2 is not null and opi.SplitMode3 = 2 and j.SplitPart3 is not null then
dbo.SplitCount(opi.ProductIn / opi.Multiplier,
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j2.FactStartDate, j2.PlanStartDate), COALESCE(j2.FactFinishDate, j2.PlanFinishDate))) from Job j2 where j2.ItemID = opi.ItemID and j2.SplitPart1 = j.SplitPart1 and j2.SplitPart2 = j.SplitPart2)
)
when opi.SplitMode1 = 0 and j.SplitPart2 is null then
dbo.SplitCount(opi.ProductIn,
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j2.FactStartDate, j2.PlanStartDate), COALESCE(j2.FactFinishDate, j2.PlanFinishDate))) from Job j2 where j2.ItemID = opi.ItemID)
)
when opi.SplitMode1 = 0 and opi.SplitMode2 = 1 and j.SplitPart2 is not null and j.SplitPart3 is null then
dbo.SplitCount(opi.ProductIn,
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j2.FactStartDate, j2.PlanStartDate), COALESCE(j2.FactFinishDate, j2.PlanFinishDate))) from Job j2 where j2.ItemID = opi.ItemID)
)
when opi.SplitMode1 = 0 and opi.SplitMode2 = 2 and j.SplitPart2 is not null and j.SplitPart3 is null then
dbo.SplitCount(opi.ProductIn,
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j2.FactStartDate, j2.PlanStartDate), COALESCE(j2.FactFinishDate, j2.PlanFinishDate))) from Job j2 where j2.ItemID = opi.ItemID)
)
when opi.SplitMode1 = 1 and j.SplitPart1 is not null and opi.SplitMode2 = 2 and j.SplitPart2 is not null and opi.SplitMode3 = 0 and j.SplitPart3 is not null then
dbo.SplitCount(opi.ProductIn / opi.Multiplier,
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j7.FactStartDate, j7.PlanStartDate), COALESCE(j7.FactFinishDate, j7.PlanFinishDate))) from Job j7 where j7.ItemID = opi.ItemID and j7.SplitPart1 = j.SplitPart1 and j7.SplitPart2 = j.SplitPart2)
)
when opi.SplitMode1 = 2 and j.SplitPart1 is not null and opi.SplitMode2 = 0 and j.SplitPart2 is not null and j.SplitPart3 is null then
dbo.SplitCount(opi.ProductIn,
COALESCE(j.FactStartDate, j.PlanStartDate),
COALESCE(j.FactFinishDate, j.PlanFinishDate),
(select sum(datediff(second, COALESCE(j10.FactStartDate, j10.PlanStartDate), COALESCE(j10.FactFinishDate, j10.PlanFinishDate))) from Job j10 where j10.ItemID = opi.ItemID and j10.SplitPart1 = j.SplitPart1)
)
else
opi.ProductIn
end)
 as ProductIn
,

 j.EquipCode, j.PlanStartDate, j.PlanFinishDate, j.FactStartDate, j.FactFinishDate, j.TimeLocked,
 wo.OrderState, wo.ID_Number, opi.ItemID, wo.FinishDate, opi.EstimatedDuration, j.IsPaused,
 j.Executor, j.FactProductOut, opi.ProcessID, j.JobID, j.JobComment, j.JobAlert, opi.AutoSplit,
 j.SplitPart1, j.SplitPart2, j.SplitPart3, opi.SplitMode1, opi.SplitMode2, opi.SplitMode3,
 j.JobColor,
 cast((case when exists (select * from OrderNotes orn where orn.OrderID = wo.N and orn.UseTech = 1) then 1 else 0 end) as bit) as HasTechNotes,
cast((opi.OwnCost + opi.ItemProfit) * wo.Course as decimal(18,2)) as ItemCost
,
ColorsA, ColorsB, PaperType, PrintType, PaperDensity, Pages, MachNum, NotebookPages, PaperFormatX, PaperFormatY, sp.Cathegory, cast(0 as int) as PantoneCountA, cast(0 as int) as PantoneCountB, (select top 1 cast(sl.Type as varchar(10)) + ':' + cast(opi1.Part as varchar(10)) from Service_Lakirovka sl inner join OrderProcessItem opi1 on sl.ItemID = opi1.ItemID   where opi1.OrderID = opi.OrderID and (opi1.Part = opi.Part or opi1.Part > 1000) and opi1.Enabled = 1 order by sl.N) as ProtectLakType1, (select top 1 cast(sl.Type as varchar(10)) + ':' + cast(opi1.Part as varchar(10)) from Service_Lakirovka sl inner join OrderProcessItem opi1 on sl.ItemID = opi1.ItemID   where opi1.OrderID = opi.OrderID and (opi1.Part = opi.Part or opi1.Part > 1000) and opi1.Enabled = 1 order by sl.N desc) as ProtectLakType2, CallCustomer, cast((select count(*) from OrderProcessItem opi2 where opi2.OrderID = opi.OrderID   and opi2.Enabled = 1 and opi2.ContractorProcess = 1 and opi2.ProcessID <> 2 and opi2.ProcessID <> 39 and (opi2.Part = opi.Part or opi.Part > 1000 or opi2.Part > 1000)) as bit) as HasContractorProcess, dbo.GetInkNames(j.ItemID, 1, (select COUNT(*) from Service_PrintInk p1 inner join OrderProcessItem opi1 on opi1.ItemID = p1.ItemID where LinkedItemID = j.ItemID and (InkSide = 1 or InkSide = 3))) as PantoneFace, dbo.GetInkNames(j.ItemID, 2, (select COUNT(*) from Service_PrintInk p1 inner join OrderProcessItem opi1 on opi1.ItemID = p1.ItemID where LinkedItemID = j.ItemID and (InkSide = 2 or InkSide = 3))) as PantoneBack, (select top 1 (case when FactReceiveDate is not null then cast(0 as datetime) else PlanReceiveDate end) from OrderProcessItemMaterial where MatTypeName = 'Paper' and ItemID = opi.ItemID and RequestModified = 0) as PaperReadyDate
FROM OrderProcessItem opi  inner join WorkOrder wo on wo.N = opi.OrderID
 inner join Customer cc on cc.N = wo.Customer
 right join Job j on j.ItemID = opi.ItemID
 left join Dic_SpecialJob dsj on dsj.Code = JobType
left join Service_Print sp on sp.ItemID = opi.ItemID
WHERE  j.EquipCode = 13
 and ((opi.Enabled = 1 and wo.IsDraft = 0 and wo.IsDeleted = 0) or JobType <> 0) and ((j.PlanStartDate between convert(datetime, '2012-08-29 07:00:00.000', 121) and convert(datetime, '2012-09-26 06:59:00.000', 121)) and j.FactStartDate is null  or (j.FactStartDate between convert(datetime, '2012-08-29 07:00:00.000', 121) and convert(datetime, '2012-09-26 06:59:00.000', 121)) or (j.PlanFinishDate between convert(datetime, '2012-08-29 07:00:00.000', 121) and convert(datetime, '2012-09-26 06:59:00.000', 121)) and j.FactFinishDate is null  or (j.FactFinishDate between convert(datetime, '2012-08-29 07:00:00.000', 121) and convert(datetime, '2012-09-26 06:59:00.000', 121)) or ((j.PlanStartDate < convert(datetime, '2012-08-29 07:00:00.000', 121) and j.FactStartDate is null or j.FactStartDate < convert(datetime, '2012-08-29 07:00:00.000', 121)) and (j.PlanFinishDate > convert(datetime, '2012-09-26 06:59:00.000', 121) and j.FactFinishDate is null or j.FactFinishDate > convert(datetime, '2012-09-26 06:59:00.000', 121))))

