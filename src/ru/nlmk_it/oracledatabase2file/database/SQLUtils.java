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
    
    private static final Logger LOGGER = LogManager.getLogger(SQLUtils.class);
    
    /**
     * 
     * @param script
     * @return 
     */
    public static List<String> splitScript(final String script) {
        if (LOGGER.isTraceEnabled()) {
            LOGGER.trace("The method buildScript() was invoked\n"
                + "\tString script <= " + script);
        }
        else {
            LOGGER.debug("The method buildScript() was invoked\n"
                + "\tString script <= " + (script == null ? "null" 
                        : (script.length() <= 30 ? script : script.substring(0, 30))));
        }
        
        List<String> result = new ArrayList<>();
        
        String copy = replaceCommentsStringsAndAliasesToSpace(script);
        
        int startIndex = 0;
        for (int i = 0; i < copy.length(); i++) {
            if (copy.charAt(i) == ';') {
                
                String selectedExpression = script.substring(startIndex, i).trim();
                
                if (!selectedExpression.equalsIgnoreCase("")) {
                    LOGGER.trace("selectedExpression = '" + selectedExpression + "'");
                    result.add(selectedExpression);
                }
                startIndex = i + 1;
            }
        }
        
        if (startIndex != copy.length()) {
            
            String selectedExpression = script.substring(startIndex, copy.length()).trim();
            
            if (!selectedExpression.equalsIgnoreCase("")) {
                
                if (selectedExpression.charAt(selectedExpression.length() - 1) == ';') {
                    selectedExpression = selectedExpression.substring(0, selectedExpression.length() - 1).trim();
                }
                
                LOGGER.trace("selectedExpression = '" + selectedExpression + "'");
                result.add(selectedExpression);
            }
        }
        
        LOGGER.trace("splitScript() returned => " + result.toString());
        return result;
    }
    
    /**
     * 
     * @param script
     * @param variableMarker
     * @return 
     */
    public static Set<String> getVariables(final String script, final String variableMarker) {
        LOGGER.trace("The method getVariables() was invoked\n"
                + "\tString script <= " + (script == null ? "null" 
                        : (script.length() <= 30 ? script : script.substring(0, 30)))
                + "\n\tString variableMarker <= " + (variableMarker == null ? "null" 
                        : (variableMarker.length() <= 30 ? script : variableMarker.substring(0, 30))));
        
        Set<String> result = new HashSet<>();
        
        String copy = replaceCommentsStringsAndAliasesToSpace(script);
        
        // Нужно разделить выражение на отдельные элементы.
        // разделителем является любой символ, кроме:
        // Букв, цифр, подчёркивания, амперсанда, маркера переменной
        String[] words = copy.split("[^a-zA-Z0-9_" + variableMarker + "]+");
        
        for (String word: words) {
            
            if (word.length() < 1) {
                continue;
            }
            //LOGGER.trace("word = " + word);
            if (word.substring(0, variableMarker.length()).equalsIgnoreCase(variableMarker)) {
                result.add(word.substring(1));
            }
        }
        
        LOGGER.trace("getVariables() returned => " + result.toString());
        return result;
    }
    
    /**
     * 
     * @param expression
     * @param oldSequence
     * @param newSequence
     * @return 
     */
    public static String replaceCharSequence(String expression, String oldSequence, String newSequence) {

        if (LOGGER.isTraceEnabled()) {
            LOGGER.trace("The method replaceCharSequence() was invoked\n"
                    + "\tString expression <= " + expression + "\n"
                    + "\tString oldSequence <= " + oldSequence + "\n"
                    + "\tString newSequence <= " + newSequence);
        }
        else {
            LOGGER.debug("The method replaceCharSequence() was invoked\n"
                    + "\tString expression <= " + (expression == null ? "null"
                            : (expression.length() <= 30 ? expression
                                    : expression.substring(0, 30) + "...")) + "\n"
                    + "\tString oldSequence <= " + (oldSequence == null ? "null"
                            : (oldSequence.length() <= 30 ? oldSequence
                                    : oldSequence.substring(0, 30) + "...")) + "\n"
                    + "\tString newSequence <= " + (newSequence == null ? "null"
                            : (newSequence.length() <= 30 ? newSequence
                                    : newSequence.substring(0, 30))));
        }
	
	String result = replaceCommentsStringsAndAliasesToSpace(expression)
                .replaceAll(oldSequence, newSequence);
        
        LOGGER.trace("replaceCharSequence => " + result);
        return result;
    }
    
    
    /**
     * 
     * @param script
     * @return 
     */
    private static String replaceCommentsStringsAndAliasesToSpace(final String script) {
        LOGGER.trace("The method replaceCommentsStringsAndAliasesToSpace() was invoked,\n"
                + "\tString script <= " + (script == null ? "null" 
                        : (script.length() <= 30 ? script : script.substring(0, 30))));
        
        char[] symbol = script.toCharArray();
        LOGGER.debug("The length of script is " + symbol.length + " symbols.");
        
        // There's removing strings, aliases and comments to simplify
        // the allocation of the variables
        StringBuilder copy = new StringBuilder(script);
        
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
                            else {
                                copy.setCharAt(index, symbol[index]);
                                continue;
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
            
            copy.setCharAt(index, ' ');
        }
        
        String result = copy.toString();
        
        LOGGER.trace("Copied script = " + result);
        
        return result;
    }
    
    
    /**
     * 
     * @param script
     * @return 
     */
    public static String replaceCommentsToSpace(final String script) {
        LOGGER.trace("The method replaceCommentsToSpace() was invoked,\n"
                + "\tString script <= " + (script == null ? "null" 
                        : (script.length() <= 30 ? script : script.substring(0, 30))));
        
        char[] symbol = script.toCharArray();
        LOGGER.debug("The length of script is " + symbol.length + " symbols.");
        
        // There's removing strings, aliases and comments to simplify
        // the allocation of the variables
        StringBuilder copy = new StringBuilder(script);
        
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
                                copy.setCharAt(index-1, ' ');
                            }
                            else if (symbol[index] == '*' && index != 0 && symbol[index-1] == '/') {
                                isMultiLineComment = true;
                                copy.setCharAt(index-1, ' ');
                            }
                            else if (symbol[index] == '\'') {
                                isString = true;
                                copy.setCharAt(index, symbol[index]);
                                continue;
                            }
                            else if (symbol[index] == '"') {
                                isAlias = true;
                                copy.setCharAt(index, symbol[index]);
                                continue;
                            }
                            else {
                                copy.setCharAt(index, symbol[index]);
                                continue;
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
                    continue;
                }
            }
            
            copy.setCharAt(index, ' ');
        }
        
        String result = copy.toString();
        
        LOGGER.trace("Copied script = " + result);
        
        return result;
    }
}
