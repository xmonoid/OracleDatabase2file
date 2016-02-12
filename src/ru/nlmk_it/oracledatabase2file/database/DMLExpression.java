/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.database;

import java.sql.Connection;
import java.sql.SQLException;
import oracle.jdbc.OraclePreparedStatement;
import org.apache.log4j.Logger;
import static ru.nlmk_it.oracledatabase2file.logutils.LogUtils.substring;

/**
 *
 * @author Косых Евгений
 */
public abstract class DMLExpression extends SQLExpression {
    
    private static final Logger LOGGER = Logger.getLogger(DMLExpression.class);
    
    public DMLExpression(String expression) {
        super(expression);
        LOGGER.trace("The object of DMLExpression class was created\n"
                + "\tString expression <= " + substring(expression));
    }
    
    @Override
    public void createStatement(Connection connection) throws SQLException {
        LOGGER.trace("The method createStatement() was invoked\n"
                + "\tConnection connection <= " + connection);
        preparedStatement = (OraclePreparedStatement) connection.prepareStatement(expression);
    }
    
    @Override
    public boolean execute() throws SQLException {
        LOGGER.trace("The method execute() was invoked");
        boolean result = preparedStatement.execute();
        
        LOGGER.trace("execute() method returned => " + result);
        return result;
    }
}
