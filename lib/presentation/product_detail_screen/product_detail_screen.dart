import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:mc_dashboard/domain/entities/product.dart';
import 'package:mc_dashboard/presentation/product_detail_screen/product_detail_view_model.dart';

import 'package:provider/provider.dart';

// ignore: depend_on_referenced_packages

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final TextEditingController _subjectIdController = TextEditingController();
  final TextEditingController _vendorCodeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _packLengthController = TextEditingController();
  final TextEditingController _packWidthController = TextEditingController();
  final TextEditingController _packHeightController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();

  List<TextEditingController> _charControllers = [];
  bool _isProductCreated = false;

  // Список извлечённых изображений и выбранные индексы
  List<Uint8List> _extractedImages = [];
  final Set<int> _selectedImageIndices = {};

  @override
  void dispose() {
    _subjectIdController.dispose();
    _vendorCodeController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _packLengthController.dispose();
    _packWidthController.dispose();
    _packHeightController.dispose();
    for (final ctrl in _charControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _initializeCharControllers(ProductDetailViewModel viewModel) {
    _charControllers = List.generate(
      viewModel.charcs.length,
      (_) => TextEditingController(),
    );
  }

  // Извлекает изображения из zip-архива
  Future<void> _loadImages() async {
    // Путь к архиву: Env.inputPath + widget.product.zipFileName
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.isEmpty) {
      // Пользователь отменил выбор
      return;
    }

    // Получаем байты выбранного файла
    final pickedFile = result.files.first;
    final zipBytes = pickedFile.bytes;
    if (zipBytes == null) {
      // Не удалось считать байты
      return;
    }

    // Распаковываем архив
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final images = <Uint8List>[];

    for (final file in archive) {
      if (file.isFile && file.name.toLowerCase().endsWith('.jpg')) {
        final data = file.content as List<int>;
        images.add(Uint8List.fromList(data));
      }
    }

    setState(() {
      _extractedImages = images; // Ваш список Uint8List
    });
  }

  final List<SpeedDialChild> speedDialChildren = [
    SpeedDialChild(
      child: const Icon(Icons.shopping_bag),
      label: 'https://www.wildberries.ru/', // URL
    ),
    SpeedDialChild(
      child: const Icon(Icons.store),
      label: 'https://seller.wildberries.ru/', // URL
    ),
    SpeedDialChild(
      child: const Icon(Icons.shopping_cart),
      label: 'https://www.ozon.ru/', // URL
    ),
    SpeedDialChild(
      child: const Icon(Icons.business),
      label: 'https://seller.ozon.ru/app/dashboard/main', // URL
    ),
    SpeedDialChild(
      child: const Icon(Icons.dashboard),
      label: '/dashboard', // Локальный маршрут в приложении
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.charcs.isNotEmpty && _charControllers.isEmpty) {
          _initializeCharControllers(viewModel);
        }
        return Scaffold(
          appBar: AppBar(title: Text(widget.product.title)),
          floatingActionButton: SpeedDial(
            children: speedDialChildren,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfoSection(),
                  const SizedBox(height: 20),
                  _buildFetchCharacteristicsButton(viewModel),
                  const SizedBox(height: 20),
                  _buildCompactFields(),
                  const SizedBox(height: 20),
                  _buildMultilineTextField(_titleController, "title",
                      maxLength: 60),
                  const SizedBox(height: 20),
                  _buildMultilineTextField(_descController, "description",
                      maxLength: 2000),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _productIdController,
                        decoration: const InputDecoration(
                          labelText: "Введите productID",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          final productId = _productIdController.text.trim();
                          if (productId.isNotEmpty) {
                            viewModel.fetchCardInfoAndMergeCharacteristics(
                                productId, _charControllers);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Введите корректный productID')),
                            );
                          }
                        },
                        child: const Text("Загрузить данные карточки"),
                      ),
                    ],
                  ),
                  _buildCharcsForm(viewModel),
                  const SizedBox(height: 30),
                  _buildActionButtons(viewModel),
                  const SizedBox(height: 20),
                  if (_isProductCreated && _extractedImages.isNotEmpty)
                    _buildImageSelection(viewModel),
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (viewModel.errorMessage != null)
                    Center(
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Отображение данных товара
  Widget _buildProductInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCopyableText('Название', widget.product.title),
        _buildCopyableText('Описание', widget.product.description),
        _buildCopyableText('Ссылка', widget.product.url),
        ...widget.product.properties.entries
            .map((entry) => _buildCopyableText(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildCopyableText(String label, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(color: Colors.blue)),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label скопировано')),
            );
          },
        ),
      ),
    );
  }

  // Кнопка для загрузки характеристик
  Widget _buildFetchCharacteristicsButton(ProductDetailViewModel viewModel) {
    return ElevatedButton(
      onPressed: () {
        final subjectId = int.tryParse(_subjectIdController.text);
        if (subjectId != null) {
          viewModel.fetchData(subjectId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Введите корректный subjectID')),
          );
        }
      },
      child: const Text("Загрузить характеристики"),
    );
  }

  Widget _buildCompactFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  _subjectIdController, "subjectID", TextInputType.number),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                  _vendorCodeController, "vendorCode", TextInputType.text),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  _packLengthController, "Длина (см)", TextInputType.number),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                  _packWidthController, "Ширина (см)", TextInputType.number),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                  _packHeightController, "Высота (см)", TextInputType.number),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      TextInputType keyboardType) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildMultilineTextField(
      TextEditingController controller, String label,
      {int? maxLength}) {
    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          controller: controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            labelText: "$label (${controller.text.length}/${maxLength ?? '∞'})",
            border: const OutlineInputBorder(),
            errorText: (maxLength != null && controller.text.length > maxLength)
                ? "Превышено максимальное количество символов ($maxLength)"
                : null,
          ),
          onChanged: (text) => setState(() {}),
        );
      },
    );
  }

  Widget _buildCharcsForm(ProductDetailViewModel viewModel) {
    if (_charControllers.length < viewModel.charcs.length) {
      _charControllers.addAll(
        List.generate(viewModel.charcs.length - _charControllers.length,
            (_) => TextEditingController()),
      );
    } else if (_charControllers.length > viewModel.charcs.length) {
      _charControllers = _charControllers.sublist(0, viewModel.charcs.length);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: viewModel.charcs.map((charc) {
        final index = viewModel.charcs.indexOf(charc);
        final controller = _charControllers[index];
        final List<String> options =
            viewModel.getCharacteristicOptions(charc.name);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                charc.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              if (options.isNotEmpty)
                DropdownButtonFormField<String>(
                  items: options.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.text = value;
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Выберите значение",
                  ),
                ),
              const SizedBox(height: 5),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Или введите своё значение",
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(ProductDetailViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () async {
            await viewModel.generateFullProductJson(
              _vendorCodeController.text.trim(),
              _titleController.text.trim(),
              _descController.text.trim(),
              _packLengthController.text.trim(),
              _packWidthController.text.trim(),
              _packHeightController.text.trim(),
              _charControllers,
            );
            setState(() {
              _isProductCreated = true;
            });
            await _loadImages();
          },
          child: const Text("Создать"),
        ),
        const SizedBox(height: 10),
        if (_isProductCreated && _extractedImages.isNotEmpty)
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              // Запрашиваем nmId через всплывающее окно
              final nmId = await showDialog<String>(
                context: context,
                builder: (context) {
                  final TextEditingController nmIdController =
                      TextEditingController();
                  return AlertDialog(
                    title: const Text('Введите nmId'),
                    content: TextField(
                      controller: nmIdController,
                      decoration: const InputDecoration(labelText: 'nmId'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pop(nmIdController.text.trim()),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );

              if (nmId != null && nmId.isNotEmpty) {
                final selectedImages = _selectedImageIndices
                    .map((index) => _extractedImages[index])
                    .toList();
                await viewModel.uploadProductImages(selectedImages, nmId);
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('nmId не может быть пустым')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Загрузить изображения"),
          ),
      ],
    );
  }

  Widget _buildImageSelection(ProductDetailViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Выберите изображения для загрузки:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _extractedImages.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedImageIndices.contains(index);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedImageIndices.remove(index);
                  } else {
                    _selectedImageIndices.add(index);
                  }
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    _extractedImages[index],
                    fit: BoxFit.cover,
                  ),
                  if (isSelected)
                    Container(
                      color: Colors.black45,
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 30),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            if (_selectedImageIndices.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Выберите хотя бы одно изображение')),
              );
              return;
            }

            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final nmId = await showDialog<String>(
              context: context,
              builder: (context) {
                final TextEditingController nmIdController =
                    TextEditingController();
                return AlertDialog(
                  title: const Text('Введите nmId'),
                  content: TextField(
                    controller: nmIdController,
                    decoration: const InputDecoration(labelText: 'nmId'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(nmIdController.text.trim()),
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );

            if (nmId != null && nmId.isNotEmpty) {
              final selectedImages = _selectedImageIndices
                  .map((index) => _extractedImages[index])
                  .toList();
              await viewModel.uploadProductImages(selectedImages, nmId);

              // Сбрасываем выбор после загрузки
              setState(() {
                _selectedImageIndices.clear();
              });

              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Изображения успешно загружены')),
              );
            } else {
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('nmId не может быть пустым')),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("Загрузить изображения"),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
