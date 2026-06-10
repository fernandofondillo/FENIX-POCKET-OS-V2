import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
// import 'package:fenix_app/services/secure_storage_service.dart';
// import 'package:fenix_app/services/perfil_db_service.dart';
// import 'package:fenix_app/views/chat_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _profesionCtrl = TextEditingController();
  final TextEditingController _metaCtrl = TextEditingController();
  final TextEditingController _vpsUrlCtrl = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nombreCtrl.dispose();
    _profesionCtrl.dispose();
    _metaCtrl.dispose();
    _vpsUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _inicializarBoveda() async {
    setState(() => _isLoading = true);

    try {
      // 1. Generación del Identificador Anónimo Descentralizado (Zero-Knowledge)
      final uuid = Uuid();
      final String userId = uuid.v4();

      // 2. Generación y almacenamiento seguro de la clave maestra AES-256 en el KeyStore/Keychain
      // await SecureStorageService.guardarClaveMaestra(userId);
      // await SecureStorageService.guardarUrlVPS(_vpsUrlCtrl.text.trim());
      // await SecureStorageService.guardarUserId(userId);

      // 3. Persistencia Local Inicial en SQLite (Identity Profile)
      /*
      final db = PerfilDbService();
      await db.insertarAtributo("identidad", "nombre", _nombreCtrl.text.trim());
      await db.insertarAtributo("identidad", "rol_profesional", _profesionCtrl.text.trim());
      await db.insertarAtributo("identidad", "meta_principal", _metaCtrl.text.trim());
      
      // 4. Perfil Semilla de Prueba por Defecto
      await db.insertarAtributo("GENERAL", "config_inicial", "Activa");
      */

      // Simulación de escritura criptográfica (para demo visual)
      await Future.delayed(Duration(seconds: 2));

      // 5. Redirección al entorno principal (Chat Dinámico)
      /*
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen()),
      );
      */
      
      // Para simular redirección
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bóveda generada. Redirigiendo a ChatScreen...')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error crítico aislando cápsula local: \$e'),
          backgroundColor: Colors.redAccent,
        )
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0C),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _construirPantallaBienvenida(),
          _construirPantallaFormulario(),
        ],
      ),
    );
  }

  Widget _construirPantallaBienvenida() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 80, color: const Color(0xFFC5A059)),
              SizedBox(height: 40),
              Text(
                "A.G.O.S. / FÉNIX",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Space Grotesk',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Tu Agente de Inteligencia Soberana.\n100% Privado. Zero-Knowledge. Evolutivo.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5A059),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(
                  "Inicializar mi Asistente Soberano",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirPantallaFormulario() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              "Arquitectura de Identidad",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Space Grotesk',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Configura la matriz local. Estos datos no viajan de forma estática en la red, se inyectan en tiempo de ejecución al vuelo.",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            SizedBox(height: 40),
            _crearCampoTexto("Tu Nombre/Alias", "Ej. Alex", _nombreCtrl, false),
            _crearCampoTexto("Profesión / Rol", "Ej. Ingeniero DevOps, Estudiante", _profesionCtrl, false),
            _crearCampoTexto("Meta Principal con Fénix", "Ej. Productividad, Fitness, Longevidad", _metaCtrl, false),
            
            SizedBox(height: 20),
            Divider(color: Colors.white12),
            SizedBox(height: 20),
            
            Text(
              "Conexión VPS (Producción)",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Space Grotesk',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _crearCampoTexto("URL Endpoint Fénix", "https://api.tu-dominio.com", _vpsUrlCtrl, true),
            
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5A059),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _inicializarBoveda,
                child: _isLoading 
                  ? SizedBox(
                      width: 20, height: 20, 
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                    )
                  : Text(
                      "Crear Compañero Personal",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearCampoTexto(String titulo, String hint, TextEditingController controller, bool esUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: esUrl ? TextInputType.url : TextInputType.text,
            style: TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF141414),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: const Color(0xFF2A2A2A)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: const Color(0xFF2A2A2A)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: const Color(0xFFC5A059).withOpacity(0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
