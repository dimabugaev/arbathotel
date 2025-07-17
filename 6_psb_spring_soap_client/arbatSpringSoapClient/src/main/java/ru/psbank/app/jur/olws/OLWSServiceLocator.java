/**
 * OLWSServiceLocator.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package ru.psbank.app.jur.olws;

public class OLWSServiceLocator extends org.apache.axis.client.Service implements OLWSService {

    public OLWSServiceLocator() {
    }


    public OLWSServiceLocator(org.apache.axis.EngineConfiguration config) {
        super(config);
    }

    public OLWSServiceLocator(String wsdlLoc, javax.xml.namespace.QName sName) throws javax.xml.rpc.ServiceException {
        super(wsdlLoc, sName);
    }

    // Use to get a proxy class for OLWS
    private String OLWS_address = "https://online.payment.ru:9443/OLWSWM/services/OLWS";

    public String getOLWSAddress() {
        return OLWS_address;
    }

    // The WSDD service name defaults to the port name.
    private String OLWSWSDDServiceName = "OLWS";

    public String getOLWSWSDDServiceName() {
        return OLWSWSDDServiceName;
    }

    public void setOLWSWSDDServiceName(String name) {
        OLWSWSDDServiceName = name;
    }

    public OLWS getOLWS() throws javax.xml.rpc.ServiceException {
       java.net.URL endpoint;
        try {
            endpoint = new java.net.URL(OLWS_address);
        }
        catch (java.net.MalformedURLException e) {
            throw new javax.xml.rpc.ServiceException(e);
        }
        return getOLWS(endpoint);
    }

    public OLWS getOLWS(java.net.URL portAddress) throws javax.xml.rpc.ServiceException {
        try {
            OLWSSoapBindingStub _stub = new OLWSSoapBindingStub(portAddress, this);
            _stub.setPortName(getOLWSWSDDServiceName());
            return _stub;
        }
        catch (org.apache.axis.AxisFault e) {
            return null;
        }
    }

    public void setOLWSEndpointAddress(String address) {
        OLWS_address = address;
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        try {
            if (OLWS.class.isAssignableFrom(serviceEndpointInterface)) {
                OLWSSoapBindingStub _stub = new OLWSSoapBindingStub(new java.net.URL(OLWS_address), this);
                _stub.setPortName(getOLWSWSDDServiceName());
                return _stub;
            }
        }
        catch (Throwable t) {
            throw new javax.xml.rpc.ServiceException(t);
        }
        throw new javax.xml.rpc.ServiceException("There is no stub implementation for the interface:  " + (serviceEndpointInterface == null ? "null" : serviceEndpointInterface.getName()));
    }

    /**
     * For the given interface, get the stub implementation.
     * If this service has no port for the given interface,
     * then ServiceException is thrown.
     */
    public java.rmi.Remote getPort(javax.xml.namespace.QName portName, Class serviceEndpointInterface) throws javax.xml.rpc.ServiceException {
        if (portName == null) {
            return getPort(serviceEndpointInterface);
        }
        String inputPortName = portName.getLocalPart();
        if ("OLWS".equals(inputPortName)) {
            return getOLWS();
        }
        else  {
            java.rmi.Remote _stub = getPort(serviceEndpointInterface);
            ((org.apache.axis.client.Stub) _stub).setPortName(portName);
            return _stub;
        }
    }

    public javax.xml.namespace.QName getServiceName() {
        return new javax.xml.namespace.QName("http://olws.jur.app.psbank.ru", "OLWSService");
    }

    private java.util.HashSet ports = null;

    public java.util.Iterator getPorts() {
        if (ports == null) {
            ports = new java.util.HashSet();
            ports.add(new javax.xml.namespace.QName("http://olws.jur.app.psbank.ru", "OLWS"));
        }
        return ports.iterator();
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(String portName, String address) throws javax.xml.rpc.ServiceException {
        
if ("OLWS".equals(portName)) {
            setOLWSEndpointAddress(address);
        }
        else 
{ // Unknown Port Name
            throw new javax.xml.rpc.ServiceException(" Cannot set Endpoint Address for Unknown Port" + portName);
        }
    }

    /**
    * Set the endpoint address for the specified port name.
    */
    public void setEndpointAddress(javax.xml.namespace.QName portName, String address) throws javax.xml.rpc.ServiceException {
        setEndpointAddress(portName.getLocalPart(), address);
    }

}
