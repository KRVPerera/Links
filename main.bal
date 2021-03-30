import ballerina/io;
import rukshanp/Links.db as db;
import rukshanp/Links.util as util;
// import rukshanp/Links.data as data;
import ballerina/http;
import ballerina/log;
import ballerinax/java.jdbc as jdbc;
import ballerina/sql;

jdbc:Client|sql:Error linkdDbClient = db:getLinksDbClient();

public function main() returns error? {
    var initializeLinksDb = check db:initializeLinksDb();
    // data:DataLoader loader = new data:DataLoader();
    // error? loadData = loader.loadData();
    // if (loadData is error) {
    // log:print("CSV loading failed");
    // }
    io:println("Hello World!");
}

service /links on new http:Listener(9090) {
    resource function get all(http:Caller caller, http:Request req) {
        http:Response res = new;
        res.statusCode = 500;
        res.setPayload("Asasd");
        var x = caller->respond("sfs");
    }

    @http:ResourceConfig {consumes: ["application/json"]}
    resource function post db(http:Caller caller, http:Request req) returns error? {
        var jsonMsg = check req.getJsonPayload();
        log:printDebug(jsonMsg.toString());
        json|error nameString = jsonMsg.name;

        http:Response|error response;
        if nameString is json {
            log:printInfo("namestring is json");
            if nameString.toString() == "all" {
                util:LinksResponse res = new util:LinksResponse(200);

                log:printInfo("Hit all request");

                if (linkdDbClient is jdbc:Client) {
                    json[] queryResult = db:getAllRecords(linkdDbClient);
                    log:printInfo("RECIEVED data from DB");
                    _ = res.setPayload(queryResult);
                }

                var result1 = caller->respond(res.res);
                if (result1 is error) {
                    log:printError("Error sending response", 'error = result1);
                }

            } else {
                util:LinksResponse res = new (500);
                _ = res.setPayload("Invalid Response");
                http:ListenerError? respond = caller->respond(res.res);
                if respond is error {
                    log:printError(respond.message(), 'error = respond);
                }
            }
        } else {
            util:LinksResponse res = new (500);
            _ = res.setPayload(nameString.message());
            var result3 = caller->respond(res.res);
            if result3 is error {
                log:printError("Error sending response", 'error = result3);
            }
        }
    }

    @http:ResourceConfig {
        // cors: {allowOrigins: ["*", "http://localhost:3000"]},
        consumes: ["application/json"]}
    resource function post group(http:Caller caller, http:Request req) {
        var jsonMsg = req.getJsonPayload();
        if jsonMsg is json {
            log:printInfo(jsonMsg.toString());
            json|error groupName = jsonMsg.group;

            http:Response|error response;
            if (groupName is json) {
                http:Response res = new;

                log:printInfo("Hit group request");

                if linkdDbClient is jdbc:Client {
                    json[] queryResult = db:getAllRecordsInGroup(linkdDbClient, groupName.toString());
                    res.statusCode = 200;
                    res.setPayload(queryResult);
                }

                var result = caller->respond(res);
                if result is error {
                    log:printError("Error sending response", 'error = result);
                }
            } else {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(<@untainted>groupName.message());
                var result = caller->respond(res);
                if result is error {
                    log:printError("Error sending response", 'error = result);
                }
            }
        } else {
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(<@untainted>jsonMsg.message());
            var result = caller->respond(res);
            if result is error {
                log:printError("Error sending response", 'error = result);
            }
        }
    }
}
