import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chit_provider.dart';
import '../../widgets/chit_card.dart';
import '../opening/opening_screen.dart';
import 'create_member_screen.dart';
import 'create_chit_screen.dart';
import 'month_list_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChitProvider>().loadAllChits();
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
        title: Text('Hi, ${authUser?.name ?? 'Admin'}'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ChitProvider>().loadAllChits(),
        child: chitProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : chitProvider.chits.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text('No chits created yet.\nTap + to create one.', textAlign: TextAlign.center)),
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
                              builder: (_) => MonthListScreen(chit: chit, isAdmin: true),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'createMember',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateMemberScreen()));
            },
            label: const Text('Member'),
            icon: const Icon(Icons.person_add),
            backgroundColor: Colors.teal,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'createChit',
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateChitScreen()));
              if (mounted) context.read<ChitProvider>().loadAllChits();
            },
            label: const Text('Chit'),
            icon: const Icon(Icons.add),
            backgroundColor: Colors.indigo,
          ),
        ],
      ),
    );
  }
}
