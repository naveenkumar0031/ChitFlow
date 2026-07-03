import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/month_model.dart';
import '../../widgets/custom_button.dart';

class ViewAuctionScreen extends StatefulWidget {
  final MonthModel month;

  const ViewAuctionScreen({super.key, required this.month});

  @override
  State<ViewAuctionScreen> createState() => _ViewAuctionScreenState();
}

class _ViewAuctionScreenState extends State<ViewAuctionScreen> {
  bool _isDownloading = false;

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Future<void> _downloadPdf() async {
    final url = widget.month.pdfUrl;
    if (url == null) return;

    setState(() => _isDownloading = true);
    try {
      // Fetch the PDF bytes from Firebase Storage's download URL.
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      // Save it into the app's own storage folder (no special permission
      // needed on Android 11+, works out of the box on iOS too).
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'chit_month_${widget.month.monthNumber}_auction.pdf';
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved as $fileName. Opening...')),
      );

      // Open it with whatever PDF viewer is installed on the device.
      await OpenFilex.open(filePath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final month = widget.month;
    return Scaffold(
      appBar: AppBar(title: Text('Month ${month.monthNumber} Auction')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _row('Auction Date', month.auctionDate ?? '-'),
                    const Divider(),
                    _row('Auction Time', month.auctionTime ?? '-'),
                    const Divider(),
                    _row('Chit Total Value',
                        '₹${month.chitValue?.toStringAsFixed(0) ?? '-'}'),
                    const Divider(),
                    _row('Bid Amount',
                        '₹${month.bidAmount?.toStringAsFixed(0) ?? '-'}'),
                    const Divider(),
                    _row('Prize Amount',
                        '₹${month.prizeAmount?.toStringAsFixed(0) ?? '-'}'),
                    const Divider(),
                    _row('Winner Name', month.winnerName ?? '-'),
                    const Divider(),
                    _row('Dividend',
                        '₹${month.dividend?.toStringAsFixed(0) ?? '-'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (month.pdfUrl != null)
              CustomButton(
                text: 'Download Auction PDF',
                isLoading: _isDownloading,
                onPressed: _downloadPdf,
              )
            else
              const Text('No auction PDF uploaded yet.',
                  textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
