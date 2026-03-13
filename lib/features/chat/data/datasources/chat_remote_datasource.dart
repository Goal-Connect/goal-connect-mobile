import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations(String userId);
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  });
}

class MockChatRemoteDataSource implements ChatRemoteDataSource {
  static const String _currentUserId = 'current_user';

  final Map<String, List<MessageModel>> _messagesByConversation = {};
  late final List<ConversationModel> _conversations;

  MockChatRemoteDataSource() {
    _initMockData();
  }

  void _initMockData() {
    final now = DateTime.now();

    // ─── Seed messages per conversation ───
    _messagesByConversation['conv_1'] = [
      _msg('conv_1', 'scout_1', 'ScoutEthiopia_FA',
          'Hello! I watched your latest highlight. Very impressive footwork!',
          now.subtract(const Duration(hours: 5))),
      _msg('conv_1', _currentUserId, 'yafet10',
          'Thank you so much! I have been training every day.',
          now.subtract(const Duration(hours: 4, minutes: 50))),
      _msg('conv_1', 'scout_1', 'ScoutEthiopia_FA',
          'We would like to invite you for a trial with the Ethiopian U-20 squad.',
          now.subtract(const Duration(hours: 4, minutes: 30))),
      _msg('conv_1', _currentUserId, 'yafet10',
          'That is a dream come true! When is the trial?',
          now.subtract(const Duration(hours: 4, minutes: 20))),
      _msg('conv_1', 'scout_1', 'ScoutEthiopia_FA',
          'Next Saturday at Addis Ababa Stadium. Be there at 9am. Bring boots!',
          now.subtract(const Duration(hours: 4))),
      _msg('conv_1', _currentUserId, 'yafet10',
          'I will be there. Thank you for the opportunity! 🙏🇪🇹',
          now.subtract(const Duration(hours: 3, minutes: 55))),
    ];

    _messagesByConversation['conv_2'] = [
      _msg('conv_2', 'scout_2', 'AbujaAcademyNG',
          'Hey! Saw your dribbling reel. Nigeria here. Are you open to academies abroad?',
          now.subtract(const Duration(days: 1, hours: 2))),
      _msg('conv_2', _currentUserId, 'yafet10',
          'Hello! Yes, I am open to opportunities. What academy are you from?',
          now.subtract(const Duration(days: 1, hours: 1, minutes: 50))),
      _msg('conv_2', 'scout_2', 'AbujaAcademyNG',
          'Abuja Youth Football Academy. We have sent 12 players to European clubs.',
          now.subtract(const Duration(days: 1, hours: 1, minutes: 30))),
      _msg('conv_2', _currentUserId, 'yafet10',
          'That sounds incredible. What are the next steps?',
          now.subtract(const Duration(days: 1, hours: 1))),
      _msg('conv_2', 'scout_2', 'AbujaAcademyNG',
          'Send me your full highlight reel and a short bio. We will review within 2 weeks.',
          now.subtract(const Duration(days: 1))),
    ];

    _messagesByConversation['conv_3'] = [
      _msg('conv_3', 'scout_3', 'EthioLeagueCoach',
          'Yafet, I coach Saint George FC youth team. Want to train with us this weekend?',
          now.subtract(const Duration(days: 2, hours: 3))),
      _msg('conv_3', _currentUserId, 'yafet10',
          'Coach! Yes absolutely. Saint George is my dream club! ⚽',
          now.subtract(const Duration(days: 2, hours: 2, minutes: 45))),
      _msg('conv_3', 'scout_3', 'EthioLeagueCoach',
          'Great attitude. We train Saturday 7am. Bring your A-game, we are watching closely.',
          now.subtract(const Duration(days: 2, hours: 2, minutes: 30))),
      _msg('conv_3', _currentUserId, 'yafet10',
          'I will be ready. Should I bring anything specific?',
          now.subtract(const Duration(days: 2, hours: 2))),
      _msg('conv_3', 'scout_3', 'EthioLeagueCoach',
          'Boots, shin guards, and your hunger to succeed. See you Saturday! 💪',
          now.subtract(const Duration(days: 2, hours: 1, minutes: 50))),
      _msg('conv_3', _currentUserId, 'yafet10',
          'Thank you Coach. I will not let you down! 🙏',
          now.subtract(const Duration(days: 2, hours: 1, minutes: 40))),
    ];

    _messagesByConversation['conv_4'] = [
      _msg('conv_4', 'scout_4', 'CAFYouthDev',
          'CAF Youth Development Programme here. We noticed your profile on GoalConnect.',
          now.subtract(const Duration(days: 3, hours: 5))),
      _msg('conv_4', _currentUserId, 'yafet10',
          'Wow, CAF! This is unbelievable. How can I help?',
          now.subtract(const Duration(days: 3, hours: 4, minutes: 50))),
      _msg('conv_4', 'scout_4', 'CAFYouthDev',
          'We select 20 players per year for our Pan-African development camp. You are on our shortlist.',
          now.subtract(const Duration(days: 3, hours: 4, minutes: 30))),
      _msg('conv_4', _currentUserId, 'yafet10',
          'That is an honour. What are the requirements?',
          now.subtract(const Duration(days: 3, hours: 4))),
      _msg('conv_4', 'scout_4', 'CAFYouthDev',
          'Age 14-19, minimum 3 highlight videos, school report, and coach recommendation letter.',
          now.subtract(const Duration(days: 3, hours: 3, minutes: 30))),
      _msg('conv_4', _currentUserId, 'yafet10',
          'I have all of that. Let me prepare and send it this week.',
          now.subtract(const Duration(days: 3, hours: 3))),
      _msg('conv_4', 'scout_4', 'CAFYouthDev',
          'Perfect. Deadline is end of month. Good luck, Yafet! 🌍⚽',
          now.subtract(const Duration(days: 3, hours: 2, minutes: 45))),
    ];

    _messagesByConversation['conv_5'] = [
      _msg('conv_5', 'scout_5', 'NairobiSportsMgmt',
          'Hi Yafet! I am a sports agent based in Nairobi. Represent 8 African players in Europe.',
          now.subtract(const Duration(days: 4, hours: 6))),
      _msg('conv_5', _currentUserId, 'yafet10',
          'Hello! That is impressive. Which clubs are your players at?',
          now.subtract(const Duration(days: 4, hours: 5, minutes: 45))),
      _msg('conv_5', 'scout_5', 'NairobiSportsMgmt',
          'Clubs in Belgium, Netherlands, and Portugal. All started just like you on platforms like this.',
          now.subtract(const Duration(days: 4, hours: 5, minutes: 30))),
      _msg('conv_5', _currentUserId, 'yafet10',
          'That is inspiring. I would love to learn more about representation.',
          now.subtract(const Duration(days: 4, hours: 5))),
      _msg('conv_5', 'scout_5', 'NairobiSportsMgmt',
          'Let us schedule a video call this week. I will share our agency profile with you.',
          now.subtract(const Duration(days: 4, hours: 4, minutes: 30))),
    ];

    _messagesByConversation['conv_6'] = [
      _msg('conv_6', 'scout_6', 'AddisCoachBiruk',
          'Yafet! It is Coach Biruk from your school. I shared your highlight with our federation contact.',
          now.subtract(const Duration(days: 5, hours: 3))),
      _msg('conv_6', _currentUserId, 'yafet10',
          'Coach Biruk! Thank you so much. What did they say?',
          now.subtract(const Duration(days: 5, hours: 2, minutes: 50))),
      _msg('conv_6', 'scout_6', 'AddisCoachBiruk',
          'Very positive feedback! They want to see you play live next Friday.',
          now.subtract(const Duration(days: 5, hours: 2, minutes: 30))),
      _msg('conv_6', _currentUserId, 'yafet10',
          'I will be ready. Should I tell my parents?',
          now.subtract(const Duration(days: 5, hours: 2))),
      _msg('conv_6', 'scout_6', 'AddisCoachBiruk',
          'Yes, bring them. This could be big for your career. Stay focused and train hard! 💪',
          now.subtract(const Duration(days: 5, hours: 1, minutes: 45))),
    ];

    // ─── Build conversations ───
    _conversations = [
      ConversationModel(
        id: 'conv_1',
        participantId: 'scout_1',
        participantName: 'ScoutEthiopia FA',
        participantImage: 'https://ui-avatars.com/api/?name=scout_eth&background=00D084&color=000&size=150',
        participantRole: 'scout',
        lastMessage: 'Next Saturday at Addis Ababa Stadium. Be there at 9am.',
        updatedAt: now.subtract(const Duration(hours: 4)),
        unreadCount: 2,
      ),
      ConversationModel(
        id: 'conv_2',
        participantId: 'scout_2',
        participantName: 'Abuja Academy NG',
        participantImage: 'https://ui-avatars.com/api/?name=scout_ng&background=00D084&color=000&size=150',
        participantRole: 'scout',
        lastMessage: 'Send me your full highlight reel and a short bio.',
        updatedAt: now.subtract(const Duration(days: 1)),
        unreadCount: 1,
      ),
      ConversationModel(
        id: 'conv_3',
        participantId: 'scout_3',
        participantName: 'Saint George FC Coach',
        participantImage: 'https://ui-avatars.com/api/?name=scout_sg&background=00D084&color=000&size=150',
        participantRole: 'coach',
        lastMessage: 'Thank you Coach. I will not let you down! 🙏',
        updatedAt: now.subtract(const Duration(days: 2, hours: 1, minutes: 40)),
        unreadCount: 0,
      ),
      ConversationModel(
        id: 'conv_4',
        participantId: 'scout_4',
        participantName: 'CAF Youth Dev',
        participantImage: 'https://ui-avatars.com/api/?name=scout_caf&background=00D084&color=000&size=150',
        participantRole: 'scout',
        lastMessage: 'Deadline is end of month. Good luck! 🌍',
        updatedAt: now.subtract(const Duration(days: 3, hours: 2, minutes: 45)),
        unreadCount: 0,
      ),
      ConversationModel(
        id: 'conv_5',
        participantId: 'scout_5',
        participantName: 'Nairobi Sports Mgmt',
        participantImage: 'https://ui-avatars.com/api/?name=scout_nbi&background=00D084&color=000&size=150',
        participantRole: 'agent',
        lastMessage: 'Let us schedule a video call this week.',
        updatedAt: now.subtract(const Duration(days: 4, hours: 4, minutes: 30)),
        unreadCount: 3,
      ),
      ConversationModel(
        id: 'conv_6',
        participantId: 'scout_6',
        participantName: 'Coach Biruk',
        participantImage: 'https://ui-avatars.com/api/?name=scout_bir&background=00D084&color=000&size=150',
        participantRole: 'coach',
        lastMessage: 'Stay focused and train hard! 💪',
        updatedAt: now.subtract(const Duration(days: 5, hours: 1, minutes: 45)),
        unreadCount: 0,
      ),
    ];
  }

  MessageModel _msg(
    String conversationId,
    String senderId,
    String senderName,
    String text,
    DateTime createdAt,
  ) =>
      MessageModel(
        id: 'msg_${conversationId}_${senderId}_${createdAt.millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        createdAt: createdAt,
        isRead: senderId != 'current_user',
      );

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _conversations;
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _messagesByConversation[conversationId] ?? [];
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final message = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: DateTime.now(),
      isRead: false,
    );
    _messagesByConversation.putIfAbsent(conversationId, () => []);
    _messagesByConversation[conversationId]!.add(message);

    // Update the conversation's last message
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final old = _conversations[idx];
      _conversations[idx] = ConversationModel(
        id: old.id,
        participantId: old.participantId,
        participantName: old.participantName,
        participantImage: old.participantImage,
        participantRole: old.participantRole,
        lastMessage: text,
        updatedAt: DateTime.now(),
        unreadCount: 0,
      );
    }
    return message;
  }
}
