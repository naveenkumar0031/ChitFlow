import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chit_provider.dart';
import '../../widgets/chit_card.dart';
import '../opening/opening_screen.dart';
import '../admin/month_list_screen.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final phone = context.read<AuthProvider>().currentUser?.phone;
      if (phone != null) {
        context.read<ChitProvider>().loadChitsForMember(phone);
      }
    });
  }

  void _logout() {
    context.read<AuthProvider>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OpeningScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthProvider>().currentUser;
    final chitProvider = context.watch<ChitProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${authUser?.name ?? 'Member'}'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final phone = authUser?.phone;
          if (phone != null) {
            await context.read<ChitProvider>().loadChitsForMember(phone);
          }
        },
        child: chitProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : chitProvider.chits.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text("You haven't joined any chits yet.", textAlign: TextAlign.center)),
                    ],
                  )
                : ListView.builder(
                    itemCount: chitProvider.chits.length,
                    itemBuilder: (context, index) {
                      final chit = chitProvider.chits[index];
                      return ChitCard(
                        chit: chit,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MonthListScreen(chit: chit, isAdmin: false),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
