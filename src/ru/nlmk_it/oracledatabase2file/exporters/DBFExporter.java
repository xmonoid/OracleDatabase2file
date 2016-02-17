/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.exporters;

import com.linuxense.javadbf.DBFException;
import com.linuxense.javadbf.DBFField;
import com.linuxense.javadbf.DBFWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.nio.file.Path;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.apache.log4j.Logger;

/**
 *
 * @author Косых Евгений
 */
final class DBFExporter extends Exporter {
    
    private static final Logger LOGGER = Logger.getLogger(DBFExporter.class);
    
    /**
     * Кодировка для текста в DBF файле.
     */
    private final String charsetEncoding;
    
    /**
     * Количество столбцов.
     */
    private int numberOfColumns;
    
    protected DBFExporter(String exportFilename,
            Path exportPath,
            String extension,
            DateFormat exportDateFormat,
            String charsetEncoding) {
        super(exportFilename, exportPath, extension, exportDateFormat);
        this.charsetEncoding = charsetEncoding;
        LOGGER.trace("The object of DBFExporter class was created.");
    }

    @Override
    public void export(ResultSet resultSet) throws IOException, SQLException {
        LOGGER.trace("The method export() was invoked:\n"
                + "\tResultSet resultSet <= " + resultSet);
        
        File outputFile = createNewExportFile();
        
        OutputStream out = new FileOutputStream(outputFile);
	
        DBFWriter writer = new DBFWriter(outputFile);
	
        try {
            writer.setCharactersetName(charsetEncoding);
            writer.setFields(createFields(resultSet));
            long count = putRows(writer, resultSet);
            LOGGER.info(count + " rows were added into the file " + actualExportFilename);
        }
        finally {
            writer.write(out);
            out.close();
        }
    }
    
    @Override
    public void export(Set<ResultSet> resultSets) throws IOException, SQLException {
        LOGGER.trace("The method export() was invoked:\n"
                + "\tSet<ResultSet> resultSets <= " + resultSets);
        export(resultSets.toArray(new ResultSet[0])[0]);
    }
    
    /**
     * 
     * @param resultSet
     * @return
     * @throws SQLException
     * @throws DBFException 
     */
    private DBFField[] createFields(ResultSet resultSet) throws SQLException, DBFException {
        LOGGER.trace("The method createFields() was invoked:\n"
                + "\tResultSet resultSet <= " + resultSet);
        List<DBFField> fields = new ArrayList<DBFField>();

        ResultSetMetaData resultSetMetaData = resultSet.getMetaData();
        numberOfColumns = resultSetMetaData.getColumnCount();
        for (int i = 0; i < numberOfColumns; i++) {
            
            DBFField field = new DBFField();
            
            String columnLabel = resultSetMetaData.getColumnLabel(i + 1);
            String name = columnLabel.length() < 10 ? columnLabel :
                    columnLabel.substring(0, 10);
            field.setName(name);
            LOGGER.debug("Field name = " + name);
            int length = resultSetMetaData.getColumnDisplaySize(i + 1);
            if (length > 244) {
                length = 244;
            }
            if (length < 1) {
                length = 1;
            }
            LOGGER.debug("Field name length = " + length);

            byte fieldType = getDBFType(resultSetMetaData.getColumnType(i + 1));
            
            LOGGER.debug("Field type = " + getDBFTypeName(fieldType));
            
            field.setDataType(fieldType);

            switch (fieldType) {
            case DBFField.FIELD_TYPE_N:
                field.setFieldLength(length);
                break;
            case DBFField.FIELD_TYPE_C:
                field.setFieldLength(length);
                break;
            }

            fields.add(field);
        }

        return fields.toArray(new DBFField[fields.size()]);
    }
    
    /**
     * 
     * @param sqlType
     * @return
     * @throws DBFException 
     */
    private byte getDBFType(int sqlType) throws DBFException {
        LOGGER.trace("The method getDBFType() was invoked:\n"
                + "\tint sqlType <= " + sqlType);
        byte result;

        switch (sqlType) {
        case Types.CHAR:
        case Types.VARCHAR:
        case Types.CLOB:
            result = DBFField.FIELD_TYPE_C;
            break;
        case Types.INTEGER:
        case Types.DECIMAL:
        case Types.FLOAT:
        case Types.NUMERIC:
            result = DBFField.FIELD_TYPE_N;
            break;
        case Types.DATE:
        case Types.TIMESTAMP:
            result = DBFField.FIELD_TYPE_D;
            break;
        case Types.BOOLEAN:
            result = DBFField.FIELD_TYPE_L;
            break;
        default:
            throw new DBFException("Unknown SQL type");
        }

        LOGGER.trace("getDBFType() returned => " + result);
        return result;
    }
    
    /**
     * 
     * @param typeCode
     * @return 
     */
    private String getDBFTypeName(byte typeCode) {
	LOGGER.trace("The method getDBFTypeName() was invoked:\n"
                + "\tbyte typeCode <= " + typeCode);
        
        String result = null;
        switch (typeCode) {
        case DBFField.FIELD_TYPE_C:
            result = "C";
            break;
        case DBFField.FIELD_TYPE_N:
            result = "N";
            break;
        case DBFField.FIELD_TYPE_D:
            result = "D";
            break;
        case DBFField.FIELD_TYPE_L:
            result = "L";
            break;
        case DBFField.FIELD_TYPE_M:
            result = "M";
            break;
        case DBFField.FIELD_TYPE_F:
            result = "F";
            break;
        }
        
        LOGGER.trace("getDBFTypeName() returned => " + result);
        return result;
    }
    
    /**
     * 
     * @param writer
     * @param resultSet
     * @return
     * @throws DBFException
     * @throws SQLException 
     */
    private long putRows(DBFWriter writer, ResultSet resultSet) throws DBFException, SQLException {
	LOGGER.trace("The method putRows() was invoked:\n"
                + "\tDBFWriter writer <= " + writer + "\n"
                + "\tResultSet resultSet <= " + resultSet);
        long count = 0;
        while (resultSet.next()) {
            Object[] rowData = new Object[numberOfColumns];
            for (int i = 0; i < numberOfColumns; i++) {
                Object object= resultSet.getObject(i + 1);

                if (object instanceof String) {
                    rowData[i] = ((String) object);
                }
                else if (object instanceof BigDecimal) {
                    double value = ((BigDecimal) object).doubleValue();
                    rowData[i] = resultSet.wasNull() ? null : new Double(value);
                }
                else if (object instanceof BigInteger) {
                    int value = ((BigInteger) object).intValue();
                    rowData[i] = resultSet.wasNull() ? null : new Integer(value);
                }
                else {
                    rowData[i] = object;
                }
            }
            writer.addRecord(rowData);
            count++;
            
            if (count % 25000 == 0) {
                LOGGER.info(count + " rows were added into the file " + actualExportFilename);
            }
        }
        
        LOGGER.trace("putRows() returned => " + count);
        return count;
    }
}
