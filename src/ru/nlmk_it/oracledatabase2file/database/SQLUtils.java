/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.database;

import java.text.DateFormat;
import java.text.ParseException;
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
        LOGGER.trace("The method splitScript() was invoked\n"
            + "\tString script <= " + script);
        
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
                + "\tString script <= " + script
                + "\n\tString variableMarker <= " + variableMarker);
        
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
    public static String replaceCharSequence(String expression,
            String oldSequence,
            String newSequence) {
        LOGGER.trace("The method replaceCharSequence() was invoked\n"
                + "\tString expression <= " + expression + "\n"
                + "\tString oldSequence <= " + oldSequence + "\n"
                + "\tString newSequence <= " + newSequence);

        String copy = replaceCommentsStringsAndAliasesToSpace(expression);
	
        StringBuilder result = new StringBuilder(expression);
        
        int position;
	while ((position = copy.indexOf(oldSequence)) >= 0) {
            
            result.replace(position, position + oldSequence.length(), newSequence);
            
            copy = replaceCommentsStringsAndAliasesToSpace(result.toString());
        }
        
        LOGGER.trace("replaceCharSequence => " + result);
        return result.toString();
    }
    
    
    /**
     * 
     * @param script
     * @return 
     */
    private static String replaceCommentsStringsAndAliasesToSpace(final String script) {
        LOGGER.trace("The method replaceCommentsStringsAndAliasesToSpace() was invoked,\n"
                + "\tString script <= " + script);
        
        char[] symbol = script.toCharArray();
        LOGGER.trace("The length of script is " + symbol.length + " symbols.");
        
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
                + "\tString script <= " + script);
        
        char[] symbol = script.toCharArray();
        LOGGER.trace("The length of script is " + symbol.length + " symbols.");
        
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
                            continue;
                        }
                    }
                    else {
                        // The end of a string.
                        if (symbol[index] == '\'') {
                            isString = false;
                        }
                        continue;
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
    
    /**
     * 
     * @param enteredValue
     * @param dateFormat
     * @return 
     */
    public static Object bindedObject(String enteredValue, DateFormat dateFormat) {
        LOGGER.trace("The method bindedObject() was invoked:\n"
                + "\tString enteredValue <= " + enteredValue);
        
        Object result;
        try {
            
            result = dateFormat.parse(enteredValue);
        }
        catch (ParseException e) {
            result = enteredValue;
        }
        LOGGER.trace("bindedObject() returned => " + result);
        return result;
    }
}
