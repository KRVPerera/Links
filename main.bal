import ballerina/io;
import rukshanp/Links.db as db;
import ballerina/http;
import ballerina/log;
import ballerinax/java.jdbc as jdbc;
import ballerina/sql;

jdbc:Client|sql:Error linkdDbClient = db:getLinksDbClient();

public function main() {
    db:initializeLinksDb();
    io:println("Hello World!");
}

service /links on new http:Listener(9090) {
    resource function get all(http:Caller caller, http:Request req) {

        http:Response res = new;
        res.statusCode = 500;
        res.setPayload("Asasd");
        var x = caller->respond("sfs");
    }

    @http:ResourceConfig {
        // cors: {allowOrigins: ["*", "http://localhost:3000"]},
        consumes: ["application/json"]
    }
    resource function post db(http:Caller caller, http:Request req) {
        var jsonMsg = req.getJsonPayload();
        if (jsonMsg is json) {
            log:print(jsonMsg.toString());
            json|error nameString = jsonMsg.name;

            http:Response|error response;
            if (nameString is json) {
                log:print("namestring is json");
                if (nameString.toString() == "all") {
                    http:Response res = new;
                    res.statusCode = 200;

                    log:print("Hit all request");

                    if (linkdDbClient is jdbc:Client) {
                        json[] queryResult = db:getAllRecords(linkdDbClient);
                        log:print("RECIEVED data from DB");
                        res.setPayload(queryResult);
                    }

                    var result1 = caller->respond(res);
                    if (result1 is error) {
                        log:printError("Error sending response", err = result1);
                    }

                } else {
                    http:Response res = new;
                    res.statusCode = 500;
                    res.setPayload("Invalid request");
                    var result2 = caller->respond(res);
                    if (result2 is error) {
                        log:printError("Error sending response", err = result2);
                    }
                }
            } else {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(<@untainted>nameString.message());
                var result3 = caller->respond(res);
                if (result3 is error) {
                    log:printError("Error sending response", err = result3);
                }
            }
        } else {
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(<@untainted>jsonMsg.message());
            var result4 = caller->respond(res);
            if (result4 is error) {
                log:printError("Error sending response", err = result4);
            } else {
               log:print("no json pay load"); 
            }
        }
    }
}
