/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.arguments;

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
    
    private static final Logger log = LogManager.getLogger(FiletypeEnum.class);
	
    /**
     * Supported types.
     * @return List of supported types in the form of a comma-separated {@link String}.
     */
    public static String valuesToString() {
        log.trace("Invoke valuesToString()");
        String list = new String();
        for (FiletypeEnum type: FiletypeEnum.values()) {
                list += ", " + type.toString().toLowerCase();
        }
        return list.substring(2);
    }
}
