/*
 * GET home page.
 */

var config = require('./config-sql');
var Connection = require('tedious').Connection;
var Request = require('tedious').Request;
var fs = require('fs');

var sql_config = {
    userName: 'sa',
    password: 'st',
    server: config.server,
    options: {
        database: config.database,
        debug: {
            packet: true,
            data: true,
            payload: true,
            token: false,
            log: true
        }
    }
};

var dropTempSql = "drop table #tmp";

var createTempSql = "CREATE TABLE #tmp(RowNum int identity, OrigId int)";

var insertSql = "INSERT INTO #tmp (OrigID) \
SELECT opi.ItemID \
FROM EnabledMix opi with (noexpand)  left join Dic_OrderState dos on opi.OrderState = dos.Code \
left join Dic_Equip deq on deq.Code = opi.EquipCode \
inner join Service_Print sp on sp.ItemID = opi.ItemID \
WHERE  (((opi.DefaultEquipGroupCode = 1 and (opi.EquipCode is null or opi.EquipCode = 0)) \
or (opi.EquipCode is not null and opi.EquipCode in (select Code from Dic_Equip where A1 = 1))) \
and opi.PlanFinishDate is null and opi.FactFinishDate is null \
and dos.A7 <> 1 and (deq.A2 <> 1 or deq.A2 is null)) and ( \
    PrintType <> 4 and (opi.OrderState = 21 or opi.OrderState = 15 or opi.OrderState = 20 or opi.OrderState = 30 or opi.OrderState = 40 or opi.OrderState = 50 or opi.OrderState = 60 or opi.OrderState = 53 or opi.OrderState = 56 or opi.OrderState = 100))";

var notPlannedSql = "SELECT opi.OrderID, opi.CustomerName, opi.JobID, \
opi.Part, opi.EquipCode, opi.Comment, opi.ID_Number, opi.ItemDesc, opi.ProductOut, \
    opi.FinishDate, opi.PlanStartDate, opi.PlanFinishDate, opi.FactStartDate, opi.FactFinishDate, \
    opi.ItemID, opi.OrderState, opi.EstimatedDuration, opi.ProcessID, opi.OwnCost + opi.ItemProfit as Cost, \
    opi.SideCount, opi.Multiplier, opi.JobComment, opi.JobAlert, \
    cast((case when exists (select * from OrderNotes orn where orn.OrderID = opi.OrderID and orn.UseTech = 1) then 1 else 0 end) as bit) as HasTechNotes \
    , ColorsA, ColorsB, PaperType, PrintType, Cathegory, PaperDensity, Pages, PrintPages, MachNum, NotebookPages, PaperFormatX, PaperFormatY, cast(0 as int) as PantoneCountA, cast(0 as int) as PantoneCountB, (select top 1 (case when FactReceiveDate is not null then cast(0 as datetime) else PlanReceiveDate end) from OrderProcessItemMaterial where MatTypeName = ''Paper'' and ItemID = opi.ItemID) as PaperReadyDate, (select top 1 cast(sl.Type as varchar(10)) + '':'' + cast(opi1.Part as varchar(10)) from Service_Lakirovka sl inner join OrderProcessItem opi1 on sl.ItemID = opi1.ItemID   where opi1.OrderID = opi.OrderID and (opi1.Part = opi.Part or opi1.Part > 1000) and opi1.Enabled = 1 order by sl.N) as ProtectLakType1, (select top 1 cast(sl.Type as varchar(10)) + '':'' + cast(opi1.Part as varchar(10)) from Service_Lakirovka sl inner join OrderProcessItem opi1 on sl.ItemID = opi1.ItemID   where opi1.OrderID = opi.OrderID and (opi1.Part = opi.Part or opi1.Part > 1000) and opi1.Enabled = 1 order by sl.N desc) as ProtectLakType2, cast((select count(*) from OrderProcessItem opi2 where opi2.OrderID = opi.OrderID and opi2.Enabled = 1 and opi2.ContractorProcess = 1 and opi2.ProcessID <> 2 and opi2.ProcessID <> 39 and (opi.Part = opi2.Part or opi2.Part > 1000 or opi.Part > 1000)) as bit) as HasContractorProcess\
FROM #tmp AS temp_table INNER JOIN EnabledMix opi with (noexpand) on temp_table.OrigId = opi.ItemID \
left join Dic_OrderState dos on opi.OrderState = dos.Code \
left join Dic_Equip deq on deq.Code = opi.EquipCode \
inner join Service_Print sp on sp.ItemID = opi.ItemID \
WHERE temp_table.RowNum BETWEEN (300 * 0 + 1) AND (300 * (0 + 1))";

var connection = new Connection(sql_config);

connection.on('connect', function (err) {
    if (err) {
        console.log(err);
    }
    else {
        console.log('connected');
    }
});

connection.on('debug', function (text) {
        console.log(text);
    }
);
connection.on('errorMessage', infoError);

function infoError(info) {
    console.log(info.number + ' : ' + info.message);
}

exports.index = function (req, res) {
    console.log(connection.state);
    if (connection.state == connection.STATE.LOGGED_IN)
        renderPlannedJobs(res);
    else {
        res.render('index', { title:'Не получилось' });
    }
};

function renderPlannedJobs(res) {
    fs.readFile('Plan.sql', function (err, data) {
        if (err) throw err;
        var planSql = data;
        var request = new Request(planSql, function (err, rowCount) {
            if (err) throw err;
            else {
                console.log('Read planned jobs');
                res.render('index', { title: 'Выполнение заказов' });
            }
        });
        request.on('done', function (rowCount, more) {
            console.log(rowCount + ' rows returned');
        });
        connection.execSql(request);
    });
}