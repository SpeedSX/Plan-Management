var server = '(local)';
var database = 'tetrisNew';
var user = 'alexey';
var password = 'dosia';

exports.connectionString = "Driver={SQL Server Native Client 10.0}"
    + ";Server=" + server
    + ";Database=" + database
    + ";UID={" + user + "}"
    + ";PWD={" + password + "}";
