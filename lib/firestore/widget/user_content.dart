import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/firestore/bloc/firestore_bloc.dart';
import 'package:test/firestore/model/task.dart';

class UserContent extends StatefulWidget {
  const UserContent({Key? key}) : super(key: key);

  @override
  State<UserContent> createState() => _UserContentState();
}

class _UserContentState extends State<UserContent> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FirestoreBloc, FirestoreState>(
      builder: (context, state) {
        if (state.tasks.isEmpty) {
          return Center(
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const TaskAddDialog(),
                );
              },
              child: const Text('Add new'),
            ),
          );
        }
        return ListView(
          children: [
            for (final task in state.tasks) TaskUi(task: task),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const TaskAddDialog(),
                );
              },
              child: const Text('Add new'),
            ),
          ],
        );
      },
    );
  }
}

class TaskUi extends StatelessWidget {
  final Task task;

  const TaskUi({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListTile(
        tileColor: task is FinishedTask?  Colors.lightBlue.withOpacity(0.3) : Colors.red.shade50,
        contentPadding: EdgeInsets.all(8),
        leading: Text(task.name),
        trailing: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task is UnfinishedTask)
              IconButton(
                onPressed: () {
                  context.read<FirestoreBloc>().add(TaskCompleted(task));
                },
                icon: Icon(Icons.task, color: Colors.green),
              ),
            IconButton(
              onPressed: () {
                context.read<FirestoreBloc>().add(TaskDeleted(task));
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskAddDialog extends StatefulWidget {
  const TaskAddDialog({Key? key}) : super(key: key);

  @override
  State<TaskAddDialog> createState() => _TaskAddDialogState();
}

class _TaskAddDialogState extends State<TaskAddDialog> {
  final key = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Name'),
              Form(
                key: key,
                child: TextFormField(
                  controller: _controller,
                  validator: (str) {
                    if (str == null || str.isEmpty) {
                      return 'This field cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (key.currentState?.validate() == true) {
                        context.read<FirestoreBloc>().add(
                              TaskAdded(
                                UnfinishedTask(
                                  createdAt: DateTime.now(),
                                  name: _controller.text,
                                ),
                              ),
                            );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
