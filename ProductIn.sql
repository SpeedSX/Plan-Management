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
