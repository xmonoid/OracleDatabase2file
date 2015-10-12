/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.database;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author Косых Евгений
 */
public final class SQLUtils {
    
    private static final Logger log = LogManager.getLogger(SQLUtils.class);
    
    public static List<String> splitScript(final String script) {
        log.trace("It was invoked buildScript() method\n"
                + "\tString script <= " + script);
        
        List<String> result = new ArrayList<>();
        char[] symbol = script.toCharArray();
        log.debug("The length of script is " + symbol.length + " symbols.");
        
        boolean isOneLineComment = false;
        boolean isMultiLineComment = false;
        boolean isString = false;
        boolean isAlias = false;
        int fixed = 0;
        int index = 1;
        
        for (; index < symbol.length; index++) {
            
            if (!isOneLineComment) {
                if (!isMultiLineComment) {
                    if (!isString) {
                        if (!isAlias) {
                            
                            if (symbol[index] == '-' && symbol[index-1] == '-') {
                                isOneLineComment = true;
                            }
                            else if (symbol[index-1] == '/' && symbol[index] == '*') {
                                isMultiLineComment = true;
                            }
                            else if (symbol[index] == '\'') {
                                isString = true;
                            }
                            else if (symbol[index] == '"') {
                                isAlias = true;
                            }
                            else if (symbol[index] == ';') {
                                String expression = script.substring(fixed, index).trim();
//                                if (!expression.equals(""))
                                    result.add(expression);
                                fixed = index + 1;
                            }
                            else if (index == symbol.length - 1) {
                                String expression = script.substring(fixed, index + 1).trim();
                                if (!expression.equals(""))
                                    result.add(expression);
                            }
                        }
                        else {
                            // The end of an alias.
                            if (symbol[index] == '"') {
                                isAlias = false;
                            }
                        }
                    }
                    else {
                        // The end of a string.
                        if (symbol[index] == '\'') {
                            isString = false;
                        }
                    }
                }
                else {
                    // The end of a multiply line comment.
                    if (symbol[index-1] == '*' && symbol[index] == '/') {
                        isMultiLineComment = false;
                    }
                }
            }
            else {
                // The end of one line comment.
                if (symbol[index] == '\n') {
                    isOneLineComment = false;
                }
            }
        }
        
        log.trace("splitScript() returned => " + result.toString());
        return result;
    }
    
    
    public static Set<String> getVariables(final String script, final char variableMarker) {
        log.trace("It was invoked getVariables() method\n"
                + "\tString script <= " + script);
        
        Set<String> result = new HashSet<>();
        
        char[] symbol = script.toCharArray();
        log.debug("The length of script is " + symbol.length + " symbols.");
        
        boolean isOneLineComment = false;
        boolean isMultiLineComment = false;
        boolean isString = false;
        boolean isAlias = false;
        
        for (int index = 0; index < symbol.length; index++) {
            if (!isOneLineComment) {
                if (!isMultiLineComment) {
                    if (!isString) {
                        if (!isAlias) {
                            
                            if (symbol[index] == '-' && index != 0 && symbol[index-1] == '-') {
                                isOneLineComment = true;
                            }
                            else if (symbol[index] == '*' && index != 0 && symbol[index-1] == '/') {
                                isMultiLineComment = true;
                            }
                            else if (symbol[index] == '\'') {
                                isString = true;
                            }
                            else if (symbol[index] == '"') {
                                isAlias = true;
                            }
                            
                            if (symbol[index] == variableMarker) {
                                
                            }
                        }
                        else {
                            // The end of an alias.
                            if (symbol[index] == '"') {
                                isAlias = false;
                            }
                        }
                    }
                    else {
                        // The end of a string.
                        if (symbol[index] == '\'') {
                            isString = false;
                        }
                    }
                }
                else {
                    // The end of a multiply line comment.
                    if (symbol[index-1] == '*' && symbol[index] == '/') {
                        isMultiLineComment = false;
                    }
                }
            }
            else {
                // The end of one line comment.
                if (symbol[index] == '\n') {
                    isOneLineComment = false;
                }
            }
        }
        
        log.trace("getVariables() returned => " + result.toString());
        return result;
    }
    
    
}
