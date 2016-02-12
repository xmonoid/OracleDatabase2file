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
public abstract class SQLExpression {
    
    private static final Logger LOGGER = Logger.getLogger(SQLExpression.class);
    
    protected final String expression;
    
    protected OraclePreparedStatement preparedStatement;
    
    public SQLExpression(String expression) {
        LOGGER.trace("The object of SQLExpression class was created\n"
                + "\tString expression <= " + substring(expression));
        // Некоторые команды (такие как commit) выражений не содержат.
        this.expression = (expression == null || expression.isEmpty()) ? "" : expression.trim();
    }
    
    @Override
    public String toString() {
        LOGGER.trace("The method toString() was created\n");
        LOGGER.trace("toString() was returned => " + expression);
        return expression;
    }
    
    
    /**
     * 
     * @return 
     */
    public String toStringShort() {
        
        return substring(expression);
    }
    
    /**
     * This method creates the statement before it will be executed.
     * 
     * @param connection Opened SQL connection.
     * @throws SQLException Caused if during the creation of the connection there was a problem.
     */
    public abstract void createStatement(Connection connection) throws SQLException;
    
    /**
     * This method binds a variable in current SQL-expression.
     * 
     * @param name A string name of variable.
     * @param value A value of the variable.
     * @throws SQLException Caused is during binding the variable there was a problem.
     */
    public void bindVariable(String name, Object value) throws SQLException {
        LOGGER.trace("The method bindVariable() was invoked\n"
                + "\tString name <= " + substring(name) + "\n"
                + "\tObject value <= " + value);
        
        if (value instanceof java.util.Date) {
            preparedStatement.setDateAtName(name, new java.sql.Date(((java.util.Date) value).getTime()));
        }
        else if (value instanceof java.lang.String) {
            preparedStatement.setFixedCHARAtName(name, (String) value);
        }
    }
    
    /**
     * This method executes the SQL-expression.
     * @return true if the expression was executed complete and false otherwise.
     * @throws SQLException Caused is during execution of the expression there was a problem.
     */
    public abstract boolean execute() throws SQLException;
    
    /**
     * This method closes the connection.
     * 
     * @throws SQLException Caused is during closing the connection there was a problem.
     */
    public void close() throws SQLException {
        LOGGER.trace("The method close() was invoked");
        preparedStatement.close();
        LOGGER.debug("Statement was closed.");
    }
    
    /**
     * 
     * @param expression
     * @return
     * @throws SQLException 
     */
    public static SQLExpression recognizeExpression(String expression) throws SQLException {
        
        String[] tokens = SQLUtils.replaceCommentsToSpace(expression).trim().split("\\s+");
            
        if (tokens[0].equalsIgnoreCase("select")) {
            return new Select(expression);
        }
        
        throw new UnsupportedOperationException("Not supported yet.");
    }
}
