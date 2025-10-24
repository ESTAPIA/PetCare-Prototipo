import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/consulta.dart';
import '../../data/mock/mock_bot_service.dart';
import '../../data/mock/mock_consult_history.dart';
import '../../models/reminder.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../reminders/reminder_new_screen.dart';
import '../plans/plan_template_list_screen.dart';
import '../vets/vet_map_screen.dart';
import 'chat_summary_screen.dart';

/// SCR-CONS-CHAT: Pantalla de chat activo con el bot
/// PROC-005: Consulta Express IA
/// 
/// Funcionalidades:
/// - Chat bidireccional con bot
/// - Sugerencias rápidas iniciales
/// - Typing indicator
/// - Modo readonly para consultas antiguas
class ChatActiveScreen extends StatefulWidget {
  final String? consultId; // Si viene consultId, es consulta existente

  const ChatActiveScreen({
    super.key,
    this.consultId,
  });

  @override
  State<ChatActiveScreen> createState() => _ChatActiveScreenState();
}

class _ChatActiveScreenState extends State<ChatActiveScreen> {
  // Controladores
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Estado
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _showSuggestions = true;
  bool _isReadonly = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Inicializar chat (cargar consulta existente o empezar nueva)
  void _initializeChat() {
    if (widget.consultId != null) {
      // Cargar consulta existente (modo readonly)
      final consulta = MockConsultHistory.getConsultaById(widget.consultId!);
      if (consulta != null) {
        setState(() {
          _messages.addAll(consulta.messages);
          _isReadonly = true;
          _showSuggestions = false;
        });
        // Auto-scroll al último mensaje después de cargar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animated: false);
        });
      }
    }
  }

  /// Enviar mensaje del usuario
  void _sendMessage(String text) {
    if (text.trim().isEmpty || _isReadonly) return;

    final userMessage = ChatMessage.user(text.trim());

    setState(() {
      _messages.insert(0, userMessage);
      _showSuggestions = false;
      _isTyping = true;
    });

    _textController.clear();
    _focusNode.unfocus();
    _scrollToBottom();

    // Simular delay de respuesta del bot (2-3 segundos)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;

      final botResponse = MockBotService.getResponse(text);

      setState(() {
        _messages.insert(0, botResponse);
        _isTyping = false;
      });

      _scrollToBottom();
    });
  }

  /// Auto-scroll al último mensaje
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0.0);
    }
  }

  /// Manejar tap en botón de acción del bot
  /// PASO F: Navegación real a pantallas placeholder
  void _handleActionTap(MessageAction action) {
    switch (action.type) {
      case ActionType.createReminder:
        // Navegar a pantalla real de creación de recordatorio (PROC-003)
        // Pre-seleccionar tipo "vacuna" si el contexto lo sugiere
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReminderNewScreen(
              sourceContext: 'chat',
              initialType: ReminderType.vaccine,
            ),
          ),
        );
        break;

      case ActionType.viewPlan:
        // Navegar a pantalla real de plantillas de plan (PROC-002)
        // Mostrar plantillas con énfasis en vacunas
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PlanTemplateListScreen(
              sourceContext: 'chat',
              filterCategory: 'Vacunas',
            ),
          ),
        );
        break;

      case ActionType.searchVet:
        // Navegar a pantalla real de veterinarias (PROC-004)
        // Pasar contexto para mostrar banner y botón de regreso
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VetMapScreen(sourceContext: 'chat'),
          ),
        );
        break;

      case ActionType.navigate:
        // Navegación genérica según ruta
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navegación a ${action.route} - Por implementar'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.consultId != null ? 'Consulta Anterior' : 'Nueva Consulta',
        ),
        actions: [
          if (!_isReadonly && _messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _finishConsultation,
              tooltip: 'Finalizar consulta',
            ),
          if (!_isReadonly)
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                _showHelpDialog();
              },
              tooltip: 'Ayuda',
            ),
        ],
      ),
      body: Column(
        children: [
          // Banner de modo readonly
          if (_isReadonly)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: AppColors.info.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Consulta finalizada - Solo lectura',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // Último mensaje abajo
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: _messages.length +
                  (_isTyping ? 1 : 0) +
                  (_showSuggestions ? 1 : 0),
              itemBuilder: (context, index) {
                // Typing indicator
                if (_isTyping && index == 0) {
                  return _buildTypingIndicator();
                }

                // Sugerencias rápidas
                if (_showSuggestions &&
                    index == (_isTyping ? 1 : 0) &&
                    _messages.isEmpty) {
                  return _buildSuggestions();
                }

                // Mensajes normales
                final messageIndex = index -
                    (_isTyping ? 1 : 0) -
                    (_showSuggestions && _messages.isEmpty ? 1 : 0);

                if (messageIndex >= _messages.length) return const SizedBox();

                return ChatBubble(
                  message: _messages[messageIndex],
                  onActionTap: _handleActionTap,
                );
              },
            ),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Sugerencias rápidas (chips)
  Widget _buildSuggestions() {
    final suggestions = MockBotService.getQuickSuggestions();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sugerencias:',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: suggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () => _sendMessage(suggestion),
                backgroundColor: AppColors.surfaceVariant,
                labelStyle: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                ),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Indicador de "escribiendo..."
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Avatar del bot
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Burbuja con puntos animados
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Escribiendo',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                _buildDotAnimation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Animación de puntos (...)
  Widget _buildDotAnimation() {
    return SizedBox(
      width: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: (value + index * 0.3) % 1.0,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
            onEnd: () {
              if (mounted && _isTyping) {
                setState(() {}); // Reiniciar animación
              }
            },
          );
        }),
      ),
    );
  }

  /// Área de input (TextField + botón)
  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // TextField
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  enabled: !_isReadonly,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _isReadonly
                        ? 'Consulta finalizada'
                        : 'Escribe tu pregunta...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: _isReadonly
                        ? AppColors.surfaceVariant.withValues(alpha: 0.5)
                        : AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Botón enviar
              Container(
                decoration: BoxDecoration(
                  color: _isReadonly
                      ? AppColors.textDisabled
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  color: AppColors.onPrimary,
                  onPressed: _isReadonly
                      ? null
                      : () => _sendMessage(_textController.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mostrar diálogo de ayuda
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cómo usar Consulta Express?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Puedes escribir tu pregunta o seleccionar una sugerencia.\n\n'
              '2. El bot te responderá con información útil.\n\n'
              '3. Si la respuesta incluye botones, puedes tocarlos para navegar a otras secciones.\n\n'
              '4. En caso de emergencia, el bot te alertará inmediatamente.',
              style: AppTypography.body,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Finalizar consulta y navegar al resumen
  void _finishConsultation() {
    if (_messages.isEmpty) return;

    // Detectar el topic basado en el primer mensaje del usuario
    final topic = _detectTopic(_messages);

    // Extraer acciones recomendadas de las respuestas del bot
    final actions = _extractRecommendedActions(_messages);

    // Calcular tiempos (primer mensaje = inicio, ahora = fin)
    final startTime = _messages.last.timestamp;
    final endTime = DateTime.now();

    // Crear consulta
    final consulta = Consulta(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      petName: 'Sin mascota',
      topic: topic,
      messages: _messages.reversed.toList(),
      startTime: startTime,
      endTime: endTime,
      recommendedActions: actions,
    );

    // Guardar en historial
    MockConsultHistory.saveConsulta(consulta);

    // Navegar al resumen con push (preserva ChatActiveScreen en el stack)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatSummaryScreen(consulta: consulta),
      ),
    );
  }

  /// Detectar topic basado en palabras clave del primer mensaje del usuario
  String _detectTopic(List<ChatMessage> messages) {
    // Obtener el primer mensaje del usuario
    final firstUserMessage = messages.reversed.firstWhere(
      (msg) => msg.isUser,
      orElse: () => messages.first,
    );

    final text = firstUserMessage.text.toLowerCase();

    // Detección por palabras clave
    if (text.contains('vacuna')) {
      return 'Vacunas';
    } else if (text.contains('sangr') || text.contains('emergencia')) {
      return 'Emergencia';
    } else if (text.contains('diarrea') || text.contains('vomit') || text.contains('síntoma')) {
      return 'Salud';
    } else if (text.contains('comida') || text.contains('alimenta')) {
      return 'Alimentación';
    } else if (text.contains('comportamiento') || text.contains('ladra') || text.contains('comporta')) {
      return 'Comportamiento';
    } else if (text.contains('desparasit') || text.contains('parásito')) {
      return 'Desparasitación';
    } else if (text.contains('baño') || text.contains('higiene')) {
      return 'Higiene';
    }

    return 'Consulta General';
  }

  /// Extraer acciones recomendadas de las respuestas del bot
  List<String> _extractRecommendedActions(List<ChatMessage> messages) {
    final Set<String> actionsSet = {};

    for (final message in messages) {
      if (!message.isUser && message.actions != null) {
        for (final action in message.actions!) {
          actionsSet.add(action.label);
        }
      }
    }

    return actionsSet.toList();
  }
}
