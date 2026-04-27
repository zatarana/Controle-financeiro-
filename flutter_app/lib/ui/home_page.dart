import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/finance_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const DebtsLoansTab(),
    const ReportsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CtrlFinance', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Dívidas'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Relatórios'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigoAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(4)), margin: const EdgeInsets.only(bottom: 20)),
              ListTile(
                leading: const Icon(Icons.compare_arrows, color: Colors.green),
                title: const Text('Nova Transação'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showTransactionForm(context);
                },
              ),
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.redAccent),
                title: const Text('Nova Dívida/Empréstimo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDebtLoanForm(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
    });
  }

  void _showTransactionForm(BuildContext context) {
    // Implementação do formulário nativo minimalista
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isExpense = true;
    
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Lançar Transação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor')),
            SwitchListTile(
              title: Text(isExpense ? 'Despesa' : 'Receita'),
              activeColor: Colors.redAccent,
              inactiveTrackColor: Colors.green.withOpacity(0.5),
              inactiveThumbColor: Colors.greenAccent,
              value: isExpense,
              onChanged: (val) => setState(() => isExpense = val),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                final provider = context.read<FinanceProvider>();
                provider.addTransaction(FinanceTransaction(
                  id: DateTime.now().toString(),
                  title: titleCtrl.text,
                  amount: double.parse(amountCtrl.text),
                  date: DateTime.now(),
                  isExpense: isExpense
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          )
        ],
      ),
    ));
  }

  void _showDebtLoanForm(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isDebt = true;
    
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Adicionar Dívida/Empréstimo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Descrição')),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valor')),
            SwitchListTile(
              title: Text(isDebt ? 'Eu devo (Dívida)' : 'Me devem (Empréstimo)'),
              activeColor: Colors.redAccent,
              inactiveTrackColor: Colors.green.withOpacity(0.5),
              inactiveThumbColor: Colors.greenAccent,
              value: isDebt,
              onChanged: (val) => setState(() => isDebt = val),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                final provider = context.read<FinanceProvider>();
                provider.addDebtLoan(DebtLoan(
                  id: DateTime.now().toString(),
                  title: titleCtrl.text,
                  amount: double.parse(amountCtrl.text),
                  date: DateTime.now(),
                  isDebt: isDebt
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          )
        ],
      ),
    ));
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.indigo, Colors.blueAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: Column(
              children: [
                const Text('Saldo Atual', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text('R\$ \${provider.totalBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildInfoCard('Dívidas', provider.totalUnpaidDebts, Colors.redAccent, Icons.arrow_downward)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard('Empréstimos', provider.totalUnpaidLoans, Colors.greenAccent, Icons.arrow_upward)),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Últimas Transações', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          provider.transactions.isEmpty 
            ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Nenhuma transação', style: TextStyle(color: Colors.grey)))))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.transactions.length,
                itemBuilder: (context, index) {
                  final t = provider.transactions.reversed.toList()[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: t.isExpense ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                        child: Icon(t.isExpense ? Icons.shopping_cart : Icons.attach_money, color: t.isExpense ? Colors.redAccent : Colors.greenAccent),
                      ),
                      title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text(
                        '\${t.isExpense ? "-" : "+"} R\$ \${t.amount.toStringAsFixed(2)}',
                        style: TextStyle(color: t.isExpense ? Colors.redAccent : Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  );
                },
            )
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text('R\$ \${amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
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
    return provider.debtsLoans.isEmpty
      ? const Center(child: Text('Nenhuma dívida ou empréstimo registrado.', style: TextStyle(color: Colors.grey)))
      : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.debtsLoans.length,
        itemBuilder: (context, index) {
          final dl = provider.debtsLoans[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dl.isPaid ? Colors.grey.withOpacity(0.2) : (dl.isDebt ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(dl.isDebt ? Icons.money_off : Icons.monetization_on, color: dl.isPaid ? Colors.grey : (dl.isDebt ? Colors.redAccent : Colors.greenAccent)),
              ),
              title: Text(dl.title, style: TextStyle(decoration: dl.isPaid ? TextDecoration.lineThrough : null, fontWeight: FontWeight.w600)),
              subtitle: Text('R\$ \${dl.amount.toStringAsFixed(2)}', style: TextStyle(color: dl.isPaid ? Colors.grey : Colors.white70)),
              trailing: Switch(
                value: dl.isPaid,
                activeColor: Colors.indigoAccent,
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
    
    double expenses = provider.transactions.where((t) => t.isExpense).fold(0, (sum, t) => sum + t.amount);
    double income = provider.transactions.where((t) => !t.isExpense).fold(0, (sum, t) => sum + t.amount);
    double total = expenses + income;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Resumo Financeiro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          total == 0 
            ? const Expanded(child: Center(child: Text('Insira transações para gerar relatórios.', style: TextStyle(color: Colors.grey))))
            : SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(color: Colors.redAccent, value: expenses, title: '\${((expenses/total)*100).toStringAsFixed(1)}%', radius: 60, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    PieChartSectionData(color: Colors.greenAccent, value: income, title: '\${((income/total)*100).toStringAsFixed(1)}%', radius: 60, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ]
                )
              )
            ),
            const SizedBox(height: 32),
            if (total > 0) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 _buildLegendItem(Colors.redAccent, 'Despesas'),
                 const SizedBox(width: 32),
                 _buildLegendItem(Colors.greenAccent, 'Receitas'),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
