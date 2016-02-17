package ru.nlmk_it.oracledatabase2file.exporters;

import java.io.File;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DateFormat;
import java.util.Set;
import org.apache.log4j.Logger;
import ru.nlmk_it.oracledatabase2file.arguments.Arguments;
import static ru.nlmk_it.oracledatabase2file.logutils.LogUtils.substring;

/**
 *
 * @author Косых Евгений
 */
public abstract class Exporter {
    
    private static final Logger LOGGER = Logger.getLogger(Exporter.class);
    
    protected final String exportFilenameTemplate;
    
    protected String actualExportFilename;
    
    protected final File exportPath;
    
    protected final String extension;
    
    protected final DateFormat exportDateFormat;
    
    /**
     * 
     * @param exportFilename 
     * @param exportPath 
     * @param extension 
     * @param exportDateFormat 
     */
    protected Exporter(String exportFilename,
            File exportPath,
            String extension,
            DateFormat exportDateFormat) {
        LOGGER.trace("The object of Exporter class was created:\n"
                + "\tFile exportFile <= " + substring(exportFilename));
        this.actualExportFilename = 
                this.exportFilenameTemplate = exportFilename;
        this.exportPath = exportPath;
        this.extension = extension;
        this.exportDateFormat = exportDateFormat;
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
                        filetype.toString().toLowerCase(),
                        arguments.getExportDateFormat(),
                        arguments.getXlsxRowsBeforeFlush()
                );
                break;
            case DBF:
                result = new DBFExporter(arguments.getExportFilename(),
                        arguments.getExportDir(),
                        filetype.toString().toLowerCase(),
                        arguments.getExportDateFormat(),
                        arguments.getDbfCharsetEncoding()
                );
                break;
            case CSV:
                result = new CSVExporter(arguments.getExportFilename(),
                        arguments.getExportDir(),
                        filetype.toString().toLowerCase(),
                        arguments.getExportDateFormat(),
                        arguments.getCsvCharsetEncoding(),
                        arguments.getCsvCellSeparator(),
                        arguments.getCsvRowSeparator(),
                        arguments.getCsvRowsBeforeFlush()
                );
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
    
    /**
     * 
     * @return
     * @throws IOException 
     */
    protected File createNewExportFile() throws IOException {
        LOGGER.trace("The method createNewExportFile() was invoked.");
        actualExportFilename = exportFilenameTemplate + "." + extension;
        
        File result = new File(exportPath.toString() + File.separator + actualExportFilename);
        
        LOGGER.trace("createNewExportFile() returned => " + result.getCanonicalPath());
        return result;
    }
}
