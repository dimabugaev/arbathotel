/**
 * PermissionForAuthBean.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package ru.psbank.ent.auth.xmlbean;

public class PermissionForAuthBean  implements java.io.Serializable {
    private AclBean acl;

    private ru.psbank.ent.Filial filial;

    private AuthEntryBean owner;

    private String serverB64Cert;

    public PermissionForAuthBean() {
    }

    public PermissionForAuthBean(
           AclBean acl,
           ru.psbank.ent.Filial filial,
           AuthEntryBean owner,
           String serverB64Cert) {
           this.acl = acl;
           this.filial = filial;
           this.owner = owner;
           this.serverB64Cert = serverB64Cert;
    }


    /**
     * Gets the acl value for this PermissionForAuthBean.
     * 
     * @return acl
     */
    public AclBean getAcl() {
        return acl;
    }


    /**
     * Sets the acl value for this PermissionForAuthBean.
     * 
     * @param acl
     */
    public void setAcl(AclBean acl) {
        this.acl = acl;
    }


    /**
     * Gets the filial value for this PermissionForAuthBean.
     * 
     * @return filial
     */
    public ru.psbank.ent.Filial getFilial() {
        return filial;
    }


    /**
     * Sets the filial value for this PermissionForAuthBean.
     * 
     * @param filial
     */
    public void setFilial(ru.psbank.ent.Filial filial) {
        this.filial = filial;
    }


    /**
     * Gets the owner value for this PermissionForAuthBean.
     * 
     * @return owner
     */
    public AuthEntryBean getOwner() {
        return owner;
    }


    /**
     * Sets the owner value for this PermissionForAuthBean.
     * 
     * @param owner
     */
    public void setOwner(AuthEntryBean owner) {
        this.owner = owner;
    }


    /**
     * Gets the serverB64Cert value for this PermissionForAuthBean.
     * 
     * @return serverB64Cert
     */
    public String getServerB64Cert() {
        return serverB64Cert;
    }


    /**
     * Sets the serverB64Cert value for this PermissionForAuthBean.
     * 
     * @param serverB64Cert
     */
    public void setServerB64Cert(String serverB64Cert) {
        this.serverB64Cert = serverB64Cert;
    }

    private Object __equalsCalc = null;
    public synchronized boolean equals(Object obj) {
        if (!(obj instanceof PermissionForAuthBean)) return false;
        PermissionForAuthBean other = (PermissionForAuthBean) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.acl==null && other.getAcl()==null) || 
             (this.acl!=null &&
              this.acl.equals(other.getAcl()))) &&
            ((this.filial==null && other.getFilial()==null) || 
             (this.filial!=null &&
              this.filial.equals(other.getFilial()))) &&
            ((this.owner==null && other.getOwner()==null) || 
             (this.owner!=null &&
              this.owner.equals(other.getOwner()))) &&
            ((this.serverB64Cert==null && other.getServerB64Cert()==null) || 
             (this.serverB64Cert!=null &&
              this.serverB64Cert.equals(other.getServerB64Cert())));
        __equalsCalc = null;
        return _equals;
    }

    private boolean __hashCodeCalc = false;
    public synchronized int hashCode() {
        if (__hashCodeCalc) {
            return 0;
        }
        __hashCodeCalc = true;
        int _hashCode = 1;
        if (getAcl() != null) {
            _hashCode += getAcl().hashCode();
        }
        if (getFilial() != null) {
            _hashCode += getFilial().hashCode();
        }
        if (getOwner() != null) {
            _hashCode += getOwner().hashCode();
        }
        if (getServerB64Cert() != null) {
            _hashCode += getServerB64Cert().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(PermissionForAuthBean.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://xmlbean.auth.ent.psbank.ru", "PermissionForAuthBean"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("acl");
        elemField.setXmlName(new javax.xml.namespace.QName("", "acl"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://xmlbean.auth.ent.psbank.ru", "AclBean"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("filial");
        elemField.setXmlName(new javax.xml.namespace.QName("", "filial"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://ent.psbank.ru", "Filial"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("owner");
        elemField.setXmlName(new javax.xml.namespace.QName("", "owner"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://xmlbean.auth.ent.psbank.ru", "AuthEntryBean"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("serverB64Cert");
        elemField.setXmlName(new javax.xml.namespace.QName("", "serverB64Cert"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
    }

    /**
     * Return type metadata object
     */
    public static org.apache.axis.description.TypeDesc getTypeDesc() {
        return typeDesc;
    }

    /**
     * Get Custom Serializer
     */
    public static org.apache.axis.encoding.Serializer getSerializer(
           String mechType,
           Class _javaType,
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanSerializer(
            _javaType, _xmlType, typeDesc);
    }

    /**
     * Get Custom Deserializer
     */
    public static org.apache.axis.encoding.Deserializer getDeserializer(
           String mechType,
           Class _javaType,
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanDeserializer(
            _javaType, _xmlType, typeDesc);
    }

}
