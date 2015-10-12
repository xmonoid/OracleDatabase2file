/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.database;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author Косых Евгений
 */
public abstract class SQLExpression {
    
    private static final Logger log = LogManager.getLogger(SQLExpression.class);
    
    protected final String expression;
    
    public SQLExpression(String expression) {
        log.trace("It was created an object of SQLExpression class\n"
                + "\tString expression <= " + expression);
        // Некоторые команды (такие как commit) выражений не содержат.
        this.expression =  (expression == null || expression.isEmpty()) ? "" : expression.trim();
    }
}
