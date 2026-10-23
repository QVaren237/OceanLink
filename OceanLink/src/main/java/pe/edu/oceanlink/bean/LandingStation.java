package pe.edu.oceanlink.bean;

public class LandingStation {
    private int idLandingStation;
    private String codigo;
    private String nombre;
    private String ubicacion;
    private String estado;
    private String descripcion;

    public LandingStation() {}

    public int getIdLandingStation() { return idLandingStation; }
    public void setIdLandingStation(int idLandingStation) { this.idLandingStation = idLandingStation; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String ubicacion) { this.ubicacion = ubicacion; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
}
