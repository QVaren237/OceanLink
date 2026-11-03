package pe.edu.oceanlink.bean;

import java.math.BigDecimal;
/** Cliente y servicio asociados a un segmento afectado. */
public class SupervisorAfectado {
    private String empresa, servicio, contacto;
    private BigDecimal capacidad;
    public String getEmpresa(){return empresa;}
    public void setEmpresa(String v){empresa=v;}
    public String getServicio(){return servicio;}
    public void setServicio(String v){servicio=v;}
    public String getContacto(){return contacto;}
    public void setContacto(String v){contacto=v;}
    public BigDecimal getCapacidad(){return capacidad;}
    public void setCapacidad(BigDecimal v){capacidad=v;}
}
