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

/**
 *
 * @author Косых Евгений
 */
final class XLSXExporter extends Exporter {
    
    private static final Logger LOGGER = LogManager.getLogger(XLSXExporter.class);
    
    public XLSXExporter(String exportFilename) {
        super(exportFilename);
        LOGGER.trace("The object of XLSXExporter class was created.");
    }

    @Override
    public void export(ResultSet resultSet) throws IOException, SQLException {
        LOGGER.trace("The method export() was invoked,\n"
                + "\tResultSet resultSet <= " + resultSet);
    }

    @Override
    public void export(Set<ResultSet> resultSets) throws IOException, SQLException {
        LOGGER.trace("The method export() was invoked,\n"
                + "\tSet<ResultSet> resultSets <= " + resultSets);
    }
}
