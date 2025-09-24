import '../models/contact.dart';
import 'relationship_analyzer.dart';

/// AI-Powered Relationship Advisor
/// यह service relationship analysis के based पर personalized advice देती है
/// Cultural context के साथ Hindi और English में solutions provide करती है
class RelationshipAdvisor {
  /// Generate comprehensive relationship advice based on analysis
  RelationshipAdvice generateAdvice(RelationshipHealth health) {
    final contact = health.contact;
    final score = health.overallScore;

    return RelationshipAdvice(
      contact: contact,
      overallAssessment: _generateOverallAssessment(health),
      specificIssues: _identifySpecificIssues(health),
      actionPlan: _createActionPlan(health),
      conversationStarters: _generateConversationStarters(contact),
      culturalTips: _getCulturalTips(contact),
      timeBasedSuggestions: _getTimeBasedSuggestions(health),
      emergencyActions: score < 0.3 ? _getEmergencyActions(health) : [],
    );
  }

  /// 📋 Overall Relationship Assessment
  RelationshipAssessment _generateOverallAssessment(RelationshipHealth health) {
    final score = health.overallScore;

    if (score >= 0.8) {
      return RelationshipAssessment(
        status: RelationshipStatus.thriving,
        titleEn: "Thriving Relationship",
        titleHi: "फलता-फूलता रिश्ता",
        descriptionEn:
            "Your relationship with ${health.contact.displayName} is strong and healthy. Keep nurturing this connection!",
        descriptionHi:
            "${health.contact.displayName} के साथ आपका रिश्ता मजबूत और स्वस्थ है। इस जुड़ाव को बनाए रखते रहें!",
        emoji: "💚",
        confidenceLevel: 0.9,
      );
    } else if (score >= 0.6) {
      return RelationshipAssessment(
        status: RelationshipStatus.stable,
        titleEn: "Stable Connection",
        titleHi: "स्थिर जुड़ाव",
        descriptionEn:
            "Good foundation, but there's room for improvement in your relationship.",
        descriptionHi: "अच्छी नींव है, लेकिन रिश्ते में सुधार की गुंजाइश है।",
        emoji: "💛",
        confidenceLevel: 0.8,
      );
    } else if (score >= 0.4) {
      return RelationshipAssessment(
        status: RelationshipStatus.needsAttention,
        titleEn: "Needs Attention",
        titleHi: "ध्यान देने की जरूरत",
        descriptionEn:
            "Your relationship is showing signs of drift. Time to take action!",
        descriptionHi:
            "आपका रिश्ता दूर होने के संकेत दिखा रहा है। कार्रवाई का समय है!",
        emoji: "🧡",
        confidenceLevel: 0.7,
      );
    } else {
      return RelationshipAssessment(
        status: RelationshipStatus.atRisk,
        titleEn: "At Risk",
        titleHi: "खतरे में",
        descriptionEn:
            "This relationship needs immediate care and attention to prevent further deterioration.",
        descriptionHi:
            "इस रिश्ते को और बिगड़ने से रोकने के लिए तुरंत देखभाल और ध्यान की जरूरत है।",
        emoji: "❤️‍🩹",
        confidenceLevel: 0.9,
      );
    }
  }

  /// 🔍 Identify Specific Issues
  List<RelationshipIssue> _identifySpecificIssues(RelationshipHealth health) {
    List<RelationshipIssue> issues = [];

    // Communication Frequency Issue
    if (health.frequencyHealth < 0.5) {
      issues.add(RelationshipIssue(
        type: IssueType.lowFrequency,
        severity: health.frequencyHealth < 0.3
            ? IssueSeverity.high
            : IssueSeverity.medium,
        titleEn: "Infrequent Communication",
        titleHi: "कम बातचीत",
        descriptionEn:
            "You don't communicate as often as healthy relationships typically do.",
        descriptionHi:
            "आप उतनी बार बात नहीं करते जितनी स्वस्थ रिश्तों में होती है।",
        solutionEn:
            "Try to increase contact frequency gradually. Aim for at least one meaningful interaction per week.",
        solutionHi:
            "धीरे-धीरे संपर्क की आवृत्ति बढ़ाने की कोशिश करें। सप्ताह में कम से कम एक सार्थक बातचीत का लक्ष्य रखें।",
      ));
    }

    // Response Time Issue
    if (health.responseHealth < 0.5) {
      issues.add(RelationshipIssue(
        type: IssueType.slowResponse,
        severity: IssueSeverity.medium,
        titleEn: "Delayed Responses",
        titleHi: "देर से जवाब",
        descriptionEn:
            "Either you or they take too long to respond to messages.",
        descriptionHi:
            "या तो आप या वे संदेशों का जवाब देने में बहुत समय लेते हैं।",
        solutionEn:
            "Set expectations about response times and try to respond more promptly yourself.",
        solutionHi:
            "जवाब के समय के बारे में अपेक्षाएं तय करें और खुद भी जल्दी जवाब देने की कोशिश करें।",
      ));
    }

    // Mutuality Issue
    if (health.mutualityHealth < 0.4) {
      final contact = health.contact;
      final isOneWay = contact.mutualityScore < 0.3;

      issues.add(RelationshipIssue(
        type: IssueType.imbalancedInitiation,
        severity: IssueSeverity.high,
        titleEn: "One-sided Communication",
        titleHi: "एकतरफा संवाद",
        descriptionEn: isOneWay
            ? "You're initiating most conversations. They may not be as invested."
            : "The conversation initiation is heavily skewed to one side.",
        descriptionHi: isOneWay
            ? "आप ज्यादातर बातचीत शुरू कर रहे हैं। हो सकता है वे उतने invested न हों।"
            : "बातचीत की शुरुआत एक तरफ ज्यादा झुकी हुई है।",
        solutionEn:
            "Give them space to reach out sometimes. Don't always be the first to message.",
        solutionHi:
            "कभी-कभी उन्हें संपर्क करने के लिए जगह दें। हमेशा पहले संदेश न भेजें।",
      ));
    }

    return issues;
  }

  /// 📋 Create Actionable Plan
  ActionPlan _createActionPlan(RelationshipHealth health) {
    List<ActionItem> immediateActions = [];
    List<ActionItem> weeklyActions = [];
    List<ActionItem> monthlyActions = [];

    final daysSinceContact = health.contact.daysSinceLastContact;

    // Immediate Actions (next 24-48 hours)
    if (daysSinceContact > 7) {
      immediateActions.add(ActionItem(
        titleEn: "Send a friendly check-in message",
        titleHi: "एक दोस्ताना संदेश भेजें",
        descriptionEn:
            "Break the silence with a casual 'How are you?' or share something interesting",
        descriptionHi:
            "कैजुअल 'कैसे हो?' के साथ खामोशी तोड़ें या कुछ दिलचस्प शेयर करें",
        priority: ActionPriority.high,
        estimatedTime: "2-5 minutes",
      ));
    }

    // Weekly Actions
    weeklyActions.add(ActionItem(
      titleEn: "Schedule regular check-ins",
      titleHi: "नियमित संपर्क निर्धारित करें",
      descriptionEn:
          "Set a weekly reminder to reach out, even if it's just a quick message",
      descriptionHi:
          "साप्ताहिक रिमाइंडर सेट करें, भले ही यह सिर्फ एक छोटा संदेश हो",
      priority: ActionPriority.medium,
      estimatedTime: "5-10 minutes",
    ));

    // Monthly Actions
    monthlyActions.add(ActionItem(
      titleEn: "Plan a deeper conversation",
      titleHi: "गहरी बातचीत की योजना बनाएं",
      descriptionEn:
          "Have a meaningful conversation about life, goals, or shared interests",
      descriptionHi:
          "जीवन, लक्ष्यों या साझा रुचियों के बारे में सार्थक बातचीत करें",
      priority: ActionPriority.medium,
      estimatedTime: "20-30 minutes",
    ));

    return ActionPlan(
      immediateActions: immediateActions,
      weeklyActions: weeklyActions,
      monthlyActions: monthlyActions,
      timeframe: "Next 30 days",
      successMetrics: [
        "Increased communication frequency",
        "More balanced conversation initiation",
        "Improved response times",
        "Deeper connection"
      ],
    );
  }

  /// 💬 Generate Conversation Starters
  List<ConversationStarter> _generateConversationStarters(Contact contact) {
    return [
      ConversationStarter(
        category: "Casual Check-in",
        messageEn: "Hey! How have you been? It's been a while!",
        messageHi: "अरे! कैसे हो? काफी दिन हो गए!",
        context: "Perfect for breaking long silences",
        tone: ConversationTone.friendly,
      ),
      ConversationStarter(
        category: "Shared Interest",
        messageEn: "Saw this and thought of you! [share something relevant]",
        messageHi: "यह देखा तो आपकी याद आई! [कुछ प्रासंगिक शेयर करें]",
        context: "Great for showing you remember their interests",
        tone: ConversationTone.thoughtful,
      ),
      ConversationStarter(
        category: "Current Events",
        messageEn:
            "What do you think about [recent event]? Would love your perspective!",
        messageHi:
            "[हाल की घटना] के बारे में आपका क्या विचार है? आपका नजरिया जानना चाहूंगा!",
        context: "Good for intellectual discussions",
        tone: ConversationTone.curious,
      ),
      ConversationStarter(
        category: "Memory Sharing",
        messageEn:
            "Remember when we [shared memory]? That was such a good time!",
        messageHi:
            "याद है जब हमने [साझा यादें] किया था? वह कितना अच्छा समय था!",
        context: "Perfect for strengthening emotional bonds",
        tone: ConversationTone.nostalgic,
      ),
    ];
  }

  /// 🌍 Cultural Communication Tips
  List<CulturalTip> _getCulturalTips(Contact contact) {
    return [
      CulturalTip(
        category: "Hindi Communication",
        titleEn: "Use respectful language",
        titleHi: "सम्मानजनक भाषा का उपयोग करें",
        tipEn: "Address elders with 'Aap' and use respectful terms like 'ji'",
        tipHi: "बड़ों को 'आप' कहें और 'जी' जैसे सम्मानजनक शब्दों का उपयोग करें",
      ),
      CulturalTip(
        category: "Indian Context",
        titleEn: "Remember festivals and occasions",
        titleHi: "त्योहारों और अवसरों को याद रखें",
        tipEn:
            "Sending wishes on Diwali, Eid, Christmas shows you care about their culture",
        tipHi:
            "दिवाली, ईद, क्रिसमस पर शुभकामनाएं भेजना दिखाता है कि आप उनकी संस्कृति की परवाह करते हैं",
      ),
      CulturalTip(
        category: "Family Importance",
        titleEn: "Ask about family",
        titleHi: "परिवार के बारे में पूछें",
        tipEn:
            "In Indian culture, asking about family shows genuine care and interest",
        tipHi:
            "भारतीय संस्कृति में परिवार के बारे में पूछना वास्तविक देखभाल और रुचि दिखाता है",
      ),
    ];
  }

  /// ⏰ Time-based Suggestions
  List<TimeSuggestion> _getTimeBasedSuggestions(RelationshipHealth health) {
    return [
      TimeSuggestion(
        timeType: TimeType.bestContactTime,
        suggestion:
            "Based on past interactions, they're most responsive in the evening",
        suggestionHi:
            "पिछली बातचीत के आधार पर, वे शाम में सबसे ज्यादा responsive हैं",
      ),
      TimeSuggestion(
        timeType: TimeType.frequencyRecommendation,
        suggestion: "Aim for 2-3 meaningful interactions per week",
        suggestionHi: "सप्ताह में 2-3 सार्थक बातचीत का लक्ष्य रखें",
      ),
    ];
  }

  /// 🚨 Emergency Actions for At-Risk Relationships
  List<EmergencyAction> _getEmergencyActions(RelationshipHealth health) {
    return [
      EmergencyAction(
        urgencyLevel: UrgencyLevel.high,
        titleEn: "Reach out immediately",
        titleHi: "तुरंत संपर्क करें",
        actionEn:
            "Send a heartfelt message acknowledging the distance and expressing your desire to reconnect",
        actionHi:
            "दूरी को स्वीकार करते हुए और फिर से जुड़ने की इच्छा व्यक्त करते हुए दिल से संदेश भेजें",
        template:
            "Hi [Name], I realize we haven't been in touch lately and I miss our conversations. I'd love to catch up - are you free for a quick call this week?",
        templateHi:
            "हाई [नाम], मुझे एहसास है कि हम हाल ही में संपर्क में नहीं रहे हैं और मुझे हमारी बातचीत की याद आती है। मैं catch up करना चाहूंगा - क्या आप इस सप्ताह एक छोटी कॉल के लिए free हैं?",
      ),
    ];
  }
}

// Supporting Data Classes

class RelationshipAdvice {
  final Contact contact;
  final RelationshipAssessment overallAssessment;
  final List<RelationshipIssue> specificIssues;
  final ActionPlan actionPlan;
  final List<ConversationStarter> conversationStarters;
  final List<CulturalTip> culturalTips;
  final List<TimeSuggestion> timeBasedSuggestions;
  final List<EmergencyAction> emergencyActions;

  RelationshipAdvice({
    required this.contact,
    required this.overallAssessment,
    required this.specificIssues,
    required this.actionPlan,
    required this.conversationStarters,
    required this.culturalTips,
    required this.timeBasedSuggestions,
    required this.emergencyActions,
  });
}

class RelationshipAssessment {
  final RelationshipStatus status;
  final String titleEn;
  final String titleHi;
  final String descriptionEn;
  final String descriptionHi;
  final String emoji;
  final double confidenceLevel;

  RelationshipAssessment({
    required this.status,
    required this.titleEn,
    required this.titleHi,
    required this.descriptionEn,
    required this.descriptionHi,
    required this.emoji,
    required this.confidenceLevel,
  });
}

enum RelationshipStatus { thriving, stable, needsAttention, atRisk }

class RelationshipIssue {
  final IssueType type;
  final IssueSeverity severity;
  final String titleEn;
  final String titleHi;
  final String descriptionEn;
  final String descriptionHi;
  final String solutionEn;
  final String solutionHi;

  RelationshipIssue({
    required this.type,
    required this.severity,
    required this.titleEn,
    required this.titleHi,
    required this.descriptionEn,
    required this.descriptionHi,
    required this.solutionEn,
    required this.solutionHi,
  });
}

enum IssueType {
  lowFrequency,
  slowResponse,
  imbalancedInitiation,
  decliningSentiment
}

enum IssueSeverity { low, medium, high, critical }

class ActionPlan {
  final List<ActionItem> immediateActions;
  final List<ActionItem> weeklyActions;
  final List<ActionItem> monthlyActions;
  final String timeframe;
  final List<String> successMetrics;

  ActionPlan({
    required this.immediateActions,
    required this.weeklyActions,
    required this.monthlyActions,
    required this.timeframe,
    required this.successMetrics,
  });
}

class ActionItem {
  final String titleEn;
  final String titleHi;
  final String descriptionEn;
  final String descriptionHi;
  final ActionPriority priority;
  final String estimatedTime;

  ActionItem({
    required this.titleEn,
    required this.titleHi,
    required this.descriptionEn,
    required this.descriptionHi,
    required this.priority,
    required this.estimatedTime,
  });
}

enum ActionPriority { low, medium, high, urgent }

class ConversationStarter {
  final String category;
  final String messageEn;
  final String messageHi;
  final String context;
  final ConversationTone tone;

  ConversationStarter({
    required this.category,
    required this.messageEn,
    required this.messageHi,
    required this.context,
    required this.tone,
  });
}

enum ConversationTone { friendly, formal, thoughtful, curious, nostalgic }

class CulturalTip {
  final String category;
  final String titleEn;
  final String titleHi;
  final String tipEn;
  final String tipHi;

  CulturalTip({
    required this.category,
    required this.titleEn,
    required this.titleHi,
    required this.tipEn,
    required this.tipHi,
  });
}

class TimeSuggestion {
  final TimeType timeType;
  final String suggestion;
  final String suggestionHi;

  TimeSuggestion({
    required this.timeType,
    required this.suggestion,
    required this.suggestionHi,
  });
}

enum TimeType { bestContactTime, frequencyRecommendation, seasonalSuggestion }

class EmergencyAction {
  final UrgencyLevel urgencyLevel;
  final String titleEn;
  final String titleHi;
  final String actionEn;
  final String actionHi;
  final String template;
  final String templateHi;

  EmergencyAction({
    required this.urgencyLevel,
    required this.titleEn,
    required this.titleHi,
    required this.actionEn,
    required this.actionHi,
    required this.template,
    required this.templateHi,
  });
}

enum UrgencyLevel { medium, high, critical }
