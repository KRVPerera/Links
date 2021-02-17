import ballerinax/java.jdbc;
import ballerina/sql;
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
    check linksDBClient.close();
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

function initializeLinksTable(jdbc:Client jdbcClient) returns int|string|sql:Error? {
    sql:ExecutionResult result = check jdbcClient->execute(
    "CREATE TABLE IF NOT EXISTS Links" + "(linkID INTEGER NOT NULL IDENTITY, linkName VARCHAR(300) NOT NULL UNIQUE, linkPath VARCHAR(300)," + "groupName VARCHAR(300), PRIMARY KEY (linkID))");
}

function addDefaultLinksTable(jdbc:Client jdbcClient) returns sql:Error? {
    sql:ExecutionResult result = check jdbcClient->execute(
    "INSERT INTO Links (linkName," + "linkPath, groupName) VALUES ('Me', 'https://github.com/KRVPerera', 'daily_use')");
    result = check jdbcClient->execute(
    "INSERT INTO Links (linkName," + "linkPath, groupName) VALUES ('My Issues', 'https://github.com/ballerina-platform/ballerina-lang/issues/assigned/KRVPerera', 'daily_use')");
}

function updateRecord(jdbc:Client jdbcClient, int generatedId, string linkPath, string linkName) {
    sql:ParameterizedQuery updateQuery = `Update Links set linkPath = ${linkPath} linkName = ${linkName}
         where linkId = ${
    generatedId}`;

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
