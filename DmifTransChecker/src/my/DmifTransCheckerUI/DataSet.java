/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package my.DmifTransCheckerUI;

import java.util.Vector;

/**
 *
 * @author honli
 */
public class DataSet {
    public Vector DataSrc = new Vector();
    public Vector ColName = new Vector();

    public DataSet() {
        this.ColName.addElement("FrameCnt");
        this.ColName.addElement("UinitID");
        this.ColName.addElement("ReqTime");
        this.ColName.addElement("ReqAddress");
        this.ColName.addElement("Tag");        
        this.ColName.addElement("RetTime");
        this.ColName.addElement("DeltaTime");
        this.ColName.addElement("Data1");
        this.ColName.addElement("Data2");        
    }
    
    public void CleanUp(){
        if (!this.DataSrc.isEmpty()){
            this.DataSrc.clear();
        }          
    }  
    
}
