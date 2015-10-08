/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.database;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * TODO: The class contains the stubs of methods.
 * @author Косых Евгений
 */
public class SQLScript {
    
    private static final Logger log = LogManager.getLogger(SQLScript.class);
    
    
    /**
     * 
     * @param f The file with properties
     * @throws IOException
     * @throws SQLException 
     */
    public SQLScript(File f) throws IOException, SQLException {
        
    }
    
    @Override
    public String toString() {
        log.trace("Invoking toString() method.");
        
        String result = super.toString();
        
        log.trace("toString() returned => " + result);
        return result;
    }
}
