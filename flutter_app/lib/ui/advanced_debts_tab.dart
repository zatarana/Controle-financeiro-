import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/finance_provider.dart';
import '../core/debt_models.dart';
import 'debt_detail_page.dart';
import 'add_advanced_debt_form.dart';

class AdvancedDebtsTab extends StatelessWidget {
  const AdvancedDebtsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final debts = provider.advancedDebts;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: debts.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.black26),
                const SizedBox(height: 16),
                const Text('Nenhuma dívida cadastrada.', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Cadastrar Dívida'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showAddDebtForm(context),
                )
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: debts.length,
            itemBuilder: (context, index) {
              final debt = debts[index];
              final progress = debt.progressPercentage;
              Color statusColor = Colors.orange;
              String statusText = 'Pendente';
              
              if (debt.status == DebtStatus.emPagamento) {
                statusColor = Colors.blue;
                statusText = 'Em Pagamento';
              } else if (debt.status == DebtStatus.quitada) {
                statusColor = Colors.green;
                statusText = 'Quitada';
              } else if (debt.status == DebtStatus.renegociada) {
                statusColor = Colors.purple;
                statusText = 'Renegociada';
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DebtDetailPage(debtId: debt.id)));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF3F4F6))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(debt.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5)),
                                const SizedBox(height: 4),
                                Text(debt.creditor, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Valor Original', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(currencyFormat.format(debt.originalTotalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Saldo Devedor', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(currencyFormat.format(debt.currentBalance), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\${(progress * 100).toStringAsFixed(1)}% pago', style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
                          if (debt.generatedEconomy > 0)
                            Text('Economia original: \${currencyFormat.format(debt.generatedEconomy)}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: debts.isNotEmpty // Exibe o FAB apenas se a lista não estiver vazia (pois se vazia, já tem o botão central)
          ? FloatingActionButton(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              onPressed: () => _showAddDebtForm(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddDebtForm(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => const AddAdvancedDebtForm()
    );
  }
}
