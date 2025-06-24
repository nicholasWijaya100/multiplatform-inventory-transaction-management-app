import 'package:flutter/material.dart';

class ProductColorPicker extends StatefulWidget {
  final String? initialColor;
  final Function(String?) onColorChanged;
  final List<String> existingColors;

  const ProductColorPicker({
    Key? key,
    this.initialColor,
    required this.onColorChanged,
    this.existingColors = const [],
  }) : super(key: key);

  @override
  State<ProductColorPicker> createState() => _ProductColorPickerState();
}

class _ProductColorPickerState extends State<ProductColorPicker> {
  String? selectedColor;
  final TextEditingController customColorController = TextEditingController();
  bool showCustomInput = false;

  // Predefined color options
  static const List<String> predefinedColors = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
    'Purple',
    'Pink',
    'Brown',
    'Black',
    'White',
    'Gray',
    'Navy',
    'Maroon',
    'Teal',
    'Lime',
    'Olive',
    'Silver',
    'Gold',
  ];

  // Color mappings for visual representation
  static const Map<String, Color> colorMap = {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.yellow,
    'Orange': Colors.orange,
    'Purple': Colors.purple,
    'Pink': Colors.pink,
    'Brown': Colors.brown,
    'Black': Colors.black,
    'White': Colors.white,
    'Gray': Colors.grey,
    'Navy': Color(0xFF000080),
    'Maroon': Color(0xFF800000),
    'Teal': Colors.teal,
    'Lime': Colors.lime,
    'Olive': Color(0xFF808000),
    'Silver': Color(0xFFC0C0C0),
    'Gold': Color(0xFFFFD700),
  };

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
    if (selectedColor != null && !predefinedColors.contains(selectedColor)) {
      customColorController.text = selectedColor!;
      showCustomInput = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),

        // Display selected color
        if (selectedColor != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getColorFromName(selectedColor!),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[400]!,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedColor!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      selectedColor = null;
                      customColorController.clear();
                      showCustomInput = false;
                    });
                    widget.onColorChanged(null);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Predefined colors grid
        if (selectedColor == null) ...[
          Text(
            'Choose a color:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // Predefined color grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: predefinedColors.length,
            itemBuilder: (context, index) {
              final colorName = predefinedColors[index];
              final color = colorMap[colorName] ?? Colors.grey;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = colorName;
                    showCustomInput = false;
                    customColorController.clear();
                  });
                  widget.onColorChanged(colorName);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[400]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: colorName == 'White'
                      ? Center(
                    child: Text(
                      colorName[0],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : null,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Existing colors from database
          if (widget.existingColors.isNotEmpty) ...[
            Text(
              'Recently used colors:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.existingColors
                  .where((color) => !predefinedColors.contains(color))
                  .take(10)
                  .map((colorName) => GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = colorName;
                    showCustomInput = false;
                    customColorController.clear();
                  });
                  widget.onColorChanged(colorName);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    colorName,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Custom color input
          Row(
            children: [
              Expanded(
                child: showCustomInput
                    ? TextField(
                  controller: customColorController,
                  decoration: const InputDecoration(
                    labelText: 'Custom color name',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Sky Blue, Dark Red',
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      setState(() {
                        selectedColor = value.trim();
                        showCustomInput = false;
                      });
                      widget.onColorChanged(value.trim());
                    }
                  },
                )
                    : OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      showCustomInput = true;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add custom color'),
                ),
              ),
              if (showCustomInput) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (customColorController.text.trim().isNotEmpty) {
                      setState(() {
                        selectedColor = customColorController.text.trim();
                        showCustomInput = false;
                      });
                      widget.onColorChanged(customColorController.text.trim());
                    }
                  },
                  icon: const Icon(Icons.check),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      showCustomInput = false;
                      customColorController.clear();
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Color _getColorFromName(String colorName) {
    return colorMap[colorName] ?? Colors.grey[400]!;
  }

  @override
  void dispose() {
    customColorController.dispose();
    super.dispose();
  }
}