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
     * @param scriptFile The file with properties
     * @throws IOException
     * @throws SQLException 
     */
    public SQLScript(final File scriptFile) throws IOException, SQLException {
        log.trace("It was created an object of SQLScript class\n"
                + "\tFile scriptFile <= " + scriptFile.getAbsolutePath());
        
        StringBuilder fileData = new StringBuilder();
	
        try ( // Чтение файла.
                BufferedReader reader = new BufferedReader(new FileReader(scriptFile))) {
            char[] buf = new char[1024];
            int numRead;
            while((numRead = reader.read(buf)) != -1){
                String readData = String.valueOf(buf, 0, numRead);
                fileData.append(readData);
            }
        }
        
        this.setScript(fileData);
    }
    
    
    private void setScript(final StringBuilder script) throws SQLException {
        log.trace("It was invoket setScript() method.\n"
                + "\tStringBuilder script <= " + (script.length() <= 50 ? script.toString() : script.substring(0, 50)));
        
    }
    
    
    @Override
    public String toString() {
        log.trace("It was invoked toString() method.");
        
        String result = super.toString();
        
        log.trace("toString() returned => " + result);
        return result;
    }
}
