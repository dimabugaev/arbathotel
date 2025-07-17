/**
 * DocHeader.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package ru.psbank.ent.doc;

public class DocHeader  implements java.io.Serializable {
    private long bankWorkId;

    private java.util.Calendar date;

    private boolean firstSigned;

    private long id;

    private String numberDoc;

    private String reciever;

    private boolean secondSigned;

    private DocStatus status;

    private java.math.BigDecimal summa;

    private boolean thirdSigned;

    private DocType type;

    public DocHeader() {
    }

    public DocHeader(
           long bankWorkId,
           java.util.Calendar date,
           boolean firstSigned,
           long id,
           String numberDoc,
           String reciever,
           boolean secondSigned,
           DocStatus status,
           java.math.BigDecimal summa,
           boolean thirdSigned,
           DocType type) {
           this.bankWorkId = bankWorkId;
           this.date = date;
           this.firstSigned = firstSigned;
           this.id = id;
           this.numberDoc = numberDoc;
           this.reciever = reciever;
           this.secondSigned = secondSigned;
           this.status = status;
           this.summa = summa;
           this.thirdSigned = thirdSigned;
           this.type = type;
    }


    /**
     * Gets the bankWorkId value for this DocHeader.
     * 
     * @return bankWorkId
     */
    public long getBankWorkId() {
        return bankWorkId;
    }


    /**
     * Sets the bankWorkId value for this DocHeader.
     * 
     * @param bankWorkId
     */
    public void setBankWorkId(long bankWorkId) {
        this.bankWorkId = bankWorkId;
    }


    /**
     * Gets the date value for this DocHeader.
     * 
     * @return date
     */
    public java.util.Calendar getDate() {
        return date;
    }


    /**
     * Sets the date value for this DocHeader.
     * 
     * @param date
     */
    public void setDate(java.util.Calendar date) {
        this.date = date;
    }


    /**
     * Gets the firstSigned value for this DocHeader.
     * 
     * @return firstSigned
     */
    public boolean isFirstSigned() {
        return firstSigned;
    }


    /**
     * Sets the firstSigned value for this DocHeader.
     * 
     * @param firstSigned
     */
    public void setFirstSigned(boolean firstSigned) {
        this.firstSigned = firstSigned;
    }


    /**
     * Gets the id value for this DocHeader.
     * 
     * @return id
     */
    public long getId() {
        return id;
    }


    /**
     * Sets the id value for this DocHeader.
     * 
     * @param id
     */
    public void setId(long id) {
        this.id = id;
    }


    /**
     * Gets the numberDoc value for this DocHeader.
     * 
     * @return numberDoc
     */
    public String getNumberDoc() {
        return numberDoc;
    }


    /**
     * Sets the numberDoc value for this DocHeader.
     * 
     * @param numberDoc
     */
    public void setNumberDoc(String numberDoc) {
        this.numberDoc = numberDoc;
    }


    /**
     * Gets the reciever value for this DocHeader.
     * 
     * @return reciever
     */
    public String getReciever() {
        return reciever;
    }


    /**
     * Sets the reciever value for this DocHeader.
     * 
     * @param reciever
     */
    public void setReciever(String reciever) {
        this.reciever = reciever;
    }


    /**
     * Gets the secondSigned value for this DocHeader.
     * 
     * @return secondSigned
     */
    public boolean isSecondSigned() {
        return secondSigned;
    }


    /**
     * Sets the secondSigned value for this DocHeader.
     * 
     * @param secondSigned
     */
    public void setSecondSigned(boolean secondSigned) {
        this.secondSigned = secondSigned;
    }


    /**
     * Gets the status value for this DocHeader.
     * 
     * @return status
     */
    public DocStatus getStatus() {
        return status;
    }


    /**
     * Sets the status value for this DocHeader.
     * 
     * @param status
     */
    public void setStatus(DocStatus status) {
        this.status = status;
    }


    /**
     * Gets the summa value for this DocHeader.
     * 
     * @return summa
     */
    public java.math.BigDecimal getSumma() {
        return summa;
    }


    /**
     * Sets the summa value for this DocHeader.
     * 
     * @param summa
     */
    public void setSumma(java.math.BigDecimal summa) {
        this.summa = summa;
    }


    /**
     * Gets the thirdSigned value for this DocHeader.
     * 
     * @return thirdSigned
     */
    public boolean isThirdSigned() {
        return thirdSigned;
    }


    /**
     * Sets the thirdSigned value for this DocHeader.
     * 
     * @param thirdSigned
     */
    public void setThirdSigned(boolean thirdSigned) {
        this.thirdSigned = thirdSigned;
    }


    /**
     * Gets the type value for this DocHeader.
     * 
     * @return type
     */
    public DocType getType() {
        return type;
    }


    /**
     * Sets the type value for this DocHeader.
     * 
     * @param type
     */
    public void setType(DocType type) {
        this.type = type;
    }

    private Object __equalsCalc = null;
    public synchronized boolean equals(Object obj) {
        if (!(obj instanceof DocHeader)) return false;
        DocHeader other = (DocHeader) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            this.bankWorkId == other.getBankWorkId() &&
            ((this.date==null && other.getDate()==null) || 
             (this.date!=null &&
              this.date.equals(other.getDate()))) &&
            this.firstSigned == other.isFirstSigned() &&
            this.id == other.getId() &&
            ((this.numberDoc==null && other.getNumberDoc()==null) || 
             (this.numberDoc!=null &&
              this.numberDoc.equals(other.getNumberDoc()))) &&
            ((this.reciever==null && other.getReciever()==null) || 
             (this.reciever!=null &&
              this.reciever.equals(other.getReciever()))) &&
            this.secondSigned == other.isSecondSigned() &&
            ((this.status==null && other.getStatus()==null) || 
             (this.status!=null &&
              this.status.equals(other.getStatus()))) &&
            ((this.summa==null && other.getSumma()==null) || 
             (this.summa!=null &&
              this.summa.equals(other.getSumma()))) &&
            this.thirdSigned == other.isThirdSigned() &&
            ((this.type==null && other.getType()==null) || 
             (this.type!=null &&
              this.type.equals(other.getType())));
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
        _hashCode += new Long(getBankWorkId()).hashCode();
        if (getDate() != null) {
            _hashCode += getDate().hashCode();
        }
        _hashCode += (isFirstSigned() ? Boolean.TRUE : Boolean.FALSE).hashCode();
        _hashCode += new Long(getId()).hashCode();
        if (getNumberDoc() != null) {
            _hashCode += getNumberDoc().hashCode();
        }
        if (getReciever() != null) {
            _hashCode += getReciever().hashCode();
        }
        _hashCode += (isSecondSigned() ? Boolean.TRUE : Boolean.FALSE).hashCode();
        if (getStatus() != null) {
            _hashCode += getStatus().hashCode();
        }
        if (getSumma() != null) {
            _hashCode += getSumma().hashCode();
        }
        _hashCode += (isThirdSigned() ? Boolean.TRUE : Boolean.FALSE).hashCode();
        if (getType() != null) {
            _hashCode += getType().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(DocHeader.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://doc.ent.psbank.ru", "DocHeader"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("bankWorkId");
        elemField.setXmlName(new javax.xml.namespace.QName("", "bankWorkId"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "long"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("date");
        elemField.setXmlName(new javax.xml.namespace.QName("", "date"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "dateTime"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("firstSigned");
        elemField.setXmlName(new javax.xml.namespace.QName("", "firstSigned"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "boolean"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("id");
        elemField.setXmlName(new javax.xml.namespace.QName("", "id"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "long"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("numberDoc");
        elemField.setXmlName(new javax.xml.namespace.QName("", "numberDoc"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("reciever");
        elemField.setXmlName(new javax.xml.namespace.QName("", "reciever"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("secondSigned");
        elemField.setXmlName(new javax.xml.namespace.QName("", "secondSigned"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "boolean"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("status");
        elemField.setXmlName(new javax.xml.namespace.QName("", "status"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://doc.ent.psbank.ru", "DocStatus"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("summa");
        elemField.setXmlName(new javax.xml.namespace.QName("", "summa"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "decimal"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("thirdSigned");
        elemField.setXmlName(new javax.xml.namespace.QName("", "thirdSigned"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "boolean"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("type");
        elemField.setXmlName(new javax.xml.namespace.QName("", "type"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://doc.ent.psbank.ru", "DocType"));
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
