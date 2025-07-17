/**
 * Exctract.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package ru.psbank.ent.doc;

public class Exctract  implements java.io.Serializable {

    private String account;

    private String accountDescription;

    private String bankName;

    private java.math.BigDecimal conversionIn;

    private java.math.BigDecimal conversionOut;

    private String currency;

    private boolean debit;

    private ExtractRow[] exctractRows;

    private java.util.Calendar from;

    private java.math.BigDecimal inSaldo;

    private java.util.Calendar saldoInDate;

    private java.util.Calendar to;

    public Exctract() {
    }

    public Exctract(
           String account,
           String accountDescription,
           String bankName,
           java.math.BigDecimal conversionIn,
           java.math.BigDecimal conversionOut,
           String currency,
           boolean debit,
           ExtractRow[] exctractRows,
           java.util.Calendar from,
           java.math.BigDecimal inSaldo,
           java.util.Calendar saldoInDate,
           java.util.Calendar to) {
           this.account = account;
           this.accountDescription = accountDescription;
           this.bankName = bankName;
           this.conversionIn = conversionIn;
           this.conversionOut = conversionOut;
           this.currency = currency;
           this.debit = debit;
           this.exctractRows = exctractRows;
           this.from = from;
           this.inSaldo = inSaldo;
           this.saldoInDate = saldoInDate;
           this.to = to;
    }


    /**
     * Gets the account value for this Exctract.
     * 
     * @return account
     */
    public String getAccount() {
        return account;
    }


    /**
     * Sets the account value for this Exctract.
     * 
     * @param account
     */
    public void setAccount(String account) {
        this.account = account;
    }


    /**
     * Gets the accountDescription value for this Exctract.
     * 
     * @return accountDescription
     */
    public String getAccountDescription() {
        return accountDescription;
    }


    /**
     * Sets the accountDescription value for this Exctract.
     * 
     * @param accountDescription
     */
    public void setAccountDescription(String accountDescription) {
        this.accountDescription = accountDescription;
    }


    /**
     * Gets the bankName value for this Exctract.
     * 
     * @return bankName
     */
    public String getBankName() {
        return bankName;
    }


    /**
     * Sets the bankName value for this Exctract.
     * 
     * @param bankName
     */
    public void setBankName(String bankName) {
        this.bankName = bankName;
    }


    /**
     * Gets the conversionIn value for this Exctract.
     * 
     * @return conversionIn
     */
    public java.math.BigDecimal getConversionIn() {
        return conversionIn;
    }


    /**
     * Sets the conversionIn value for this Exctract.
     * 
     * @param conversionIn
     */
    public void setConversionIn(java.math.BigDecimal conversionIn) {
        this.conversionIn = conversionIn;
    }


    /**
     * Gets the conversionOut value for this Exctract.
     * 
     * @return conversionOut
     */
    public java.math.BigDecimal getConversionOut() {
        return conversionOut;
    }


    /**
     * Sets the conversionOut value for this Exctract.
     * 
     * @param conversionOut
     */
    public void setConversionOut(java.math.BigDecimal conversionOut) {
        this.conversionOut = conversionOut;
    }


    /**
     * Gets the currency value for this Exctract.
     * 
     * @return currency
     */
    public String getCurrency() {
        return currency;
    }


    /**
     * Sets the currency value for this Exctract.
     * 
     * @param currency
     */
    public void setCurrency(String currency) {
        this.currency = currency;
    }


    /**
     * Gets the debit value for this Exctract.
     * 
     * @return debit
     */
    public boolean isDebit() {
        return debit;
    }


    /**
     * Sets the debit value for this Exctract.
     * 
     * @param debit
     */
    public void setDebit(boolean debit) {
        this.debit = debit;
    }


    /**
     * Gets the exctractRows value for this Exctract.
     * 
     * @return exctractRows
     */
    public ExtractRow[] getExctractRows() {
        return exctractRows;
    }


    /**
     * Sets the exctractRows value for this Exctract.
     * 
     * @param exctractRows
     */
    public void setExctractRows(ExtractRow[] exctractRows) {
        this.exctractRows = exctractRows;
    }


    /**
     * Gets the from value for this Exctract.
     * 
     * @return from
     */
    public java.util.Calendar getFrom() {
        return from;
    }


    /**
     * Sets the from value for this Exctract.
     * 
     * @param from
     */
    public void setFrom(java.util.Calendar from) {
        this.from = from;
    }


    /**
     * Gets the inSaldo value for this Exctract.
     * 
     * @return inSaldo
     */
    public java.math.BigDecimal getInSaldo() {
        return inSaldo;
    }


    /**
     * Sets the inSaldo value for this Exctract.
     * 
     * @param inSaldo
     */
    public void setInSaldo(java.math.BigDecimal inSaldo) {
        this.inSaldo = inSaldo;
    }


    /**
     * Gets the saldoInDate value for this Exctract.
     * 
     * @return saldoInDate
     */
    public java.util.Calendar getSaldoInDate() {
        return saldoInDate;
    }


    /**
     * Sets the saldoInDate value for this Exctract.
     * 
     * @param saldoInDate
     */
    public void setSaldoInDate(java.util.Calendar saldoInDate) {
        this.saldoInDate = saldoInDate;
    }


    /**
     * Gets the to value for this Exctract.
     * 
     * @return to
     */
    public java.util.Calendar getTo() {
        return to;
    }


    /**
     * Sets the to value for this Exctract.
     * 
     * @param to
     */
    public void setTo(java.util.Calendar to) {
        this.to = to;
    }

    private Object __equalsCalc = null;
    public synchronized boolean equals(Object obj) {
        if (!(obj instanceof Exctract)) return false;
        Exctract other = (Exctract) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.account==null && other.getAccount()==null) || 
             (this.account!=null &&
              this.account.equals(other.getAccount()))) &&
            ((this.accountDescription==null && other.getAccountDescription()==null) || 
             (this.accountDescription!=null &&
              this.accountDescription.equals(other.getAccountDescription()))) &&
            ((this.bankName==null && other.getBankName()==null) || 
             (this.bankName!=null &&
              this.bankName.equals(other.getBankName()))) &&
            ((this.conversionIn==null && other.getConversionIn()==null) || 
             (this.conversionIn!=null &&
              this.conversionIn.equals(other.getConversionIn()))) &&
            ((this.conversionOut==null && other.getConversionOut()==null) || 
             (this.conversionOut!=null &&
              this.conversionOut.equals(other.getConversionOut()))) &&
            ((this.currency==null && other.getCurrency()==null) || 
             (this.currency!=null &&
              this.currency.equals(other.getCurrency()))) &&
            this.debit == other.isDebit() &&
            ((this.exctractRows==null && other.getExctractRows()==null) || 
             (this.exctractRows!=null &&
              java.util.Arrays.equals(this.exctractRows, other.getExctractRows()))) &&
            ((this.from==null && other.getFrom()==null) || 
             (this.from!=null &&
              this.from.equals(other.getFrom()))) &&
            ((this.inSaldo==null && other.getInSaldo()==null) || 
             (this.inSaldo!=null &&
              this.inSaldo.equals(other.getInSaldo()))) &&
            ((this.saldoInDate==null && other.getSaldoInDate()==null) || 
             (this.saldoInDate!=null &&
              this.saldoInDate.equals(other.getSaldoInDate()))) &&
            ((this.to==null && other.getTo()==null) || 
             (this.to!=null &&
              this.to.equals(other.getTo())));
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
        if (getAccount() != null) {
            _hashCode += getAccount().hashCode();
        }
        if (getAccountDescription() != null) {
            _hashCode += getAccountDescription().hashCode();
        }
        if (getBankName() != null) {
            _hashCode += getBankName().hashCode();
        }
        if (getConversionIn() != null) {
            _hashCode += getConversionIn().hashCode();
        }
        if (getConversionOut() != null) {
            _hashCode += getConversionOut().hashCode();
        }
        if (getCurrency() != null) {
            _hashCode += getCurrency().hashCode();
        }
        _hashCode += (isDebit() ? Boolean.TRUE : Boolean.FALSE).hashCode();
        if (getExctractRows() != null) {
            for (int i=0;
                 i<java.lang.reflect.Array.getLength(getExctractRows());
                 i++) {
                Object obj = java.lang.reflect.Array.get(getExctractRows(), i);
                if (obj != null &&
                    !obj.getClass().isArray()) {
                    _hashCode += obj.hashCode();
                }
            }
        }
        if (getFrom() != null) {
            _hashCode += getFrom().hashCode();
        }
        if (getInSaldo() != null) {
            _hashCode += getInSaldo().hashCode();
        }
        if (getSaldoInDate() != null) {
            _hashCode += getSaldoInDate().hashCode();
        }
        if (getTo() != null) {
            _hashCode += getTo().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(Exctract.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://doc.ent.psbank.ru", "Exctract"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("account");
        elemField.setXmlName(new javax.xml.namespace.QName("", "account"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("accountDescription");
        elemField.setXmlName(new javax.xml.namespace.QName("", "accountDescription"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("bankName");
        elemField.setXmlName(new javax.xml.namespace.QName("", "bankName"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("conversionIn");
        elemField.setXmlName(new javax.xml.namespace.QName("", "conversionIn"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "decimal"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("conversionOut");
        elemField.setXmlName(new javax.xml.namespace.QName("", "conversionOut"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "decimal"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("currency");
        elemField.setXmlName(new javax.xml.namespace.QName("", "currency"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("debit");
        elemField.setXmlName(new javax.xml.namespace.QName("", "debit"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "boolean"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("exctractRows");
        elemField.setXmlName(new javax.xml.namespace.QName("", "exctractRows"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://doc.ent.psbank.ru", "ExtractRow"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("from");
        elemField.setXmlName(new javax.xml.namespace.QName("", "from"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "dateTime"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("inSaldo");
        elemField.setXmlName(new javax.xml.namespace.QName("", "inSaldo"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "decimal"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("saldoInDate");
        elemField.setXmlName(new javax.xml.namespace.QName("", "saldoInDate"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "dateTime"));
        elemField.setNillable(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("to");
        elemField.setXmlName(new javax.xml.namespace.QName("", "to"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "dateTime"));
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
