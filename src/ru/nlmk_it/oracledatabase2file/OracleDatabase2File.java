/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.apache.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.arguments.Arguments;
import ru.nlmk_it.oracledatabase2file.database.SQLExpression;
import ru.nlmk_it.oracledatabase2file.database.SQLScript;
import ru.nlmk_it.oracledatabase2file.database.SQLUtils;
import ru.nlmk_it.oracledatabase2file.database.Select;
import ru.nlmk_it.oracledatabase2file.exporters.Exporter;

/**
 *
 * @author Косых Евгений
 */
public final class OracleDatabase2File {
    
    private static final Logger LOGGER = Logger.getLogger(OracleDatabase2File.class);
    
    private final Connection connection;
    
    private final Arguments arguments;
    
    /**
     * 
     * @param arguments
     * @throws SQLException 
     * @throws java.lang.ClassNotFoundException 
     */
    public OracleDatabase2File(Arguments arguments) throws SQLException, ClassNotFoundException {
        LOGGER.trace("The object of OracleDatabase2File class was created\n"
                + "\tArguments arguments <= " + arguments.toString());
        
        arguments.validate();
        LOGGER.debug("All arguments = " + arguments.toString());
        
        String url = arguments.getURL();
        String login = arguments.getLogin();
        LOGGER.debug("Trying to connect to database: " + url + "\n"
                + "\tlogin = " + login);
        
        Class.forName("oracle.jdbc.driver.OracleDriver");
        
        connection = DriverManager.getConnection(url, login, arguments.getPassword());
        
        LOGGER.info("Database connection created.");
        
        this.arguments = arguments;
    }
    
    /**
     * 
     * @throws SQLException
     * @throws IOException 
     */
    public void execute() throws SQLException, IOException {
        LOGGER.trace("The method execute() was invoked");
        
        SQLScript script = arguments.getSQLScript();
        
        script.buildScript(arguments.getSqlVariableMarker());
        
        Set<String> vars = script.getVariables();
        LOGGER.debug("The set of all parameters in the script = " + vars);
        
        Map<String, String> params = arguments.getSqlParams();
        LOGGER.debug("Actual SQL parameters = " + params);
        
        checkBindedVariables(vars, params.keySet());
        
        List<SQLExpression> expressions = script.getExpressions();
        
        LOGGER.info("There's selected " + expressions.size() + " expressions.");
        
        Set<ResultSet> resultSets = new HashSet<ResultSet>();
        for (SQLExpression expression: expressions) {
            LOGGER.debug("Executing the expression =\n" + expression.toStringShort());
            
            Set<String> variables = SQLUtils.getVariables(expression.toString(), ":");
            
            LOGGER.debug("Variables in the current expression: " + variables);
            expression.createStatement(connection);
            
            for (String var: variables) {
                
                if (!params.containsKey(var)) {
                    throw new SQLException("The variable '" + var + "' doesn't binded.");
                }
                expression.bindVariable(var,
                        SQLUtils.bindedObject(params.get(var), arguments.getSqlDateFormat()));
            }
            
            if (expression instanceof Select) {
                LOGGER.debug("The expression was recognized as the Select statement.");
                Select select = (Select) expression;
                ResultSet resultSet = select.executeSelect();

                resultSets.add(resultSet);
            }
            else {
                expression.execute();
            }
        }
        LOGGER.info("All SQL expressions executed correctly, it's starting the export.");
        
        Exporter exporter = Exporter.getExporter(arguments);
        
        exporter.export(resultSets);
        
        for (SQLExpression expression: expressions) {
            expression.close();
        }
    }
    
    /**
     * 
     * @throws SQLException 
     */
    //@Override
    public void close() throws SQLException {
        LOGGER.trace("The method close() was invoked");
        connection.close();
    }
    
    /**
     * 
     * @param requiredVariables
     * @param actualVariables
     * @throws SQLException 
     */
    static void checkBindedVariables(Set<String> requiredVariables,
            Set<String> actualVariables) throws SQLException {
        LOGGER.trace("The method checkBindedVariables() was invoked:\n"
                + "\tSet<String> requiredVariables = " + requiredVariables + "\n"
                + "\tSet<String> actualVariables = " + actualVariables);
        
        for (String variable: requiredVariables) {
            
            if (!actualVariables.contains(variable)) {
                
                throw new SQLException("SQL parameter required: " + variable);
            }
        }
    }
}
