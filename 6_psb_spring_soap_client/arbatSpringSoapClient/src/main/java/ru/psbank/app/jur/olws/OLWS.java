/**
 * OLWS.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package ru.psbank.app.jur.olws;

public interface OLWS extends java.rmi.Remote {
    public Object initAppRef(String url, String appCtx) throws java.rmi.RemoteException;
    public ru.psbank.ent.Client[] getClients() throws java.rmi.RemoteException;
    public ru.psbank.ent.doc.Exctract getExctract(String account, String dateFrom, String dateTo) throws java.rmi.RemoteException, ru.psbank.srv.SrvException;
    public void setUrl(String inUrl) throws java.rmi.RemoteException;
    public void setUrlFromContainer(String envUrlName) throws java.rmi.RemoteException;
    public void setCtx(String inCtx) throws java.rmi.RemoteException;
    public void setCtxFromContainer(String envCtxName) throws java.rmi.RemoteException;
    public ru.psbank.ent.Filial[] getFilias() throws java.rmi.RemoteException, ru.psbank.appbase.soap.AuthSOAPException;
    public int setUI(String ui) throws java.rmi.RemoteException, ru.psbank.appbase.soap.SrvSOAPException;
    public ru.psbank.ent.auth.xmlbean.PermissionForAuthBean getPermission(int filial_id) throws java.rmi.RemoteException, ru.psbank.appbase.soap.AuthSOAPException;
    public ru.psbank.ent.AppAttribytes getAttribytes(int filial_id) throws java.rmi.RemoteException;
    public void destroyIface() throws java.rmi.RemoteException;
    public void initIface(String url, String appCtx) throws java.rmi.RemoteException;
    public ru.psbank.ent.UserInfo getUserInfo() throws java.rmi.RemoteException, ru.psbank.appbase.soap.SrvSOAPException;
}
