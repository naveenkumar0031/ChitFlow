import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chit_model.dart';
import '../../models/month_model.dart';
import '../../providers/chit_provider.dart';
import 'update_auction_screen.dart';
import '../member/view_auction_screen.dart';

class MonthListScreen extends StatefulWidget {
  final ChitModel chit;
  final bool isAdmin;

  const MonthListScreen({super.key, required this.chit, required this.isAdmin});

  @override
  State<MonthListScreen> createState() => _MonthListScreenState();
}

class _MonthListScreenState extends State<MonthListScreen> {
  List<MonthModel> _months = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonths();
  }

  Future<void> _loadMonths() async {
    setState(() => _isLoading = true);
    final months = await context.read<ChitProvider>().getMonths(widget.chit.chitId, widget.chit.totalMonths);
    if (!mounted) return;
    setState(() {
      _months = months;
      _isLoading = false;
    });
  }

  /// A month is open for interaction if it is already filled, OR
  /// (for Admin only) it's the next month right after the last filled one.
  bool _isMonthAccessible(int index) {
    if (widget.isAdmin) {
      if (index == 0) return true;
      return _months[index - 1].isFilled;
    } else {
      return _months[index].isFilled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chit.chitName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _months.length,
              itemBuilder: (context, index) {
                final month = _months[index];
                final accessible = _isMonthAccessible(index);
                final filled = month.isFilled;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: filled
                          ? Colors.green
                          : (accessible ? Colors.indigo : Colors.grey),
                      child: Text('${month.monthNumber}', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text('Month ${month.monthNumber}'),
                    subtitle: Text(filled ? 'Auction completed' : (accessible ? 'Pending' : 'Locked')),
                    trailing: !accessible
                        ? const Icon(Icons.lock, color: Colors.grey)
                        : Text(
                            widget.isAdmin ? 'Edit' : 'View',
                            style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                          ),
                    onTap: !accessible
                        ? null
                        : () async {
                            if (widget.isAdmin) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UpdateAuctionScreen(
                                    chitId: widget.chit.chitId,
                                    month: month,
                                  ),
                                ),
                              );
                              _loadMonths();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ViewAuctionScreen(month: month),
                                ),
                              );
                            }
                          },
                  ),
                );
              },
            ),
    );
  }
}
