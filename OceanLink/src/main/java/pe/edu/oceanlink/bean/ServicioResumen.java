package pe.edu.oceanlink.bean;

import java.math.BigDecimal;
import java.util.Locale;

// Datos del JOIN cliente-servicio-segmento que se muestran en el panel.
public class ServicioResumen {
    private int idCliente;
    private String razonSocial;
    private String codigoServicio;
    private String codigoSegmento;
    private String nombreOrigen;
    private String nombreDestino;
    private BigDecimal capacidadContratada;
    private String estado;

    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int valor) { idCliente = valor; }
    public String getRazonSocial() { return razonSocial; }
    public void setRazonSocial(String valor) { razonSocial = valor; }
    public String getCodigoServicio() { return codigoServicio; }
    public void setCodigoServicio(String valor) { codigoServicio = valor; }
    public String getCodigoSegmento() { return codigoSegmento; }
    public void setCodigoSegmento(String valor) { codigoSegmento = valor; }
    public String getNombreOrigen() { return nombreOrigen; }
    public void setNombreOrigen(String valor) { nombreOrigen = valor; }
    public String getNombreDestino() { return nombreDestino; }
    public void setNombreDestino(String valor) { nombreDestino = valor; }
    public BigDecimal getCapacidadContratada() { return capacidadContratada; }
    public void setCapacidadContratada(BigDecimal valor) { capacidadContratada = valor; }
    public String getEstado() { return estado; }
    public void setEstado(String valor) { estado = valor; }

    public String getIniciales() {
        String iniciales = "";
        if (razonSocial != null) {
            for (String parte : razonSocial.trim().split("\\s+")) {
                if (!parte.isEmpty() && iniciales.length() < 2) iniciales += parte.substring(0, 1);
            }
        }
        return iniciales.toUpperCase(Locale.ROOT);
    }

    public String getEnlace() {
        return codigoSegmento == null ? "Sin segmentos asignados" : nombreOrigen + " - " + nombreDestino + " (" + codigoSegmento + ")";
    }
}
