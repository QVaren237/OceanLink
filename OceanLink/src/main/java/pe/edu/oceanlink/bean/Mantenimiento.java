package pe.edu.oceanlink.bean;

public class Mantenimiento {
    private int idMantenimiento;
    public int getIdMantenimiento(){return idMantenimiento;}
    public void setIdMantenimiento(int valor){idMantenimiento=valor;}
    private String codigo;
    public String getCodigo(){return codigo;}
    public void setCodigo(String valor){codigo=valor;}
    private String tipo;
    public String getTipo(){return tipo;}
    public void setTipo(String valor){tipo=valor;}
    private String titulo;
    public String getTitulo(){return titulo;}
    public void setTitulo(String valor){titulo=valor;}
    private String descripcion;
    public String getDescripcion(){return descripcion;}
    public void setDescripcion(String valor){descripcion=valor;}
    private Integer idIncidencia;
    public Integer getIdIncidencia(){return idIncidencia;}
    public void setIdIncidencia(Integer valor){idIncidencia=valor;}
    private Integer idSegmento;
    public Integer getIdSegmento(){return idSegmento;}
    public void setIdSegmento(Integer valor){idSegmento=valor;}
    private Integer idLandingStation;
    public Integer getIdLandingStation(){return idLandingStation;}
    public void setIdLandingStation(Integer valor){idLandingStation=valor;}
    private java.sql.Timestamp fechaInicio;
    public java.sql.Timestamp getFechaInicio(){return fechaInicio;}
    public void setFechaInicio(java.sql.Timestamp valor){fechaInicio=valor;}
    private java.sql.Timestamp fechaFin;
    public java.sql.Timestamp getFechaFin(){return fechaFin;}
    public void setFechaFin(java.sql.Timestamp valor){fechaFin=valor;}
    private java.math.BigDecimal duracionEstimada;
    public java.math.BigDecimal getDuracionEstimada(){return duracionEstimada;}
    public void setDuracionEstimada(java.math.BigDecimal valor){duracionEstimada=valor;}
    private String estado;
    public String getEstado(){return estado;}
    public void setEstado(String valor){estado=valor;}
    private String actividades;
    public String getActividades(){return actividades;}
    public void setActividades(String valor){actividades=valor;}
    private String resultado;
    public String getResultado(){return resultado;}
    public void setResultado(String valor){resultado=valor;}
    private int idUsuario;
    public int getIdUsuario(){return idUsuario;}
    public void setIdUsuario(int valor){idUsuario=valor;}
    private String responsable;
    public String getResponsable(){return responsable;}
    public void setResponsable(String valor){responsable=valor;}
    private String infraestructuraCodigo;
    public String getInfraestructuraCodigo(){return infraestructuraCodigo;}
    public void setInfraestructuraCodigo(String valor){infraestructuraCodigo=valor;}
    private String infraestructuraNombre;
    public String getInfraestructuraNombre(){return infraestructuraNombre;}
    public void setInfraestructuraNombre(String valor){infraestructuraNombre=valor;}
    private String incidenciaCodigo;
    public String getIncidenciaCodigo(){return incidenciaCodigo;}
    public void setIncidenciaCodigo(String valor){incidenciaCodigo=valor;}
    public boolean isFinalizado(){return "Finalizado".equals(estado);}
}
