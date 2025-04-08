class IdGenerator {
  // Generate invoice ID with format: INV-YYYYMMDD-XXXX (where XXXX is a random number)
  static String generateInvoiceId() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomNum = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
    return 'INV-$dateStr-$randomNum';
  }

  // Generate sales order ID with format: SO-YYYYMMDD-XXXX
  static String generateSalesOrderId() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomNum = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
    return 'SO-$dateStr-$randomNum';
  }

  // Generate purchase order ID with format: PO-YYYYMMDD-XXXX
  static String generatePurchaseOrderId() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomNum = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
    return 'PO-$dateStr-$randomNum';
  }

  // Generate purchase invoice ID with format: PINV-YYYYMMDD-XXXX
  static String generatePurchaseInvoiceId() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomNum = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
    return 'PINV-$dateStr-$randomNum';
  }
}