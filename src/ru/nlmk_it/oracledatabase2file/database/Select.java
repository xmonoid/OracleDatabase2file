/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.database;

import java.sql.ResultSet;
import java.sql.SQLException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import static ru.nlmk_it.oracledatabase2file.logutils.LogUtils.substring;

/**
 *
 * @author Косых Евгений
 */
public final class Select extends DMLExpression {
    
    private static final Logger LOGGER = LogManager.getLogger(Select.class);

    public Select(String expression) {
        super(expression);
        LOGGER.trace("The object of Select class was created\n"
                + "\tString expression <= " + substring(expression));
    }
    
    public ResultSet executeSelect() throws SQLException {
        LOGGER.trace("The method executeSelect() was invoked.");
        LOGGER.info("Executing select...");
        ResultSet result = preparedStatement.executeQuery();
        
        LOGGER.info("The select statement executed correctly.");
        LOGGER.trace("executeSelect() returned => " + result);
        return result;
    }
    
    @Override
    public String toString() {
        LOGGER.trace("The method executeSelect() was invoked.");
        LOGGER.trace("toString() returned => " + expression);
        return expression;
    }
}
