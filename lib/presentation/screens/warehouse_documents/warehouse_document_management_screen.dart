import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/warehouse_documents/warehouse_document_bloc.dart';
import '../../../data/models/warehouse_document_model.dart';
import '../../../utils/formatter.dart';
import '../../widgets/common/custom_search_field.dart';
import '../../widgets/warehouse_documents/warehouse_document_details_dialog.dart';
import '../../widgets/warehouse_documents/warehouse_document_list.dart';

class WarehouseDocumentsScreen extends StatefulWidget {
  const WarehouseDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<WarehouseDocumentsScreen> createState() => _WarehouseDocumentsScreenState();
}

class _WarehouseDocumentsScreenState extends State<WarehouseDocumentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  WarehouseDocumentType? _selectedType;
  String? _selectedWarehouseId;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    context.read<WarehouseDocumentBloc>().add(const LoadWarehouseDocuments());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 16),
            _buildStatisticsCards(),
            const SizedBox(height: 24),
            Expanded(
              child: _buildDocumentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Warehouse Documents',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Manual create button could be added here if needed
      ],
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: 300,
          child: CustomSearchField(
            controller: _searchController,
            hintText: 'Search documents...',
            onChanged: (value) {
              context.read<WarehouseDocumentBloc>().add(
                SearchWarehouseDocuments(value),
              );
            },
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<WarehouseDocumentType>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Document Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Types'),
              ),
              DropdownMenuItem(
                value: WarehouseDocumentType.entryWaybill,
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    const Text('Entry Waybill'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: WarehouseDocumentType.deliveryNote,
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text('Delivery Note'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
              context.read<WarehouseDocumentBloc>().add(
                FilterWarehouseDocumentsByType(value),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return BlocBuilder<WarehouseDocumentBloc, WarehouseDocumentState>(
      builder: (context, state) {
        if (state is! WarehouseDocumentsLoaded) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 120, // adjust to fit your card height + padding
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard(
                  'Entry Waybills',
                  state.entryWaybillCount.toString(),
                  Icons.arrow_downward,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Delivery Notes',
                  state.deliveryNoteCount.toString(),
                  Icons.arrow_upward,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Pending',
                  state.pendingCount.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return BlocBuilder<WarehouseDocumentBloc, WarehouseDocumentState>(
      builder: (context, state) {
        if (state is WarehouseDocumentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WarehouseDocumentError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadDocuments,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is WarehouseDocumentsLoaded) {
          if (state.documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No documents found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Documents will appear here when orders are received or shipped',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return WarehouseDocumentList(
            documents: state.documents,
            onViewDetails: (document) {
              showDialog(
                context: context,
                builder: (context) => WarehouseDocumentDetailsDialog(document: document),
              );
            },
            onStatusUpdate: (document, status) {
              context.read<WarehouseDocumentBloc>().add(
                UpdateWarehouseDocumentStatus(document.id, status),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}