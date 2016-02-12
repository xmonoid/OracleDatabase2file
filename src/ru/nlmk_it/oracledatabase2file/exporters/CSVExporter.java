/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.exporters;

import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.nio.file.Path;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.text.DateFormat;
import java.util.Set;
import org.apache.log4j.Logger;

/**
 *
 * @author Косых Евгений
 */
final class CSVExporter extends Exporter {
    
    private static final Logger LOGGER = Logger.getLogger(CSVExporter.class);
    
    private final String cellSeparator;
    
    private final String rowSeparator;
    
    private final String charsetEncoding;
    
    private final DateFormat dateFormat;
    
    private final int bufferSize;
    
    private int numberOfColumns;
	
    private long numberOfRows;
    
    protected CSVExporter(String exportFilename,
            Path exportPath,
            String extension,
            DateFormat exportDateFormat,
            String charsetEncoding,
            String cellSeparator,
            String rowSeparator,
            int bufferSize) {
        super(exportFilename, exportPath, extension, exportDateFormat);
        
        this.charsetEncoding= charsetEncoding;
        this.dateFormat = exportDateFormat;
        this.cellSeparator = cellSeparator;
        this.rowSeparator = rowSeparator;
        this.bufferSize = bufferSize;
        
        LOGGER.trace("The object of CSVExporter class was created.");
    }

    @Override
    public void export(ResultSet resultSet) throws IOException, SQLException {
        LOGGER.trace("The method export() was invoked\n"
                + "\tResultSet resultSet <= " + resultSet);
        Writer writer = new BufferedWriter(
                new OutputStreamWriter(
                        new FileOutputStream(
                                createNewExportFile()
                        ),
                        charsetEncoding
                ));

        try {
            setFields(writer, resultSet);
            long count = putRows(writer, resultSet);
            LOGGER.info(count + " rows were added into the file " + actualExportFilename);
        }
        finally {
            writer.flush();
            writer.close();
        }
    }
    
    /**
     * 
     * @param writer
     * @param resultSet
     * @throws IOException
     * @throws SQLException 
     */
    private void setFields(Writer writer, ResultSet resultSet) throws IOException, SQLException {
	LOGGER.trace("The method setFields() was invoked:\n"
                + "\tWriter writer <= " + writer + "\n"
                + "\tResultSet resultSet <= " + resultSet);
        
        ResultSetMetaData resultSetMetaData = resultSet.getMetaData();
        numberOfColumns = resultSetMetaData.getColumnCount();
        numberOfRows = 0;
        
        for (int i = 0; i < numberOfColumns; i++) {
            
            String columnLabel = resultSetMetaData.getColumnLabel(i + 1);
            
            LOGGER.debug("Field name = " + columnLabel);
            
            writer.append(columnLabel + cellSeparator);
        }
        writer.append(rowSeparator);
        numberOfRows++;
    }
	
	
    private long putRows(Writer writer, ResultSet resultSet) throws IOException, SQLException {
        LOGGER.trace("The method setFields() was invoked:\n"
                + "\tWriter writer <= " + writer + "\n"
                + "\tResultSet resultSet <= " + resultSet);
        
        while (resultSet.next()) {

            for (int i = 0; i < numberOfColumns; i++) {
                Object obj = resultSet.getObject(i + 1);
                String cell = null;

                if (obj == null) {
                    cell = "";
                }
                else if (obj instanceof String) {
                    String s = (String) obj;
                    if (s.contains("\t")) {
                        s = "\"" + s + "\""; // Спецсимволы обрамляем кавычками.
                    }
                    cell = s;
                }
                else if (obj instanceof java.sql.Date) {
                    cell = dateFormat.format(
                            new java.util.Date(
                                    ((java.sql.Date) obj).getTime()
                            )
                    );
                }
                else if (obj instanceof java.sql.Timestamp) {
                    cell = dateFormat.format(
                            new java.util.Date(
                                    ((java.sql.Timestamp) obj).getTime()
                            )
                    );
                }
                else if (obj instanceof BigDecimal) {
                    cell = ((BigDecimal) obj).toPlainString();
                }
                else if (obj instanceof BigInteger) {
                    cell = ((BigInteger) obj).toString();
                }
                else {
                    throw new RuntimeException("Unknown type: " + obj.getClass().getName());
                }

                writer.append(cell);

                if (i != numberOfColumns - 1) {
                    writer.append(cellSeparator);
                }
            }
            writer.append(rowSeparator);
            numberOfRows++;
            if (numberOfRows % bufferSize == 0) {
                
                LOGGER.info(numberOfRows + " rows were added into the file " + actualExportFilename);
                writer.flush();
            }
        }
        
        LOGGER.trace("putRows() returned => " + numberOfRows);
        return numberOfRows;
    }
    
    @Override
    public void export(Set<ResultSet> resultSets) throws IOException, SQLException {
        LOGGER.trace("The method export() was invoked\n"
                + "\tSet<ResultSet> resultSets <= " + resultSets);
        export(resultSets.toArray(new ResultSet[0])[0]);
    }
}
