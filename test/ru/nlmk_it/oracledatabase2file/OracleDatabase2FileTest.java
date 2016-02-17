/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file;

import java.io.File;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import ru.nlmk_it.oracledatabase2file.arguments.Arguments;
import ru.nlmk_it.oracledatabase2file.database.SQLScript;
import ru.nlmk_it.oracledatabase2file.exporters.FiletypeEnum;

/**
 *
 * @author Косых Евгений
 */
public class OracleDatabase2FileTest {
    
    private Arguments arguments;
    
    private static File exportPath;
    
    @BeforeClass
    public static void setUpClass() throws Exception {
        
        exportPath = new File("./export/");
        
    }

    @Before
    public void setUp() throws Exception {
        System.out.println("Starting to test the connection to database");
        
        arguments = new Arguments();
        arguments.setParametersFromConfigFile(new File("./etc/parameters.property"));
    }

    /**
     * Test of checkBindedVariables method, of class OracleDatabase2File.
     * @throws java.lang.Exception
     */
    @Test
    public void testCheckBindedVariablesCorrect() throws Exception {
        
        Set<String> requiredVariables = new HashSet<String>();
        requiredVariables.add("a");
        requiredVariables.add("b");
        requiredVariables.add("c");
        requiredVariables.add("d");
        
        Set<String> actualVariables = new HashSet<String>();
        actualVariables.add("a");
        actualVariables.add("b");
        actualVariables.add("c");
        actualVariables.add("d");
        actualVariables.add("e");
        
        OracleDatabase2File.checkBindedVariables(requiredVariables, actualVariables);
    }
    
    /**
     * 
     * @throws Exception 
     */
    @Test(expected = SQLException.class)
    public void testCheckBindedVariables() throws Exception {
        
        Set<String> requiredVariables = new HashSet<String>();
        requiredVariables.add("a");
        requiredVariables.add("b");
        requiredVariables.add("c");
        requiredVariables.add("d");
        
        Set<String> actualVariables = new HashSet<String>();
        actualVariables.add("a");
        actualVariables.add("b");
        actualVariables.add("c");
        
        OracleDatabase2File.checkBindedVariables(requiredVariables, actualVariables);
    }

    /**
     * Test of execute method, of class OracleDatabase2File.
     * @throws java.lang.Exception
     */
    @Test
    public void testExecuteTrivial() throws Exception {
        System.out.println("execute (trivial.sql)");
        arguments.setFiletype(FiletypeEnum.XLSX);
        arguments.setSQLScript(new SQLScript(new File("./queries/trivial.sql")));
        arguments.setExportDir(exportPath);
        
        OracleDatabase2File odf = new OracleDatabase2File(arguments);
        try {
            odf.execute();
        }
        finally {
            odf.close();
        }
    }

    /**
     * Test of execute method, of class OracleDatabase2File.
     * @throws java.lang.Exception
     */
    @Test
    public void testExecuteFirst50Accounts() throws Exception {
        System.out.println("execute (first50accounts.sql)");
        arguments.setFiletype(FiletypeEnum.XLSX);
        arguments.setSQLScript(new SQLScript(new File("./queries/first50accounts.sql")));
        arguments.setExportDir(exportPath);
        
        OracleDatabase2File odf = new OracleDatabase2File(arguments);
        try {
            odf.execute();
        }
        finally {
            odf.close();
        }
    }
}
