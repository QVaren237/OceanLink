package pe.edu.oceanlink.bean;

import java.math.BigDecimal;
 // vamos con la clases
public class CapacidadServicio {
    private int idServicio;
    private int idCliente;
    private String codigo;
    private String cliente;
    private String ruc;
    private String ruta;
    private String estado;
    private BigDecimal capacidadContratada;
    public int getIdServicio() { return idServicio; }
    public void setIdServicio(int valor) { idServicio = valor; }
    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int valor) { idCliente = valor; }
    public String getCodigo() { return codigo; }
    public void setCodigo(String valor) { codigo = valor; }
    public String getCliente() { return cliente; }
    public void setCliente(String valor) { cliente = valor; }
    public String getRuc() { return ruc; }
    public void setRuc(String valor) { ruc = valor; }
    public String getRuta() { return ruta; }
    public void setRuta(String valor) { ruta = valor; }
    public String getEstado() { return estado; }
    public void setEstado(String valor) { estado = valor; }
    public BigDecimal getCapacidadContratada() { return capacidadContratada; }
    public void setCapacidadContratada(BigDecimal valor) { capacidadContratada = valor; }
    public String getIniciales() {
        StringBuilder iniciales = new StringBuilder();
        if (cliente != null) for (String parte : cliente.trim().split("\\s+")) {
            if (!parte.isEmpty() && iniciales.length() < 2) iniciales.append(parte.substring(0,1).toUpperCase(java.util.Locale.ROOT));
        }
        return iniciales.toString();
    }
}
