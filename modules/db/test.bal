import ballerinax/java.jdbc;
import ballerina/sql;
import ballerina/log;

public function getAllRecord(jdbc:Client|sql:Error jdbcClient) returns json[] {
    json[] output = [];
    log:print(output.toString());
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