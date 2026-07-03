import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chit_model.dart';
import '../../providers/chit_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class CreateChitScreen extends StatefulWidget {
  const CreateChitScreen({super.key});

  @override
  State<CreateChitScreen> createState() => _CreateChitScreenState();
}

class _CreateChitScreenState extends State<CreateChitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _totalMembersController = TextEditingController();
  final _totalMonthsController = TextEditingController();

  List<Map<String, dynamic>> _cachedMembers = [];
  final Set<String> _selectedPhones = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final provider = context.read<ChitProvider>();
    // Ensure the local Hive cache has the latest members from Firestore.
    await provider.syncMembersToHive();
    setState(() {
      _cachedMembers = provider.getCachedMembers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _totalMembersController.dispose();
    _totalMonthsController.dispose();
    super.dispose();
  }

  Future<void> _createChit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPhones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one member')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final selectedMembers = _cachedMembers
          .where((m) => _selectedPhones.contains(m['phone']))
          .map((m) => ChitMember(phone: m['phone'], name: m['name']))
          .toList();

      await context.read<ChitProvider>().createChit(
            chitName: _nameController.text.trim(),
            totalAmount: double.parse(_amountController.text.trim()),
            totalMembers: int.parse(_totalMembersController.text.trim()),
            totalMonths: int.parse(_totalMonthsController.text.trim()),
            selectedMembers: selectedMembers,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chit created successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Chit')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Chit Name',
                validator: (v) => Validators.required(v, field: 'Chit name'),
              ),
              CustomTextField(
                controller: _amountController,
                label: 'Total Amount',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.number(v, field: 'Total amount'),
              ),
              CustomTextField(
                controller: _totalMembersController,
                label: 'Total Members',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.positiveInt(v, field: 'Total members'),
              ),
              CustomTextField(
                controller: _totalMonthsController,
                label: 'Total Months',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.positiveInt(v, field: 'Total months'),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Select Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 8),
              if (_cachedMembers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No members found. Create members first.'),
                )
              else
                ..._cachedMembers.map((m) {
                  final phone = m['phone'] as String;
                  final name = m['name'] as String;
                  return CheckboxListTile(
                    title: Text(name),
                    subtitle: Text(phone),
                    value: _selectedPhones.contains(phone),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedPhones.add(phone);
                        } else {
                          _selectedPhones.remove(phone);
                        }
                      });
                    },
                  );
                }),
              const SizedBox(height: 24),
              CustomButton(text: 'Create Chit', isLoading: _isSaving, onPressed: _createChit),
            ],
          ),
        ),
      ),
    );
  }
}
