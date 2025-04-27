import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/product_model.dart';
import '../models/customer_model.dart';
import '../models/supplier_model.dart';
import '../models/warehouse_model.dart';
import '../models/sales_order_model.dart';
import '../models/purchase_order_model.dart';

class ChatbotService {
  final FirebaseFirestore _firestore;
  final GenerativeModel _model;

  // History will store conversation context
  final List<Content> _history = [];

  ChatbotService({
    FirebaseFirestore? firestore,
    required String apiKey,
  }) :
        _firestore = firestore ?? FirebaseFirestore.instance,
        _model = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: apiKey,
          systemInstruction: Content.text(
            'You are a helpful assistant for an inventory management system. Answer questions about products, customers, sales, purchases, and inventory levels. Use only the data provided to you for answering questions. If you don\'t have the data needed to answer, tell the user that more information is needed. Always be polite and professional.',
          ),
        );

  /// Sends a message to the chatbot and gets a response
  Future<String> sendMessage(String message) async {
    try {
      // Create user message content
      final userMessage = Content.text(message);
      _history.add(userMessage);

      // Extract entities from the message to help with retrieval
      final entities = await _extractEntities(message);

      // Retrieve relevant data based on the entities
      final retrievedData = await _retrieveRelevantData(entities, message);

      // Construct the prompt with the retrieved data
      final prompt = _constructPrompt(message, retrievedData);

      // Create content with retrieved data for context
      final modelContent = Content.text(prompt);

      // Create the chat session with history
      final chat = _model.startChat(history: _history);

      // Generate response
      final response = await chat.sendMessage(modelContent);

      // Add response to history
      _history.add(Content.text(response.text ?? 'I encountered an error processing your request.'));

      return response.text ?? 'I encountered an error processing your request.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  /// Extracts entities from the user message
  Future<Map<String, List<String>>> _extractEntities(String message) async {
    final Map<String, List<String>> entities = {
      'products': [],
      'customers': [],
      'suppliers': [],
      'warehouses': [],
      'sales': [],
      'purchases': [],
    };

    // Extract product names
    final productSnapshot = await _firestore.collection('products').get();
    for (final doc in productSnapshot.docs) {
      final productName = doc.data()['name'] as String;
      if (message.toLowerCase().contains(productName.toLowerCase())) {
        entities['products']!.add(doc.id);
      }
    }

    // Extract customer names
    final customerSnapshot = await _firestore.collection('customers').get();
    for (final doc in customerSnapshot.docs) {
      final customerName = doc.data()['name'] as String;
      if (message.toLowerCase().contains(customerName.toLowerCase())) {
        entities['customers']!.add(doc.id);
      }
    }

    // Extract supplier names
    final supplierSnapshot = await _firestore.collection('suppliers').get();
    for (final doc in supplierSnapshot.docs) {
      final supplierName = doc.data()['name'] as String;
      if (message.toLowerCase().contains(supplierName.toLowerCase())) {
        entities['suppliers']!.add(doc.id);
      }
    }

    // Extract warehouse names
    final warehouseSnapshot = await _firestore.collection('warehouses').get();
    for (final doc in warehouseSnapshot.docs) {
      final warehouseName = doc.data()['name'] as String;
      if (message.toLowerCase().contains(warehouseName.toLowerCase())) {
        entities['warehouses']!.add(doc.id);
      }
    }

    // For sales and purchases, we'll check for order IDs
    if (message.toLowerCase().contains('sales') || message.toLowerCase().contains('order')) {
      entities['sales'] = ['all'];
    }

    if (message.toLowerCase().contains('purchase') || message.toLowerCase().contains('order')) {
      entities['purchases'] = ['all'];
    }

    return entities;
  }

  /// Retrieves relevant data from Firestore based on entities and the query
  Future<Map<String, dynamic>> _retrieveRelevantData(
      Map<String, List<String>> entities,
      String message
      ) async {
    final Map<String, dynamic> retrievedData = {};

    // Determine what kind of query it is
    final isProductQuery = message.toLowerCase().contains('product') ||
        message.toLowerCase().contains('inventory') ||
        message.toLowerCase().contains('stock');

    final isCustomerQuery = message.toLowerCase().contains('customer') ||
        message.toLowerCase().contains('client');

    final isSupplierQuery = message.toLowerCase().contains('supplier') ||
        message.toLowerCase().contains('vendor');

    final isWarehouseQuery = message.toLowerCase().contains('warehouse') ||
        message.toLowerCase().contains('location');

    final isSalesQuery = message.toLowerCase().contains('sales') ||
        message.toLowerCase().contains('selling') ||
        message.toLowerCase().contains('revenue');

    final isPurchaseQuery = message.toLowerCase().contains('purchase') ||
        message.toLowerCase().contains('buying') ||
        message.toLowerCase().contains('procurement');

    // Retrieve product data
    if (isProductQuery || entities['products']!.isNotEmpty) {
      List<Map<String, dynamic>> products = [];

      if (entities['products']!.isEmpty) {
        // Get all products (limited)
        final querySnapshot = await _firestore.collection('products')
            .orderBy('updatedAt', descending: true)
            .limit(10)
            .get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          products.add(data);
        }
      } else {
        // Get specific products
        for (final productId in entities['products']!) {
          final doc = await _firestore.collection('products').doc(productId).get();
          if (doc.exists) {
            final data = doc.data()!;
            data['id'] = doc.id;
            products.add(data);
          }
        }
      }

      retrievedData['products'] = products;
    }

    // Retrieve customer data
    if (isCustomerQuery || entities['customers']!.isNotEmpty) {
      List<Map<String, dynamic>> customers = [];

      if (entities['customers']!.isEmpty) {
        // Get all customers (limited)
        final querySnapshot = await _firestore.collection('customers')
            .orderBy('updatedAt', descending: true)
            .limit(10)
            .get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          customers.add(data);
        }
      } else {
        // Get specific customers
        for (final customerId in entities['customers']!) {
          final doc = await _firestore.collection('customers').doc(customerId).get();
          if (doc.exists) {
            final data = doc.data()!;
            data['id'] = doc.id;
            customers.add(data);
          }
        }
      }

      retrievedData['customers'] = customers;
    }

    // Retrieve supplier data
    if (isSupplierQuery || entities['suppliers']!.isNotEmpty) {
      List<Map<String, dynamic>> suppliers = [];

      if (entities['suppliers']!.isEmpty) {
        // Get all suppliers (limited)
        final querySnapshot = await _firestore.collection('suppliers')
            .orderBy('updatedAt', descending: true)
            .limit(10)
            .get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          suppliers.add(data);
        }
      } else {
        // Get specific suppliers
        for (final supplierId in entities['suppliers']!) {
          final doc = await _firestore.collection('suppliers').doc(supplierId).get();
          if (doc.exists) {
            final data = doc.data()!;
            data['id'] = doc.id;
            suppliers.add(data);
          }
        }
      }

      retrievedData['suppliers'] = suppliers;
    }

    // Retrieve warehouse data
    if (isWarehouseQuery || entities['warehouses']!.isNotEmpty) {
      List<Map<String, dynamic>> warehouses = [];

      if (entities['warehouses']!.isEmpty) {
        // Get all warehouses
        final querySnapshot = await _firestore.collection('warehouses').get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          warehouses.add(data);
        }
      } else {
        // Get specific warehouses
        for (final warehouseId in entities['warehouses']!) {
          final doc = await _firestore.collection('warehouses').doc(warehouseId).get();
          if (doc.exists) {
            final data = doc.data()!;
            data['id'] = doc.id;
            warehouses.add(data);
          }
        }
      }

      retrievedData['warehouses'] = warehouses;
    }

    // Retrieve sales order data
    if (isSalesQuery || entities['sales']!.isNotEmpty) {
      List<Map<String, dynamic>> salesOrders = [];

      // Get recent sales orders
      final querySnapshot = await _firestore.collection('sales_orders')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        salesOrders.add(data);
      }

      retrievedData['salesOrders'] = salesOrders;
    }

    // Retrieve purchase order data
    if (isPurchaseQuery || entities['purchases']!.isNotEmpty) {
      List<Map<String, dynamic>> purchaseOrders = [];

      // Get recent purchase orders
      final querySnapshot = await _firestore.collection('purchase_orders')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        purchaseOrders.add(data);
      }

      retrievedData['purchaseOrders'] = purchaseOrders;
    }

    // If nothing was retrieved but we have a query about low stock
    if (retrievedData.isEmpty && message.toLowerCase().contains('low stock')) {
      final querySnapshot = await _firestore.collection('products')
          .where('quantity', isLessThan: 10)
          .where('isActive', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> lowStockProducts = [];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        lowStockProducts.add(data);
      }

      retrievedData['lowStockProducts'] = lowStockProducts;
    }

    // If asking about total inventory value
    if (message.toLowerCase().contains('total value') ||
        message.toLowerCase().contains('inventory value')) {
      final warehouseSnapshot = await _firestore.collection('warehouses').get();

      double totalValue = 0;
      for (final doc in warehouseSnapshot.docs) {
        totalValue += (doc.data()['totalValue'] as num).toDouble();
      }

      retrievedData['totalInventoryValue'] = totalValue;
    }

    return retrievedData;
  }

  /// Constructs a prompt with the retrieved data to send to the model
  String _constructPrompt(String userMessage, Map<String, dynamic> retrievedData) {
    String prompt = '''
USER QUERY: $userMessage

RETRIEVED DATA:
''';

    if (retrievedData.isEmpty) {
      prompt += 'No specific data found related to the query. Please provide a general response based on your knowledge of inventory management systems.';
      return prompt;
    }

    if (retrievedData.containsKey('products')) {
      prompt += '\nPRODUCTS:\n';

      for (final product in retrievedData['products']) {
        prompt += '''
- ID: ${product['id']}
  Name: ${product['name']}
  Category: ${product['category']}
  Quantity: ${product['quantity']}
  Price: ${product['price']}
  Description: ${product['description'] ?? 'N/A'}
  isActive: ${product['isActive']}
''';
      }
    }

    if (retrievedData.containsKey('customers')) {
      prompt += '\nCUSTOMERS:\n';

      for (final customer in retrievedData['customers']) {
        prompt += '''
- ID: ${customer['id']}
  Name: ${customer['name']}
  City: ${customer['city']}
  Email: ${customer['email'] ?? 'N/A'}
  Total Orders: ${customer['totalOrders']}
  Total Purchases: ${customer['totalPurchases']}
''';
      }
    }

    if (retrievedData.containsKey('suppliers')) {
      prompt += '\nSUPPLIERS:\n';

      for (final supplier in retrievedData['suppliers']) {
        prompt += '''
- ID: ${supplier['id']}
  Name: ${supplier['name']}
  City: ${supplier['city']}
  Email: ${supplier['email'] ?? 'N/A'}
  Total Orders: ${supplier['totalOrders']}
  Total Purchases: ${supplier['totalPurchases']}
''';
      }
    }

    if (retrievedData.containsKey('warehouses')) {
      prompt += '\nWAREHOUSES:\n';

      for (final warehouse in retrievedData['warehouses']) {
        prompt += '''
- ID: ${warehouse['id']}
  Name: ${warehouse['name']}
  Location: ${warehouse['city']}
  Total Products: ${warehouse['totalProducts']}
  Total Value: ${warehouse['totalValue']}
''';
      }
    }

    if (retrievedData.containsKey('salesOrders')) {
      prompt += '\nRECENT SALES ORDERS:\n';

      for (final order in retrievedData['salesOrders']) {
        prompt += '''
- ID: ${order['id']}
  Customer: ${order['customerName']}
  Status: ${order['status']}
  Total Amount: ${order['totalAmount']}
  Creation Date: ${(order['createdAt'] as Timestamp).toDate().toString()}
''';
      }
    }

    if (retrievedData.containsKey('purchaseOrders')) {
      prompt += '\nRECENT PURCHASE ORDERS:\n';

      for (final order in retrievedData['purchaseOrders']) {
        prompt += '''
- ID: ${order['id']}
  Supplier: ${order['supplierName']}
  Status: ${order['status']}
  Total Amount: ${order['totalAmount']}
  Creation Date: ${(order['createdAt'] as Timestamp).toDate().toString()}
''';
      }
    }

    if (retrievedData.containsKey('lowStockProducts')) {
      prompt += '\nLOW STOCK PRODUCTS (below 10 units):\n';

      for (final product in retrievedData['lowStockProducts']) {
        prompt += '''
- ID: ${product['id']}
  Name: ${product['name']}
  Current Quantity: ${product['quantity']}
''';
      }
    }

    if (retrievedData.containsKey('totalInventoryValue')) {
      prompt += '\nTOTAL INVENTORY VALUE: ${retrievedData['totalInventoryValue']}\n';
    }

    prompt += '\nBased on the above data, please provide a concise and accurate answer to the user query.';

    return prompt;
  }

  /// Clears the conversation history
  void clearHistory() {
    _history.clear();
  }
}