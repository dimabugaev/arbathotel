/**
 * AclEntryBean.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package ru.psbank.ent.auth.xmlbean;

public class AclEntryBean  implements java.io.Serializable {
    private boolean negative;

    private PSB2PermissionBean[] permission;

    private PrincipalBean principal;

    public AclEntryBean() {
    }

    public AclEntryBean(
           boolean negative,
           PSB2PermissionBean[] permission,
           PrincipalBean principal) {
           this.negative = negative;
           this.permission = permission;
           this.principal = principal;
    }


    /**
     * Gets the negative value for this AclEntryBean.
     * 
     * @return negative
     */
    public boolean isNegative() {
        return negative;
    }


    /**
     * Sets the negative value for this AclEntryBean.
     * 
     * @param negative
     */
    public void setNegative(boolean negative) {
        this.negative = negative;
    }


    /**
     * Gets the permission value for this AclEntryBean.
     * 
     * @return permission
     */
    public PSB2PermissionBean[] getPermission() {
        return permission;
    }


    /**
     * Sets the permission value for this AclEntryBean.
     * 
     * @param permission
     */
    public void setPermission(PSB2PermissionBean[] permission) {
        this.permission = permission;
    }


    /**
     * Gets the principal value for this AclEntryBean.
     * 
     * @return principal
     */
    public PrincipalBean getPrincipal() {
        return principal;
    }


    /**
     * Sets the principal value for this AclEntryBean.
     * 
     * @param principal
     */
    public void setPrincipal(PrincipalBean principal) {
        this.principal = principal;
    }

    private Object __equalsCalc = null;
    public synchronized boolean equals(Object obj) {
        if (!(obj instanceof AclEntryBean)) return false;
        AclEntryBean other = (AclEntryBean) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            this.negative == other.isNegative() &&
            ((this.permission==null && other.getPermission()==null) || 
             (this.permission!=null &&
              java.util.Arrays.equals(this.permission, other.getPermission()))) &&
            ((this.principal==null && other.getPrincipal()==null) || 
             (this.principal!=null &&
              this.principal.equals(other.getPrincipal())));
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
        _hashCode += (isNegative() ? Boolean.TRUE : Boolean.FALSE).hashCode();
        if (getPermission() != null) {
            for (int i=0;
                 i<java.lang.reflect.Array.getLength(getPermission());
                 i++) {
                Object obj = java.lang.reflect.Array.get(getPermission(), i);
                if (obj != null &&
                    !obj.getClass().isArray()) {
                    _hashCode += obj.hashCode();
                }
            }
        }
        if (getPrincipal() != null) {
            _hashCode += getPrincipal().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(AclEntryBean.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://xmlbean.auth.ent.psbank.ru", "AclEntryBean"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("negative");
        elemField.setXmlName(new javax.xml.namespace.QName("", "negative"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "boolean"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("permission");
        elemField.setXmlName(new javax.xml.namespace.QName("", "permission"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://xmlbean.auth.ent.psbank.ru", "PSB2PermissionBean"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("principal");
        elemField.setXmlName(new javax.xml.namespace.QName("", "principal"));
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
