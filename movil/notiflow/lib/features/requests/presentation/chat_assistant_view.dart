import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/token_storage.dart';
import '../../../config/routes.dart';
import '../data/request_service.dart';
import '../domain/workflow_template_model.dart';

enum MessageSender { bot, user }

class ChatMessage {
  final MessageSender sender;
  final String text;
  final Widget? customWidget;
  final DateTime time;

  ChatMessage({
    required this.sender,
    required this.text,
    this.customWidget,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class ChatAssistantView extends StatefulWidget {
  const ChatAssistantView({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatAssistantView(),
    );
  }

  @override
  State<ChatAssistantView> createState() => _ChatAssistantViewState();
}

class _ChatAssistantViewState extends State<ChatAssistantView> {
  final RequestService _requestService = RequestService();
  final TokenStorage _tokenStorage = TokenStorage();
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  List<WorkflowTemplate> _templates = [];
  WorkflowTemplate? _selectedTemplate;
  FormModel? _formModel;
  int _currentFieldIndex = -1;
  final Map<String, dynamic> _collectedData = {};

  String _clientName = '';
  String _clientId = '';

  @override
  void initState() {
    super.initState();
    _loadClientInfo();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadClientInfo() async {
    final name = await _tokenStorage.getNombre() ?? '';
    final rawUserId = await _tokenStorage.getUserId() ?? '';
    final cleanClientId = rawUserId.replaceAll('USER_CLIENTE_', '');

    setState(() {
      _clientName = name;
      _clientId = cleanClientId;
    });

    _initChat();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addBotMessage(String text, {Widget? customWidget}) {
    setState(() {
      _messages.add(ChatMessage(
        sender: MessageSender.bot,
        text: text,
        customWidget: customWidget,
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        sender: MessageSender.user,
        text: text,
      ));
    });
    _scrollToBottom();
  }

  void _initChat() async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 800));

    _addBotMessage(
      '¡Hola, $_clientName! 👋 Soy tu Asistente Virtual. Te ayudaré a iniciar tu trámite en segundos. '
      'Por favor, elige el tipo de solicitud que deseas realizar hoy:',
    );

    try {
      final templates = await _requestService.getTemplates();
      setState(() {
        _templates = templates;
        _isTyping = false;
      });

      if (_templates.isEmpty) {
        _addBotMessage(
          'Lo siento, no se encontraron plantillas de trámites activas en el sistema. Por favor, vuelve a intentarlo más tarde.',
        );
      } else {
        _addBotOptionsWidget();
      }
    } catch (e) {
      setState(() => _isTyping = false);
      _addBotMessage(
        'Ocurrió un error al obtener los trámites disponibles del servidor. Por favor, verifica tu conexión.',
      );
    }
  }

  void _addBotOptionsWidget() {
    _addBotMessage(
      'Selecciona una de las siguientes opciones:',
      customWidget: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _templates.map((template) {
            return ActionChip(
              backgroundColor: const Color(0xFFEFF6FF),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              label: Text(
                template.nombre,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => _selectTemplate(template),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _selectTemplate(WorkflowTemplate template) async {
    _addUserMessage('Quiero iniciar un trámite de "${template.nombre}"');

    setState(() {
      _selectedTemplate = template;
      _isTyping = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    _addBotMessage(
      'Excelente elección. Voy a cargar las preguntas para tu solicitud de **${template.nombre}**...',
    );

    try {
      final form = await _requestService.getFormById(template.formularioId);
      setState(() {
        _formModel = form;
        _currentFieldIndex = 0;
        _isTyping = false;
      });

      if (_formModel == null || _formModel!.campos.isEmpty) {
        _addBotMessage(
          'El formulario asociado a este trámite está vacío o no se pudo cargar. Por favor, selecciona otra opción.',
        );
        _addBotOptionsWidget();
      } else {
        _askNextField();
      }
    } catch (e) {
      setState(() => _isTyping = false);
      _addBotMessage(
        'Hubo un problema al conectar con el servidor para cargar el formulario.',
      );
    }
  }

  void _askNextField() async {
    if (_formModel == null) return;

    if (_currentFieldIndex < _formModel!.campos.length) {
      final field = _formModel!.campos[_currentFieldIndex];
      setState(() => _isTyping = true);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _isTyping = false);

      String question = 'Por favor, ingresa tu **${field.etiqueta}**:';

      // Lógica de asistencia inteligente: Pre-llenar campos conocidos
      Widget? helperWidget;
      if (field.nombre == 'nombreCompleto' && _clientName.isNotEmpty) {
        question = 'He detectado tu nombre registrado: **$_clientName**. ¿Deseas usarlo para este trámite?';
        helperWidget = Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              ActionChip(
                backgroundColor: const Color(0xFFDCFCE7),
                side: const BorderSide(color: Color(0xFFBBF7D0)),
                label: const Text(
                  'Sí, usar mi nombre',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w800),
                ),
                onPressed: () {
                  _collectedData[field.nombre] = _clientName;
                  _addUserMessage('Sí, usar mi nombre: $_clientName');
                  _currentFieldIndex++;
                  _askNextField();
                },
              ),
            ],
          ),
        );
      } else if (field.nombre == 'ci') {
        question = 'Por favor, ingresa tu **Documento de identidad (CI)**:';
      } else if (field.nombre == 'telefono') {
        question = 'Por favor, ingresa tu **Número de teléfono o celular** de contacto:';
      }

      _addBotMessage(question, customWidget: helperWidget);
    } else {
      // Todos los campos recolectados
      _showConfirmationRecap();
    }
  }

  void _showConfirmationRecap() async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isTyping = false);

    StringBuffer recap = StringBuffer();
    _collectedData.forEach((key, value) {
      final field = _formModel!.campos.firstWhere((f) => f.nombre == key);
      recap.writeln('• **${field.etiqueta}:** $value');
    });

    _addBotMessage(
      '¡Perfecto! He recolectado todos los datos. Por favor, confirma si la información es correcta antes de enviar tu trámite:\n\n${recap.toString()}',
      customWidget: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Confirmar y Enviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: _submitForm,
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () {
                _addUserMessage('Quiero corregir los datos.');
                _resetChat();
              },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    _addUserMessage('Confirmo los datos. Enviar trámite.');

    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final request = await _requestService.createRequest(
        templateId: _selectedTemplate!.id,
        clienteId: _clientId,
        datosFormulario: _collectedData,
      );

      setState(() => _isTyping = false);

      if (request != null) {
        _addBotMessage(
          '¡Felicidades! 🎉 Tu trámite ha sido iniciado con éxito en el sistema.',
          customWidget: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              border: Border.all(color: const Color(0xFFBBF7D0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      request.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                    children: [
                      const TextSpan(text: 'Tipo: ', style: TextStyle(fontWeight: FontWeight.w900)),
                      TextSpan(text: request.title),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                    children: [
                      const TextSpan(text: 'Estado: ', style: TextStyle(fontWeight: FontWeight.w900)),
                      TextSpan(text: request.status),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                    children: [
                      const TextSpan(text: 'Oficina Actual: ', style: TextStyle(fontWeight: FontWeight.w900)),
                      TextSpan(text: request.currentOffice),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Cerrar bottom sheet
                      Navigator.pushNamed(
                        context,
                        AppRoutes.requestTracking,
                        arguments: request.id,
                      );
                    },
                    child: const Text('Ver Seguimiento en Vivo'),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        _addBotMessage(
          'No pudimos registrar tu solicitud. Ocurrió un error en el servidor. Por favor, intenta de nuevo.',
          customWidget: ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Reintentar Envío'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isTyping = false);
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      _addBotMessage(
        'No pudimos registrar tu solicitud. Motivo del servidor:\n**$errorMsg**',
        customWidget: ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Reintentar Envío'),
        ),
      );
    }
  }

  void _resetChat() {
    setState(() {
      _selectedTemplate = null;
      _formModel = null;
      _currentFieldIndex = -1;
      _collectedData.clear();
    });
    _addBotMessage('Volvamos a empezar. Por favor, elige el tipo de solicitud que deseas realizar:');
    _addBotOptionsWidget();
  }

  void _handleSendText() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    _addUserMessage(text);

    if (_formModel != null && _currentFieldIndex < _formModel!.campos.length) {
      final field = _formModel!.campos[_currentFieldIndex];
      _collectedData[field.nombre] = text;
      _currentFieldIndex++;
      _askNextField();
    } else {
      // El usuario escribe mensajes libres, respondemos con ayuda genérica
      _respondGenericHelp(text);
    }
  }

  void _respondGenericHelp(String text) async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _isTyping = false);

    _addBotMessage(
      'Para iniciar un trámite, por favor selecciona una plantilla de la lista o responde a las preguntas correspondientes.',
    );
    if (_selectedTemplate == null) {
      _addBotOptionsWidget();
    } else {
      _askNextField();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Cabecera del Bottom Sheet
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asistente Virtual IA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Creación guiada de trámites',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Lista de Mensajes del Chat
            Expanded(
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isBot = message.sender == MessageSender.bot;

                    return Align(
                      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isBot) ...[
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                  child: const Icon(Icons.smart_toy, size: 14, color: AppColors.primary),
                                ),
                              ),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isBot ? Colors.white : AppColors.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(14),
                                    topRight: const Radius.circular(14),
                                    bottomLeft: Radius.circular(isBot ? 0 : 14),
                                    bottomRight: Radius.circular(isBot ? 14 : 0),
                                  ),
                                  boxShadow: isBot
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _formatMessageText(message.text, !isBot),
                                    if (message.customWidget != null) message.customWidget!,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Indicador de Escribiendo...
            if (_isTyping)
              Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.smart_toy, size: 12, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const _TypingIndicator(),
                    ),
                  ],
                ),
              ),
            // Input y Envío de Texto
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _inputController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _handleSendText(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 16),
                      onPressed: _handleSendText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Permite renderizar negritas simples (**texto**) en las burbujas del chat
  Widget _formatMessageText(String text, bool isUser) {
    if (!text.contains('**')) {
      return Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      );
    }

    final parts = text.split('**');
    final List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      final isBold = i % 2 == 1;
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isUser ? Colors.white : Colors.black,
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, height: 1.3),
        children: spans,
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double offset = index * 0.2;
            double progress = (_controller.value - offset) % 1.0;
            if (progress < 0) progress += 1.0;
            double opacity = 0.3 + 0.7 * (1.0 - (progress - 0.5).abs() * 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
