/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.exporters;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.nio.file.Path;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;

/**
 *
 * @author Косых Евгений
 */
final class XLSXExporter extends Exporter {
    
    private static final Logger LOGGER = LogManager.getLogger(XLSXExporter.class);
    
    /**
     * The workbook - the main class defining an export file.
     */
    private SXSSFWorkbook workbook;
    
    /**
     * The style for correct displaying dates.
     */
    private CellStyle dateCellStyle;
    
    /**
     * The counter of rows in the sheet.
     */
    private int currentRowInTheSheet = 0;
    
    /**
     * The counter of rows in the file.
     */
    private BigInteger allRowsInTheFile = BigInteger.ZERO;
    
    /**
     * The number of columns in the sheet.
     */
    private int numberOfColumns;
    
    /**
     * The number of saved rows in the batch.
     */
    private final int xlsxRowsInTheBatch;
    
    /**
     * The maximal number of rows in XLSX format.
     */
    private static final int MAX_NUMBER_OF_ROWS = 0xFFFFF;
    
    /**
     * 
     * @param exportFilename 
     */
    protected XLSXExporter(String exportFilename,
            Path exportPath,
            String extension,
            DateFormat dateFormat,
            int xlsxRowsInTheBatch) {
        super(exportFilename, exportPath, extension, dateFormat);
        this.xlsxRowsInTheBatch = xlsxRowsInTheBatch;
        LOGGER.trace("The object of XLSXExporter class was created.");
    }

    /**
     * Setting fields in export file.
     * @param resultSet Instance of {@link ResultSet} with results of SQL query.
     * @return New sheet with column headers.
     * @throws SQLException
     */
    private Sheet setFields(ResultSet resultSet) throws SQLException {
        LOGGER.trace("The method setFields() was invoked:\n"
                + "\tResultSet resultSet <= " + resultSet);

        Sheet sheet = workbook.createSheet();
        Row row = sheet.createRow(currentRowInTheSheet++);
        ResultSetMetaData rsMetaData = resultSet.getMetaData();
        numberOfColumns = rsMetaData.getColumnCount();

        Map<String, String> fields = new HashMap<>();
        for (int cellnum = 0; cellnum < numberOfColumns; cellnum++) {
            
            String field = rsMetaData.getColumnLabel(cellnum + 1);
            
            String type = rsMetaData.getColumnTypeName(cellnum + 1);
            fields.put(field, type);
            
            Cell cell = row.createCell(cellnum);
            cell.setCellValue(field);
        }
        
        LOGGER.debug("The list of fileds = " + fields);
        return sheet;
    }
	

    
    /**
     * 
     * @param resultSet
     * @param sheet
     * @param buffer
     * @throws SQLException
     */
    private int putRows(ResultSet resultSet,
            Sheet sheet,
            int startRowNumber) throws SQLException {
        LOGGER.trace("The method putRows() was invoked:\n"
                + "\tResultSet resultSet <= " + resultSet + "\n"
                + "\tSheet sheet <= " + sheet);
        
        int index = 0;
        while (resultSet.next()) {
            
            if (startRowNumber > MAX_NUMBER_OF_ROWS) {
                LOGGER.debug("The maximum number of rows in the sheet was reached.");
                break;
            }
            
            Row row = sheet.createRow(startRowNumber++);
            
            for(int cellnum = 0; cellnum < numberOfColumns; cellnum++) {
                putCell(row.createCell(cellnum), resultSet.getObject(cellnum + 1));
            }
            
            index++;
            
            if (index % xlsxRowsInTheBatch == 0) {
                LOGGER.info(index + " rows added.");
            }
        }
        
        LOGGER.debug(index + " rows with data added into the file '"
                + actualExportFilename + "'");
        LOGGER.trace("putRows() returned => " + startRowNumber);
        return startRowNumber;
    }
    
    /**
    * 
    * @param cell
    * @param value
    */
    private void putCell(Cell cell, Object value) {
        
        LOGGER.trace("The method putCell() was invoked:\n"
                + "\tCell cell = " + cell + "\n"
                + "\tObject value = " + value);
        
        if (value instanceof BigDecimal) {
            BigDecimal bd = (BigDecimal) value;
            cell.setCellValue(bd.doubleValue());
        }
        else if (value instanceof String) {
            String s = ((String) value);
            cell.setCellValue(s);
        }
        else if (value instanceof Date) {

            Date d = (Timestamp) value;

            cell.setCellValue(d);
            cell.setCellStyle(dateCellStyle);
        }
    }
        
    @Override
    public void export(ResultSet resultSet) throws IOException, SQLException {
        LOGGER.trace("The method export() was invoked:\n"
                + "\tResultSet resultSet <= " + resultSet);
        
        Set<ResultSet> resultSets = new HashSet<>();
        resultSets.add(resultSet);
        export(resultSets);
    }

    @Override
    public void export(Set<ResultSet> resultSets) throws IOException, SQLException {
        LOGGER.trace("The method export() was invoked:\n"
                + "\tSet<ResultSet> resultSets <= " + resultSets);
        
        try (OutputStream out = new FileOutputStream(createNewExportFile())) {
            
            workbook = new SXSSFWorkbook(xlsxRowsInTheBatch);
            workbook.setCompressTempFiles(true);
            dateCellStyle = workbook.createCellStyle();
            dateCellStyle.setDataFormat(
                    workbook.createDataFormat().getFormat(
                            ((SimpleDateFormat) exportDateFormat).toPattern()));
            for (ResultSet resultSet: resultSets) {
                
                // If the number of rows is more than 2^20-1,
                // the new sheet will be created.
                do {
                    currentRowInTheSheet = 0;
                    
                    Sheet sheet = setFields(resultSet);
                    
                    LOGGER.debug("New sheet was created: " + sheet.getSheetName());
                    
                    currentRowInTheSheet = putRows(resultSet, sheet, currentRowInTheSheet);
                    
                    LOGGER.info(currentRowInTheSheet
                            + " rows were added into the sheet " + sheet.getSheetName());
                    allRowsInTheFile = allRowsInTheFile.add(
                            BigInteger.valueOf(currentRowInTheSheet));
                }
                while (!resultSet.isAfterLast());

            }
            
            LOGGER.info(allRowsInTheFile.toString()
                    + " rows in total were added into the file '"
                    + actualExportFilename + "'");
            LOGGER.info("Starting the compressing...");
            workbook.write(out);
            LOGGER.info("Done.");
        }
        finally {
            if (workbook != null) {
                LOGGER.info("Temp file deleted: " + workbook.dispose() + ".");
            }
        }
    }
}
