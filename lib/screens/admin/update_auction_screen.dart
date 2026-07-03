import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/month_model.dart';
import '../../providers/chit_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class UpdateAuctionScreen extends StatefulWidget {
  final String chitId;
  final MonthModel month;

  const UpdateAuctionScreen(
      {super.key, required this.chitId, required this.month});

  @override
  State<UpdateAuctionScreen> createState() => _UpdateAuctionScreenState();
}

class _UpdateAuctionScreenState extends State<UpdateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _chitValueController;
  late TextEditingController _bidAmountController;
  late TextEditingController _prizeAmountController;
  late TextEditingController _winnerController;
  late TextEditingController _dividendController;

  File? _pickedPdf;
  String? _existingPdfUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.month;
    _dateController = TextEditingController(text: m.auctionDate ?? '');
    _timeController = TextEditingController(text: m.auctionTime ?? '');
    _chitValueController =
        TextEditingController(text: m.chitValue?.toString() ?? '');
    _bidAmountController =
        TextEditingController(text: m.bidAmount?.toString() ?? '');
    _prizeAmountController =
        TextEditingController(text: m.prizeAmount?.toString() ?? '');
    _winnerController = TextEditingController(text: m.winnerName ?? '');
    _dividendController =
        TextEditingController(text: m.dividend?.toString() ?? '');
    _existingPdfUrl = m.pdfUrl;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _chitValueController.dispose();
    _bidAmountController.dispose();
    _prizeAmountController.dispose();
    _winnerController.dispose();
    _dividendController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      _timeController.text = picked.format(context);
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() => _pickedPdf = File(result.files.single.path!));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final monthData = MonthModel(
        monthNumber: widget.month.monthNumber,
        auctionDate: _dateController.text.trim(),
        auctionTime: _timeController.text.trim(),
        chitValue: double.parse(_chitValueController.text.trim()),
        bidAmount: double.parse(_bidAmountController.text.trim()),
        prizeAmount: double.parse(_prizeAmountController.text.trim()),
        winnerName: _winnerController.text.trim(),
        dividend: double.parse(_dividendController.text.trim()),
        pdfUrl: _existingPdfUrl,
      );

      await context.read<ChitProvider>().updateAuction(
            chitId: widget.chitId,
            monthNumber: widget.month.monthNumber,
            monthData: monthData,
            pdfFile: _pickedPdf,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auction details updated')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Month ${widget.month.monthNumber} Auction')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _dateController,
                label: 'Auction Date',
                validator: (v) => Validators.required(v, field: 'Auction date'),
              ),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Pick Date'),
              ),
              CustomTextField(
                controller: _timeController,
                label: 'Auction Time',
                validator: (v) => Validators.required(v, field: 'Auction time'),
              ),
              TextButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.access_time),
                label: const Text('Pick Time'),
              ),
              CustomTextField(
                controller: _chitValueController,
                label: 'Chit Total Value',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    Validators.number(v, field: 'Chit total value'),
              ),
              CustomTextField(
                controller: _bidAmountController,
                label: 'Bid Amount',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.number(v, field: 'Bid amount'),
              ),
              CustomTextField(
                controller: _prizeAmountController,
                label: 'Prize Amount',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.number(v, field: 'Prize amount'),
              ),
              CustomTextField(
                controller: _winnerController,
                label: 'Winner Name',
                validator: (v) => Validators.required(v, field: 'Winner name'),
              ),
              CustomTextField(
                controller: _dividendController,
                label: 'Dividend',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.number(v, field: 'Dividend'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.upload_file),
                label: Text(_pickedPdf != null
                    ? 'Selected: ${_pickedPdf!.path.split('/').last}'
                    : (_existingPdfUrl != null
                        ? 'Replace Auction PDF'
                        : 'Upload Auction PDF')),
              ),
              const SizedBox(height: 24),
              CustomButton(
                  text: 'Update', isLoading: _isSaving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
