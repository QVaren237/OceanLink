package pe.edu.oceanlink.servlet;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.ColumnText;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import pe.edu.oceanlink.bean.SupervisorDatoGrafico;
import pe.edu.oceanlink.bean.SupervisorEstadisticas;
import pe.edu.oceanlink.bean.SupervisorMes;

import java.awt.Color;
import java.io.OutputStream;
import java.util.List;

final class SupervisorEstadisticasPdf {
    private static final Color TINTA = new Color(32, 60, 62);
    private static final Color TEXTO = new Color(73, 105, 107);
    private static final Color FONDO = new Color(237, 246, 247);
    private static final Color TARJETA = new Color(251, 254, 253);
    private static final Color VERDE = new Color(8, 125, 132);
    private static final Color VERDE_CLARO = new Color(217, 240, 238);
    private static final Color MORADO = new Color(120, 100, 166);
    private static final Color MORADO_CLARO = new Color(231, 224, 246);
    private static final Color ROJO = new Color(164, 78, 96);
    private static final Color ROJO_CLARO = new Color(245, 223, 228);
    private static final int MESES_EN_PORTADA = 10;
    private static final int MESES_POR_PAGINA = 12;

    private SupervisorEstadisticasPdf() {}

    static void escribir(OutputStream salida, SupervisorEstadisticas datos, String periodo) throws DocumentException {
        Rectangle pagina = PageSize.A4.rotate();
        pagina.setBackgroundColor(FONDO);
        Document documento = new Document(pagina, 28, 28, 25, 25);
        try {
            PdfWriter.getInstance(documento, salida);
            documento.addTitle("OceanLink | Estadísticas de operaciones");
            documento.open();
            encabezado(documento, periodo);
            documento.add(indicadores(datos));

            List<SupervisorMes> meses = datos.getMeses();
            int limite = Math.min(MESES_EN_PORTADA, meses.size());
            PdfPTable paneles = tabla(3, 2);
            paneles.setSpacingBefore(12);
            int maximo = datos.getMaximoMensual();
            paneles.addCell(tarjeta(evolucion(meses.subList(0, limite), maximo), 0, 6));
            paneles.addCell(tarjeta(severidad(datos), 6, 0));
            documento.add(paneles);

            for (int desde = limite; desde < meses.size(); desde += MESES_POR_PAGINA) {
                documento.newPage();
                encabezado(documento, periodo);
                int hasta = Math.min(desde + MESES_POR_PAGINA, meses.size());
                PdfPTable continuacion = tabla(1);
                continuacion.addCell(tarjeta(evolucion(meses.subList(desde, hasta), maximo), 0, 0));
                documento.add(continuacion);
            }
        } finally {
            documento.close();
        }
    }

    private static void encabezado(Document doc, String periodo) throws DocumentException {
        doc.add(new Paragraph("OceanLink / Supervisor", fuente(10, Font.BOLD, VERDE)));
        Paragraph titulo = new Paragraph(31, "Estadísticas de operaciones", fuente(25, Font.BOLD, TINTA));
        titulo.setSpacingBefore(4);
        doc.add(titulo);
        Paragraph fechas = new Paragraph(17, "Período consultado: " + periodo, fuente(10, Font.NORMAL, TEXTO));
        fechas.setSpacingAfter(14);
        doc.add(fechas);
    }

    private static PdfPTable indicadores(SupervisorEstadisticas datos) {
        PdfPTable tabla = tabla(1, 1, 1, 1);
        indicador(tabla, "Incidencias detectadas", datos.getTotalIncidencias(), VERDE, 0, 5);
        indicador(tabla, "Mantenimientos", datos.getTotalMantenimientos(), MORADO, 5, 5);
        indicador(tabla, "Segmentos involucrados", datos.getSegmentosInvolucrados(), VERDE, 5, 5);
        indicador(tabla, "Clientes relacionados", datos.getClientesRelacionados(), MORADO, 5, 0);
        return tabla;
    }

    private static void indicador(PdfPTable tabla, String etiqueta, int valor, Color color, int margenIzq, int margenDer) {
        PdfPCell celda = new PdfPCell();
        celda.setBorder(Rectangle.BOX);
        celda.setBorderColor(FONDO);
        celda.setBorderWidth(0);
        celda.setBorderWidthLeft(margenIzq);
        celda.setBorderWidthRight(margenDer);
        celda.setUseBorderPadding(true);
        celda.setPadding(11);
        celda.setCellEvent((c, posicion, capas) -> {
            PdfContentByte fondo = capas[PdfPTable.BACKGROUNDCANVAS];
            fondo.setColorFill(TARJETA);
            fondo.roundRectangle(posicion.getLeft() + margenIzq, posicion.getBottom(),
                    posicion.getWidth() - margenIzq - margenDer, posicion.getHeight(), 9);
            fondo.fill();
            fondo.setColorStroke(color);
            fondo.setLineWidth(2);
            fondo.moveTo(posicion.getLeft() + margenIzq + 11, posicion.getTop() - 2);
            fondo.lineTo(posicion.getRight() - margenDer - 11, posicion.getTop() - 2);
            fondo.stroke();
        });
        celda.addElement(new Paragraph(13, etiqueta, fuente(10, Font.NORMAL, TEXTO)));
        celda.addElement(new Paragraph(25, String.valueOf(valor), fuente(23, Font.BOLD, TINTA)));
        tabla.addCell(celda);
    }

    private static PdfPTable evolucion(List<SupervisorMes> meses, int maximo) {
        PdfPTable tabla = tabla(1, 4);
        titulo(tabla, "Evolución mensual", 2);
        if (meses.isEmpty()) {
            PdfPCell vacio = texto("No se registraron incidencias ni mantenimientos en este período.", 10, Font.NORMAL);
            vacio.setColspan(2);
            tabla.addCell(vacio);
            return tabla;
        }

        PdfPCell leyenda = new PdfPCell();
        leyenda.setBorder(Rectangle.NO_BORDER);
        leyenda.setColspan(2);
        leyenda.setPaddingBottom(7);
        PdfPTable series = tabla(10, 108, 10, 90);
        series.setTotalWidth(218);
        series.setLockedWidth(true);
        series.setHorizontalAlignment(Element.ALIGN_LEFT);
        series.addCell(muestra(VERDE));
        series.addCell(texto("Incidencias detectadas", 9, Font.NORMAL));
        series.addCell(muestra(MORADO));
        series.addCell(texto("Mantenimientos", 9, Font.NORMAL));
        leyenda.addElement(series);
        tabla.addCell(leyenda);

        for (SupervisorMes mes : meses) {
            tabla.addCell(texto(mes.getEtiqueta(), 10, Font.BOLD));
            PdfPTable par = tabla(14, 1);
            par.addCell(barra(mes.getIncidencias(), maximo, VERDE, VERDE_CLARO));
            par.addCell(numero(mes.getIncidencias()));
            par.addCell(barra(mes.getMantenimientos(), maximo, MORADO, MORADO_CLARO));
            par.addCell(numero(mes.getMantenimientos()));
            PdfPCell fila = new PdfPCell();
            fila.setBorder(Rectangle.NO_BORDER);
            fila.setPaddingBottom(4);
            fila.addElement(par);
            tabla.addCell(fila);
        }
        return tabla;
    }

    private static PdfPTable severidad(SupervisorEstadisticas datos) {
        PdfPTable tabla = tabla(1, 1.4f, 0.26f);
        titulo(tabla, "Estado y severidad de incidencias", 3);
        int total = datos.getTotalIncidencias();
        PdfPTable medidores = tabla(1, 1, 1);
        medidores.addCell(medidor("Abiertas", datos.getIncidenciasAbiertas(), total,
                datos.porcentajeIncidencias(datos.getIncidenciasAbiertas()), VERDE, VERDE_CLARO));
        medidores.addCell(medidor("Cerradas", datos.getIncidenciasCerradas(), total,
                datos.porcentajeIncidencias(datos.getIncidenciasCerradas()), MORADO, MORADO_CLARO));
        medidores.addCell(medidor("Críticas o altas", datos.getIncidenciasGraves(), total,
                datos.porcentajeIncidencias(datos.getIncidenciasGraves()), ROJO, ROJO_CLARO));
        PdfPCell bloque = new PdfPCell();
        bloque.setBorder(Rectangle.NO_BORDER);
        bloque.setPaddingBottom(10);
        bloque.setColspan(3);
        bloque.addElement(medidores);
        tabla.addCell(bloque);
        for (SupervisorDatoGrafico dato : datos.getSeveridades()) {
            tabla.addCell(texto(dato.getEtiqueta(), 9, Font.NORMAL));
            tabla.addCell(barra(dato.getCantidad(), total, VERDE, VERDE_CLARO));
            tabla.addCell(numero(dato.getCantidad()));
        }
        return tabla;
    }

    private static PdfPCell medidor(String etiqueta, int valor, int total, int porcentaje, Color color, Color pista) {
        PdfPCell celda = texto(etiqueta, 9, Font.BOLD);
        celda.setHorizontalAlignment(Element.ALIGN_CENTER);
        celda.setVerticalAlignment(Element.ALIGN_TOP);
        celda.setFixedHeight(88);
        celda.setPaddingTop(9);
        celda.setCellEvent((c, posicion, capas) -> {
            PdfContentByte fondo = capas[PdfPTable.BACKGROUNDCANVAS];
            fondo.setColorFill(FONDO);
            fondo.roundRectangle(posicion.getLeft() + 3, posicion.getBottom(), posicion.getWidth() - 6,
                    posicion.getHeight(), 7);
            fondo.fill();

            PdfContentByte linea = capas[PdfPTable.LINECANVAS];
            float x = (posicion.getLeft() + posicion.getRight()) / 2;
            float y = posicion.getBottom() + 40;
            float radio = 21;
            linea.saveState();
            linea.setLineWidth(5);
            linea.setColorStroke(pista);
            linea.arc(x - radio, y - radio, x + radio, y + radio, 225, -270);
            linea.stroke();
            if (porcentaje > 0) {
                linea.setColorStroke(color);
                linea.arc(x - radio, y - radio, x + radio, y + radio, 225, -270 * porcentaje / 100f);
                linea.stroke();
            }
            linea.restoreState();

            PdfContentByte contenido = capas[PdfPTable.TEXTCANVAS];
            ColumnText.showTextAligned(contenido, Element.ALIGN_CENTER,
                    new Phrase(total == 0 ? "-" : porcentaje + " %", fuente(12, Font.BOLD, TINTA)), x, y - 4, 0);
            ColumnText.showTextAligned(contenido, Element.ALIGN_CENTER,
                    new Phrase(valor + " de " + total, fuente(8, Font.NORMAL, TEXTO)), x, posicion.getBottom() + 9, 0);
        });
        return celda;
    }

    private static PdfPCell barra(int valor, int maximo, Color color, Color pista) {
        PdfPCell celda = new PdfPCell();
        celda.setBorder(Rectangle.NO_BORDER);
        celda.setMinimumHeight(12);
        celda.setCellEvent((c, posicion, capas) -> {
            PdfContentByte fondo = capas[PdfPTable.BACKGROUNDCANVAS];
            float ancho = posicion.getWidth() - 8;
            float y = (posicion.getTop() + posicion.getBottom()) / 2 - 2;
            fondo.setColorFill(pista);
            fondo.roundRectangle(posicion.getLeft(), y, ancho, 4, 2);
            fondo.fill();
            if (valor > 0 && maximo > 0) {
                float ocupado = ancho * valor / maximo;
                fondo.setColorFill(color);
                fondo.roundRectangle(posicion.getLeft(), y, ocupado, 4, Math.min(2, ocupado / 2));
                fondo.fill();
            }
        });
        return celda;
    }

    private static PdfPCell numero(int valor) {
        PdfPCell celda = texto(String.valueOf(valor), 9, Font.BOLD);
        celda.setHorizontalAlignment(Element.ALIGN_RIGHT);
        celda.setPaddingTop(1);
        celda.setPaddingBottom(1);
        return celda;
    }

    private static PdfPCell muestra(Color color) {
        PdfPCell celda = new PdfPCell();
        celda.setBorder(Rectangle.NO_BORDER);
        celda.setCellEvent((c, posicion, capas) -> {
            PdfContentByte fondo = capas[PdfPTable.BACKGROUNDCANVAS];
            float y = (posicion.getTop() + posicion.getBottom()) / 2 - 2.5f;
            fondo.setColorFill(color);
            fondo.roundRectangle(posicion.getLeft(), y, 5, 5, 1);
            fondo.fill();
        });
        return celda;
    }

    private static PdfPCell tarjeta(PdfPTable contenido, int margenIzq, int margenDer) {
        PdfPCell celda = new PdfPCell();
        celda.setVerticalAlignment(Element.ALIGN_TOP);
        celda.setBorder(Rectangle.NO_BORDER);
        celda.setPadding(12);
        celda.setPaddingLeft(12 + margenIzq);
        celda.setPaddingRight(12 + margenDer);
        celda.setCellEvent((c, posicion, capas) -> {
            PdfContentByte fondo = capas[PdfPTable.BASECANVAS];
            fondo.setColorFill(TARJETA);
            fondo.roundRectangle(posicion.getLeft() + margenIzq, posicion.getBottom(),
                    posicion.getWidth() - margenIzq - margenDer, posicion.getHeight(), 10);
            fondo.fill();
        });
        celda.addElement(contenido);
        return celda;
    }

    private static void titulo(PdfPTable tabla, String titulo, int columnas) {
        PdfPCell celda = texto(titulo, 13, Font.BOLD);
        celda.setPaddingBottom(10);
        celda.setColspan(columnas);
        tabla.addCell(celda);
    }

    private static PdfPCell texto(String valor, int puntos, int estilo) {
        PdfPCell celda = new PdfPCell(new Phrase(valor, fuente(puntos, estilo, TINTA)));
        celda.setBorder(Rectangle.NO_BORDER);
        celda.setPaddingLeft(0);
        celda.setPaddingRight(0);
        celda.setVerticalAlignment(Element.ALIGN_MIDDLE);
        return celda;
    }

    private static PdfPTable tabla(float... anchos) {
        PdfPTable tabla = new PdfPTable(anchos);
        tabla.setWidthPercentage(100);
        return tabla;
    }

    private static Font fuente(int puntos, int estilo, Color color) {
        return new Font(Font.HELVETICA, puntos, estilo, color);
    }
}
