import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importa o Provider
import 'package:meu_buteco/models/user_model.dart'; // Importa seu UserProvider

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _passwordController = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  Widget build(BuildContext context) {
 return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("CRIAR CONTA",
        style: TextStyle(
          color: Colors.black,
        ),),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child){
          if (userProvider.isLoading){
            return const Center(child: CircularProgressIndicator(),);
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[

                //Nome
                TextFormField(
                  controller: _nameController,
                  validator: (text){
                    if(text!.isEmpty ) {
                      return "Insira nome valido";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Nome completo",
                  ),
                ),
                SizedBox(height: 16.0,),

                //Email
                TextFormField(
                  controller: _emailController,
                  validator: (String? text) {
                    // Expressão regular para validar e-mail (padrão comum,
                    // garantindo que o domínio de nível superior (TLD) tenha pelo menos 2 caracteres)
                    //.*\@.*\..*
                    final emailRegex = RegExp(r"^\S+@\S+\.\S+$");
                    if (text == null || text.isEmpty || !emailRegex.hasMatch(text)) {
                      return "Insira um e-mail válido";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "E-mail",
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.0,),
                //Senha1
                TextFormField(
                  controller: _passwordController,
                  validator: (text){
                    if(text!.isEmpty || text.length < 6) {
                      return "Insira uma senha valida";
                    }
                    return null;
                  }, 
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: (){
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                SizedBox(height: 16.0),
                //Senha2
                TextFormField(
                  controller: _passwordConfirm,
                  validator: (text){
                    if(text!.isEmpty || text.length < 6) {
                      return "Insira uma senha válida";
                    }
                    if(text != _passwordController.text){
                      return "As senhas não são iguais";
                    }
                    return null;
                  },              
                  decoration: InputDecoration(
                    hintText: "Confirme sua senha",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordConfirm ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: (){
                        setState(() {
                          _obscurePasswordConfirm = !_obscurePasswordConfirm;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePasswordConfirm,
                ),
                SizedBox(height: 16.0),
                
                //Botao cadastrar
                SizedBox(
                  height: 44.00,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.purple[900],
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: (){
                      if(_formKey.currentState!.validate()){

                        Map<String, dynamic> userData = {
                          "name" : _nameController.text,
                          "email" : _emailController.text,
                        };
                        Provider.of<UserProvider>(context, listen: false).signUp(
                          userData: userData, 
                          pass: _passwordController.text, 
                          onSuccess: _onSuccess, 
                          onFail: _onFail,
                        );
                      }
                    }, 
                    child: Text("Cadastrar",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),

                //Botao cancelar
                SizedBox(
                  height: 44.00,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.purple[900],
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: (){
                      Navigator.of(context).pop();
                    }, 
                    child: Text("Cancelar",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        })
    ); 
  }

    void _onSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Verifique seu endereço de e-mail para logar"),
        duration: Duration(seconds: 5),
      )
      
    );
    Navigator.of(context).pop();
  }

  // Função chamada em caso de falha no cadastro
  void _onFail(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Falha ao criar usuário!: "))
    );
  }

}