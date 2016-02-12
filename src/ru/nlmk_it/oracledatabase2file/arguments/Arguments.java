/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.arguments;

import ru.nlmk_it.oracledatabase2file.exporters.FiletypeEnum;
import com.beust.jcommander.DynamicParameter;
import com.beust.jcommander.Parameter;
import com.beust.jcommander.ParameterException;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import org.apache.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.database.SQLScript;

/**
 * This class contains a set of the command line parameters.
 * 
 * {@link http://jcommander.org/}
 * @author Косых Евгений
 */
public final class Arguments {
    
    private static final Logger LOGGER = Logger.getLogger(Arguments.class);
    
    @Parameter(names = {"-help", "-h"},
            description = "Print this help and exit",
            help=true)
    private boolean help;
    
    @Parameter(names = {"-export.filetype"},
            description = "The format of the export file",
            required = true,
            converter = FiletypeEnumConverter.class)
    private FiletypeEnum filetype;
    
    @Parameter(names = {"-script"},
            description = "The file that contains the SQL queries",
            required = true,
            converter = SQLScriptConverter.class)
    private SQLScript sqlScript;
    
    @Parameter(names = {"-export.directory"},
            description = "The path to the directory where will be the export file",
            required = false,
            converter = DirectoryConverter.class)
    private Path exportDir;
    
    @Parameter(names = {"-url"},
            description = "Database URL",
            required = false)
    private String url;
    
    @Parameter(names = {"-login"},
            description = "User login for database connection",
            required = false)
    private String login;
    
    @Parameter(names = {"-password"},
            description = "User password for database connection",
            password = true,
            echoInput = true,
            required = false)
    private String passrowd;
    
    @Parameter(names = {"-sql.variableMarker"},
            description = "Variable marker for SQL expression",
            required = false)
    private String sqlVariableMarker;
    
    @Parameter(names = {"-sql.dateFormat"},
            description = "The format of date type for SQL",
            required = false,
            converter = DateFormatConverter.class)
    private DateFormat sqlDateFormat;
    
    @DynamicParameter(names = "-P",
            description = "Parameters of the SQL expression",
            required = false)
    private Map<String, String> sqlParams = new HashMap<>();
    
    @Parameter(names = {"-export.filename"},
            description = "The name of the export file(s)",
            required = false)
    private String exportFilename;
    
    private static final int DEFAULT_ROWS_BEFORE_FLUSH = 1000;
    
    @Parameter(names = {"-xlsx.rowsBeforeFlush"},
            description = "The number of saved rows before flushing (XLSX)",
            required = false)
    private int xlsxRowsBeforeFlush = DEFAULT_ROWS_BEFORE_FLUSH;
    
    @Parameter(names = {"-export.dateFormat"},
            description = "The format of date type in the export file",
            required = false,
            converter = DateFormatConverter.class)
    private DateFormat exportDateFormat;
    
    @Parameter(names = {"-dbf.charsetEncoding"},
            description = "String encoding code (DBF)",
            required = false)
    private String dbfCharsetEncoding;
    
    @Parameter(names = {"-csv.charsetEncoding"},
            description = "String encoding code (CSV)",
            required = false)
    private String csvCharsetEncoding;
    
    @Parameter(names = {"-csv.rowSeparator"},
            description = "The separator of rows (CSV)",
            required = false)
    private String csvRowSeparator;
    
    @Parameter(names = {"-csv.cellSeparator"},
            description = "The separator of cells (CSV)",
            required = false)
    private String csvCellSeparator;
    
    @Parameter(names = {"-csv.rowsBeforeFlush"},
            description = "The number of saved rows before flushing (CSV)",
            required = false)
    private int csvRowsBeforeFlush;
    
    /**
     * Creates new {@code Arguments} instance with empty parameters.
     */
    public Arguments() {
        LOGGER.trace("The object of class Arguments was created with empty parameters");
    }
    
    /**
     * Creates new {@code Arguments} instance with parameters which was loaded
     * from property file.
     * 
     * @param propertyFile the file with some parameters of this program.
     * @throws IOException if an I/O error occurs
     */
    public void setParametersFromConfigFile (File propertyFile) throws IOException {
        LOGGER.trace("The method setParametersFromConfigFile() was invoked\n"
                + "\tFile propertyFile <= " + propertyFile.getAbsolutePath());
        
        Properties properties = new Properties();
        try (InputStream in = new FileInputStream(propertyFile.getAbsolutePath())) {
            properties.load(in);
            
            String property = properties.getProperty("url");
            if (property != null && this.url == null) {
                this.url = property;
            }
            
            property = properties.getProperty("login");
            if (property != null && this.login == null) {
                this.login = property;
            }
            
            property = properties.getProperty("password");
            if (property != null && this.passrowd == null) {
                this.passrowd = property;
            }
            
            property = properties.getProperty("sql.variableMarker");
            if (property != null && this.sqlVariableMarker == null) {
                this.sqlVariableMarker = property;
            }
            
            property = properties.getProperty("sql.dateFormat");
            if (property != null && this.sqlDateFormat == null) {
                this.sqlDateFormat = new SimpleDateFormat(property);
            }
            
            property = properties.getProperty("export.directory");
            if (property != null && this.exportDir == null) {
                this.exportDir = new DirectoryConverter().convert(property);
            }
            
            property = properties.getProperty("xlsx.rowsBeforeFlush");
            if (property != null
                    && (this.xlsxRowsBeforeFlush <= 0
                    || Integer.parseInt(property) != DEFAULT_ROWS_BEFORE_FLUSH)) {
                this.xlsxRowsBeforeFlush = Integer.parseInt(property);
            }
            
            property = properties.getProperty("export.dateFormat");
            if (property != null && this.exportDateFormat == null) {
                this.exportDateFormat = new SimpleDateFormat(property);
            }
            
            property = properties.getProperty("dbf.charsetEncoding");
            if (property != null && dbfCharsetEncoding == null) {
                this.dbfCharsetEncoding = property;
            }
            
            property = properties.getProperty("csv.charsetEncoding");
            if (property != null && getCsvCharsetEncoding() == null) {
                this.csvCharsetEncoding = property;
            }
            
            property = properties.getProperty("csv.rowSeparator");
            if (property != null && getCsvRowSeparator() == null) {
                this.csvRowSeparator = property;
            }
            
            property = properties.getProperty("csv.cellSeparator");
            if (property != null && getCsvCellSeparator() == null) {
                this.csvCellSeparator = property;
            }
            
            property = properties.getProperty("csv.rowsBeforeFlush");
            if (property != null
                    && (this.getCsvRowsBeforeFlush() <= 0
                    || Integer.parseInt(property) != DEFAULT_ROWS_BEFORE_FLUSH)) {
                this.csvRowsBeforeFlush = Integer.parseInt(property);
            }
        }
    }
    
    /**
     * 
     * @return {@code true} if the <b><i>help</i></b> option was selected,
     * {@code false} otherwise.
     */
    public boolean isHelp() {
        LOGGER.trace("The method isHelp() was invoked.");
        LOGGER.trace("isHelp() was returned => " + help);
        return help;
    }
    
    /**
     * 
     * @return 
     */
    public FiletypeEnum getFiletype() {
        LOGGER.trace("The method getFiletype() was invoked.");
        LOGGER.trace("getFiletype() was returned => " + filetype.toString().toUpperCase());
        return filetype;
    }
    
    /**
     * 
     * @param filetype 
     */
    public void setFiletype(FiletypeEnum filetype) {
        LOGGER.trace("The method setFiletype() was invoked:\n"
                + "\tFiletypeEnum filetype <= " + filetype);
        this.filetype = filetype;
    }
    
    /**
     * 
     * @return 
     */
    public SQLScript getSQLScript() {
        LOGGER.trace("The method getSQLScript() was invoked.");
        LOGGER.trace("getSQLScript() was returned => " + sqlScript);
        return sqlScript;
    }
    
    /**
     * 
     * @param script 
     */
    public void setSQLScript(SQLScript script) {
        LOGGER.trace("The method setSQLScript() was invoked:\n"
                + "\tSQLScript script <= " + script);
        this.sqlScript = script;
    }
    
    /**
     * 
     * @return 
     */
    public Path getExportDir() {
        LOGGER.trace("The method getExportDir() was invoked.");
        LOGGER.trace("getExportDir() was returned => " + exportDir.toString());
        return exportDir;
    }
    
    /**
     * 
     * @param exportDir 
     */
    public void setExportDir(Path exportDir) {
        LOGGER.trace("The method setExportDir() was invoked:\n"
                + "\tPath exportDir <= " + exportDir);
        this.exportDir = exportDir;
    }
    
    /**
     * 
     * @return 
     */
    public String getURL() {
        LOGGER.trace("The method getURL() was invoked.");
        LOGGER.trace("getURL() was returned => " + url);
        return url;
    }
    
    /**
     * 
     * @return 
     */
    public String getLogin() {
        LOGGER.trace("The method getLogin() was invoked.");
        LOGGER.trace("getLogin() was returned => " + login);
        return login;
    }
    
    /**
     * 
     * @return 
     */
    public String getPassword() {
        LOGGER.trace("The method getPassword() was invoked.");
        LOGGER.trace("getPassword() was returned => " + passrowd.replaceAll(".", "*"));
        return passrowd;
    }
    
    /**
     * 
     * @return 
     */
    public String getSqlVariableMarker() {
        LOGGER.trace("The method getSqlVariableMarker() was invoked.");
        LOGGER.trace("getSqlVariableMarker() was returned => " + sqlVariableMarker);
        return sqlVariableMarker;
    }
    
    /**
     * 
     * @return 
     */
    public DateFormat getSqlDateFormat() {
        LOGGER.trace("The method getSqlDateFormat() was invoked.");
        LOGGER.trace("getSqlDateFormat() was returned => " + sqlDateFormat);
        return sqlDateFormat;
    }
    /**
     * 
     * @return 
     */
    public Map<String, String> getSqlParams() {
        LOGGER.trace("The method getSqlParams() was invoked.");
        
        if (sqlParams == null) {
            sqlParams = new HashMap<>();
        }
        
        LOGGER.trace("getSqlParams() was returned => " + sqlParams);
        return sqlParams;
    }
    
    /**
     * 
     * @return 
     */
    public String getExportFilename() {
        LOGGER.trace("The method getExportFilename() was invoked.");
        LOGGER.trace("getExportFilename() was returned => " + exportFilename);
        return exportFilename;
    }
    
    /**
     * 
     * @return 
     */
    public int getXlsxRowsBeforeFlush() {
        LOGGER.trace("The method getXlsxRowsInTheBatch() was invoked.");
        LOGGER.trace("getXlsxRowsInTheBatch() was returned => " + xlsxRowsBeforeFlush);
        return xlsxRowsBeforeFlush;
    }
    
    /**
     * 
     * @return 
     */
    public DateFormat getExportDateFormat() {
        LOGGER.trace("The method getExportDateFormat() was invoked.");
        LOGGER.trace("getExportDateFormat() was returned => " + exportDateFormat);
        return exportDateFormat;
    }
    
    /**
     * 
     * @return 
     */
    public String getDbfCharsetEncoding() {
        LOGGER.trace("The method getDbfCharsetEncoding() was invoked.");
        LOGGER.trace("getDbfCharsetEncoding() was returned => " + dbfCharsetEncoding);
        return dbfCharsetEncoding;
    }
    
    
    /**
     * @return the csvCharsetEncoding
     */
    public String getCsvCharsetEncoding() {
        LOGGER.trace("The method getCsvCharsetEncoding() was invoked.");
        LOGGER.trace("getCsvCharsetEncoding() was returned => " + csvCharsetEncoding);
        return csvCharsetEncoding;
    }

    /**
     * @return the csvRowSeparator
     */
    public String getCsvRowSeparator() {
        LOGGER.trace("The method getCsvRowSeparator() was invoked.");
        LOGGER.trace("getCsvRowSeparator() was returned => " + csvRowSeparator);
        return csvRowSeparator;
    }

    /**
     * @return the csvCellSeparator
     */
    public String getCsvCellSeparator() {
        LOGGER.trace("The method getCsvCellSeparator() was invoked.");
        LOGGER.trace("getCsvCellSeparator() was returned => " + csvCellSeparator);
        return csvCellSeparator;
    }

    /**
     * @return the csvRowsBeforeFlush
     */
    public int getCsvRowsBeforeFlush() {
        LOGGER.trace("The method getCsvRowsBeforeFlush() was invoked.");
        LOGGER.trace("getCsvRowsBeforeFlush() was returned => " + csvRowsBeforeFlush);
        return csvRowsBeforeFlush;
    }
    
    /**
     * 
     * @return 
     */
    private String defaultExportFilename() {
        LOGGER.trace("The method setDefaultExportFilename() was invoked.");
        
        StringBuilder defaultFilename = new StringBuilder(sqlScript.toString());
        
        if (sqlParams != null) {
            for (Map.Entry<String, String> entry: sqlParams.entrySet()) {
                defaultFilename.append("_")
                        .append(entry.getKey())
                        .append("=")
                        .append(entry.getValue());
            }
        }
        
        defaultFilename.append("_").append(
                new SimpleDateFormat("dd.MM.yyyy_HH.mm.ss").format(
                        new java.util.Date()));
        
        String result = defaultFilename.toString();
        
        LOGGER.trace("defaultExportFilename() was returned => " + result);
        return result;
    }
    
    /**
     * Validates a set of parameters.
     * @throws ParameterException if any parameter is invalid.
     */
    public void validate() throws ParameterException {
        LOGGER.trace("The method validate() was invoked.");
        
        if (exportDir == null) {
            throw new ParameterException("The following option is required:"
                    + " { -export.directory } <directory>");
        }
        if (filetype == null) {
            throw new ParameterException("The following option is required:"
                    + " { -export.filetype } <type>");
        }
        if (sqlScript == null) {
            throw new ParameterException("The following option is required:"
                    + " { -script }");
        }
        if (url == null) {
            throw new ParameterException("The following option is required:"
                    + " { -url }");
        }
        if (login == null) {
            throw new ParameterException("The following option is required:"
                    + " { -login }");
        }
        if (passrowd == null) {
            throw new ParameterException("The following option is required:"
                    + " { -password }");
        }
        if (exportFilename == null) {
            exportFilename = defaultExportFilename();
        }
        if (xlsxRowsBeforeFlush <= 0) {
            throw new ParameterException("Incorrect value for parameter"
                    + " xlsx.rowsBeforeFlush: " + xlsxRowsBeforeFlush);
        }
        if (exportDateFormat == null) {
            throw new ParameterException("The following option is required:"
                    + " { export.dateFormat } <format>");
        }
    }
    
    @Override
    public String toString() {
        LOGGER.trace("The method toString() was invoked.");
        
        StringBuilder stringBuilder = new StringBuilder("[");
        
        if (exportDir != null) {
            stringBuilder.append("export.directory = ").append(exportDir).append("; ");
        }
        if (filetype != null) {
            stringBuilder.append("export.filetype = ").append(filetype).append("; ");
        }
        if (sqlScript != null) {
            stringBuilder.append("sqript = ").append(sqlScript).append("; ");
        }
        if (url != null) {
            stringBuilder.append("url = ").append(url).append("; ");
        }
        if (login != null) {
            stringBuilder.append("login = ").append(login).append("; ");
        }
        if (passrowd != null) {
            stringBuilder.append("password = ").append(passrowd.replaceAll(".", "*")).append("; ");
        }
        
        int length = stringBuilder.length();
        if (stringBuilder.lastIndexOf("; ") > 0 &&
                stringBuilder.lastIndexOf("; ") == length - "; ".length()) {
            stringBuilder.delete(length - 1, length);
        }
        
        String result = stringBuilder.append("]").toString();
        
        LOGGER.trace("toString() was returned => " + result);
        return result;
    }
}
