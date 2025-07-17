/**
 * ExtractRow.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package ru.psbank.ent.doc;

public class ExtractRow  implements java.io.Serializable {

    private String KB;

    private String PO;

    private String account;

    private String contragent;

    private String contragentINN;

    private java.math.BigDecimal conversion;

    private boolean debit;

    private String description;

    private DocHeader doc;

    private String outerAccount;

    private java.math.BigDecimal summaRUR;

    public ExtractRow() {
    }

    public ExtractRow(
           String KB,
           String PO,
           String account,
           String contragent,
           String contragentINN,
           java.math.BigDecimal conversion,
           boolean debit,
           String description,
           DocHeader doc,
           String outerAccount,
           java.math.BigDecimal summaRUR) {
           this.KB = KB;
           this.PO = PO;
           this.account = account;
           this.contragent = contragent;
           this.contragentINN = contragentINN;
           this.conversion = conversion;
           this.debit = debit;
           this.description = description;
           this.doc = doc;
           this.outerAccount = outerAccount;
           this.summaRUR = summaRUR;
    }


    /**
     * Gets the KB value for this ExtractRow.
     * 
     * @return KB
     */
    public String getKB() {
        return KB;
    }


    /**
     * Sets the KB value for this ExtractRow.
     * 
     * @param KB
     */
    public void setKB(String KB) {
        this.KB = KB;
    }


    /**
     * Gets the PO value for this ExtractRow.
     * 
     * @return PO
     */
    public String getPO() {
        return PO;
    }


    /**
     * Sets the PO value for this ExtractRow.
     * 
     * @param PO
     */
    public void setPO(String PO) {
        this.PO = PO;
    }


    /**
     * Gets the account value for this ExtractRow.
     * 
     * @return account
     */
    public String getAccount() {
        return account;
    }


    /**
     * Sets the account value for this ExtractRow.
     * 
     * @param account
     */
    public void setAccount(String account) {
        this.account = account;
    }


    /**
     * Gets the contragent value for this ExtractRow.
     * 
     * @return contragent
     */
    public String getContragent() {
        return contragent;
    }


    /**
     * Sets the contragent value for this ExtractRow.
     * 
     * @param contragent
     */
    public void setContragent(String contragent) {
        this.contragent = contragent;
    }


    /**
     * Gets the contragentINN value for this ExtractRow.
     * 
     * @return contragentINN
     */
    public String getContragentINN() {
        return contragentINN;
    }


    /**
     * Sets the contragentINN value for this ExtractRow.
     * 
     * @param contragentINN
     */
    public void setContragentINN(String contragentINN) {
        this.contragentINN = contragentINN;
    }


    /**
     * Gets the conversion value for this ExtractRow.
     * 
     * @return conversion
     */
    public java.math.BigDecimal getConversion() {
        return conversion;
    }


    /**
     * Sets the conversion value for this ExtractRow.
     * 
     * @param conversion
     */
    public void setConversion(java.math.BigDecimal conversion) {
        this.conversion = conversion;
    }


    /**
     * Gets the debit value for this ExtractRow.
     * 
     * @return debit
     */
    public boolean isDebit() {
        return debit;
    }


    /**
     * Sets the debit value for this ExtractRow.
     * 
     * @param debit
     */
    public void setDebit(boolean debit) {
        this.debit = debit;
    }


    /**
     * Gets the description value for this ExtractRow.
     * 
     * @return description
     */
    public String getDescription() {
        return description;
    }


    /**
     * Sets the description value for this ExtractRow.
     * 
     * @param description
     */
    public void setDescription(String description) {
        this.description = description;
    }


    /**
     * Gets the doc value for this ExtractRow.
     * 
     * @return doc
     */
    public DocHeader getDoc() {
        return doc;
    }


    /**
     * Sets the doc value for this ExtractRow.
     * 
     * @param doc
     */
    public void setDoc(DocHeader doc) {
        this.doc = doc;
    }


    /**
     * Gets the outerAccount value for this ExtractRow.
     * 
     * @return outerAccount
     */
    public String getOuterAccount() {
        return outerAccount;
    }


    /**
     * Sets the outerAccount value for this ExtractRow.
     * 
     * @param outerAccount
     */
    public void setOuterAccount(String outerAccount) {
        this.outerAccount = outerAccount;
    }


    /**
     * Gets the summaRUR value for this ExtractRow.
     * 
     * @return summaRUR
     */
    public java.math.BigDecimal getSummaRUR() {
        return summaRUR;
    }


    /**
     * Sets the summaRUR value for this ExtractRow.
     * 
     * @param summaRUR
     */
    public void setSummaRUR(java.math.BigDecimal summaRUR) {
        this.summaRUR = summaRUR;
    }

    private Object __equalsCalc = null;
    public synchronized boolean equals(Object obj) {
        if (!(obj instanceof ExtractRow)) return false;
        ExtractRow other = (ExtractRow) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.KB==null && other.getKB()==null) || 
             (this.KB!=null &&
              this.KB.equals(other.getKB()))) &&
            ((this.PO==null && other.getPO()==null) || 
             (this.PO!=null &&
              this.PO.equals(other.getPO()))) &&
            ((this.account==null && other.getAccount()==null) || 
             (this.account!=null &&
              this.account.equals(other.getAccount()))) &&
            ((this.contragent==null && other.getContragent()==null) || 
             (this.contragent!=null &&
              this.contragent.equals(other.getContragent()))) &&
            ((this.contragentINN==null && other.getContragentINN()==null) || 
             (this.contragentINN!=null &&
              this.contragentINN.equals(other.getContragentINN()))) &&
            ((this.conversion==null && other.getConversion()==null) || 
             (this.conversion!=null &&
              this.conversion.equals(other.getConversion()))) &&
            this.debit == other.isDebit() &&
            ((this.description==null && other.getDescription()==null) || 
             (this.description!=null &&
              this.description.equals(other.getDescription()))) &&
            ((this.doc==null && other.getDoc()==null) || 
             (this.doc!=null &&
              this.doc.equals(other.getDoc()))) &&
            ((this.outerAccount==null && other.getOuterAccount()==null) || 
             (this.outerAccount!=null &&
              this.outerAccount.equals(other.getOuterAccount()))) &&
            ((this.summaRUR==null && other.getSummaRUR()==null) || 
             (this.summaRUR!=null &&
              this.summaRUR.equals(other.getSummaRUR())));
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
        if (getKB() != null) {
            _hashCode += getKB().hashCode();
        }
        if (getPO() != null) {
            _hashCode += getPO().hashCode();
        }
        if (getAccount() != null) {
            _hashCode += getAccount().hashCode();
        }
        if (getContragent() != null) {
            _hashCode += getContragent().hashCode();
        }
        if (getContragentINN() != null) {
            _hashCode += getContragentINN().hashCode();
        }
        if (getConversion() != null) {
            _hashCode += getConversion().hashCode();
        }
        _hashCode += (isDebit() ? Boolean.TRUE : Boolean.FALSE).hashCode();
        if (getDescription() != null) {
            _hashCode += getDescription().hashCode();
        }
        if (getDoc() != null) {
            _hashCode += getDoc().hashCode();
        }
        if (getOuterAccount() != null) {
            _hashCode += getOuterAccount().hashCode();
        }
        if (getSummaRUR() != null) {
            _hashCode += getSummaRUR().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(ExtractRow.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://doc.ent.psbank.ru", "ExtractRow"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("KB");
        elemField.setXmlName(new javax.xml.namespace.QName("", "KB"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("PO");
        elemField.setXmlName(new javax.xml.namespace.QName("", "PO"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("account");
        elemField.setXmlName(new javax.xml.namespace.QName("", "account"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("contragent");
        elemField.setXmlName(new javax.xml.namespace.QName("", "contragent"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("contragentINN");
        elemField.setXmlName(new javax.xml.namespace.QName("", "contragentINN"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("conversion");
        elemField.setXmlName(new javax.xml.namespace.QName("", "conversion"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "decimal"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("debit");
        elemField.setXmlName(new javax.xml.namespace.QName("", "debit"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "boolean"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("description");
        elemField.setXmlName(new javax.xml.namespace.QName("", "description"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("doc");
        elemField.setXmlName(new javax.xml.namespace.QName("", "doc"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://doc.ent.psbank.ru", "DocHeader"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("outerAccount");
        elemField.setXmlName(new javax.xml.namespace.QName("", "outerAccount"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("summaRUR");
        elemField.setXmlName(new javax.xml.namespace.QName("", "summaRUR"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "decimal"));
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
