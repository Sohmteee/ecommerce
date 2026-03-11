import 'package:ecommerce/core/widgets/glass_container.dart';
import 'package:ecommerce/core/widgets/glass_widgets.dart';
import 'package:ecommerce/features/home/domain/models/product.dart';
import 'package:ecommerce/features/home/presentation/providers/product_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:toastification/toastification.dart';

/// A dialog to confirm the deletion of a [product].
class DeleteConfirmationDialog extends ConsumerStatefulWidget {
  /// The product targeted for deletion.
  final Product product;

  const DeleteConfirmationDialog({super.key, required this.product});

  @override
  ConsumerState<DeleteConfirmationDialog> createState() => _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends ConsumerState<DeleteConfirmationDialog> {
  bool _isLoading = false;

  Future<void> _delete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(productsProvider.notifier);
      await notifier.deleteProduct(widget.product.id);
      
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('${widget.product.title} deleted'),
          // description: const Text('Deletion simulated successfully'),
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(seconds: 4),
        );
        Navigator.pop(context);
      }
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          opacity: 0.1,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlassContainer(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  opacity: 0.1,
                  padding: EdgeInsets.all(16),
                  child: Icon(Iconsax.trash, color: Colors.red, size: 32),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Delete Product?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "${widget.product.title}"? This action is simulated and cannot be undone.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
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
                        label: 'Delete',
                        color: Colors.red,
                        isLoading: _isLoading,
                        onPressed: _delete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
