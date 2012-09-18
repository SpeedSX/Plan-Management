var server = '.\\SQLEXPRESS';
var database = 'TriadaNew';
var user = 'sa';
var password = 'st';

exports.connectionString = "Driver={SQL Server Native Client 11.0}"
    + ";Server=" + server
    + ";Database={" + database
    + "};UID={" + user
    + "};PWD={" + password + "}";
