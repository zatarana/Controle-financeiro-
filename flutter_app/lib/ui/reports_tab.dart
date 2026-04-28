import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/finance_provider.dart';
import '../core/finance_models.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  // true = Data de Lançamento/Vencimento (Previsto/Competência)
  // false = Data de Efetivação/Pagamento (Caixa)
  bool _useCompetencia = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    var validTransactions = provider.transactions.where((t) => !t.ignoreInStats).toList();

    if (!_useCompetencia) {
      validTransactions = validTransactions.where((t) => t.isPaid).toList();
    }

    final expenses = validTransactions
        .where((t) => t.type == TransactionType.expense || t.type == TransactionType.creditCardExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final income = validTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final total = expenses + income;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resumo Financeiro',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Configurações dos relatórios',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Auditoria visual dos seus ganhos e gastos',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Regime de Caixa (Realizado)')),
              ButtonSegment(value: true, label: Text('Competência (Previsto)')),
            ],
            selected: {_useCompetencia},
            onSelectionChanged: (Set<bool> val) => setState(() => _useCompetencia = val.first),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: total == 0
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Nenhuma transação encontrada.',
                        style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 70,
                            startDegreeOffset: 270,
                            sections: [
                              if (expenses > 0)
                                PieChartSectionData(
                                  color: Colors.black,
                                  value: expenses,
                                  title: '${((expenses / total) * 100).toStringAsFixed(0)}%',
                                  radius: 24,
                                  titleStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              if (income > 0)
                                PieChartSectionData(
                                  color: const Color(0xFFE5E7EB),
                                  value: income,
                                  title: '${((income / total) * 100).toStringAsFixed(0)}%',
                                  radius: 24,
                                  titleStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem(Colors.black, 'Despesas', expenses, currencyFormat),
                          Container(width: 1, height: 40, color: const Color(0xFFF3F4F6)),
                          _buildLegendItem(const Color(0xFFE5E7EB), 'Receitas', income, currencyFormat),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Dívidas vs Empréstimos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dívidas Restantes',
                      style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(provider.totalUnpaidDebts),
                      style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: const Color(0xFFF3F4F6)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Empréstimos Rest.',
                      style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(provider.totalUnpaidLoans),
                      style: const TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, double amount, NumberFormat format) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(format.format(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5)),
      ],
    );
  }
}
