import ballerina/http;
import ballerinax/java.jdbc as jdbc;
import ballerina/sql;
import rukshanp/Links.db;
import ballerina/log;


jdbc:Client|sql:Error linkdDbClient = db:getLinksDbClient();

service /links on new http:Listener(8080) {
    resource function get all(http:Caller caller, http:Request req) {
               var jsonMsg = req.getJsonPayload();
        if (jsonMsg is json) {
            log:printInfo(jsonMsg.toString());
            json|error nameString = jsonMsg.name;

            http:Response|error response;
            if (nameString is json) {
                if (nameString.toString() == "all") {
                    http:Response res = new;
                    res.statusCode = 200;

                    log:printInfo("Hit all request");

                    if (linkdDbClient is jdbc:Client) {
                        json[] queryResult = db:getAllRecords(linkdDbClient);
                        log:printInfo("RECIEVED data from DB");
                        // log:print(queryResult);
                        res.setPayload(queryResult);
                    }

                    var result = caller->respond(res);
                    if (result is error) {
                        log:printError("Error sending response", 'error = result);
                    }

                } else {
                    http:Response res = new;
                    res.statusCode = 500;
                    res.setPayload("Invalid request");
                    var result = caller->respond(res);
                    if (result is error) {
                        log:printError("Error sending response", 'error = result);
                    }
                }
            } else {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(<@untainted>nameString.message());                
                var result = caller->respond(res);
                if (result is error) {
                    log:printError("Error sending response", 'error = result);
                }
            }
        } else {
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(<@untainted>jsonMsg.message());            
            var result = caller->respond(res);
            if (result is error) {
                log:printError("Error sending response", 'error = result);
            }
        } 
    }
}