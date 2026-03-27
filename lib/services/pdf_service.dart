import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/product.dart';

class PdfService {

  // Genera y abre el PDF con la lista de productos recibida
  // Recibe los productos ya filtrados desde la pantalla de búsqueda
  static Future<void> exportarProductos(List<Producto> productos) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        // Configuración de página A4 horizontal para que quepan bien las columnas
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        // Header que aparece en todas las páginas
        header: (context) => _buildHeader(context),
        // Footer con número de página
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildTitulo(productos.length),
          pw.SizedBox(height: 16),
          _buildTabla(productos),
        ],
      ),
    );

    // Abre el diálogo nativo del navegador/sistema para guardar o imprimir
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'inventario_productos.pdf',
    );
  }

  // Cabecera del PDF con título y fecha
  static pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.purple, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'InvenStock — Listado de productos',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple800,
            ),
          ),
          pw.Text(
            'Generado: ${_formatFecha(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // Footer con número de página
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'InvenStock — Gestión de Inventario',
            style: const pw.TextStyle(
                fontSize: 9, color: PdfColors.grey500),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(
                fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  // Título con el total de productos exportados
  static pw.Widget _buildTitulo(int total) {
    return pw.Row(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColors.purple100,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            '$total productos exportados',
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.purple800,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Tabla con todos los productos
  static pw.Widget _buildTabla(List<Producto> productos) {
    // Cabeceras de la tabla
    const headers = ['Nombre', 'Marca', 'Descripción', 'Precio', 'Stock'];

    // Filas de datos — una por producto
    final rows = productos.map((p) => [
      p.nombre,
      p.marca,
      p.descripcion,
      '€${p.precio.toStringAsFixed(2)}',
      '${p.stock} uds',
    ]).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      // Estilo de la cabecera
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 11,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.purple700,
      ),
      // Estilo de las filas
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellHeight: 28,
      // Colores alternos en las filas para mejor legibilidad
      rowDecoration: const pw.BoxDecoration(
        color: PdfColors.white,
      ),
      oddRowDecoration: const pw.BoxDecoration(
        color: PdfColors.purple50,
      ),
      // Ancho de cada columna
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5), // Nombre
        1: const pw.FlexColumnWidth(1.5), // Marca
        2: const pw.FlexColumnWidth(3),   // Descripción
        3: const pw.FlexColumnWidth(1),   // Precio
        4: const pw.FlexColumnWidth(1),   // Stock
      },
      headerPadding: const pw.EdgeInsets.symmetric(
          horizontal: 8, vertical: 6),
      cellPadding: const pw.EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
    );
  }

  // Formatea la fecha actual como dd/mm/yyyy
  static String _formatFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }
}