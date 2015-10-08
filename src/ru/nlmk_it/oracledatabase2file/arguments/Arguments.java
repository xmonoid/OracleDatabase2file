/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.arguments;

import com.beust.jcommander.Parameter;
import java.nio.file.Path;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.database.SQLScript;

/**
 * This class contains a set of the command line parameters.
 * 
 * {@link http://jcommander.org/}
 * @author Косых Евгений
 */
public final class Arguments {
    
    private static final Logger log = LogManager.getLogger(Arguments.class);
    
    @Parameter(names = {"-help", "-h"},
            description = "Print this help and exit",
            help=true)
    private boolean help;
    
    @Parameter(names = {"-filetype", "-type", "-t"},
            description = "The format of the export file",
            required = true,
            converter = FiletypeEnumConverter.class)
    private FiletypeEnum filetype;
    
    @Parameter(names = {"-script", "-s"},
            description = "The file that contains the SQL queries",
            required = true,
            converter = SQLScriptConverter.class)
    private SQLScript sqlScript;
    
    @Parameter(names = {"-exportdir", "-dir", "-d"},
            description = "The path to the directory where will be the export file",
            required = true,
            converter = DirectoryConverter.class)
    private Path exportDir;
    
    /**
     * 
     * @return {@code true} if the <b><i>help</i></b> option was selected,
     * {@code false} otherwise.
     */
    public boolean isHelp() {
        log.trace("Invoking isHelp() method.");
        log.trace("isHelp() was returned => " + help);
        return help;
    }
    
    /**
     * 
     * @return 
     */
    public FiletypeEnum getFiletype() {
        log.trace("Invoking getFiletype() method.");
        log.trace("getFiletype() was returned => " + filetype.toString().toUpperCase());
        return filetype;
    }
    
    /**
     * 
     * @return 
     */
    public SQLScript getSQLScript() {
        log.trace("Invoking getSQLScript() method.");
        log.trace("getSQLScript() was returned => " + sqlScript);
        return sqlScript;
    }
    
    /**
     * 
     * @return 
     */
    public Path getExportDir() {
        log.trace("Invoking getExportDir() method.");
        log.trace("getExportDir() was returned => " + exportDir.toString());
        return exportDir;
    }
}
