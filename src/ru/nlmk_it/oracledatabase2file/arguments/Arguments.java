/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.arguments;

import com.beust.jcommander.Parameter;
import com.beust.jcommander.ParameterException;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.util.Properties;
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
            required = false,
            converter = FiletypeEnumConverter.class)
    private FiletypeEnum filetype;
    
    @Parameter(names = {"-script", "-s"},
            description = "The file that contains the SQL queries",
            required = false,
            converter = SQLScriptConverter.class)
    private SQLScript sqlScript;
    
    @Parameter(names = {"-exportdir", "-dir", "-d"},
            description = "The path to the directory where will be the export file",
            required = false,
            converter = DirectoryConverter.class)
    private Path exportDir;
    
    @Parameter(names = {"-url", "-u"},
            description = "Database URL",
            required = false)
    private String url;
    
    @Parameter(names = {"-login", "-l"},
            description = "User login for database connection",
            required = false)
    private String login;
    
    @Parameter(names = {"-password", "-p"},
            description = "User password for database connection",
            password = true,
            required = false)
    private String passrowd;
    
    /**
     * Creates new {@code Arguments} instance with empty parameters.
     */
    public Arguments() {
        log.trace("It was created an object of Arguments with empty params");
    }
    
    /**
     * Creates new {@code Arguments} instance with parameters which was loaded
     * from property file.
     * 
     * @param propertyFile the file with some parameters of this program.
     * @throws IOException if an I/O error occurs
     */
    public Arguments(File propertyFile) throws IOException {
        log.trace("It was created an object of Arguments \n"
                + "\tFile propertyFile <= " + propertyFile.getAbsolutePath());
        
        Properties properties = new Properties();
        InputStream in = new FileInputStream(propertyFile.getAbsolutePath());
        properties.load(in);
        
        String property = properties.getProperty("url");
        if (property != null) {
            this.url = property;
        }
        
        property = properties.getProperty("login");
        if (property != null) {
            this.login = property;
        }
        
        property = properties.getProperty("password");
        if (property != null) {
            this.passrowd = property;
        }
    }
    
    /**
     * 
     * @return {@code true} if the <b><i>help</i></b> option was selected,
     * {@code false} otherwise.
     */
    public boolean isHelp() {
        log.trace("It was invoked isHelp() method.");
        log.trace("isHelp() was returned => " + help);
        return help;
    }
    
    /**
     * 
     * @return 
     */
    public FiletypeEnum getFiletype() {
        log.trace("It was invoked getFiletype() method.");
        log.trace("getFiletype() was returned => " + filetype.toString().toUpperCase());
        return filetype;
    }
    
    /**
     * 
     * @return 
     */
    public SQLScript getSQLScript() {
        log.trace("It was invoked getSQLScript() method.");
        log.trace("getSQLScript() was returned => " + sqlScript);
        return sqlScript;
    }
    
    /**
     * 
     * @return 
     */
    public Path getExportDir() {
        log.trace("It was invoked getExportDir() method.");
        log.trace("getExportDir() was returned => " + exportDir.toString());
        return exportDir;
    }
    
    /**
     * 
     * @return 
     */
    public String getURL() {
        log.trace("It was invoked getURL() method.");
        log.trace("getURL() was returned => " + url);
        return url;
    }
    
    /**
     * 
     * @return 
     */
    public String getLogin() {
        log.trace("It was invoked getLogin() method.");
        log.trace("getLogin() was returned => " + login);
        return login;
    }
    
    /**
     * 
     * @return 
     */
    public String getPassword() {
        log.trace("It was invoked getPassword() method.");
        log.trace("getPassword() was returned => " + passrowd);
        return passrowd;
    }
    
    /**
     * Validates a set of parameters.
     * @throws ParameterException if any parameter is invalid.
     */
    public void validate() throws ParameterException {
        log.trace("It was invoked validate() method.");
        
        if (exportDir == null) {
            throw new ParameterException("The following option is required: { -exportdir | -dir | -d } <directory>");
        }
        if (filetype == null) {
            throw new ParameterException("The following option is required: { -filetype | -type | -t } <type>");
        }
        if (sqlScript == null) {
            throw new ParameterException("The following option is required: { -script | -s }");
        }
        if (url == null) {
            throw new ParameterException("The following option is required: { -url | -u }");
        }
        if (login == null) {
            throw new ParameterException("The following option is required: { -login | -l }");
        }
        if (passrowd == null) {
            throw new ParameterException("The following option is required: { -password | -p }");
        }
    }
    
    @Override
    public String toString() {
        StringBuilder result = new StringBuilder("[");
        
        if (exportDir != null) {
            result.append("exportDir = ").append(exportDir).append(",");
        }
        if (filetype != null) {
            result.append("filetype = ").append(filetype).append("; ");
        }
        if (sqlScript != null) {
            result.append("sqlSqript = ").append(sqlScript).append("; ");
        }
        if (url != null) {
            result.append("url = ").append(url).append("; ");
        }
        if (login != null) {
            result.append("login = ").append(login).append("; ");
        }
        if (passrowd != null) {
            result.append("password = ").append(passrowd.replaceAll(".", "*")).append("; ");
        }
        
        int length = result.length();
        if (result.lastIndexOf("; ") == length - "; ".length()) {
            result.delete(length - 1, length);
        }
        return result.append("]").toString();
    }
}
