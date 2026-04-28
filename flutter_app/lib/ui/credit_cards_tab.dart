import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/finance_provider.dart';
import '../core/finance_models.dart';

class CreditCardsPage extends StatefulWidget {
  const CreditCardsPage({super.key});

  @override
  State<CreditCardsPage> createState() => _CreditCardsPageState();
}

class _CreditCardsPageState extends State<CreditCardsPage> {
  void _showAddEditCreditCardDialog(BuildContext context, [CreditCard? card]) {
    final nameCtrl = TextEditingController(text: card?.name ?? '');
    final limitCtrl = TextEditingController(text: card?.limit.toString() ?? '');
    final closingDayCtrl = TextEditingController(text: card?.closingDay.toString() ?? '');
    final dueDayCtrl = TextEditingController(text: card?.dueDay.toString() ?? '');
    
    final provider = context.read<FinanceProvider>();
    String? selectedAccountId = card?.defaultAccountId ?? (provider.accounts.isNotEmpty ? provider.accounts.first.id : null);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(card == null ? 'Novo Cartão' : 'Editar Cartão'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome da fatura (ex: Cartão NuBank)')),
                const SizedBox(height: 16),
                TextField(controller: limitCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Limite do Cartão')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(controller: closingDayCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dia de Fechamento'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: dueDayCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dia de Vencimento'))),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Conta para pagamento'),
                  value: selectedAccountId,
                  items: provider.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedAccountId = v),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && selectedAccountId != null) {
                   if (card == null) {
                     provider.creditCards.add(CreditCard(
                       id: DateTime.now().toString(),
                       name: nameCtrl.text,
                       limit: double.tryParse(limitCtrl.text.replaceAll(',', '.')) ?? 0,
                       closingDay: int.tryParse(closingDayCtrl.text) ?? 1,
                       dueDay: int.tryParse(dueDayCtrl.text) ?? 5,
                       defaultAccountId: selectedAccountId!
                     ));
                   } else {
                     card.name = nameCtrl.text;
                     card.limit = double.tryParse(limitCtrl.text.replaceAll(',', '.')) ?? 0;
                     card.closingDay = int.tryParse(closingDayCtrl.text) ?? 1;
                     card.dueDay = int.tryParse(dueDayCtrl.text) ?? 5;
                     card.defaultAccountId = selectedAccountId!;
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Cartões de Crédito')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddEditCreditCardDialog(context),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.creditCards.length,
        itemBuilder: (context, index) {
          final card = provider.creditCards[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFF3F4F6))),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.credit_card, color: Colors.red),
              ),
              title: Text(card.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Fecha dia \${card.closingDay} • Vence dia \${card.dueDay}\nLimite: R\$ \${card.limit.toStringAsFixed(2)}', style: const TextStyle(height: 1.4)),
              trailing: PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') _showAddEditCreditCardDialog(context, card);
                  if (val == 'delete') {
                    provider.creditCards.remove(card);
                    provider.saveData();
                    provider.notifyListeners();
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
