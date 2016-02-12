/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.database;

import java.sql.Connection;
import java.sql.SQLException;
import oracle.jdbc.OracleCallableStatement;
import org.apache.log4j.Logger;
import static ru.nlmk_it.oracledatabase2file.logutils.LogUtils.substring;

/**
 *
 * @author Косых Евгений
 */
public abstract class CallableExpression extends SQLExpression {
    
    private static final Logger LOGGER = Logger.getLogger(CallableExpression.class);
    
    protected final String callableExpression;
    
    public CallableExpression(String expression) {
        super(expression);
        LOGGER.trace("The object of DMLExpression class was created\n"
                + "\tString expression <= " + substring(expression));
        this.callableExpression = "{" + expression + "}";
    }
    
    
    @Override
    public void createStatement(Connection connection) throws SQLException {
        LOGGER.trace("The method createStatement() was invoked\n"
                + "\tConnection connection <= " + connection);
        preparedStatement = (OracleCallableStatement) connection.prepareCall(expression);
    }
    
    @Override
    public boolean execute() throws SQLException {
        LOGGER.trace("The method execute() was invoked.");
        
        int updateRows = preparedStatement.executeUpdate();
        LOGGER.debug("");
        
        boolean result = updateRows > 0;
        LOGGER.trace("execute() was returned => " + result);
        return result;
    }
}
