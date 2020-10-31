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

    return linksDBClient;
}

public function getAllRecord(jdbc:Client|sql:Error jdbcClient) returns json {
    sql:ParameterizedQuery query = `select * from Links`;
    if (jdbcClient is jdbc:Client) {
        sql:ExecutionResult|sql:Error result = jdbcClient->executeQuery(query);

        if (result is sql:ExecutionResult) {
            log:printDebug(result?.affectedRowCount);
            log:printDebug(result);
            json js = {};
            json j8 = checkpanic js.mergeJson(result?.affectedRowCount);
            return result?.affectedRowCount.toJsonString();
        } else {
            log:printError("Error occurred: ", result);
        }
    }
    return ();
}

public function initializeLinksTable(jdbc:Client jdbcClient) returns int|string|sql:Error? {
    sql:ExecutionResult result = check jdbcClient->execute("CREATE TABLE IF NOT EXISTS Links" + 
    "(linkId INTEGER NOT NULL IDENTITY, linkName VARCHAR(300), " + "linkPath VARCHAR(300), PRIMARY KEY (linkId))");
}