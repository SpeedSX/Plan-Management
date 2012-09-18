/*
 * GET home page.
 */

var config = require('./config-sql')
    , sql = require('node-sqlserver')
    , fs = require('fs')
    , moment = require('moment');
//    , nvl = require('nvl');

var dictionaries;

exports.index = function (req, res, next) {
    sql.open(config.connectionString, function (err, conn) {
        if (err) {
            console.log("Error opening the connection " + err);
            //res.render('error', { title: 'Ошибка' });
            return next(err);
        }
        if (!dictionaries)
        {
            loadDictionaries(conn, res, next, function(err, conn, res, next) {
                if (err) {
                    console.log("Error opening dictionaries " + err);
                    //res.render('error', { title: 'Ошибка' });
                    return next(err);
                }
                renderPlannedJobs(conn, res, next);
            });
        }
        else
            renderPlannedJobs(conn, res, next);
    });
};

function Dictionary(dicData)
{
    this.dicData = dicData;
}

Dictionary.prototype.Value = function (code, col) {
    for (var i in this.dicData)
    {
        console.log(this.dicData[i].Code);
        if (this.dicData[i].Code == code)
        {
           // console.log('found');
           // console.log(this.dicData[i]);
            return this.dicData[i]['A' + col];
        }
    }
    console.log('not found');
    return null;
};

function loadDictionaries(conn, res, next, callback)
{
    conn.query('select * from Dic_Equip order by Code', function (err, dic_results) {
            if (!err) {
               // console.log(dic_results);
                 dictionaries = [];
                 var dic = new Dictionary(dic_results);
                 dictionaries['Equip'] = dic;
            }
            callback(err, conn, res, next);
        }
    );
}

function formatSQLDate(time)
{
    return "'" + time.format('YYYY-MM-DD hh:mm:ss') + "'";
}

function renderPlannedJobs(conn, res, next) {
    fs.readFile('./Plan.sql', 'utf8', function (err, data) {
        if (err) {
            console.log("Error reading file with query text: " + err);
            return next(err);
        }
        var startTime = moment().startOf('day');
        var endTime = moment().endOf('day');
        var planSql = data
            .replace(/{STARTDATE}/g, formatSQLDate(startTime))
            .replace(/{ENDDATE}/g, formatSQLDate(endTime));
        console.log(planSql);

        conn.query(planSql, function (err, results) {
            if (err) {
                console.log("Error running plan sql: " + err);
                return next(err);
            }
            console.log('Read planned jobs ' + results.length);
            //console.log(results[0].OrderID);
            res.render('index', { title: 'Выполнение заказов', plan: processPlanResults(results), moment: moment });
        });
    });
}

function processPlanResults(results)
{
    for (var i in results)
    {
        var row = results[i];
        row.AnyStartDate = row.FactStartDate || row.PlanStartDate;
        row.AnyFinishDate = row.FactFinishDate || row.PlanFinishDate;
        row.Colors = (row.ColorsA || '0') + '+' + (row.ColorsB || '0');
        row.DurationText = moment().minutes(getDuration(row)).format('hh:mm');
        //console.log(row);
    }
    return results;
}

var pmOnPageOwnBack = 2;

function getDictionary(dicName)
{
    return dictionaries[dicName];
}

function getDuration(row)
{
    var d = 0;
    var de = getDictionary('Equip');
    // Приладка
    if (row.MachNum)
    {
        d = row.MachNum * (de.Value(row.EquipCode, 7) + de.Value(row.EquipCode, 8));
        //console.log(row.ItemID + ': EquipCode = ' + row.EquipCode);
        console.log(row.ItemID + ': Duration1 = ' + d);
        if (row.ColorsB > 0 && row.PrintType == pmOnPageOwnBack)
            d += de.Value(row.EquipCode, 9);
        // Время на тираж. Проверка порогового значения
        if (row.PrintPause > 0)
        {
            if (row.ProductOut / row.PrintPause > de.Value(row.EquipCode, 10))
                d += row.ProductOut * 60 / de.Value(row.EquipCode, 12);
            else
                d += row.ProductOut * 60 / de.Value(row.EquipCode, 11);
        }
    }
    console.log(row.ItemID + ': Duration2 = ' + d);
    return d;
}