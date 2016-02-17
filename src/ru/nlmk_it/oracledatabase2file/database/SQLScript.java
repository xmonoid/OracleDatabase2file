/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.database;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.apache.log4j.Logger;
import static ru.nlmk_it.oracledatabase2file.logutils.LogUtils.*;

/**
 * TODO: The class contains the stubs of methods.
 * @author Косых Евгений
 */
public class SQLScript {
    
    private static final Logger LOGGER = Logger.getLogger(SQLScript.class);
    
    /**
     * The name of the SQL script file. Maybe need to export file.
     */
    private final String scriptName;
    
    /**
     * The list if atomic expressions if the SQL script.
     */
    private List<SQLExpression> expressions;
    
    /**
     * The set of variables in the SQL script.
     */
    private Set<String> variables;
    
    /**
     * 
     */
    private final StringBuilder fileData;
    
    /**
     * 
     * @param scriptFile The file with SQL expressions.
     * @throws IOException
     * @throws SQLException 
     */
    public SQLScript(final File scriptFile) throws IOException, SQLException {
        LOGGER.trace("The object of SQLScript class was created.\n"
                + "\tFile scriptFile <= " + scriptFile.getAbsolutePath());
        
        scriptName = scriptFile.getName();
        
        fileData = new StringBuilder();
	
        // Чтение файла.
        BufferedReader reader = new BufferedReader(new FileReader(scriptFile));
        try {
            char[] buf = new char[1024];
            int numRead;
            while((numRead = reader.read(buf)) != -1){
                String readData = String.valueOf(buf, 0, numRead);
                fileData.append(readData);
            }
        }
        finally {
            reader.close();
        }
    }
    
    
    public void buildScript(String sqlVariableMarker) throws SQLException {
        LOGGER.trace("The method buildScript() was invoked.\n"
                + "\tStringBuilder script <= " + substring(sqlVariableMarker));
        
        if (fileData == null) {
            throw new SQLException("Source file doesn't contain any SQL expressions");
        }
        
        expressions = new ArrayList<SQLExpression>();
        
        variables = SQLUtils.getVariables(fileData.toString(), sqlVariableMarker);
        
        List<String> expressionList = SQLUtils.splitScript(fileData.toString());
        
        for (String expression: expressionList) {
            
            expressions.add(SQLExpression.recognizeExpression(
                    SQLUtils.replaceCharSequence(expression, sqlVariableMarker, ":"))
            );
        }
    }
    
    
    @Override
    public String toString() {
        LOGGER.trace("The method toString() was invoked.");
        
        String result = scriptName.substring(0, scriptName.lastIndexOf("."));
        
        LOGGER.trace("toString() returned => " + result);
        return result;
    }
    
    
    /**
     * 
     * @return 
     * @throws java.sql.SQLException 
     */
    public List<SQLExpression> getExpressions() throws SQLException {
        LOGGER.trace("The method getExpressions() was invoked.");
        LOGGER.trace("getExpressions() returned => " + expressions);
        return expressions;
    }
    
    
    /**
     * 
     * @return 
     * @throws java.sql.SQLException 
     */
    public Set<String> getVariables() throws SQLException {
        LOGGER.trace("The method getVariables() was invoked.");
        LOGGER.trace("getVariables() returned => " + variables);
        return variables;
    }
}
