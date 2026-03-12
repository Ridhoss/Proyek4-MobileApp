import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logbook_app_059/components/logbook/header_bar.dart';
import 'package:logbook_app_059/controller/log_controller.dart';
import 'package:logbook_app_059/features/logbook/counter_view.dart';
import 'package:logbook_app_059/features/logbook/log_editor_page.dart';
import 'package:logbook_app_059/features/logbook/models/log_model.dart';
import 'package:logbook_app_059/features/logbook/models/user_model.dart';
import 'package:logbook_app_059/services/access_control_services.dart';
import 'package:logbook_app_059/services/sync_service.dart';

class LogView extends StatefulWidget {
  final UserModel user;
  const LogView({super.key, required this.user});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  final TextEditingController _searchController = TextEditingController();

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Task":
        return Colors.green;
      case "Information":
        return Colors.blue;
      case "Bug":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    SyncService().syncTrigger.addListener(() {
      _controller.fetchLogs(widget.user.teamIds.first);
    });

    _loadLogs();
  }

  Future<void> _loadLogs() async {
    await _controller.fetchLogs(widget.user.teamIds.first);
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return "Baru saja";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} menit yang lalu";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} jam yang lalu";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} hari yang lalu";
    } else {
      return DateFormat("dd MMM yyyy", "id_ID").format(date);
    }
  }

  void _goToEditor({LogModel? log}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEditorPage(
          log: log,
          controller: _controller,
          currentUser: widget.user,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBar(username: widget.user.username),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari..",
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller.loadingNotifier,
              builder: (context, loading, child) {
                // loading
                if (loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ValueListenableBuilder<List<LogModel>>(
                  valueListenable: _controller.logsNotifier,
                  builder: (context, currentLogs, child) {
                    final query = _searchController.text.toLowerCase();

                    final filteredLogs = currentLogs.where((log) {
                      return log.title.toLowerCase().contains(query) ||
                          log.description.toLowerCase().contains(query);
                    }).toList();

                    /// empty
                    if (filteredLogs.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await _controller.fetchLogs(
                            widget.user.teamIds.first,
                          );
                        },
                        child: ListView(
                          children: const [
                            SizedBox(height: 120),
                            Icon(Icons.cloud_off, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                "Belum ada catatan",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    /// list data
                    return RefreshIndicator(
                      onRefresh: () async {
                        await _controller.fetchLogs(widget.user.teamIds.first);
                      },
                      child: ListView.builder(
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          final bool isOwner = log.iduser == widget.user.id;

                          return Dismissible(
                            key: UniqueKey(),

                            direction:
                                AccessControlServices.canPerform(
                                  widget.user.role,
                                  'delete',
                                  isOwner: isOwner,
                                )
                                ? DismissDirection.endToStart
                                : DismissDirection.none,

                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),

                            onDismissed: (direction) async {
                              await _controller.removeLog(log);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Catatan dihapus"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },

                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.note),
                                title: Text(
                                  log.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(log.description),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(log.date),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(log.category),
                                          backgroundColor: _getCategoryColor(
                                            log.category,
                                          ),
                                          labelStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        _buildStorageIndicator(log),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (AccessControlServices.canPerform(
                                      widget.user.role,
                                      AccessControlServices.actionUpdate,
                                      isOwner: isOwner,
                                    ))
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _goToEditor(log: log),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "add_log",
            onPressed: () => _goToEditor(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: "counter_page",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CounterView(user: widget.user),
                ),
              );
            },
            child: const Icon(Icons.calculate),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageIndicator(LogModel log) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.storage, size: 18, color: Colors.green),
        const SizedBox(width: 6),

        Icon(
          Icons.cloud,
          size: 18,
          color: log.isSynced ? Colors.green : Colors.grey,
        ),

        const SizedBox(width: 6),

        Icon(
          log.type == "Public" ? Icons.visibility : Icons.visibility_off,
          size: 18,
          color: log.type == "Public" ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
