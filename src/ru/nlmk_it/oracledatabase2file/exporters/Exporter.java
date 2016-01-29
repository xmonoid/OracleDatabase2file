package ru.nlmk_it.oracledatabase2file.exporters;

import java.io.IOException;
import java.nio.file.Path;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Set;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.arguments.Arguments;
import static ru.nlmk_it.oracledatabase2file.logutils.LogUtils.substring;

/**
 *
 * @author Косых Евгений
 */
public abstract class Exporter {
    
    private static final Logger LOGGER = LogManager.getLogger(Exporter.class);
    
    protected final String exportFilenameTemplate;
    
    protected String actualExportFilename;
    
    protected final Path exportPath;
    
    /**
     * 
     * @param exportFilename 
     * @param exportPath 
     */
    protected Exporter(String exportFilename, Path exportPath) {
        LOGGER.trace("The object of Exporter class was created:\n"
                + "\tFile exportFile <= " + substring(exportFilename));
        this.actualExportFilename = 
                this.exportFilenameTemplate = exportFilename;
        this.exportPath = exportPath;
    }
    
    /**
     * 
     * @param arguments
     * @return 
     */
    public static Exporter getExporter(Arguments arguments) {
        LOGGER.trace("The method getExporter() was invoked:\n"
                + "\tArguments arguments <= " + arguments);
        
        FiletypeEnum filetype = arguments.getFiletype();
        
        Exporter result;
        switch (filetype) {
            case XLSX:
                result = new XLSXExporter(arguments.getExportFilename(),
                        arguments.getExportDir(), 
                        arguments.getXlsxRowsInTheBatch());
                break;
            case DBF:
                result = new DBFExporter(arguments.getExportFilename(),
                        arguments.getExportDir());
                break;
            case CSV:
                result = new CSVExporter(arguments.getExportFilename(),
                        arguments.getExportDir());
                break;
            default:
                throw new RuntimeException("Unsupported filetype");
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
        LOGGER.trace("The method toString() was invoked.");
        
        String result = getClass().getName() + "[" + exportFilenameTemplate + "]";
        
        LOGGER.trace("toString() returned => " + result);
        return result;
    }
}
