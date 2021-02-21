import ballerinax/java.jdbc;
import ballerina/sql;
import Links.data;
import ballerina/log;

jdbc:Options h2options = {
    datasourceName: "org.h2.jdbcx.JdbcDataSource",
    properties: {"loginTimeout": "2000"}
};

sql:ConnectionPool connPool = {
    maxOpenConnections: 5,
    maxConnectionLifeTimeInSeconds: 2000.0,
    minIdleConnections: 5
};

jdbc:Client linksDBClient = check new (url = "jdbc:h2:file:./target/linksDB", options = h2options, connectionPool = 
connPool);

# This method can be used to add initial DML and DDL to the database
# + return - Return Value Description  
public function initializeLinksDb() returns sql:Error? {
    int|string|sql:Error? result = initializeLinksTable(linksDBClient);
    if (result is int|string) {
        log:print(result.toBalString());
    } else if (result is sql:Error) {
        log:printError("Error occurred: ", err = result);
    }
}

public function getLinksDbClient() returns jdbc:Client|sql:Error {
    return linksDBClient;
}

public function getAllRecords(jdbc:Client|sql:Error jdbcClient) returns json[] {
    json[] output = [];
    sql:ParameterizedQuery query = `select * from Links`;
    if (jdbcClient is jdbc:Client) {
        stream<record { }, error> resultStream = jdbcClient->query(query);

        error? e = resultStream.forEach(function(record { } result) {
                                            var jsonOrError = result.cloneWithType(json);
                                            if (jsonOrError is json) {
                                                output.push(jsonOrError);
                                                log:print("Print JSON result");
                                                log:print(output.toString());
                                            }
                                        });

        if (e is error) {
            log:printError("ForEach operation on the stream failed!", err = e);
        }
    }
    return output;
}

public function getAllRecordsInGroup(jdbc:Client|sql:Error jdbcClient, string group) returns json[] {
    json[] output = [];
    sql:ParameterizedQuery query = `select * from Links where groupName=${group}`;
    if (jdbcClient is jdbc:Client) {
        stream<record { }, error> resultStream = jdbcClient->query(query);

        error? e = resultStream.forEach(function(record { } result) {
                                            var jsonOrError = result.cloneWithType(json);
                                            if (jsonOrError is json) {
                                                output.push(jsonOrError);
                                                log:print("Print JSON result");
                                                log:print(output.toString());
                                            }
                                        });

        if (e is error) {
            log:printError("ForEach operation on the stream failed!", err = e);
        }
    }
    return output;
}

function initializeLinksTable(jdbc:Client jdbcClient) returns int|string|sql:Error? {
    sql:ExecutionResult result = check jdbcClient->execute(
    "CREATE TABLE IF NOT EXISTS Links" + "(linkID INTEGER NOT NULL IDENTITY, linkName VARCHAR(300) NOT NULL UNIQUE, linkPath VARCHAR(300)," + "groupName VARCHAR(300), PRIMARY KEY (linkID))");

    return addDefaultLinksTable(jdbcClient);
}


# Description
#   TODO need to load data from defined sql files
# + jdbcClient - Parameter Description
# + return - Return Value Description  
function addDefaultLinksTable(jdbc:Client jdbcClient) returns sql:Error? {
    data:DataLoader loader = new data:DataLoader();
    data:Link[]|error? defaultLinks = loader.loadData();

    error|sql:ExecutionResult? result = ();
    if (defaultLinks is error) {
        log:printError("Cannot load default data", err = defaultLinks);
    } else if (defaultLinks is data:Link[]) {
        foreach var link in defaultLinks {
            result = addLinksToTable(jdbcClient, link.name, link.path, link.group);
        }
        if (result is error) {
            log:printError("Cannot add data to db", err = result);
        }
    } else {
        log:print("Default links are empty");
    }
}

function addLinksToTable(jdbc:Client jdbcClient, string linkName, string link, string group) returns sql:ExecutionResult|error {
    string query =  string `INSERT INTO Links (linkName,linkPath,groupName) VALUES ('${linkName}', '${link}', '${group}')`;
    // log:print(query);
    sql:ExecutionResult|error result = jdbcClient->execute(query);
    return result;
}

function updateRecord(jdbc:Client jdbcClient, int generatedId, string linkPath, string linkName) {
    sql:ParameterizedQuery updateQuery = `Update Links set linkPath = ${linkPath} linkName = ${linkName}
         where linkId = ${generatedId}`;

    sql:ExecutionResult|sql:Error result = jdbcClient->execute(updateQuery);

    if (result is sql:ExecutionResult) {
        log:print(result?.affectedRowCount.toString());
    } else {
        log:printError("Error occurred: ", err = result);
    }
}

function deleteRecord(jdbc:Client jdbcClient, int generatedId) {
    sql:ParameterizedQuery deleteQuery = `Delete from Links where linkId = ${generatedId}`;
    sql:ExecutionResult|sql:Error result = jdbcClient->execute(deleteQuery);

    if (result is sql:ExecutionResult) {
        log:print("Deleted Row count: " + result.affectedRowCount.toString());
    } else {
        log:printError("Error occurred: ", err = result);
    }
}
