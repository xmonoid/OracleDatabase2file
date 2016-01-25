/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.exporters;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 *
 * @author Косых Евгений
 */
public enum FiletypeEnum {
    
    XLSX,
    
    CSV,
    
    DBF;
    
    private static final Logger LOGGER = LogManager.getLogger(FiletypeEnum.class);
	
    /**
     * Supported types.
     * @return List of supported types in the form of a comma-separated {@link String}.
     */
    public static String toStringAll() {
        LOGGER.trace("The method valuesToString() was invoked.");
        String list = new String();
        for (FiletypeEnum type: FiletypeEnum.values()) {
                list += ", " + type.toString().toLowerCase();
        }
        
        String result = list.substring(2);
        
        LOGGER.trace("toStringAll() returned => " + result);
        return result;
    }
}
