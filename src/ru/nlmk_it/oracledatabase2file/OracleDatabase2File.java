/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.arguments.Arguments;

/**
 *
 * @author Косых Евгений
 */
public final class OracleDatabase2File implements AutoCloseable {
    
    private static final Logger log = LogManager.getLogger(OracleDatabase2File.class);
    
    private final Connection connection;
    
    public OracleDatabase2File(Arguments arguments) throws SQLException {
        log.trace("It was created an object of OracleDatabase2File class\n"
                + "\tArguments arguments <= " + arguments.toString());
        
        arguments.validate();
        
        String url = arguments.getURL();
        String login = arguments.getLogin();
        log.debug("Trying connect to database: " + url + "\n"
                + "\tlogin = " + login);
        
        connection = DriverManager.getConnection(url, login, arguments.getPassword());
        
        log.info("Connection created.");
    }
    
    public void execute() {
        log.trace("It was invoked execute() method");
    }
    
    @Override
    public void close() throws SQLException {
        log.trace("It was invoked close() method");
        connection.close();
    }
}
