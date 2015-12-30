/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package ru.nlmk_it.oracledatabase2file.database;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.Test;
import static org.junit.Assert.*;
import org.junit.BeforeClass;

/**
 * 
 *  На вход подаётся строка со сценарием.
 *  На выходе мы получаем список запросов,
 *  содержащихся в строке со сценарием.
 *
 *  Что нужно проверить следующие случаи:
 *  <ol>
 *    <li>сценарий пуст;</li>
 *    <li>сценарий содержит много пробелов;</li>
 *    <li>сценарий содержит несколько точек с запятой;</li>
 *    <li>сценарий содержит только комментарии;</li>
 *    <li>сценарий содержит один запрос;</li>
 *    <li>три запроса;</li>
 *    <li>комментарии, алиасы, строки закомментированные запросы,
 *        хинты и т.д.</li>
 *  </ol>
 * @author Косых Евгений
 */
public class SQLUtilsTest {
    
    public SQLUtilsTest() {
    }
    
    private static String mrskScript;
    
    private static String kvitMkdScript;
    
    private static String chasSectorScript;

    @BeforeClass
    public static void setUpClass() throws Exception {
        File script = new File("./tmp/mrsk.sql");
        
        StringBuilder fileData = new StringBuilder();
	
        try (BufferedReader reader = new BufferedReader(new FileReader(script))) {
            char[] buf = new char[1024];
            int numRead;
            while((numRead = reader.read(buf)) != -1){
                String readData = String.valueOf(buf, 0, numRead);
                fileData.append(readData);
            }
        }
        mrskScript = fileData.toString();
        
        script = new File("./tmp/kvit_mkd.sql");
        fileData = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new FileReader(script))) {
            char[] buf = new char[1024];
            int numRead;
            while((numRead = reader.read(buf)) != -1){
                String readData = String.valueOf(buf, 0, numRead);
                fileData.append(readData);
            }
        }
        kvitMkdScript = fileData.toString();
        
        script = new File("./tmp/chas_sector.sql");
        fileData = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new FileReader(script))) {
            char[] buf = new char[1024];
            int numRead;
            while((numRead = reader.read(buf)) != -1){
                String readData = String.valueOf(buf, 0, numRead);
                fileData.append(readData);
            }
        }
        chasSectorScript = fileData.toString();
    }

    /**
     * Сценарий пуст.
     */
    @Test
    public void testSplitScriptEmpty() {
        
        System.out.println("splitScript (empty)");
        String script = "";
        List<String> expResult = new ArrayList<>();
        List<String> result = SQLUtils.splitScript(script);
        assertEquals(expResult, result);
    }
    
    /**
     * Сценарий содержит набор пробельных символов.
     */
    @Test
    public void testSplitScriptSpaces() {
        System.out.println("splitScript (spaces)");
        String script = "   \t   \t \u00a0";
        List<String> expResult = new ArrayList<>();
        expResult.add("\u00a0");
        List<String> result = SQLUtils.splitScript(script);
        assertEquals(expResult, result);
    }
    
    /**
     * Сценарий содержит несколько точек с запятой.
     */
    @Test
    public void testSplitScriptSemicolons() {
        System.out.println("splitScript (semicolons)");
        String script = " ; -- ;\n ; /*;*/ ; ";
        List<String> expResult = new ArrayList<>();
        expResult.add("");
        expResult.add("-- ;");
        expResult.add("/*;*/");
        List<String> result = SQLUtils.splitScript(script);
        assertEquals(expResult, result);
    }
    
    /**
     * Сценарий содержит только комментарии.
     */
    @Test
    public void testSplitScriptComments() {
        System.out.println("splitScript (comments)");
        String script = "-- comm1\n"
                + "\n"
                + "/* ; and I will always love you; \n"
                + "*/\n"
                + "-- ;";
        List<String> expResult = new ArrayList<>();
        List<String> result = SQLUtils.splitScript(script);
        assertEquals(expResult, result);
    }
    
    /**
     * Сценарий содержит один запрос.
     */
    @Test
    public void testSplitScriptOneQuery() {
        System.out.println("splitScript (one query)");
        String script = "select sysdate\n"
                + "  from dual   ";
        List<String> expResult = new ArrayList<>();
        expResult.add(script.trim());
        List<String> result = SQLUtils.splitScript(script);
        assertEquals(expResult, result);
    }
    
    /**
     * три запроса.
     */
    @Test
    public void testSplitScriptThreeQuery() {
        System.out.println("splitScript (three query)");
        String script = "select sysdate\n"
                + "  from dual;\n"
                + "  \n"
                + "select 1 \n"
                + " from dual;\n"
                + "\t\n"
                + "select 'one' \n"
                + "   from\n"
                + "   dual";
        List<String> expResult = new ArrayList<>();
        expResult.add("select sysdate\n  from dual");
        expResult.add("select 1 \n from dual");
        expResult.add("select 'one' \n   from\n   dual");
        List<String> result = SQLUtils.splitScript(script);
        assertEquals(expResult, result);
    }
    
    /**
     * комментарии, алиасы, строки закомментированные запросы,
     * хинты и т.д.
     */
    @Test
    public void testSplitScriptHard() {
        System.out.println("splitScript (hard)");
        String script = "select 'г. Липецк ; '              as city, --  */ ;+ && ''' \"\"\"\n"
                + "       /*\n"
                + "        * &  -- ' \"\n"
                + "        */\n"
                + "       acct.acct_id             as ls,\n"
                + "       acct.setup_dt            as create_dt,\n"
                + "       acct.cis_division        as company,\n"
                + "       '&& \"\"\"\"; '''             as \"This is; --\"\" &alias\"\"\"\n"
                + "  from stgadm.ci_acct  acct\n"
                + " where setup_dt < &pdat\n"
                + "   and &r_on = '320008'\n"
                + "   and rownum <= 50;\n"
                + "\n"
                + "select sysdate\n"
                + "  from dual;";
        List<String> expResult = new ArrayList<>();
        expResult.add("select 'г. Липецк ; '              as city, --  */ ;+ && ''' \"\"\"\n"
                + "       /*\n"
                + "        * &  -- ' \"\n"
                + "        */\n"
                + "       acct.acct_id             as ls,\n"
                + "       acct.setup_dt            as create_dt,\n"
                + "       acct.cis_division        as company,\n"
                + "       '&& \"\"\"\"; '''             as \"This is; --\"\" &alias\"\"\"\n"
                + "  from stgadm.ci_acct  acct\n"
                + " where setup_dt < &pdat\n"
                + "   and &r_on = '320008'\n"
                + "   and rownum <= 50");
        expResult.add("select sysdate\n"
                + "  from dual");
        List<String> result = SQLUtils.splitScript(script);
        assertEquals(expResult, result);
    }
    
    /**
     * Test of getVariables method, of class SQLUtils.
     */
    @Test
    public void testGetVariablesTrivial() {
        System.out.println("getVariables (trivial)");
        String script = "select '1' from dual where &var = 123";
        Set<String> expResult = new HashSet<>();
        expResult.add("var");
        Set<String> result = SQLUtils.getVariables(script, '&');
        assertEquals(expResult, result);
    }

    /**
     * Test of getVariables method, of class SQLUtils.
     */
    @Test
    public void testGetVariablesMrsk() {
        System.out.println("getVariables (pdat)");
        String script = mrskScript;
        Set<String> expResult = new HashSet<>();
        expResult.add("pdat");
        Set<String> result = SQLUtils.getVariables(script, '&');
        assertEquals(expResult, result);
    }
    
    /**
     * Test of getVariables method, of class SQLUtils.
     */
    @Test
    public void testGetVariablesKvitMkd() {
        System.out.println("getVariables (pdat, pleskgesk, pdb_lesk, pnot_empty, use_filter)");
        String script = kvitMkdScript;
        Set<String> expResult = new HashSet<>();
        expResult.add("pdat");
        expResult.add("pleskgesk");
        expResult.add("pdb_lesk");
        expResult.add("pnot_empty");
        expResult.add("use_filter");
        Set<String> result = SQLUtils.getVariables(script, '&');
        assertEquals(expResult, result);
    }
    
    /**
     * Test of getVariables method, of class SQLUtils.
     */
    @Test
    public void testGetVariablesChasSector() {
        System.out.println("getVariables (pdat, cis_division, bill_stat, bseg_stat)");
        String script = chasSectorScript;
        Set<String> expResult = new HashSet<>();
        expResult.add("pdat");
        expResult.add("cis_division");
        expResult.add("bill_stat");
        expResult.add("bseg_stat");
        Set<String> result = SQLUtils.getVariables(script, '&');
        assertEquals(expResult, result);
    }
}
