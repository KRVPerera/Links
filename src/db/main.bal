import ballerina/java.jdbc;
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

function initializeLinksDb() returns sql:Error? {

    jdbc:Client linksDBClient = check new (url = "jdbc:h2:file:./target/linksDB", options = h2options, connectionPool = 
    connPool);

    log:printDebug("JDBC client with optional params created.");

    int|string|sql:Error? result = initializeLinksTable(linksDBClient);
    if (result is int|string) {
        log:printDebug(result);
    } else if (result is sql:Error) {
        log:printError("Error occurred: ", result);
    }

    check linksDBClient.close();
}

public function getLinksDbClient() returns jdbc:Client|sql:Error {

    jdbc:Client linksDBClient = check new (url = "jdbc:h2:file:./target/linksDB", options = h2options, connectionPool = 
    connPool);

    log:printDebug("JDBC client with optional params created.");

    int|string|sql:Error? result = initializeLinksTable(linksDBClient);
    if (result is int|string) {
        log:printDebug(result);
    } else if (result is sql:Error) {
        log:printError("Error occurred: ", result);
    }
    sql:Error? errorOut = addDefaultLinksTable(linksDBClient);

    return linksDBClient;
}

public function getAllRecord(jdbc:Client|sql:Error jdbcClient) returns json {
    sql:ParameterizedQuery query = `select * from Links`;
    if (jdbcClient is jdbc:Client) {
        stream<record { }, error> resultStream = jdbcClient->query(query);

        error? e = resultStream.forEach(function(record { } result) {
                                            log:printDebug("Print result");
                                            log:printDebug(result);
                                            // io:println("Customer first name: ", result["FIRSTNAME"]);
                                            // io:println("Customer last name: ", result["LASTNAME"]);
                                        });

        if (e is error) {
            log:printError("ForEach operation on the stream failed!", e);
        }

    }
    return ();
}

function initializeLinksTable(jdbc:Client jdbcClient) returns int|string|sql:Error? {
    sql:ExecutionResult result = check jdbcClient->execute("CREATE TABLE IF NOT EXISTS Links" + 
    "(linkName VARCHAR(300) NOT NULL, " + "linkPath VARCHAR(300), PRIMARY KEY (linkName))");
}

function addDefaultLinksTable(jdbc:Client jdbcClient) returns sql:Error? {
    sql:ExecutionResult result = check jdbcClient->execute("INSERT INTO Links (linkName," +
        "linkPath) VALUES ('Me', 'https://github.com/KRVPerera')");
}

function updateRecord(jdbc:Client jdbcClient, int generatedId, string linkPath, string linkName) {
    sql:ParameterizedQuery updateQuery = `Update Links set linkPath = ${linkPath} linkName = ${linkName}
         where linkId = ${
    generatedId}`;

    sql:ExecutionResult|sql:Error result = jdbcClient->execute(updateQuery);

    if (result is sql:ExecutionResult) {
        log:printDebug(result?.affectedRowCount);
    } else {
        log:printError("Error occurred: ", result);
    }
}

function deleteRecord(jdbc:Client jdbcClient, int generatedId) {
    sql:ParameterizedQuery deleteQuery = `Delete from Links where linkId = ${generatedId}`;
    sql:ExecutionResult|sql:Error result = jdbcClient->execute(deleteQuery);

    if (result is sql:ExecutionResult) {
        log:printDebug("Deleted Row count: " + result.affectedRowCount.toString());
    } else {
        log:printError("Error occurred: ", result);
    }
}

public function main() {
    sql:Error? err = initializeLinksDb();

    if (err is sql:Error) {
        log:printError("Error occurred, initialization failed!", err);
    } else {
        log:printDebug("Sample executed successfully!");
    }
}
