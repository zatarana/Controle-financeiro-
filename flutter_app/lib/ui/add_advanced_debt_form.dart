import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/finance_provider.dart';
import '../core/debt_models.dart';

class AddAdvancedDebtForm extends StatefulWidget {
  const AddAdvancedDebtForm({super.key});

  @override
  State<AddAdvancedDebtForm> createState() => _AddAdvancedDebtFormState();
}

class _AddAdvancedDebtFormState extends State<AddAdvancedDebtForm> {
  final _nameCtrl = TextEditingController();
  final _creditorCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _installmentsCtrl = TextEditingController();
  final _interestCtrl = TextEditingController();
  
  bool _isParcelado = false;
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nova Dívida', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 24),
            _buildTextField(_nameCtrl, 'Descrição da Dívida (ex: Cartão Nubank)'),
            const SizedBox(height: 16),
            _buildTextField(_creditorCtrl, 'Credor (Instituição ou Pessoa)'),
            const SizedBox(height: 16),
            _buildTextField(_amountCtrl, 'Valor Total (R\$)', isNumber: true),
            const SizedBox(height: 24),
            
            // Tipo de dívida (Única / Parcelada)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isParcelado = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isParcelado ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
                        border: Border.all(color: !_isParcelado ? Colors.green : Colors.transparent),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      alignment: Alignment.center,
                      child: Text('Cobrança Única', style: TextStyle(color: !_isParcelado ? Colors.green : Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isParcelado = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isParcelado ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB),
                        border: Border.all(color: _isParcelado ? Colors.blue : Colors.transparent),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      alignment: Alignment.center,
                      child: Text('Parcelada', style: TextStyle(color: _isParcelado ? Colors.blue : Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            if (_isParcelado) ...[
              _buildTextField(_installmentsCtrl, 'Número de Parcelas', isNumber: true),
              const SizedBox(height: 16),
            ],
            
            _buildTextField(_interestCtrl, 'Taxa de Juros ao Mês (%) - Opcional', isNumber: true),
            const SizedBox(height: 16),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data de Origem / 1º Vencimento', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('\${_startDate.day}/\${_startDate.month}/\${_startDate.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: _startDate, 
                  firstDate: DateTime(2000), 
                  lastDate: DateTime(2100)
                );
                if (date != null) setState(() => _startDate = date);
              },
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
              onPressed: _saveAndClose,
              child: const Text('Cadastrar Dívida', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black)),
      )
    );
  }

  void _saveAndClose() {
    if (_nameCtrl.text.isEmpty || _creditorCtrl.text.isEmpty || _amountCtrl.text.isEmpty) return;
    
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) return;

    final installmentsCount = _isParcelado ? (int.tryParse(_installmentsCtrl.text) ?? 1) : 1;
    final interestRate = double.tryParse(_interestCtrl.text.replaceAll(',', '.'));
    
    final installmentAmount = amount / installmentsCount;
    List<DebtInstallment> installments = [];
    
    for (int i = 0; i < installmentsCount; i++) {
      installments.add(DebtInstallment(
        id: '\${DateTime.now().millisecondsSinceEpoch}_$i',
        originalAmount: installmentAmount,
        dueDate: DateTime(_startDate.year, _startDate.month + i, _startDate.day),
        status: InstallmentStatus.pendente,
      ));
    }

    final newDebt = DebtItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text,
      creditor: _creditorCtrl.text,
      originalTotalAmount: amount,
      type: _isParcelado ? DebtType.parcelada : DebtType.unica,
      interestRate: interestRate,
      originDate: _startDate,
      status: DebtStatus.pendente,
      installments: installments,
    );

    context.read<FinanceProvider>().addAdvancedDebt(newDebt);
    Navigator.pop(context);
  }
}
