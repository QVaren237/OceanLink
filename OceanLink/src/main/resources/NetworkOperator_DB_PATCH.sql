-- Ejecutar una sola vez en MySQL Workbench después de importar OceanLink_DB_FIXED.sql
USE oceanlink;

-- Permite que MySQL asigne el ID de cada incidencia.
ALTER TABLE incidencia
  MODIFY COLUMN idIncidencia INT NOT NULL AUTO_INCREMENT;

-- Las observaciones son registros independientes para no sobrescribir la descripción original.
CREATE TABLE IF NOT EXISTS incidencia_observacion (
  idObservacion INT NOT NULL AUTO_INCREMENT,
  idIncidencia INT NOT NULL,
  idUsuario INT NOT NULL,
  tipo VARCHAR(30) NOT NULL DEFAULT 'Observación',
  observacion TEXT NOT NULL,
  fechaRegistro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (idObservacion),
  INDEX fk_io_incidencia (idIncidencia),
  INDEX fk_io_usuario (idUsuario),
  CONSTRAINT fk_io_incidencia FOREIGN KEY (idIncidencia)
    REFERENCES incidencia (idIncidencia),
  CONSTRAINT fk_io_usuario FOREIGN KEY (idUsuario)
    REFERENCES usuario (idUsuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
