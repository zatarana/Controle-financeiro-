import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/finance_provider.dart';
import 'package:intl/intl.dart';
import 'advanced_debts_tab.dart'; // Módulo de dívidas

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const AdvancedDebtsTab(),
    const ReportsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinançaPro'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.sync, size: 12, color: Colors.green),
                SizedBox(width: 4),
                Text('Sync Local', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Visão Geral'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Módulo Dívidas'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Auditoria'),
        ],
      ),
      floatingActionButton: _currentIndex != 1 ? FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context),
      ) : null,
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, bottom: 16),
                child: Text('Novo Registro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.swap_horiz, color: Colors.black87),
                ),
                title: const Text('Nova Transação', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Adicionar receita ou despesa', style: TextStyle(fontSize: 12, color: Colors.black54)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showTransactionForm(context);
                },
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: Color(0xFFF3F4F6), height: 1)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                ),
                title: const Text('Nova Dívida/Empréstimo', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Controlar valores a pagar e receber', style: TextStyle(fontSize: 12, color: Colors.black54)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDebtLoanForm(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
    });
  }

  void _showTransactionForm(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isExpense = true;
    
    showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Lançar Transação', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 24),
              TextField(
                controller: titleCtrl, 
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black)),
                )
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl, 
                keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black)),
                )
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isExpense = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isExpense ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
                          border: Border.all(color: isExpense ? Colors.red : Colors.transparent),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        alignment: Alignment.center,
                        child: Text('Despesa', style: TextStyle(color: isExpense ? Colors.red : Colors.black54, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isExpense = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isExpense ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
                          border: Border.all(color: !isExpense ? Colors.green : Colors.transparent),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        alignment: Alignment.center,
                        child: Text('Receita', style: TextStyle(color: !isExpense ? Colors.green : Colors.black54, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                    final provider = context.read<FinanceProvider>();
                    provider.addTransaction(FinanceTransaction(
                      id: DateTime.now().toString(),
                      title: titleCtrl.text,
                      amount: double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0,
                      date: DateTime.now(),
                      isExpense: isExpense
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Salvar Transação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      )
    );
  }

  void _showDebtLoanForm(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isDebt = true;
    
    showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Nova Dívida ou Empréstimo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 24),
              TextField(
                controller: titleCtrl, 
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black)),
                )
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl, 
                keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black)),
                )
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isDebt = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDebt ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
                          border: Border.all(color: isDebt ? Colors.red : Colors.transparent),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        alignment: Alignment.center,
                        child: Text('Eu Devo (Dívida)', style: TextStyle(color: isDebt ? Colors.red : Colors.black54, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isDebt = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isDebt ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB),
                          border: Border.all(color: !isDebt ? Colors.blue : Colors.transparent),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        alignment: Alignment.center,
                        child: Text('Me Devem (Empr.)', style: TextStyle(color: !isDebt ? Colors.blue : Colors.black54, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                    final provider = context.read<FinanceProvider>();
                    provider.addDebtLoan(DebtLoan(
                      id: DateTime.now().toString(),
                      title: titleCtrl.text,
                      amount: double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0,
                      date: DateTime.now(),
                      isDebt: isDebt
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Registrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      )
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Patrimônio Líquido', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Text(currencyFormat.format(provider.totalBalance), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Auditoria em tempo real', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildInfoCard('Dívidas', provider.totalUnpaidDebts, Colors.red, Icons.arrow_downward)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard('Empréstimos', provider.totalUnpaidLoans, Colors.blue, Icons.arrow_upward)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Últimas Transações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              Text('Ver todas', style: TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          provider.transactions.isEmpty 
            ? Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF3F4F6))),
                child: const Text('Nenhuma movimentação', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w500))
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.transactions.length > 5 ? 5 : provider.transactions.length,
                itemBuilder: (context, index) {
                  final t = provider.transactions.reversed.toList()[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: t.isExpense ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Icon(t.isExpense ? Icons.shopping_bag_outlined : Icons.account_balance_wallet_outlined, color: t.isExpense ? Colors.red : Colors.green, size: 20),
                      ),
                      title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      subtitle: Text(DateFormat('dd MMM, yyyy').format(t.date), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      trailing: Text(
                        '\${t.isExpense ? "-" : "+"} \${currencyFormat.format(t.amount)}',
                        style: TextStyle(color: t.isExpense ? Colors.black87 : Colors.green, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.5),
                      ),
                    ),
                  );
                },
            )
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, double amount, Color accentColor, IconData icon) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: accentColor, width: 4), top: const BorderSide(color: Color(0xFFF3F4F6)), right: const BorderSide(color: Color(0xFFF3F4F6)), bottom: const BorderSide(color: Color(0xFFF3F4F6)))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 16),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(currencyFormat.format(amount), style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        ],
      ),
    );
  }
}

class DebtsLoansTab extends StatelessWidget {
  const DebtsLoansTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return provider.debtsLoans.isEmpty
      ? const Center(child: Text('Tudo limpo! Nenhuma dívida ou empréstimo logado.', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)))
      : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: provider.debtsLoans.length,
        itemBuilder: (context, index) {
          final dl = provider.debtsLoans[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6))
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dl.isPaid ? const Color(0xFFF3F4F6) : (dl.isDebt ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF)),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(dl.isDebt ? Icons.money_off : Icons.monetization_on_outlined, color: dl.isPaid ? Colors.black26 : (dl.isDebt ? Colors.red : Colors.blue), size: 24),
              ),
              title: Text(dl.title, style: TextStyle(decoration: dl.isPaid ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold, fontSize: 15, color: dl.isPaid ? Colors.black38 : Colors.black87)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(currencyFormat.format(dl.amount), style: TextStyle(color: dl.isPaid ? Colors.black26 : Colors.black54, fontWeight: FontWeight.w600)),
              ),
              trailing: Switch(
                value: dl.isPaid,
                activeColor: Colors.black,
                inactiveTrackColor: const Color(0xFFE5E7EB),
                inactiveThumbColor: Colors.white,
                onChanged: (val) {
                  context.read<FinanceProvider>().togglePaidStatus(dl.id);
                },
              ),
            ),
          );
        },
      );
  }
}

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    double expenses = provider.transactions.where((t) => t.isExpense).fold(0, (sum, t) => sum + t.amount);
    double income = provider.transactions.where((t) => !t.isExpense).fold(0, (sum, t) => sum + t.amount);
    double total = expenses + income;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Resumo Financeiro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text('Auditoria visual dos seus ganhos e gastos', style: TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF3F4F6))
            ),
            child: total == 0 
              ? const SizedBox(
                  height: 200,
                  child: Center(child: Text('Insira transações para ver o gráfico.', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w500)))
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
                              PieChartSectionData(color: Colors.black, value: expenses, title: '\${((expenses/total)*100).toStringAsFixed(0)}%', radius: 24, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10)),
                            if (income > 0)
                              PieChartSectionData(color: const Color(0xFFE5E7EB), value: income, title: '\${((income/total)*100).toStringAsFixed(0)}%', radius: 24, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 10)),
                          ]
                        )
                      )
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLegendItem(Colors.black, 'Despesas', expenses, currencyFormat),
                        Container(width: 1, height: 40, color: const Color(0xFFF3F4F6)),
                        _buildLegendItem(const Color(0xFFE5E7EB), 'Receitas', income, currencyFormat),
                      ],
                    )
                  ],
                ),
          ),
          
          const SizedBox(height: 24),
          const Text('Dívidas vs Empréstimos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF3F4F6))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dívidas Restantes', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(currencyFormat.format(provider.totalUnpaidDebts), style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  ],
                ),
                Container(width: 1, height: 40, color: const Color(0xFFF3F4F6)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Empréstimos Rest.', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(currencyFormat.format(provider.totalUnpaidLoans), style: const TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  ],
                ),
              ],
            ),
          )
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
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(format.format(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5)),
      ],
    );
  }
}
