import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meu_buteco/models/user_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = userProvider.userName;
    _enderecoController.text = userProvider.userData['endereco'] ?? '';
    _telefoneController.text = userProvider.userData['telefone'] ?? '';
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidade de salvamento em desenvolvimento'),
        ),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _cancelEdit() {
    _loadUserData(); // Restaura os dados originais
    setState(() {
      _isEditing = false;
    });
  }

  //Diasfoke1304#
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (!_isEditing) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _toggleEdit,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 20.0),
                          SizedBox(height: 2),
                          Text('Editar perfil', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _saveChanges,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 2.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save, size: 20.0),
                              SizedBox(height: 2),
                              Text('Salvar', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _cancelEdit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 2.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cancel, size: 20.0),
                              SizedBox(height: 2),
                              Text('Cancelar', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar do usuário
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(26),
                      child: Text(
                        userProvider.userName.isNotEmpty
                            ? userProvider.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Informações do usuário
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Informações Pessoais',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_isEditing)
                        TextButton.icon(
                          onPressed: _toggleEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Editar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card com informações
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (_isEditing) ...[
                            // Campos editáveis
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nome',
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Informe seu nome'
                                          : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _enderecoController,
                              decoration: const InputDecoration(
                                labelText: 'Endereço',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _telefoneController,
                              decoration: const InputDecoration(
                                labelText: 'Telefone',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ] else ...[
                            // Campos estáticos
                            _buildInfoRow('Nome', userProvider.userName),
                            const Divider(),
                            _buildInfoRow('E-mail', userProvider.userEmail),
                            if (userProvider.userData['endereco'] != null &&
                                userProvider
                                    .userData['endereco']
                                    .isNotEmpty) ...[
                              const Divider(),
                              _buildInfoRow(
                                'Endereço',
                                userProvider.userData['endereco'],
                              ),
                            ],
                            if (userProvider.userData['telefone'] != null &&
                                userProvider
                                    .userData['telefone']
                                    .isNotEmpty) ...[
                              const Divider(),
                              _buildInfoRow(
                                'Telefone',
                                userProvider.userData['telefone'],
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Informações adicionais
                  if (userProvider.isMaster) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Privilégios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: Colors.amber.withValues(alpha: 0.1),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Usuário Master',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Não informado',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }
}
