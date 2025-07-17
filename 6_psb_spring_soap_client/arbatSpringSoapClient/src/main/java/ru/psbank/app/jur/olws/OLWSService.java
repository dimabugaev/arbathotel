/**
 * OLWSService.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package ru.psbank.app.jur.olws;

public interface OLWSService extends javax.xml.rpc.Service {
    public String getOLWSAddress();

    public OLWS getOLWS() throws javax.xml.rpc.ServiceException;

    public OLWS getOLWS(java.net.URL portAddress) throws javax.xml.rpc.ServiceException;
}
