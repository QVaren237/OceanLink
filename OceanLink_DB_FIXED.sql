-- ============================================================
-- OCEANLINK: BASE DE DATOS + DATOS DE PRUEBA
-- ============================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `oceanlink` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci ;
USE `oceanlink` ;

-- Table `oceanlink`.`cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`cliente` (
  `idCliente` INT NOT NULL AUTO_INCREMENT,
  `razonSocial` VARCHAR(100) NOT NULL,
  `ruc` CHAR(11) NOT NULL,
  `telefono` VARCHAR(20) NULL DEFAULT NULL,
  `correo` VARCHAR(100) NULL DEFAULT NULL,
  `direccion` VARCHAR(200) NULL DEFAULT NULL,
  `contacto` VARCHAR(100) NULL DEFAULT NULL,
  `estado` VARCHAR(20) NULL DEFAULT NULL,
  PRIMARY KEY (`idCliente`),
  UNIQUE INDEX `ruc` (`ruc` ASC) VISIBLE)
ENGINE = InnoDB -- Este apartado indica el motor de almacenamiento que usará la table, que permitirá con claves foráneas. Es recomendable eliminar este apartado
DEFAULT CHARACTER SET = utf8mb4 -- Permitirá almancenar tildes, la letra ñ, etc
COLLATE = utf8mb4_spanish_ci; -- permitirá comprar con palabras mayusculas y minusculas (textos en español)


-- -----------------------------------------------------
-- Table `oceanlink`.`landing_station`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`landing_station` (
  `idLandingStation` INT NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(30) NOT NULL,
  `nombre` VARCHAR(50) NOT NULL,
  `ubicacion` VARCHAR(150) NOT NULL,
  `estado` VARCHAR(30) NOT NULL,
  `descripcion` VARCHAR(255) NULL,
  PRIMARY KEY (`idLandingStation`),
  UNIQUE INDEX `codigo` (`codigo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`segmento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`segmento` (
  `idSegmento` INT NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(30) NOT NULL,
  `idEstacionOrigen` INT NOT NULL,
  `idEstacionDestino` INT NOT NULL,
  `capacidadTotal` DECIMAL(12,2) NULL DEFAULT NULL,
  `capacidadUtilizada` DECIMAL(12,2) NULL DEFAULT NULL,
  `capacidadReservada` DECIMAL(12,2) NULL DEFAULT NULL,
  `longitudKm` DECIMAL(10,2) NULL DEFAULT NULL,
  `estado` VARCHAR(30) NULL DEFAULT NULL,
  `descripcion` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`idSegmento`),
  UNIQUE INDEX `codigo` (`codigo` ASC) VISIBLE,
  INDEX `fk_segmento_origen` (`idEstacionOrigen` ASC) VISIBLE,
  INDEX `fk_segmento_destino` (`idEstacionDestino` ASC) VISIBLE,
  CONSTRAINT `fk_segmento_destino`
    FOREIGN KEY (`idEstacionDestino`)
    REFERENCES `oceanlink`.`landing_station` (`idLandingStation`),
  CONSTRAINT `fk_segmento_origen`
    FOREIGN KEY (`idEstacionOrigen`)
    REFERENCES `oceanlink`.`landing_station` (`idLandingStation`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`historial_capacidad`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`historial_capacidad` (
  `idHistorial` INT NOT NULL AUTO_INCREMENT,
  `idSegmento` INT NOT NULL,
  `fechaRegistro` DATETIME NULL DEFAULT NULL,
  `capacidadTotal` DECIMAL(12,2) NULL DEFAULT NULL,
  `capacidadUtilizada` DECIMAL(12,2) NULL DEFAULT NULL,
  `capacidadReservada` DECIMAL(12,2) NULL DEFAULT NULL,
  `capacidadDisponible` DECIMAL(12,2) NULL DEFAULT NULL,
  `porcentajeUtilizacion` DECIMAL(5,2) NULL DEFAULT NULL,
  PRIMARY KEY (`idHistorial`),
  INDEX `fk_hist_segmento` (`idSegmento` ASC) VISIBLE,
  CONSTRAINT `fk_hist_segmento`
    FOREIGN KEY (`idSegmento`)
    REFERENCES `oceanlink`.`segmento` (`idSegmento`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`rol`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`rol` (
  `idRol` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`idRol`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`usuario` (
  `idUsuario` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(50) NOT NULL,
  `apellido` VARCHAR(50) NOT NULL,
  `correo` VARCHAR(50) NOT NULL,
  `password` VARCHAR(256) NOT NULL,
  `estado` VARCHAR(20) NULL DEFAULT NULL,
  `idRol` INT NOT NULL,
  `foto` LONGBLOB NULL, 
  PRIMARY KEY (`idUsuario`),
  UNIQUE INDEX `correo` (`correo` ASC) VISIBLE,
  INDEX `fk_usuario_rol` (`idRol` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_rol`
    FOREIGN KEY (`idRol`)
    REFERENCES `oceanlink`.`rol` (`idRol`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`incidencia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`incidencia` (
  `idIncidencia` INT NOT NULL,
  `codigo` VARCHAR(30) NOT NULL,
  `titulo` VARCHAR(150) NOT NULL,
  `descripcion` TEXT NULL DEFAULT NULL,
  `severidad` VARCHAR(20) NULL DEFAULT NULL,
  `estado` VARCHAR(40) NULL DEFAULT NULL,
  `fechaDeteccion` DATETIME NULL DEFAULT NULL,
  `fechaCierre` DATETIME NULL DEFAULT NULL,
  `idUsuario` INT NOT NULL,
  PRIMARY KEY (`idIncidencia`),
  UNIQUE INDEX `codigo` (`codigo` ASC) VISIBLE,
  INDEX `fk_incidencia_usuario` (`idUsuario` ASC) VISIBLE,
  CONSTRAINT `fk_incidencia_usuario`
    FOREIGN KEY (`idUsuario`)
    REFERENCES `oceanlink`.`usuario` (`idUsuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`incidencia_segmento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`incidencia_segmento` (
  `idIncidencia` INT NOT NULL,
  `idSegmento` INT NOT NULL,
  PRIMARY KEY (`idIncidencia`, `idSegmento`),
  INDEX `fk_is_segmento` (`idSegmento` ASC) VISIBLE,
  CONSTRAINT `fk_is_incidencia`
    FOREIGN KEY (`idIncidencia`)
    REFERENCES `oceanlink`.`incidencia` (`idIncidencia`),
  CONSTRAINT `fk_is_segmento`
    FOREIGN KEY (`idSegmento`)
    REFERENCES `oceanlink`.`segmento` (`idSegmento`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`mantenimiento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`mantenimiento` (
  `idMantenimiento` INT NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(30) NOT NULL,
  `tipo` VARCHAR(20) NULL DEFAULT NULL,
  `idIncidencia` INT NULL DEFAULT NULL,
  `idSegmento` INT NULL DEFAULT NULL,
  `idLandingStation` INT NULL DEFAULT NULL,
  `fechaInicio` DATETIME NULL DEFAULT NULL,
  `duracionEstimada` DECIMAL(5,2) NULL DEFAULT NULL,
  `estado` VARCHAR(30) NULL DEFAULT NULL,
  `actividades` TEXT NULL DEFAULT NULL,
  `resultado` TEXT NULL DEFAULT NULL,
  `idUsuario` INT NOT NULL,
  PRIMARY KEY (`idMantenimiento`),
  UNIQUE INDEX `codigo` (`codigo` ASC) VISIBLE,
  INDEX `fk_mant_incidencia` (`idIncidencia` ASC) VISIBLE,
  INDEX `fk_mant_segmento` (`idSegmento` ASC) VISIBLE,
  INDEX `fk_mant_landing` (`idLandingStation` ASC) VISIBLE,
  INDEX `fk_mant_usuario` (`idUsuario` ASC) VISIBLE,
  CONSTRAINT `fk_mant_incidencia`
    FOREIGN KEY (`idIncidencia`)
    REFERENCES `oceanlink`.`incidencia` (`idIncidencia`),
  CONSTRAINT `fk_mant_landing`
    FOREIGN KEY (`idLandingStation`)
    REFERENCES `oceanlink`.`landing_station` (`idLandingStation`),
  CONSTRAINT `fk_mant_segmento`
    FOREIGN KEY (`idSegmento`)
    REFERENCES `oceanlink`.`segmento` (`idSegmento`),
  CONSTRAINT `fk_mant_usuario`
    FOREIGN KEY (`idUsuario`)
    REFERENCES `oceanlink`.`usuario` (`idUsuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`mantenimiento_segmento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`mantenimiento_segmento` (
  `idMantenimiento` INT NOT NULL,
  `idSegmento` INT NOT NULL,
  PRIMARY KEY (`idMantenimiento`, `idSegmento`),
  INDEX `fk_ms_segmento` (`idSegmento` ASC) VISIBLE,
  CONSTRAINT `fk_ms_mantenimiento`
    FOREIGN KEY (`idMantenimiento`)
    REFERENCES `oceanlink`.`mantenimiento` (`idMantenimiento`),
  CONSTRAINT `fk_ms_segmento`
    FOREIGN KEY (`idSegmento`)
    REFERENCES `oceanlink`.`segmento` (`idSegmento`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`ruta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`ruta` (
  `idRuta` INT NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(30) NOT NULL,
  `nombre` VARCHAR(100) NOT NULL,
  `idEstacionOrigen` INT NOT NULL,
  `idEstacionDestino` INT NOT NULL,
  `estado` VARCHAR(30) NULL DEFAULT NULL,
  `descripcion` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`idRuta`),
  UNIQUE INDEX `codigo` (`codigo` ASC) VISIBLE,
  INDEX `fk_ruta_origen` (`idEstacionOrigen` ASC) VISIBLE,
  INDEX `fk_ruta_destino` (`idEstacionDestino` ASC) VISIBLE,
  CONSTRAINT `fk_ruta_destino`
    FOREIGN KEY (`idEstacionDestino`)
    REFERENCES `oceanlink`.`landing_station` (`idLandingStation`),
  CONSTRAINT `fk_ruta_origen`
    FOREIGN KEY (`idEstacionOrigen`)
    REFERENCES `oceanlink`.`landing_station` (`idLandingStation`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`servicio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`servicio` (
  `idServicio` INT NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(30) NOT NULL,
  `idCliente` INT NOT NULL,
  `idRuta` INT NOT NULL,
  `origen` VARCHAR(100) NOT NULL,
  `destino` VARCHAR(100) NOT NULL,
  `capacidadContratada` DECIMAL(12,2) NOT NULL,
  `fechaActivacion` DATE NOT NULL,
  `estado` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`idServicio`),
  UNIQUE INDEX `codigo` (`codigo` ASC) VISIBLE,
  INDEX `fk_servicio_cliente` (`idCliente` ASC) VISIBLE,
  INDEX `fk_servicio_ruta` (`idRuta` ASC) VISIBLE,
  CONSTRAINT `fk_servicio_cliente`
    FOREIGN KEY (`idCliente`)
    REFERENCES `oceanlink`.`cliente` (`idCliente`),
  CONSTRAINT `fk_servicio_ruta`
    FOREIGN KEY (`idRuta`)
    REFERENCES `oceanlink`.`ruta` (`idRuta`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`solicitud`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`solicitud` (
  `idSolicitud` INT NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(30) NOT NULL,
  `idCliente` INT NOT NULL,
  `idRuta` INT NOT NULL,
  `capacidadSolicitada` DECIMAL(12,2) NULL DEFAULT NULL,
  `fechaSolicitud` DATE NULL DEFAULT NULL,
  `fechaLimite` DATE NULL DEFAULT NULL,
  `motivo` VARCHAR(255) NULL DEFAULT NULL,
  `estado` VARCHAR(30) NULL DEFAULT NULL,
  `observacion` VARCHAR(255) NULL DEFAULT NULL,
  `idUsuario` INT NOT NULL,
  PRIMARY KEY (`idSolicitud`),
  UNIQUE INDEX `codigo` (`codigo` ASC) VISIBLE,
  INDEX `fk_solicitud_cliente` (`idCliente` ASC) VISIBLE,
  INDEX `fk_solicitud_ruta` (`idRuta` ASC) VISIBLE,
  INDEX `fk_solicitud_usuario` (`idUsuario` ASC) VISIBLE,
  CONSTRAINT `fk_solicitud_cliente`
    FOREIGN KEY (`idCliente`)
    REFERENCES `oceanlink`.`cliente` (`idCliente`),
  CONSTRAINT `fk_solicitud_ruta`
    FOREIGN KEY (`idRuta`)
    REFERENCES `oceanlink`.`ruta` (`idRuta`),
  CONSTRAINT `fk_solicitud_usuario`
    FOREIGN KEY (`idUsuario`)
    REFERENCES `oceanlink`.`usuario` (`idUsuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`reserva_capacidad`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`reserva_capacidad` (
  `idReserva` INT NOT NULL AUTO_INCREMENT,
  `idSolicitud` INT NOT NULL,
  `idSegmento` INT NOT NULL,
  `idServicio` INT NOT NULL,
  `capacidadReservada` DECIMAL(12,2) NOT NULL,
  `fechaReserva` DATE NULL DEFAULT NULL,
  `estado` VARCHAR(30) NULL DEFAULT NULL,
  `idUsuario` INT NOT NULL,
  PRIMARY KEY (`idReserva`),
  INDEX `fk_reserva_solicitud` (`idSolicitud` ASC) VISIBLE,
  INDEX `fk_reserva_segmento` (`idSegmento` ASC) VISIBLE,
  INDEX `fk_reserva_servicio` (`idServicio` ASC) VISIBLE,
  INDEX `fk_reserva_usuario` (`idUsuario` ASC) VISIBLE,
  CONSTRAINT `fk_reserva_segmento`
    FOREIGN KEY (`idSegmento`)
    REFERENCES `oceanlink`.`segmento` (`idSegmento`),
  CONSTRAINT `fk_reserva_servicio`
    FOREIGN KEY (`idServicio`)
    REFERENCES `oceanlink`.`servicio` (`idServicio`),
  CONSTRAINT `fk_reserva_solicitud`
    FOREIGN KEY (`idSolicitud`)
    REFERENCES `oceanlink`.`solicitud` (`idSolicitud`),
  CONSTRAINT `fk_reserva_usuario`
    FOREIGN KEY (`idUsuario`)
    REFERENCES `oceanlink`.`usuario` (`idUsuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


-- -----------------------------------------------------
-- Table `oceanlink`.`ruta_segmento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `oceanlink`.`ruta_segmento` (
  `idRuta` INT NOT NULL,
  `idSegmento` INT NOT NULL,
  `orden` INT NULL DEFAULT NULL,
  `capacidadRuta` DECIMAL(12,2) NULL DEFAULT NULL,
  PRIMARY KEY (`idRuta`, `idSegmento`),
  INDEX `fk_rs_segmento` (`idSegmento` ASC) VISIBLE,
  CONSTRAINT `fk_rs_ruta`
    FOREIGN KEY (`idRuta`)
    REFERENCES `oceanlink`.`ruta` (`idRuta`),
  CONSTRAINT `fk_rs_segmento`
    FOREIGN KEY (`idSegmento`)
    REFERENCES `oceanlink`.`segmento` (`idSegmento`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_spanish_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- ============================================================
-- DATOS FICTICIOS DE PRUEBA
-- INSERT IGNORE evita errores por claves ya existentes.
-- ============================================================

USE oceanlink;
SET FOREIGN_KEY_CHECKS = 0;

-- Vaciar tablas en orden inverso de dependencia para poder volver a ejecutar el script.

SET FOREIGN_KEY_CHECKS = 1;

-- Roles
INSERT IGNORE INTO rol (idRol, nombre) VALUES
(1, 'Administrador'),
(2, 'Capacity Planner'),
(3, 'Network Operator'),
(4, 'Maintenance Coordinator'),
(5, 'Supervisor');

-- Usuarios de prueba. La contraseña es ficticia y no está destinada a autenticación real.
INSERT IGNORE INTO usuario (idUsuario, nombre, apellido, correo, password, estado, idRol, foto) VALUES
(1, 'Lucía', 'Ramos', 'lucia.ramos@oceanlink.test', 'demo_hash_admin', 'Activo', 1, NULL),
(2, 'Mateo', 'Vargas', 'mateo.vargas@oceanlink.test', 'demo_hash_capacity', 'Activo', 2, NULL),
(3, 'Camila', 'Torres', 'camila.torres@oceanlink.test', 'demo_hash_operator', 'Activo', 3, NULL),
(4, 'Diego', 'Salazar', 'diego.salazar@oceanlink.test', 'demo_hash_mantenimiento', 'Activo', 4, NULL),
(5, 'Valeria', 'Paredes', 'valeria.paredes@oceanlink.test', 'demo_hash_supervisor', 'Activo', 5, NULL),
(6, 'Andrés', 'León', 'andres.leon@oceanlink.test', 'demo_hash_operator2', 'Activo', 3, NULL);

-- Clientes empresariales ficticios
INSERT IGNORE INTO cliente (idCliente, razonSocial, ruc, telefono, correo, direccion, contacto, estado) VALUES
(1, 'Andes Data S.A.C.', '20123456781', '+51 1 555 0101', 'contacto@andesdata.test', 'Av. Javier Prado 1200, Lima, Perú', 'María Cárdenas', 'Activo'),
(2, 'Pacífico Cloud Perú S.A.C.', '20123456782', '+51 1 555 0102', 'operaciones@pacificocloud.test', 'Av. El Derby 250, Lima, Perú', 'José Medina', 'Activo'),
(3, 'Conecta Empresas S.A.', '20123456783', '+51 1 555 0103', 'redes@conectaempresas.test', 'Jr. Unión 450, Lima, Perú', 'Andrea Flores', 'Activo'),
(4, 'Nube Austral Ltda.', '20123456784', '+56 2 555 0104', 'soporte@nubeaustral.test', 'Av. Providencia 800, Santiago, Chile', 'Pablo Ríos', 'Activo'),
(5, 'Telecom del Pacífico S.A.C.', '20123456785', '+51 1 555 0105', 'contacto@telecompacifico.test', 'Calle Los Pinos 330, Lima, Perú', 'Rosa Núñez', 'Inactivo');

-- Estaciones de aterrizaje ficticias en la costa del Pacífico
INSERT IGNORE INTO landing_station (idLandingStation, codigo, nombre, ubicacion, estado, descripcion) VALUES
(1, 'LS-MAN', 'Manta', 'Manta, Ecuador', 'Operativa', 'Estación de aterrizaje en la costa ecuatoriana.'),
(2, 'LS-GYE', 'Guayaquil', 'Guayaquil, Ecuador', 'Operativa', 'Punto de conexión regional.'),
(3, 'LS-LIM', 'Lima', 'Lurín, Perú', 'Operativa', 'Estación principal para servicios en Perú.'),
(4, 'LS-ARI', 'Arica', 'Arica, Chile', 'Operativa', 'Estación de conexión del norte de Chile.'),
(5, 'LS-ANT', 'Antofagasta', 'Antofagasta, Chile', 'En mantenimiento', 'Estación con trabajos programados.'),
(6, 'LS-VAL', 'Valparaíso', 'Valparaíso, Chile', 'Operativa', 'Estación de aterrizaje en la zona central de Chile.');

-- Segmentos: capacidades en Gbps. Utilizada y reservada no superan la capacidad total.
INSERT IGNORE INTO segmento (idSegmento, codigo, idEstacionOrigen, idEstacionDestino, capacidadTotal, capacidadUtilizada, capacidadReservada, longitudKm, estado, descripcion) VALUES
(1, 'SEG-MAN-LIM', 1, 3, 1000.00, 420.00, 120.00, 850.50, 'Operativo', 'Tramo submarino Manta - Lima.'),
(2, 'SEG-LIM-ARI', 3, 4, 800.00, 560.00, 160.00, 1100.00, 'Degradado', 'Tramo submarino Lima - Arica con capacidad disponible limitada.'),
(3, 'SEG-ARI-ANT', 4, 5, 600.00, 300.00, 100.00, 700.25, 'En mantenimiento', 'Tramo submarino Arica - Antofagasta.'),
(4, 'SEG-ANT-VAL', 5, 6, 700.00, 620.00, 20.00, 950.75, 'Fuera de servicio', 'Tramo submarino Antofagasta - Valparaíso.'),
(5, 'SEG-GYE-MAN', 2, 1, 900.00, 250.00, 150.00, 190.40, 'Operativo', 'Tramo submarino Guayaquil - Manta.'),
(6, 'SEG-LIM-GYE', 3, 2, 500.00, 100.00, 50.00, 420.80, 'Operativo', 'Tramo submarino Lima - Guayaquil.');

-- Rutas de servicio
INSERT IGNORE INTO ruta (idRuta, codigo, nombre, idEstacionOrigen, idEstacionDestino, estado, descripcion) VALUES
(1, 'RUT-MAN-ARI', 'Manta - Lima - Arica', 1, 4, 'Operativa', 'Ruta compuesta por los segmentos Manta-Lima y Lima-Arica.'),
(2, 'RUT-GYE-LIM', 'Guayaquil - Manta - Lima', 2, 3, 'Operativa', 'Ruta compuesta por los segmentos Guayaquil-Manta y Manta-Lima.'),
(3, 'RUT-ARI-VAL', 'Arica - Antofagasta - Valparaíso', 4, 6, 'No operativa', 'Ruta con tramos afectados por mantenimiento y fuera de servicio.'),
(4, 'RUT-LIM-GYE', 'Lima - Guayaquil', 3, 2, 'Operativa', 'Ruta directa entre Lima y Guayaquil.');

INSERT IGNORE INTO ruta_segmento (idRuta, idSegmento, orden, capacidadRuta) VALUES
(1, 1, 1, 1000.00),
(1, 2, 2, 800.00),
(2, 5, 1, 900.00),
(2, 1, 2, 1000.00),
(3, 3, 1, 600.00),
(3, 4, 2, 700.00),
(4, 6, 1, 500.00);

-- Servicios contratados. El servicio de la ruta no operativa queda suspendido.
INSERT IGNORE INTO servicio (idServicio, codigo, idCliente, idRuta, origen, destino, capacidadContratada, fechaActivacion, estado) VALUES
(1, 'SRV-2026-001', 1, 1, 'Manta, Ecuador', 'Arica, Chile', 120.00, '2026-02-10', 'Activo'),
(2, 'SRV-2026-002', 2, 1, 'Manta, Ecuador', 'Arica, Chile', 160.00, '2026-03-15', 'Activo'),
(3, 'SRV-2026-003', 3, 2, 'Guayaquil, Ecuador', 'Lima, Perú', 100.00, '2026-04-01', 'Activo'),
(4, 'SRV-2026-004', 4, 3, 'Arica, Chile', 'Valparaíso, Chile', 80.00, '2026-04-20', 'Suspendido'),
(5, 'SRV-2026-005', 1, 4, 'Lima, Perú', 'Guayaquil, Ecuador', 50.00, '2026-05-05', 'Activo'),
(6, 'SRV-2026-006', 5, 2, 'Guayaquil, Ecuador', 'Lima, Perú', 40.00, '2026-05-18', 'Cancelado');

-- Solicitudes: se incluyen estados distintos para probar filtros y agrupaciones.
INSERT IGNORE INTO solicitud (idSolicitud, codigo, idCliente, idRuta, capacidadSolicitada, fechaSolicitud, fechaLimite, motivo, estado, observacion, idUsuario) VALUES
(1, 'SOL-2026-001', 1, 1, 120.00, '2026-01-25', '2026-02-05', 'Ampliación de conectividad empresarial', 'Activa', 'Servicio activado luego de reservar capacidad.', 2),
(2, 'SOL-2026-002', 2, 1, 160.00, '2026-02-20', '2026-03-10', 'Conexión para centro de datos', 'Activa', 'Solicitud atendida y servicio activo.', 2),
(3, 'SOL-2026-003', 3, 2, 100.00, '2026-03-10', '2026-03-25', 'Nueva conexión entre sedes', 'Activa', 'Capacidad reservada y servicio activo.', 2),
(4, 'SOL-2026-004', 4, 3, 80.00, '2026-04-05', '2026-04-18', 'Conectividad internacional', 'Pendiente por capacidad', 'Ruta afectada por indisponibilidad de infraestructura.', 2),
(5, 'SOL-2026-005', 1, 4, 50.00, '2026-04-20', '2026-05-01', 'Conexión adicional', 'Provisionada', 'Reserva registrada; pendiente de activación.', 2),
(6, 'SOL-2026-006', 5, 2, 40.00, '2026-05-01', '2026-05-12', 'Solicitud de capacidad temporal', 'Rechazada', 'Cliente inactivo al momento de la evaluación.', 2),
(7, 'SOL-2026-007', 2, 4, 75.00, '2026-06-02', '2026-06-20', 'Incremento de capacidad', 'En evaluación', 'Pendiente de revisión del Capacity Planner.', 2),
(8, 'SOL-2026-008', 3, 1, 90.00, '2026-06-15', '2026-06-30', 'Capacidad para nuevo servicio', 'Registrada', 'Solicitud recién ingresada.', 6);

-- Reservas vinculadas a solicitudes y servicios existentes.
INSERT IGNORE INTO reserva_capacidad (idReserva, idSolicitud, idSegmento, idServicio, capacidadReservada, fechaReserva, estado, idUsuario) VALUES
(1, 1, 1, 1, 120.00, '2026-02-02', 'Consumida', 2),
(2, 1, 2, 1, 120.00, '2026-02-02', 'Consumida', 2),
(3, 2, 1, 2, 160.00, '2026-03-12', 'Consumida', 2),
(4, 2, 2, 2, 160.00, '2026-03-12', 'Consumida', 2),
(5, 3, 5, 3, 100.00, '2026-03-20', 'Consumida', 2),
(6, 3, 1, 3, 100.00, '2026-03-20', 'Consumida', 2),
(7, 5, 6, 5, 50.00, '2026-05-02', 'Activa', 2);

-- Historial de capacidad para consultas históricas, tendencias y agregaciones.
INSERT IGNORE INTO historial_capacidad (idHistorial, idSegmento, fechaRegistro, capacidadTotal, capacidadUtilizada, capacidadReservada, capacidadDisponible, porcentajeUtilizacion) VALUES
(1, 1, '2026-04-01 09:00:00', 1000.00, 300.00, 100.00, 600.00, 30.00),
(2, 1, '2026-05-01 09:00:00', 1000.00, 360.00, 120.00, 520.00, 36.00),
(3, 1, '2026-06-01 09:00:00', 1000.00, 420.00, 120.00, 460.00, 42.00),
(4, 2, '2026-04-01 09:00:00', 800.00, 440.00, 100.00, 260.00, 55.00),
(5, 2, '2026-05-01 09:00:00', 800.00, 500.00, 140.00, 160.00, 62.50),
(6, 2, '2026-06-01 09:00:00', 800.00, 560.00, 160.00, 80.00, 70.00),
(7, 3, '2026-04-01 09:00:00', 600.00, 240.00, 60.00, 300.00, 40.00),
(8, 3, '2026-05-01 09:00:00', 600.00, 280.00, 80.00, 240.00, 46.67),
(9, 3, '2026-06-01 09:00:00', 600.00, 300.00, 100.00, 200.00, 50.00),
(10, 4, '2026-04-01 09:00:00', 700.00, 500.00, 40.00, 160.00, 71.43),
(11, 4, '2026-05-01 09:00:00', 700.00, 580.00, 30.00, 90.00, 82.86),
(12, 4, '2026-06-01 09:00:00', 700.00, 620.00, 20.00, 60.00, 88.57),
(13, 5, '2026-04-01 09:00:00', 900.00, 180.00, 100.00, 620.00, 20.00),
(14, 5, '2026-05-01 09:00:00', 900.00, 220.00, 120.00, 560.00, 24.44),
(15, 5, '2026-06-01 09:00:00', 900.00, 250.00, 150.00, 500.00, 27.78),
(16, 6, '2026-04-01 09:00:00', 500.00, 60.00, 30.00, 410.00, 12.00),
(17, 6, '2026-05-01 09:00:00', 500.00, 80.00, 40.00, 380.00, 16.00),
(18, 6, '2026-06-01 09:00:00', 500.00, 100.00, 50.00, 350.00, 20.00);

-- Incidencias con diferentes severidades y estados.
INSERT IGNORE INTO incidencia (idIncidencia, codigo, titulo, descripcion, severidad, estado, fechaDeteccion, fechaCierre, idUsuario) VALUES
(1, 'INC-2026-001', 'Degradación de señal en Lima-Arica', 'Se registra una degradación en el tramo; se requiere seguimiento operativo.', 'Alta', 'En análisis', '2026-06-10 08:30:00', NULL, 3),
(2, 'INC-2026-002', 'Interrupción en Antofagasta-Valparaíso', 'El segmento se encuentra fuera de servicio y afecta la ruta asociada.', 'Crítica', 'Reparación programada', '2026-06-12 14:10:00', NULL, 6),
(3, 'INC-2026-003', 'Variación de capacidad en Manta-Lima', 'Se detectó una variación que fue atendida y restaurada.', 'Media', 'Cerrada', '2026-05-02 11:00:00', '2026-05-03 16:30:00', 3),
(4, 'INC-2026-004', 'Alerta de disponibilidad en Arica-Antofagasta', 'Incidencia asociada a trabajos correctivos del segmento.', 'Alta', 'En reparación', '2026-06-18 07:45:00', NULL, 6);

INSERT IGNORE INTO incidencia_segmento (idIncidencia, idSegmento) VALUES
(1, 2),
(2, 4),
(3, 1),
(4, 3),
(4, 4);

-- Mantenimientos preventivos y correctivos, programados y concluidos.
INSERT IGNORE INTO mantenimiento (idMantenimiento, codigo, tipo, idIncidencia, idSegmento, idLandingStation, fechaInicio, duracionEstimada, estado, actividades, resultado, idUsuario) VALUES
(1, 'MNT-2026-001', 'Preventivo', NULL, 1, NULL, '2026-07-05 01:00:00', 4.00, 'Programado', 'Inspección planificada del tramo y revisión de parámetros registrados.', NULL, 4),
(2, 'MNT-2026-002', 'Correctivo', 2, 4, NULL, '2026-06-20 02:00:00', 8.00, 'En ejecución', 'Diagnóstico y reparación del tramo afectado.', NULL, 4),
(3, 'MNT-2026-003', 'Preventivo', NULL, NULL, 5, '2026-05-10 00:00:00', 3.50, 'Finalizado', 'Revisión de infraestructura de la estación.', 'Inspección concluida; se registraron observaciones para seguimiento.', 4),
(4, 'MNT-2026-004', 'Correctivo', 3, 1, NULL, '2026-05-03 08:00:00', 5.00, 'Finalizado', 'Corrección de la anomalía reportada y validación posterior.', 'Servicio restaurado y actividad cerrada.', 4);

INSERT IGNORE INTO mantenimiento_segmento (idMantenimiento, idSegmento) VALUES
(1, 1),
(2, 4),
(3, 3),
(4, 1);

-- ============================================================
-- OCEANLINK - CONSULTAS SQL
-- Consultas de lectura para los módulos principales del sistema.
-- ============================================================

-- 1. Listar clientes
SELECT
    idCliente,
    razonSocial,
    ruc,
    telefono,
    correo,
    direccion,
    contacto,
    estado
FROM cliente
ORDER BY razonSocial;

-- 2. Listar estaciones de aterrizaje
SELECT
    idLandingStation,
    codigo,
    nombre,
    ubicacion,
    estado,
    descripcion
FROM landing_station
ORDER BY nombre;

-- 3. Listar segmentos con sus estaciones de origen y destino
SELECT
    s.idSegmento,
    s.codigo,
    eo.nombre AS estacion_origen,
    ed.nombre AS estacion_destino,
    s.capacidadTotal,
    s.capacidadUtilizada,
    s.capacidadReservada,
    (s.capacidadTotal - s.capacidadUtilizada - s.capacidadReservada) AS capacidadDisponible,
    s.estado
FROM segmento s
INNER JOIN landing_station eo
    ON s.idEstacionOrigen = eo.idLandingStation
INNER JOIN landing_station ed
    ON s.idEstacionDestino = ed.idLandingStation
ORDER BY s.codigo;

-- 4. Capacidad disponible y porcentaje de utilización por segmento
SELECT
    idSegmento,
    codigo,
    capacidadTotal,
    capacidadUtilizada,
    capacidadReservada,
    (capacidadTotal - capacidadUtilizada - capacidadReservada) AS capacidadDisponible,
    (capacidadUtilizada / capacidadTotal) * 100 AS porcentajeUtilizacion
FROM segmento
ORDER BY porcentajeUtilizacion DESC;

-- 5. Listar rutas con sus estaciones de origen y destino
SELECT
    r.idRuta,
    r.codigo,
    r.nombre,
    eo.nombre AS estacion_origen,
    ed.nombre AS estacion_destino,
    r.estado,
    r.descripcion
FROM ruta r
INNER JOIN landing_station eo
    ON r.idEstacionOrigen = eo.idLandingStation
INNER JOIN landing_station ed
    ON r.idEstacionDestino = ed.idLandingStation
ORDER BY r.codigo;

-- 6. Ver los segmentos que componen cada ruta, en orden
SELECT
    r.codigo AS codigo_ruta,
    r.nombre AS nombre_ruta,
    rs.orden,
    s.codigo AS codigo_segmento,
    s.capacidadTotal,
    s.capacidadUtilizada,
    s.capacidadReservada,
    s.estado AS estado_segmento,
    rs.capacidadRuta
FROM ruta_segmento rs
INNER JOIN ruta r
    ON rs.idRuta = r.idRuta
INNER JOIN segmento s
    ON rs.idSegmento = s.idSegmento
ORDER BY r.idRuta, rs.orden;

-- 7. Listar servicios junto con el cliente y la ruta
SELECT
    sv.idServicio,
    sv.codigo,
    c.razonSocial AS cliente,
    r.nombre AS ruta,
    sv.origen,
    sv.destino,
    sv.capacidadContratada,
    sv.fechaActivacion,
    sv.estado
FROM servicio sv
INNER JOIN cliente c
    ON sv.idCliente = c.idCliente
INNER JOIN ruta r
    ON sv.idRuta = r.idRuta
ORDER BY sv.idServicio DESC;

-- 8. Capacidad contratada por cliente
SELECT
    c.idCliente,
    c.razonSocial,
    COUNT(sv.idServicio) AS cantidadServicios,
    SUM(sv.capacidadContratada) AS capacidadContratada
FROM cliente c
LEFT JOIN servicio sv
    ON c.idCliente = sv.idCliente
    AND sv.estado <> 'Cancelado'
GROUP BY c.idCliente, c.razonSocial
ORDER BY capacidadContratada DESC;

-- 9. Listar solicitudes con cliente, ruta y usuario responsable
SELECT
    so.idSolicitud,
    so.codigo,
    c.razonSocial AS cliente,
    r.nombre AS ruta,
    so.capacidadSolicitada,
    so.fechaSolicitud,
    so.fechaLimite,
    so.motivo,
    so.estado,
    so.observacion,
    CONCAT(u.nombre, ' ', u.apellido) AS usuarioResponsable
FROM solicitud so
INNER JOIN cliente c
    ON so.idCliente = c.idCliente
INNER JOIN ruta r
    ON so.idRuta = r.idRuta
LEFT JOIN usuario u
    ON so.idUsuario = u.idUsuario
ORDER BY so.fechaSolicitud DESC;

-- 10. Ver reservas de capacidad asociadas a solicitudes y segmentos
SELECT
    rc.idReserva,
    so.codigo AS solicitud,
    sv.codigo AS servicio,
    s.codigo AS segmento,
    rc.capacidadReservada,
    rc.fechaReserva,
    rc.estado,
    CONCAT(u.nombre, ' ', u.apellido) AS usuarioResponsable
FROM reserva_capacidad rc
LEFT JOIN solicitud so
    ON rc.idSolicitud = so.idSolicitud
LEFT JOIN servicio sv
    ON rc.idServicio = sv.idServicio
INNER JOIN segmento s
    ON rc.idSegmento = s.idSegmento
LEFT JOIN usuario u
    ON rc.idUsuario = u.idUsuario
ORDER BY rc.fechaReserva DESC;

-- 11. Listar incidencias con el usuario que la registró
SELECT
    i.idIncidencia,
    i.codigo,
    i.titulo,
    i.descripcion,
    i.severidad,
    i.estado,
    i.fechaDeteccion,
    i.fechaCierre,
    CONCAT(u.nombre, ' ', u.apellido) AS registrado_por
FROM incidencia i
LEFT JOIN usuario u
    ON i.idUsuario = u.idUsuario
ORDER BY i.fechaDeteccion DESC;

-- 12. Segmentos relacionados con cada incidencia
SELECT
    i.codigo AS codigo_incidencia,
    i.titulo,
    i.severidad,
    i.estado AS estado_incidencia,
    s.codigo AS codigo_segmento,
    s.estado AS estado_segmento
FROM incidencia_segmento isg
INNER JOIN incidencia i
    ON isg.idIncidencia = i.idIncidencia
INNER JOIN segmento s
    ON isg.idSegmento = s.idSegmento
ORDER BY i.idIncidencia, s.codigo;

-- 13. Listar mantenimientos con información de incidencia, segmento,
-- estación y usuario responsable
SELECT
    m.idMantenimiento,
    m.codigo,
    m.tipo,
    i.codigo AS incidencia,
    s.codigo AS segmento,
    ls.nombre AS estacion,
    m.fechaInicio,
    m.duracionEstimada,
    m.estado,
    m.actividades,
    m.resultado,
    CONCAT(u.nombre, ' ', u.apellido) AS responsable
FROM mantenimiento m
LEFT JOIN incidencia i
    ON m.idIncidencia = i.idIncidencia
LEFT JOIN segmento s
    ON m.idSegmento = s.idSegmento
LEFT JOIN landing_station ls
    ON m.idLandingStation = ls.idLandingStation
LEFT JOIN usuario u
    ON m.idUsuario = u.idUsuario
ORDER BY m.fechaInicio DESC;

-- 14. Segmentos asociados a cada mantenimiento
SELECT
    m.codigo AS codigo_mantenimiento,
    m.tipo,
    m.estado AS estado_mantenimiento,
    m.fechaInicio,
    s.codigo AS codigo_segmento,
    s.estado AS estado_segmento
FROM mantenimiento_segmento msg
INNER JOIN mantenimiento m
    ON msg.idMantenimiento = m.idMantenimiento
INNER JOIN segmento s
    ON msg.idSegmento = s.idSegmento
ORDER BY m.fechaInicio DESC, s.codigo;

-- 15. Datos resumidos para el dashboard: capacidad total,
-- utilizada, reservada y disponible de toda la red
SELECT
    SUM(capacidadTotal) AS capacidadTotalRed,
    SUM(capacidadUtilizada) AS capacidadUtilizadaRed,
    SUM(capacidadReservada) AS capacidadReservadaRed,
    SUM(capacidadTotal - capacidadUtilizada - capacidadReservada) AS capacidadDisponibleRed,
    (SUM(capacidadUtilizada) / SUM(capacidadTotal)) * 100 AS porcentajeUtilizacionRed
FROM segmento;

-- 16. Cantidad de segmentos por estado
SELECT
    estado,
    COUNT(*) AS cantidad
FROM segmento
GROUP BY estado
ORDER BY cantidad DESC;

-- 17. Cantidad de incidencias activas (no cerradas)
SELECT
    COUNT(*) AS incidenciasActivas
FROM incidencia
WHERE estado <> 'Cerrada';

-- 18. Servicios por estado
SELECT
    estado,
    COUNT(*) AS cantidadServicios
FROM servicio
GROUP BY estado
ORDER BY cantidadServicios DESC;

-- 19. Consultar el historial de capacidad por segmento
-- Se muestran todos los registros, ordenados del más reciente al más antiguo.
SELECT
    h.idHistorial,
    s.codigo AS codigo_segmento,
    h.fechaRegistro,
    h.capacidadTotal,
    h.capacidadUtilizada,
    h.capacidadReservada,
    h.capacidadDisponible,
    h.porcentajeUtilizacion
FROM historial_capacidad h
INNER JOIN segmento s
    ON h.idSegmento = s.idSegmento
ORDER BY s.codigo, h.fechaRegistro DESC;

-- 20. Servicios que utilizan rutas con al menos un segmento fuera de servicio
SELECT DISTINCT
    sv.idServicio,
    sv.codigo,
    c.razonSocial AS cliente,
    r.nombre AS ruta,
    sv.estado AS estado_servicio
FROM servicio sv
INNER JOIN cliente c
    ON sv.idCliente = c.idCliente
INNER JOIN ruta r
    ON sv.idRuta = r.idRuta
INNER JOIN ruta_segmento rs
    ON r.idRuta = rs.idRuta
INNER JOIN segmento s
    ON rs.idSegmento = s.idSegmento
WHERE s.estado = 'Fuera de servicio'
  AND sv.estado <> 'Cancelado'
ORDER BY sv.codigo;