import ballerina/java.jdbc;
import ballerina/sql;
import rukshanp/db;

jdbc:Client|sql:Error linkdDbClient = db:getLinksDbClient();