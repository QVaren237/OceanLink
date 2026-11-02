package pe.edu.oceanlink.bean;

public class Segmento {
    private int idSegmento;
    private String codigo;
    private int idEstacionOrigen;
    private int idEstacionDestino;
    private double capacidadTotal;
    private double capacidadUtilizada;
    private double capacidadReservada;
    private double longitudKm;
    private String estado;
    private String descripcion;
    // Se llenan con el JOIN para mostrarlos en la tabla
    private String nombreOrigen;
    private String nombreDestino;

    public Segmento() {}

    public int getIdSegmento() { return idSegmento; }
    public void setIdSegmento(int idSegmento) { this.idSegmento = idSegmento; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public int getIdEstacionOrigen() { return idEstacionOrigen; }
    public void setIdEstacionOrigen(int idEstacionOrigen) { this.idEstacionOrigen = idEstacionOrigen; }

    public int getIdEstacionDestino() { return idEstacionDestino; }
    public void setIdEstacionDestino(int idEstacionDestino) { this.idEstacionDestino = idEstacionDestino; }

    public double getCapacidadTotal() { return capacidadTotal; }
    public void setCapacidadTotal(double capacidadTotal) { this.capacidadTotal = capacidadTotal; }

    public double getCapacidadUtilizada() { return capacidadUtilizada; }
    public void setCapacidadUtilizada(double capacidadUtilizada) { this.capacidadUtilizada = capacidadUtilizada; }

    public double getCapacidadReservada() { return capacidadReservada; }
    public void setCapacidadReservada(double capacidadReservada) { this.capacidadReservada = capacidadReservada; }

    public double getLongitudKm() { return longitudKm; }
    public void setLongitudKm(double longitudKm) { this.longitudKm = longitudKm; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getNombreOrigen() { return nombreOrigen; }
    public void setNombreOrigen(String nombreOrigen) { this.nombreOrigen = nombreOrigen; }

    public String getNombreDestino() { return nombreDestino; }
    public void setNombreDestino(String nombreDestino) { this.nombreDestino = nombreDestino; }

    // Capacidad disponible = total - utilizada - reservada (calculada, no se guarda)
    public double getCapacidadDisponible() {
        return capacidadTotal - capacidadUtilizada - capacidadReservada;
    }
}
