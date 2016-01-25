/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.exporters;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Set;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.arguments.Arguments;

/**
 *
 * @author Косых Евгений
 */
public abstract class Exporter {
    
    private static final Logger LOGGER = LogManager.getLogger(Exporter.class);
    
    protected final String exportFilename;
    
    /**
     * 
     * @param exportFilename 
     */
    protected Exporter(String exportFilename) {
        LOGGER.trace("The object of Exporter class was created,\n"
                + "\tFile exportFile <= " + exportFilename);
        this.exportFilename = exportFilename;
    }
    
    /**
     * 
     * @param arguments
     * @return 
     */
    public static Exporter getExporter(Arguments arguments) {
        LOGGER.trace("The method getExporter() was invoked,\n"
                + "\tArguments arguments <= " + arguments);
        
        FiletypeEnum filetype = arguments.getFiletype();
        
        Exporter result;
        switch (filetype) {
            case XLSX:
                result = new XLSXExporter(arguments.getExportFilename());
                break;
            case DBF:
                result = new DBFExporter(arguments.getExportFilename());
                break;
            case CSV:
                result = new CSVExporter(arguments.getExportFilename());
                break;
            default:
                throw new RuntimeException("Shit happens...");
        }
        
        LOGGER.trace("getExporter() returned => " + result);
        return result;
    }
    
    /**
     * Export one result set.
     * @param resultSet
     * @throws IOException 
     * @throws SQLException
     */
    public abstract void export(ResultSet resultSet) throws IOException, SQLException;
    
    /**
     * Export several result sets with appropriates meta data.
     * @param resultSets
     * @throws IOException
     * @throws SQLException
     */
    public abstract void export(Set<ResultSet> resultSets) throws IOException, SQLException;
    
    @Override
    public String toString() {
        LOGGER.trace("The method getExporter() was invoked.");
        
        String result = getClass().getName() + "[" + exportFilename + "]";
        
        LOGGER.trace("getExporter() returned => " + result);
        return result;
    }
}
