import 'package:ecommerce/core/widgets/glass_container.dart';
import 'package:ecommerce/core/widgets/glass_widgets.dart';
import 'package:ecommerce/features/home/domain/models/product.dart';
import 'package:ecommerce/features/home/presentation/providers/product_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:toastification/toastification.dart';

/// A dialog for adding a new product or editing an existing one.
/// 
/// If [product] is provided, the dialog initializes with its data for editing.
/// Otherwise, it acts as a form to create a new product.
class AddEditProductDialog extends ConsumerStatefulWidget {
  /// The product to edit, or null if adding a new product.
  final Product? product;

  const AddEditProductDialog({super.key, this.product});

  @override
  ConsumerState<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends ConsumerState<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(productsProvider.notifier);
      final productData = {
        'title': _titleController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text,
      };

      if (widget.product != null) {
        await notifier.updateProduct(widget.product!.id, productData);
        if (mounted) {
          toastification.show(
            context: context,
            title: const Text('Product updated successfully'),
            // description: const Text('Changes have been simulated locally'),
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 4),
          );
        }
      } else {
        await notifier.addProduct(productData);
        if (mounted) {
          toastification.show(
            context: context,
            title: const Text('Product added successfully'),
            // description: const Text('New product added to local state'),
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 4),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: const Text('Error'),
          description: Text(e.toString()),
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            opacity: 0.1,
            child: Material(
              color: Colors.transparent,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.product != null ? 'Edit Product' : 'Add Product',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassTextField(
                      controller: _titleController,
                      label: 'Product Title',
                      prefixIcon: Iconsax.box,
                      validator: (v) => v!.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                      controller: _priceController,
                      label: 'Price',
                      prefixIcon: Iconsax.dollar_circle,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Price is required' : null,
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      prefixIcon: Iconsax.document_text,
                      validator: (v) => v!.isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            label: 'Cancel',
                            color: Colors.white,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassButton(
                            label: widget.product != null ? 'Update' : 'Add',
                            isLoading: _isLoading,
                            onPressed: _submit,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
