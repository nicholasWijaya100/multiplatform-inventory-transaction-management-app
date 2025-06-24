// lib/data/services/chatbot_service.dart
import 'dart:math';
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

  // Conversation memory to track entities mentioned across turns
  final Map<String, List<String>> _conversationMemory = {
    'products': [],
    'customers': [],
    'suppliers': [],
    'warehouses': [],
  };

  // Most recent query classification
  Map<String, double> _lastQueryClassification = {};

  ChatbotService({
    FirebaseFirestore? firestore,
    required String apiKey,
  }) :
        _firestore = firestore ?? FirebaseFirestore.instance,
        _model = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: apiKey,
          systemInstruction: Content.text(
            'You are a helpful assistant for an inventory management system. Answer questions about products, customers, sales, purchases, and inventory levels. Use only the data provided to you for answering questions. If you don\'t have the data needed to answer, tell the user that more information is needed. Always be polite and professional. For numerical data, format currency with proper symbols and use appropriate units for quantities. When discussing inventory levels, emphasize if items are low in stock (less than 10 units). For financial questions, mention the total values and highlight significant trends if visible in the data.',
          ),
        );

  /// Sends a message to the chatbot and gets a response
  Future<String> sendMessage(String message) async {
    try {
      // Create user message content
      final userMessage = Content.text(message);
      _history.add(userMessage);

      // Manage conversation history size
      _manageConversationHistory();

      // Classify the query type
      _lastQueryClassification = await _classifyQuery(message);

      // Extract entities from the message to help with retrieval
      final entities = await _extractEntities(message);

      // Update conversation memory with new entities
      _updateMemory(entities);

      // Combine current entities with memory to improve context
      final enhancedEntities = _enhanceEntitiesWithMemory(entities);

      // Retrieve relevant data based on the entities
      final retrievedData = await _retrieveRelevantData(enhancedEntities, message);

      // Enrich the prompt with domain-specific logic
      final enrichedPrompt = _enrichQueryWithDomainLogic(message, retrievedData);

      // Create content with retrieved data for context
      final modelContent = Content.text(enrichedPrompt);

      // Create the chat session with history
      final chat = _model.startChat(history: _history);

      // Generate response
      final response = await chat.sendMessage(modelContent);

      // Check for empty response or generic fallback
      String responseText = response.text ?? 'I encountered an error processing your request.';

      if (responseText.isEmpty ||
          responseText.contains("I don't have enough information")) {
        responseText = _generateFallbackResponse(message);
      }

      // Add response to history
      _history.add(Content.text(responseText));

      return responseText;
    } catch (e) {
      print('Error in chatbot: ${e.toString()}');
      return _generateFallbackResponse(message);
    }
  }

  /// Manages the size of the conversation history
  void _manageConversationHistory() {
    // Keep history within reasonable limits
    if (_history.length > 20) {
      // Remove older messages but keep the first message (system instructions)
      _history.removeRange(1, _history.length - 19);
    }
  }

  /// Updates the conversation memory with new entities
  void _updateMemory(Map<String, List<String>> entities) {
    for (final entry in entities.entries) {
      if (entry.value.isNotEmpty) {
        // Only store entities in memory that have a persistent representation
        if (_conversationMemory.containsKey(entry.key)) {
          _conversationMemory[entry.key] = [
            ...(_conversationMemory[entry.key] ?? []),
            ...entry.value,
          ].toSet().toList().cast<String>(); // Ensure uniqueness and correct type
        }
      }
    }
  }

  /// Enhances current entities with memory
  Map<String, List<String>> _enhanceEntitiesWithMemory(Map<String, List<String>> currentEntities) {
    final enhancedEntities = Map<String, List<String>>.from(currentEntities);

    // Only add memory entities if no entities of that type were found in the current message
    for (final entry in _conversationMemory.entries) {
      if (currentEntities[entry.key]?.isEmpty ?? true) {
        // Prioritize recent memory - take up to 3 most recent items from memory
        final recentMemory = entry.value.length > 3
            ? entry.value.sublist(entry.value.length - 3)
            : entry.value;

        enhancedEntities[entry.key] = recentMemory;
      }
    }

    return enhancedEntities;
  }

  /// Classifies the query to understand intent
  Future<Map<String, double>> _classifyQuery(String message) async {
    final lowerMessage = message.toLowerCase();

    // Simple rule-based classification
    Map<String, double> classification = {
      'inventory_query': 0.0,
      'sales_query': 0.0,
      'purchasing_query': 0.0,
      'customer_query': 0.0,
      'supplier_query': 0.0,
      'warehouse_query': 0.0,
      'reporting_query': 0.0,
      'low_stock_query': 0.0,
      'warehouse_document_query': 0.0,
      'analytics_query': 0.0,
    };

    // Inventory related keywords
    if (lowerMessage.contains('stock') ||
        lowerMessage.contains('inventory') ||
        lowerMessage.contains('product') ||
        lowerMessage.contains('item')) {
      classification['inventory_query'] = 0.8;
    }

    if (lowerMessage.contains('waybill') ||
        lowerMessage.contains('delivery note') ||
        lowerMessage.contains('entry waybill') ||
        lowerMessage.contains('warehouse document') ||
        lowerMessage.contains('stock movement') ||
        lowerMessage.contains('goods receipt') ||
        lowerMessage.contains('goods delivery')) {
      classification['warehouse_document_query'] = 0.8;
    }

    if (lowerMessage.contains('best selling') ||
        lowerMessage.contains('top selling') ||
        lowerMessage.contains('most sold') ||
        lowerMessage.contains('highest sales') ||
        lowerMessage.contains('top products') ||
        lowerMessage.contains('best products') ||
        lowerMessage.contains('most popular') ||
        lowerMessage.contains('top orders') ||
        lowerMessage.contains('largest orders')) {
      classification['analytics_query'] = 0.9;
      classification['sales_query'] = 0.7;
    }

    // Sales related keywords
    if (lowerMessage.contains('sale') ||
        lowerMessage.contains('revenue') ||
        lowerMessage.contains('income') ||
        lowerMessage.contains('sold')) {
      classification['sales_query'] = 0.7;
    }

    // Purchase related keywords
    if (lowerMessage.contains('purchase') ||
        lowerMessage.contains('buy') ||
        lowerMessage.contains('procurement') ||
        lowerMessage.contains('order')) {
      classification['purchasing_query'] = 0.7;
    }

    // Customer related keywords
    if (lowerMessage.contains('customer') ||
        lowerMessage.contains('client') ||
        lowerMessage.contains('buyer')) {
      classification['customer_query'] = 0.7;
    }

    // Supplier related keywords
    if (lowerMessage.contains('supplier') ||
        lowerMessage.contains('vendor') ||
        lowerMessage.contains('provider')) {
      classification['supplier_query'] = 0.7;
    }

    // Warehouse related keywords
    if (lowerMessage.contains('warehouse') ||
        lowerMessage.contains('storage') ||
        lowerMessage.contains('location')) {
      classification['warehouse_query'] = 0.7;
    }

    // Report related keywords
    if (lowerMessage.contains('report') ||
        lowerMessage.contains('analysis') ||
        lowerMessage.contains('statistic') ||
        lowerMessage.contains('summary')) {
      classification['reporting_query'] = 0.7;
    }

    // Low stock specific query
    if (lowerMessage.contains('low stock') ||
        lowerMessage.contains('out of stock') ||
        lowerMessage.contains('reorder') ||
        lowerMessage.contains('running low')) {
      classification['low_stock_query'] = 0.9;
    }

    return classification;
  }

  /// Extracts entities from the user message with improved matching
  Future<Map<String, List<String>>> _extractEntities(String message) async {
    final messageLower = message.toLowerCase();
    final Map<String, List<String>> entities = {
      'products': [],
      'customers': [],
      'suppliers': [],
      'warehouses': [],
      'sales': [],
      'purchases': [],
      'warehouseDocuments': [],
    };

    // Extract product names
    final productSnapshot = await _firestore.collection('products').get();
    final allProducts = productSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    // Use semantic search for products
    if (messageLower.contains('product') ||
        messageLower.contains('item') ||
        messageLower.contains('stock')) {
      entities['products'] = await _semanticSearch(
          messageLower,
          allProducts,
          'name'
      );
    } else {
      // Direct matching for specific product mentions
      for (final product in allProducts) {
        final productName = product['name'] as String;
        if (messageLower.contains(productName.toLowerCase()) ||
            _fuzzyMatch(messageLower, productName.toLowerCase())) {
          entities['products']!.add(product['id'] as String);
        }
      }
    }

    // Extract customer names
    final customerSnapshot = await _firestore.collection('customers').get();
    final allCustomers = customerSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    // Use semantic search for customers
    if (messageLower.contains('customer') ||
        messageLower.contains('client') ||
        messageLower.contains('buyer')) {
      entities['customers'] = await _semanticSearch(
          messageLower,
          allCustomers,
          'name'
      );
    } else {
      // Direct matching for specific customer mentions
      for (final customer in allCustomers) {
        final customerName = customer['name'] as String;
        if (messageLower.contains(customerName.toLowerCase())) {
          entities['customers']!.add(customer['id'] as String);
        }
      }
    }

    // Extract supplier names
    final supplierSnapshot = await _firestore.collection('suppliers').get();
    final allSuppliers = supplierSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    // Use semantic search for suppliers
    if (messageLower.contains('supplier') ||
        messageLower.contains('vendor') ||
        messageLower.contains('provider')) {
      entities['suppliers'] = await _semanticSearch(
          messageLower,
          allSuppliers,
          'name'
      );
    } else {
      // Direct matching for specific supplier mentions
      for (final supplier in allSuppliers) {
        final supplierName = supplier['name'] as String;
        if (messageLower.contains(supplierName.toLowerCase())) {
          entities['suppliers']!.add(supplier['id'] as String);
        }
      }
    }

    // Extract warehouse names
    final warehouseSnapshot = await _firestore.collection('warehouses').get();
    final allWarehouses = warehouseSnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    // Use semantic search for warehouses
    if (messageLower.contains('warehouse') ||
        messageLower.contains('location') ||
        messageLower.contains('storage')) {
      entities['warehouses'] = await _semanticSearch(
          messageLower,
          allWarehouses,
          'name'
      );
    } else {
      // Direct matching for specific warehouse mentions
      for (final warehouse in allWarehouses) {
        final warehouseName = warehouse['name'] as String;
        if (messageLower.contains(warehouseName.toLowerCase())) {
          entities['warehouses']!.add(warehouse['id'] as String);
        }
      }
    }

    // For sales and purchases, check for order IDs or general mentions
    if (messageLower.contains('sales') ||
        messageLower.contains('order') ||
        messageLower.contains('invoice') ||
        messageLower.contains('revenue')) {
      entities['sales'] = ['all'];
    }

    if (messageLower.contains('purchase') ||
        messageLower.contains('buy') ||
        messageLower.contains('procurement') ||
        messageLower.contains('order')) {
      entities['purchases'] = ['all'];
    }

    if (messageLower.contains('waybill') ||
        messageLower.contains('delivery note') ||
        messageLower.contains('entry waybill') ||
        messageLower.contains('warehouse document') ||
        messageLower.contains('stock movement')) {
      entities['warehouseDocuments'] = ['all'];
    }

    return entities;
  }

  /// Simple fuzzy matching function
  bool _fuzzyMatch(String source, String target) {
    // Skip very short strings to avoid false positives
    if (target.length < 4) return false;

    // Check for substring matches with some tolerance for variations
    return source.contains(target.substring(0, target.length - 1)) ||
        (target.length > 5 && source.contains(target.substring(0, target.length - 2)));
  }

  /// Semantic search implementation
  Future<List<String>> _semanticSearch(
      String query,
      List<Map<String, dynamic>> documents,
      String fieldName
      ) async {
    // Extract meaningful words from the query, ignoring common stopwords
    final stopwords = ['the', 'and', 'is', 'in', 'at', 'on', 'to', 'for', 'with', 'by'];
    final queryWords = query.toLowerCase().split(' ')
        .where((word) => word.length > 3 && !stopwords.contains(word))
        .toList();

    Map<String, int> matchScores = {};

    for (final doc in documents) {
      final content = (doc[fieldName] as String).toLowerCase();
      int score = 0;

      // Check direct word matches
      for (final word in queryWords) {
        if (content.contains(word)) {
          score += 2; // Direct matches score more
        } else if (word.length > 4 && content.contains(word.substring(0, word.length - 1))) {
          score += 1; // Partial matches
        }
      }

      // Consider other fields for additional context
      if (doc.containsKey('description') && doc['description'] != null) {
        final description = (doc['description'] as String).toLowerCase();
        for (final word in queryWords) {
          if (description.contains(word)) {
            score += 1; // Matches in description
          }
        }
      }

      if (score > 0) {
        matchScores[doc['id'] as String] = score;
      }
    }

    // Sort by score and return top matches
    final sortedMatches = matchScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedMatches.take(3).map((e) => e.key).toList();
  }

  /// Retrieves relevant data from Firestore based on entities and the query
  Future<Map<String, dynamic>> _retrieveRelevantData(
      Map<String, List<String>> entities,
      String message
      ) async {
    final Map<String, dynamic> retrievedData = {};
    final messageLower = message.toLowerCase();

    // Determine what kind of query it is based on the classification
    final isProductQuery = _lastQueryClassification['inventory_query']! > 0.5;
    final isCustomerQuery = _lastQueryClassification['customer_query']! > 0.5;
    final isSupplierQuery = _lastQueryClassification['supplier_query']! > 0.5;
    final isWarehouseQuery = _lastQueryClassification['warehouse_query']! > 0.5;
    final isSalesQuery = _lastQueryClassification['sales_query']! > 0.5;
    final isPurchaseQuery = _lastQueryClassification['purchasing_query']! > 0.5;
    final isReportingQuery = _lastQueryClassification['reporting_query']! > 0.5;
    final isLowStockQuery = _lastQueryClassification['low_stock_query']! > 0.5;
    final isWarehouseDocumentQuery = _lastQueryClassification['warehouse_document_query']! > 0.5;
    final isAnalyticsQuery = _lastQueryClassification['analytics_query']! > 0.5;

    // Retrieve product data
    if (isProductQuery || entities['products']!.isNotEmpty) {
      List<Map<String, dynamic>> products = [];

      if (entities['products']!.isEmpty) {
        // Get all products (limited)
        final querySnapshot = await _firestore.collection('products')
            .orderBy('updatedAt', descending: true)
            .limit(100)
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

    // Retrieve analytics data for best-selling queries
    if (isAnalyticsQuery ||
        messageLower.contains('best selling') ||
        messageLower.contains('top selling') ||
        messageLower.contains('most sold')) {

      // Get all delivered sales orders to analyze
      final salesOrdersQuery = await _firestore.collection('sales_orders')
          .where('status', isEqualTo: 'delivered')
          .get();

      // Aggregate product sales
      Map<String, Map<String, dynamic>> productSales = {};

      for (final doc in salesOrdersQuery.docs) {
        final orderData = doc.data();
        final items = orderData['items'] as List<dynamic>;

        for (final item in items) {
          final productId = item['productId'] as String;
          final productName = item['productName'] as String;
          final quantity = item['quantity'] as int;
          final totalPrice = (item['totalPrice'] as num).toDouble();

          if (productSales.containsKey(productId)) {
            productSales[productId]!['quantity'] += quantity;
            productSales[productId]!['revenue'] += totalPrice;
            productSales[productId]!['orderCount'] += 1;
          } else {
            productSales[productId] = {
              'productId': productId,
              'productName': productName,
              'quantity': quantity,
              'revenue': totalPrice,
              'orderCount': 1,
            };
          }
        }
      }

      // Sort by quantity sold (or revenue)
      final sortedProducts = productSales.values.toList()
        ..sort((a, b) => b['quantity'].compareTo(a['quantity']));

      // Get top 10 best sellers
      retrievedData['bestSellingProducts'] = sortedProducts.take(10).toList();
      print(retrievedData['bestSellingProducts']);

      // Also get recent high-value orders
      final highValueOrdersQuery = await _firestore.collection('sales_orders')
          .where('status', isEqualTo: 'delivered')
          .orderBy('totalAmount', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> highValueOrders = [];
      for (final doc in highValueOrdersQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        highValueOrders.add(data);
      }

      retrievedData['highValueOrders'] = highValueOrders;

      // Get customer purchase analytics
      Map<String, Map<String, dynamic>> customerPurchases = {};

      for (final doc in salesOrdersQuery.docs) {
        final orderData = doc.data();
        final customerId = orderData['customerId'] as String;
        final customerName = orderData['customerName'] as String;
        final totalAmount = (orderData['totalAmount'] as num).toDouble();

        if (customerPurchases.containsKey(customerId)) {
          customerPurchases[customerId]!['totalPurchases'] += totalAmount;
          customerPurchases[customerId]!['orderCount'] += 1;
        } else {
          customerPurchases[customerId] = {
            'customerId': customerId,
            'customerName': customerName,
            'totalPurchases': totalAmount,
            'orderCount': 1,
          };
        }
      }

      // Sort by total purchases
      final topCustomers = customerPurchases.values.toList()
        ..sort((a, b) => b['totalPurchases'].compareTo(a['totalPurchases']));

      retrievedData['topCustomers'] = topCustomers.take(5).toList();
    }

    // Retrieve customer data
    if (isCustomerQuery || entities['customers']!.isNotEmpty) {
      List<Map<String, dynamic>> customers = [];

      if (entities['customers']!.isEmpty) {
        // Get all customers (limited)
        final querySnapshot = await _firestore.collection('customers')
            .orderBy('updatedAt', descending: true)
            .limit(100)
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
            .limit(100)
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

    if (isWarehouseDocumentQuery || entities['warehouseDocuments']!.isNotEmpty) {
      List<Map<String, dynamic>> warehouseDocuments = [];

      // Get recent warehouse documents
      final querySnapshot = await _firestore.collection('warehouse_documents')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        warehouseDocuments.add(data);
      }

      retrievedData['warehouseDocuments'] = warehouseDocuments;

      // If asking about pending documents
      if (messageLower.contains('pending')) {
        final pendingQuery = await _firestore.collection('warehouse_documents')
            .where('status', isEqualTo: 'pending')
            .get();

        List<Map<String, dynamic>> pendingDocuments = [];
        for (final doc in pendingQuery.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          pendingDocuments.add(data);
        }

        retrievedData['pendingWarehouseDocuments'] = pendingDocuments;
      }

      // If asking about specific type
      if (messageLower.contains('entry waybill')) {
        final entryWaybillQuery = await _firestore.collection('warehouse_documents')
            .where('type', isEqualTo: 'entryWaybill')
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get();

        List<Map<String, dynamic>> entryWaybills = [];
        for (final doc in entryWaybillQuery.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          entryWaybills.add(data);
        }

        retrievedData['entryWaybills'] = entryWaybills;
      }

      if (messageLower.contains('delivery note')) {
        final deliveryNoteQuery = await _firestore.collection('warehouse_documents')
            .where('type', isEqualTo: 'deliveryNote')
            .orderBy('createdAt', descending: true)
            .limit(100)
            .get();

        List<Map<String, dynamic>> deliveryNotes = [];
        for (final doc in deliveryNoteQuery.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          deliveryNotes.add(data);
        }

        retrievedData['deliveryNotes'] = deliveryNotes;
      }
    }

    // Retrieve sales order data
    if (isSalesQuery || entities['sales']!.isNotEmpty) {
      List<Map<String, dynamic>> salesOrders = [];

      // Get recent sales orders
      final querySnapshot = await _firestore.collection('sales_orders')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        salesOrders.add(data);
      }

      retrievedData['salesOrders'] = salesOrders;

      // If asking about total sales, also get aggregate data
      if (messageLower.contains('total sales') ||
          messageLower.contains('sales total') ||
          messageLower.contains('revenue')) {
        try {
          // Sum up the totals from retrieved orders
          double totalSales = 0;
          for (final order in salesOrders) {
            totalSales += (order['totalAmount'] as num).toDouble();
          }
          retrievedData['totalSales'] = totalSales;
        } catch (e) {
          print('Error calculating total sales: $e');
        }
      }
    }

    // Retrieve purchase order data
    if (isPurchaseQuery || entities['purchases']!.isNotEmpty) {
      List<Map<String, dynamic>> purchaseOrders = [];

      // Get recent purchase orders
      final querySnapshot = await _firestore.collection('purchase_orders')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        purchaseOrders.add(data);
      }

      retrievedData['purchaseOrders'] = purchaseOrders;
    }

    // If nothing was retrieved but we have a query about low stock
    if ((retrievedData.isEmpty || isLowStockQuery) && messageLower.contains('low stock')) {
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
    if (messageLower.contains('total value') ||
        messageLower.contains('inventory value')) {
      final warehouseSnapshot = await _firestore.collection('warehouses').get();

      double totalValue = 0;
      for (final doc in warehouseSnapshot.docs) {
        totalValue += (doc.data()['totalValue'] as num).toDouble();
      }

      retrievedData['totalInventoryValue'] = totalValue;
    }

    return retrievedData;
  }

  /// Enriches queries with domain-specific context
  String _enrichQueryWithDomainLogic(String message, Map<String, dynamic> retrievedData) {
    final lowerMessage = message.toLowerCase();

    // Handle inventory forecasting questions
    if (lowerMessage.contains('forecast') ||
        lowerMessage.contains('predict') ||
        lowerMessage.contains('future stock')) {
      return '''
${_constructPrompt(message, retrievedData)}

Additional Context: The user is asking about inventory forecasting. When responding:
1. Consider current stock levels and historical consumption rates if available
2. Mention that accurate forecasting requires analysis of historical data
3. Suggest reviewing purchase and sales history for better predictions
4. Recommend regular stock audits and setting reorder points
''';
    }

    // Handle analytics and best-selling questions
    if (lowerMessage.contains('best selling') ||
        lowerMessage.contains('top selling') ||
        lowerMessage.contains('most sold') ||
        lowerMessage.contains('top products') ||
        lowerMessage.contains('highest sales')) {
      return '''
${_constructPrompt(message, retrievedData)}

Additional Context: The user is asking about sales analytics. When responding:
1. Focus on delivered orders only (completed sales)
2. Provide rankings with specific numbers (quantities and revenue)
3. Mention both quantity sold and revenue generated
4. If available, show trends or patterns in the data
5. Suggest actions based on the insights (e.g., restock popular items)
6. Consider mentioning top customers if relevant
''';
    }

    // Handle warehouse document questions
    if (lowerMessage.contains('warehouse document') ||
        lowerMessage.contains('waybill') ||
        lowerMessage.contains('delivery note')) {
      return '''
${_constructPrompt(message, retrievedData)}

Additional Context: The user is asking about warehouse documents. When responding:
1. Entry Waybills are created when receiving goods from suppliers (linked to Purchase Orders)
2. Delivery Notes are created when shipping goods to customers (linked to Sales Orders)
3. Documents with 'pending' status need to be processed by warehouse staff
4. Completing a document updates stock levels automatically
5. Cancelled documents may affect the related orders
''';
    }

    // Handle profitability questions
    if (lowerMessage.contains('profit') ||
        lowerMessage.contains('margin') ||
        lowerMessage.contains('revenue')) {
      return '''
${_constructPrompt(message, retrievedData)}

Additional Context: The user is asking about profitability. When responding:
1. Consider product costs vs. selling prices if available
2. Suggest analyzing the sales data by product category
3. Recommend reviewing the income statement for overall profitability
4. Note that individual product profitability requires both cost and sales data
''';
    }

    // Handle low stock questions
    if (lowerMessage.contains('low stock') ||
        lowerMessage.contains('out of stock') ||
        lowerMessage.contains('restock') ||
        lowerMessage.contains('reorder')) {
      return '''
${_constructPrompt(message, retrievedData)}

Additional Context: The user is asking about low stock items. When responding:
1. Clearly list products with quantities below 10 units
2. Suggest reordering these items soon
3. Mention which suppliers provide these products if that information is available
4. Recommend setting up automated alerts for low stock items
''';
    }

    // Handle warehouse-specific questions
    if (_lastQueryClassification['warehouse_query']! > 0.7) {
      return '''
${_constructPrompt(message, retrievedData)}

Additional Context: The user is asking about warehouses. When responding:
1. Provide information about warehouse locations and capacities
2. Mention the total value of inventory in each warehouse
3. Highlight any warehouses that are near capacity or have significant value
4. Suggest regular inventory audits for accurate stock levels
''';
    }

    // Default to standard prompt
    return _constructPrompt(message, retrievedData);
  }

  /// Constructs a prompt with the retrieved data to send to the model
  String _constructPrompt(String userMessage, Map<String, dynamic> retrievedData) {
    String prompt = '''
USER QUERY: $userMessage

CONVERSATION CONTEXT:
${_getRecentConversationSummary()}

RETRIEVED DATA:
''';

    if (retrievedData.isEmpty) {
      prompt += 'No specific data found related to the query. Please provide a general response based on your knowledge of inventory management systems.';
      return prompt;
    }

    if (retrievedData.containsKey('products')) {
      prompt += '\nPRODUCTS:\n';

      for (final product in retrievedData['products']) {
        String stockStatus = "Normal";
        if ((product['quantity'] as int) < 10 && (product['isActive'] as bool)) {
          stockStatus = "LOW STOCK";
        } else if ((product['quantity'] as int) <= 0) {
          stockStatus = "OUT OF STOCK";
        }

        prompt += '''
- ID: ${product['id']}
  Name: ${product['name']}
  Category: ${product['category']}
  Quantity: ${product['quantity']} (Status: $stockStatus)
  Price: ${product['price']}
  Description: ${product['description'] ?? 'N/A'}
  isActive: ${product['isActive']}
''';
      }
    }

    if (retrievedData.containsKey('bestSellingProducts')) {
      prompt += '\nBEST SELLING PRODUCTS:\n';

      int rank = 1;
      for (final product in retrievedData['bestSellingProducts']) {
        prompt += '''
${rank}. ${product['productName']}
   - Total Quantity Sold: ${product['quantity']} units
   - Total Revenue: ${product['revenue']}
   - Number of Orders: ${product['orderCount']}
''';
        rank++;
      }
    }

    if (retrievedData.containsKey('highValueOrders')) {
      prompt += '\nHIGHEST VALUE ORDERS:\n';

      for (final order in retrievedData['highValueOrders']) {
        prompt += '''
- Order ID: ${order['id']}
  Customer: ${order['customerName']}
  Total Amount: ${order['totalAmount']}
  Items: ${(order['items'] as List).length} different products
  Date: ${(order['createdAt'] as Timestamp).toDate().toString()}
''';
      }
    }

    if (retrievedData.containsKey('topCustomers')) {
      prompt += '\nTOP CUSTOMERS BY PURCHASE VALUE:\n';

      int rank = 1;
      for (final customer in retrievedData['topCustomers']) {
        prompt += '''
${rank}. ${customer['customerName']}
   - Total Purchases: ${customer['totalPurchases']}
   - Number of Orders: ${customer['orderCount']}
   - Average Order Value: ${(customer['totalPurchases'] / customer['orderCount']).toStringAsFixed(2)}
''';
        rank++;
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

      if (retrievedData.containsKey('totalSales')) {
        prompt += '\nTOTAL SALES VALUE: ${retrievedData['totalSales']}\n';
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
  Category: ${product['category']}
  Price: ${product['price']}
''';
      }
    }

    if (retrievedData.containsKey('warehouseDocuments')) {
      prompt += '\nWAREHOUSE DOCUMENTS:\n';

      for (final document in retrievedData['warehouseDocuments']) {
        final type = document['type'] == 'entryWaybill' ? 'Entry Waybill' : 'Delivery Note';
        final status = document['status'] ?? 'pending';

        prompt += '''
- Document Number: ${document['documentNumber']}
  Type: $type
  Status: $status
  Warehouse: ${document['warehouseName']}
  Related Order: ${document['relatedOrderNumber'] ?? 'N/A'}
  Created At: ${(document['createdAt'] as Timestamp).toDate().toString()}
  Items Count: ${(document['items'] as List).length}
  Notes: ${document['notes'] ?? 'N/A'}
''';
      }
    }

    if (retrievedData.containsKey('pendingWarehouseDocuments')) {
      prompt += '\nPENDING WAREHOUSE DOCUMENTS:\n';

      for (final document in retrievedData['pendingWarehouseDocuments']) {
        final type = document['type'] == 'entryWaybill' ? 'Entry Waybill' : 'Delivery Note';

        prompt += '''
- Document Number: ${document['documentNumber']}
  Type: $type
  Warehouse: ${document['warehouseName']}
  Related Order: ${document['relatedOrderNumber'] ?? 'N/A'}
  Items Count: ${(document['items'] as List).length}
''';
      }
    }

    if (retrievedData.containsKey('entryWaybills')) {
      prompt += '\nRECENT ENTRY WAYBILLS (Goods Received):\n';

      for (final document in retrievedData['entryWaybills']) {
        prompt += '''
- Document Number: ${document['documentNumber']}
  Status: ${document['status']}
  Warehouse: ${document['warehouseName']}
  Related Purchase Order: ${document['relatedOrderNumber'] ?? 'N/A'}
  Supplier: ${document['metadata']?['supplierName'] ?? 'N/A'}
  Created: ${(document['createdAt'] as Timestamp).toDate().toString()}
''';
      }
    }

    if (retrievedData.containsKey('deliveryNotes')) {
      prompt += '\nRECENT DELIVERY NOTES (Goods Shipped):\n';

      for (final document in retrievedData['deliveryNotes']) {
        prompt += '''
- Document Number: ${document['documentNumber']}
  Status: ${document['status']}
  Warehouse: ${document['warehouseName']}
  Related Sales Order: ${document['relatedOrderNumber'] ?? 'N/A'}
  Customer: ${document['metadata']?['customerName'] ?? 'N/A'}
  Created: ${(document['createdAt'] as Timestamp).toDate().toString()}
''';
      }
    }

    if (retrievedData.containsKey('totalInventoryValue')) {
      prompt += '\nTOTAL INVENTORY VALUE: ${retrievedData['totalInventoryValue']}\n';
    }

    prompt += '\nBased on the above data, please provide a concise and accurate answer to the user query. Format currency values with appropriate symbols and use proper units for quantities. If data is missing to fully answer the query, acknowledge what information would be needed.';

    return prompt;
  }

  /// Gets a summary of recent conversation for context
  String _getRecentConversationSummary() {
    if (_history.length <= 2) return "This is a new conversation.";

    // Get last few exchanges
    final recentExchanges = _history.sublist(max(0, _history.length - 6));

    // Convert to string summary
    StringBuffer summary = StringBuffer();
    for (var i = 0; i < recentExchanges.length; i++) {
      final content = recentExchanges[i];
      final role = i % 2 == 0 ? "User" : "Assistant";

      // Extract text properly based on the actual structure
      String text = "";
      if (content.parts.isNotEmpty) {
        final part = content.parts.first;
        if (part is TextPart) {
          text = part.text;
        }
      }

      // Limit long responses
      final displayText = text.length > 100
          ? "${text.substring(0, 100)}..."
          : text;

      summary.writeln("$role: $displayText");
    }

    return summary.toString();
  }

  /// Generates a fallback response when API calls fail
  String _generateFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('stock') || lowerMessage.contains('inventory')) {
      return "I don't have specific information about the current inventory, but you can check the Products section for the most up-to-date stock levels. Would you like me to help with something else about inventory management?";
    }

    if (lowerMessage.contains('best selling') ||
        lowerMessage.contains('top selling') ||
        lowerMessage.contains('most sold')) {
      return "I couldn't retrieve the sales analytics data at this moment. You can view detailed sales reports including best-selling products in the Sales Report section. This will show you product performance, revenue analytics, and customer insights. Is there something else I can help you with?";
    }

    if (lowerMessage.contains('sales') || lowerMessage.contains('order')) {
      return "I couldn't find detailed information about sales orders at the moment. You can view complete sales data in the Sales Orders section of the application. Is there anything else I can assist with?";
    }

    if (lowerMessage.contains('customer')) {
      return "I don't have specific customer information available right now. You can find detailed customer data in the Customers section. Would you like help with another topic?";
    }

    if (lowerMessage.contains('warehouse document') ||
        lowerMessage.contains('waybill') ||
        lowerMessage.contains('delivery note')) {
      return "I don't have specific information about warehouse documents at the moment. You can view all warehouse documents including entry waybills and delivery notes in the Warehouse Documents section. Would you like help with something else?";
    }

    if (lowerMessage.contains('supplier') || lowerMessage.contains('vendor')) {
      return "I couldn't access specific supplier information at this time. You can view all supplier details in the Suppliers section. Is there something else I can help with?";
    }

    if (lowerMessage.contains('warehouse') || lowerMessage.contains('location')) {
      return "I don't have detailed warehouse information available right now. You can find warehouse data including inventory levels in the Warehouses section. Would you like me to help with something else?";
    }

    return "I'm sorry, I couldn't find the information you're looking for. Please try asking in a different way or check the relevant section in the application directly. Is there something else I can assist with?";
  }

  /// Clears the conversation history and memory
  void clearHistory() {
    _history.clear();

    // Reset conversation memory
    for (final key in _conversationMemory.keys) {
      _conversationMemory[key] = [];
    }

    // Reset classification
    _lastQueryClassification = {};
  }
}