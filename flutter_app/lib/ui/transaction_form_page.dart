import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/finance_provider.dart';
import '../core/finance_models.dart';

class TransactionFormPage extends StatefulWidget {
  final AppFinanceTransaction? transaction;
  final TransactionType initialType;

  const TransactionFormPage({super.key, this.transaction, this.initialType = TransactionType.expense});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  bool _isPaid = true;
  DateTime _releaseDate = DateTime.now();
  DateTime _dueDate = DateTime.now();
  DateTime? _effectiveDate = DateTime.now();

  String? _selectedAccountId;
  String? _selectedDestinationAccountId;
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  String? _selectedCreditCardId;
  
  // Advanced
  bool _showAdvanced = false;
  bool _ignoreInTotals = false;
  bool _ignoreInStats = false;
  bool _ignoreInMonthlyEconomy = false;
  bool _saveAndContinue = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _titleCtrl.text = t.title;
      _amountCtrl.text = t.amount.toString();
      _notesCtrl.text = t.notes ?? '';
      _type = t.type;
      _isPaid = t.isPaid;
      _releaseDate = t.releaseDate;
      _dueDate = t.dueDate;
      _effectiveDate = t.effectiveDate;
      _selectedAccountId = t.accountId;
      _selectedDestinationAccountId = t.destinationAccountId;
      _selectedCategoryId = t.categoryId;
      _selectedSubcategoryId = t.subcategoryId;
      _selectedCreditCardId = t.creditCardId;
      _ignoreInTotals = t.ignoreInTotals;
      _ignoreInStats = t.ignoreInStats;
      _ignoreInMonthlyEconomy = t.ignoreInMonthlyEconomy;
    }
  }

  void _save() {
    if (_titleCtrl.text.isEmpty || _amountCtrl.text.isEmpty) return;
    
    double amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    final provider = context.read<FinanceProvider>();
    
    // Auto-resolve pending status based on date
    if (_dueDate.isAfter(DateTime.now()) && _isPaid) {
      _isPaid = false;
      _effectiveDate = null;
    }
    
    final newTrx = AppFinanceTransaction(
      id: widget.transaction?.id ?? DateTime.now().toString(),
      title: _titleCtrl.text,
      amount: amount,
      type: _type,
      releaseDate: _releaseDate,
      dueDate: _dueDate,
      effectiveDate: _isPaid ? (_effectiveDate ?? DateTime.now()) : null,
      isPaid: _isPaid,
      accountId: _selectedAccountId,
      destinationAccountId: _selectedDestinationAccountId,
      categoryId: _selectedCategoryId,
      subcategoryId: _selectedSubcategoryId,
      creditCardId: _selectedCreditCardId,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      ignoreInTotals: _ignoreInTotals,
      ignoreInStats: _ignoreInStats,
      ignoreInMonthlyEconomy: _ignoreInMonthlyEconomy,
    );
    
    if (widget.transaction != null) {
       // update local list
       int index = provider.transactions.indexWhere((t) => t.id == newTrx.id);
       if (index != -1) {
         provider.transactions[index] = newTrx;
       }
    } else {
       provider.transactions.add(newTrx);
    }
    
    provider.saveData();
    provider.notifyListeners();
    
    if (_saveAndContinue && widget.transaction == null) {
       _titleCtrl.clear();
       _amountCtrl.clear();
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salvo com sucesso! Cadastre o próximo.')));
    } else {
       Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final df = DateFormat('dd/MM/yyyy');

    List<FinanceCategory> currentCats = provider.categories.where((c) => c.type == (_type == TransactionType.income ? CategoryType.income : CategoryType.expense)).toList();
    FinanceCategory? activeCat = currentCats.where((c) => c.id == _selectedCategoryId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(widget.transaction != null ? 'Editar Lançamento' : 'Novo Lançamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Type Selector
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.expense, label: Text('Despesa')),
                ButtonSegment(value: TransactionType.income, label: Text('Receita')),
                ButtonSegment(value: TransactionType.creditCardExpense, label: Text('Cartão')),
                ButtonSegment(value: TransactionType.transfer, label: Text('Transf.')),
              ],
              selected: {_type},
              onSelectionChanged: (Set<TransactionType> val) {
                setState(() {
                  _type = val.first;
                  _selectedCategoryId = null; // reset cat on type change
                });
              },
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _titleCtrl,
              maxLength: 35,
              decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            // Status Switch
            SwitchListTile(
              title: Text(_isPaid ? 'Efetivada' : 'Pendente', style: TextStyle(color: _isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
              value: _isPaid,
              onChanged: (val) {
                setState(() {
                  _isPaid = val;
                  if (val && _effectiveDate == null) _effectiveDate = DateTime.now();
                });
              },
            ),
            
            const Divider(),
            
            // Dates
            Row(
              children: [
                Expanded(child: ListTile(
                  title: const Text('Lançamento', style: TextStyle(fontSize: 12)),
                  subtitle: Text(df.format(_releaseDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    final dt = await showDatePicker(context: context, initialDate: _releaseDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (dt != null) setState(() => _releaseDate = dt);
                  },
                )),
                Expanded(child: ListTile(
                  title: const Text('Vencimento', style: TextStyle(fontSize: 12)),
                  subtitle: Text(df.format(_dueDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    final dt = await showDatePicker(context: context, initialDate: _dueDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (dt != null) setState(() { 
                      _dueDate = dt;
                      if (dt.isAfter(DateTime.now())) _isPaid = false; 
                    });
                  },
                )),
              ],
            ),
            if (_isPaid) ListTile(
              title: const Text('Data Efetivação', style: TextStyle(fontSize: 12)),
              subtitle: Text(df.format(_effectiveDate ?? DateTime.now()), style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                final dt = await showDatePicker(context: context, initialDate: _effectiveDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (dt != null) setState(() => _effectiveDate = dt);
              },
            ),
            
            const Divider(),
            
            // Account / Card
            if (_type == TransactionType.creditCardExpense) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Cartão de Crédito', border: OutlineInputBorder()),
                value: _selectedCreditCardId,
                items: provider.creditCards.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _selectedCreditCardId = val),
              ),
              const SizedBox(height: 16),
            ] else if (_type != TransactionType.transfer) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Conta', border: OutlineInputBorder()),
                value: _selectedAccountId,
                items: provider.accounts.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _selectedAccountId = val),
              ),
              const SizedBox(height: 16),
            ] else ...[
               DropdownButtonFormField<String>(
                 decoration: const InputDecoration(labelText: 'Conta Origem', border: OutlineInputBorder()),
                 value: _selectedAccountId,
                 items: provider.accounts.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                 onChanged: (val) => setState(() => _selectedAccountId = val),
               ),
               const SizedBox(height: 16),
               DropdownButtonFormField<String>(
                 decoration: const InputDecoration(labelText: 'Conta Destino (Para onde foi?)', border: OutlineInputBorder()),
                 value: _selectedDestinationAccountId,
                 items: provider.accounts.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                 onChanged: (val) => setState(() => _selectedDestinationAccountId = val),
               ),
               const SizedBox(height: 16),
            ],

            // Categories
            if (_type != TransactionType.transfer) ...[
               DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                  value: _selectedCategoryId,
                  items: currentCats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() {
                    _selectedCategoryId = val;
                    _selectedSubcategoryId = null; // reset subcat
                  }),
                ),
                const SizedBox(height: 16),
                
                if (activeCat != null && activeCat.subcategories.isNotEmpty) 
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Subcategoria', border: OutlineInputBorder()),
                    value: _selectedSubcategoryId,
                    items: activeCat.subcategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _selectedSubcategoryId = val),
                  ),
            ],
            
            const SizedBox(height: 16),
            
            // Mais Opções (Expandir/Retrair)
            TextButton(
              onPressed: () => setState(() => _showAdvanced = !_showAdvanced), 
              child: Text(_showAdvanced ? 'Menos opções' : 'Mais opções')
            ),
            
            if (_showAdvanced) ...[
               TextField(
                 controller: _notesCtrl,
                 decoration: const InputDecoration(labelText: 'Observações (até 2000 caracteres) e #tags', border: OutlineInputBorder()),
                 maxLines: 3,
               ),
               const SizedBox(height: 8),
               SwitchListTile(title: const Text('Ignorar nos Totais (não soma no saldo)'), value: _ignoreInTotals, onChanged: (v) => setState(() => _ignoreInTotals = v)),
               SwitchListTile(title: const Text('Ignorar em Estatísticas e Gráficos'), value: _ignoreInStats, onChanged: (v) => setState(() => _ignoreInStats = v)),
               SwitchListTile(title: const Text('Ignorar na Economia Mensal'), value: _ignoreInMonthlyEconomy, onChanged: (v) => setState(() => _ignoreInMonthlyEconomy = v)),
               CheckboxListTile(title: const Text('Salvar e continuar cadastrando'), value: _saveAndContinue, onChanged: (v) => setState(() => _saveAndContinue = v ?? false)),
            ],
            
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _save, 
              child: const Text('Salvar')
            )
          ],
        ),
      ),
    );
  }
}
