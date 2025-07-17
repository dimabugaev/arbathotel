/**
 * AclBean.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package ru.psbank.ent.auth.xmlbean;

public class AclBean  implements java.io.Serializable {
    private AclEntryBean[] aclEntries;

    private String name;

    private AclEntryBean[] negAclEntries;

    private PrincipalBean owner;

    public AclBean() {
    }

    public AclBean(
           AclEntryBean[] aclEntries,
           String name,
           AclEntryBean[] negAclEntries,
           PrincipalBean owner) {
           this.aclEntries = aclEntries;
           this.name = name;
           this.negAclEntries = negAclEntries;
           this.owner = owner;
    }


    /**
     * Gets the aclEntries value for this AclBean.
     * 
     * @return aclEntries
     */
    public AclEntryBean[] getAclEntries() {
        return aclEntries;
    }


    /**
     * Sets the aclEntries value for this AclBean.
     * 
     * @param aclEntries
     */
    public void setAclEntries(AclEntryBean[] aclEntries) {
        this.aclEntries = aclEntries;
    }


    /**
     * Gets the name value for this AclBean.
     * 
     * @return name
     */
    public String getName() {
        return name;
    }


    /**
     * Sets the name value for this AclBean.
     * 
     * @param name
     */
    public void setName(String name) {
        this.name = name;
    }


    /**
     * Gets the negAclEntries value for this AclBean.
     * 
     * @return negAclEntries
     */
    public AclEntryBean[] getNegAclEntries() {
        return negAclEntries;
    }


    /**
     * Sets the negAclEntries value for this AclBean.
     * 
     * @param negAclEntries
     */
    public void setNegAclEntries(AclEntryBean[] negAclEntries) {
        this.negAclEntries = negAclEntries;
    }


    /**
     * Gets the owner value for this AclBean.
     * 
     * @return owner
     */
    public PrincipalBean getOwner() {
        return owner;
    }


    /**
     * Sets the owner value for this AclBean.
     * 
     * @param owner
     */
    public void setOwner(PrincipalBean owner) {
        this.owner = owner;
    }

    private Object __equalsCalc = null;
    public synchronized boolean equals(Object obj) {
        if (!(obj instanceof AclBean)) return false;
        AclBean other = (AclBean) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.aclEntries==null && other.getAclEntries()==null) || 
             (this.aclEntries!=null &&
              java.util.Arrays.equals(this.aclEntries, other.getAclEntries()))) &&
            ((this.name==null && other.getName()==null) || 
             (this.name!=null &&
              this.name.equals(other.getName()))) &&
            ((this.negAclEntries==null && other.getNegAclEntries()==null) || 
             (this.negAclEntries!=null &&
              java.util.Arrays.equals(this.negAclEntries, other.getNegAclEntries()))) &&
            ((this.owner==null && other.getOwner()==null) || 
             (this.owner!=null &&
              this.owner.equals(other.getOwner())));
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
        if (getAclEntries() != null) {
            for (int i=0;
                 i<java.lang.reflect.Array.getLength(getAclEntries());
                 i++) {
                Object obj = java.lang.reflect.Array.get(getAclEntries(), i);
                if (obj != null &&
                    !obj.getClass().isArray()) {
                    _hashCode += obj.hashCode();
                }
            }
        }
        if (getName() != null) {
            _hashCode += getName().hashCode();
        }
        if (getNegAclEntries() != null) {
            for (int i=0;
                 i<java.lang.reflect.Array.getLength(getNegAclEntries());
                 i++) {
                Object obj = java.lang.reflect.Array.get(getNegAclEntries(), i);
                if (obj != null &&
                    !obj.getClass().isArray()) {
                    _hashCode += obj.hashCode();
                }
            }
        }
        if (getOwner() != null) {
            _hashCode += getOwner().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(AclBean.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://xmlbean.auth.ent.psbank.ru", "AclBean"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("aclEntries");
        elemField.setXmlName(new javax.xml.namespace.QName("", "aclEntries"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://xmlbean.auth.ent.psbank.ru", "AclEntryBean"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("name");
        elemField.setXmlName(new javax.xml.namespace.QName("", "name"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("negAclEntries");
        elemField.setXmlName(new javax.xml.namespace.QName("", "negAclEntries"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://xmlbean.auth.ent.psbank.ru", "AclEntryBean"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("owner");
        elemField.setXmlName(new javax.xml.namespace.QName("", "owner"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://xmlbean.auth.ent.psbank.ru", "PrincipalBean"));
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
