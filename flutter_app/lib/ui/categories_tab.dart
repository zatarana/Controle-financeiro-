import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/finance_provider.dart';
import '../core/finance_models.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  void _showAddEditCategoryDialog(BuildContext context, [FinanceCategory? category]) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    CategoryType selectedType = category?.type ?? CategoryType.expense;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(category == null ? 'Nova Categoria' : 'Editar Categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome da Categoria', hintText: 'Ex: Moradia, Transporte'),
              ),
              const SizedBox(height: 16),
              if (category == null) DropdownButtonFormField<CategoryType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: CategoryType.expense, child: Text('Despesa')),
                  DropdownMenuItem(value: CategoryType.income, child: Text('Receita')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedType = val);
                  }
                },
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  final provider = context.read<FinanceProvider>();
                  if (category == null) {
                    final newCat = FinanceCategory(
                      id: DateTime.now().toString(),
                      name: nameCtrl.text,
                      type: selectedType,
                      subcategories: [FinanceSubcategory(id: 'outros', name: 'Outros')],
                    );
                    provider.categories.add(newCat);
                  } else {
                    category.name = nameCtrl.text;
                  }
                  provider.saveData();
                  provider.notifyListeners();
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Salvar'),
            )
          ],
        )
      )
    );
  }

  void _showAddEditSubcategoryDialog(BuildContext context, FinanceCategory category, [FinanceSubcategory? subcategory]) {
    if (subcategory?.id == 'outros') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A subcategoria "Outros" não pode ser editada.')));
      return;
    }
    
    final nameCtrl = TextEditingController(text: subcategory?.name ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(subcategory == null ? 'Nova Subcategoria em \${category.name}' : 'Editar Subcategoria'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Nome da Subcategoria', hintText: 'Ex: Aluguel, IPTU...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final provider = context.read<FinanceProvider>();
                if (subcategory == null) {
                  category.subcategories.add(FinanceSubcategory(id: DateTime.now().toString(), name: nameCtrl.text));
                } else {
                  subcategory.name = nameCtrl.text;
                }
                provider.saveData();
                provider.notifyListeners();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddEditCategoryDialog(context),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final cat = provider.categories[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFF3F4F6))),
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: Icon(
                cat.type == CategoryType.expense ? Icons.remove_circle_outline : Icons.add_circle_outline,
                color: cat.type == CategoryType.expense ? Colors.red : Colors.green,
              ),
              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(cat.type == CategoryType.expense ? 'Despesa' : 'Receita', style: const TextStyle(fontSize: 12)),
              children: [
                ...cat.subcategories.map((subcat) => ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 40),
                   title: Text(subcat.name),
                   trailing: subcat.id == 'outros' ? null : Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () => _showAddEditSubcategoryDialog(context, cat, subcat)),
                       IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: () {
                          cat.subcategories.remove(subcat);
                          provider.saveData();
                          provider.notifyListeners();
                       }),
                     ],
                   ),
                )),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 40),
                  leading: const Icon(Icons.subdirectory_arrow_right, color: Colors.black54),
                  title: const Text('Nova subcategoria', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                  onTap: () => _showAddEditSubcategoryDialog(context, cat),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar Categoria'),
                        onPressed: () => _showAddEditCategoryDialog(context, cat),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                        label: const Text('Excluir Categoria', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                           provider.categories.remove(cat);
                           provider.saveData();
                           provider.notifyListeners();
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
