import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/create_post_bloc.dart';
import '../blocs/create_post_event.dart';
import '../blocs/create_post_state.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Post')),
      body: BlocConsumer<CreatePostBloc, CreatePostState>(
        listener: (context, state) {
          if (state is CreatePostSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post creado con exito')),
            );
            context.pop(true);
          } else if (state is CreatePostError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state is CreatePostLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Título'),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _bodyController,
                    decoration: InputDecoration(labelText: 'Cuerpo del post'),
                    maxLines: 4,
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<CreatePostBloc>().add(
                          SubmitPostEvent(
                            title: _titleController.text,
                            body: _bodyController.text,
                          ),
                        );
                      }
                    },
                    child: Text('Guardar Post'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
