# TrueCircle Enhanced Data Models - Offline AI & Mental Health Integration

TrueCircle के नए data models offline AI analysis और mental health tracking के लिए designed हैं। यह privacy-first approach के साथ comprehensive relationship insights प्रदान करते हैं।

## 🎯 **Model Architecture Overview**

### **1. Enhanced RelationshipLog Model** (`lib/models/relationship_log.dart`)

आपके requirements के अनुसार enhanced किया गया:

```dart
class RelationshipLog {
  final String contactId; // गोपनीयता के लिए नाम नहीं, केवल ID
  final String contactName; // प्रदर्शन के लिए केवल पहला नाम
  final DateTime lastInteraction; // अंतिम बातचीत की तारीख़
  final Duration interactionGap; // पिछली बातचीत से अंतराल (AI के लिए महत्वपूर्ण)
  final int totalCallsInLastMonth;
  final int totalMessagesInLastMonth;
  final double callDurationAverage; // औसत कॉल अवधि
  final InteractionType type; // कॉल या मैसेज
  final double communicationFrequency; // दैनिक संपर्क आवृत्ति
  final RelationshipPhase currentPhase; // रिश्ते का वर्तमान चरण
}
```

#### **Key Features:**
- ✅ **Privacy-First Design** - केवल metadata, कोई personal content नहीं
- ✅ **AI-Optimized** - Offline analysis के लिए optimized fields
- ✅ **Relationship Phases** - रिश्ते के विभिन्न चरण track करता है
- ✅ **Communication Patterns** - Frequency और intimacy scoring
- ✅ **Demo Data Support** - Privacy mode के लिए sample data

#### **AI Analysis Method:**
```dart
String toSummaryString() {
  return "Contact: $contactName. Last talk: ${interactionGap.inDays} days ago. "
         "Avg call: ${callDurationAverage.toStringAsFixed(1)}s. "
         "Calls/month: $totalCallsInLastMonth, Messages/month: $totalMessagesInLastMonth. "
         "Frequency: ${communicationFrequency.toStringAsFixed(1)}/day. "
         "Phase: ${currentPhase.name}. Intimacy: ${(intimacyScore * 100).toStringAsFixed(0)}%.";
}
```

### **2. Mental Health Log Model** (`lib/models/mental_health_log.dart`)

मानसिक स्वास्थ्य tracking के लिए comprehensive model:

```dart
class MentalHealthLog {
  final DateTime timestamp;
  final MoodLevel primaryMood;
  final List<EmotionTag> emotionTags;
  final int energyLevel; // 1-10 scale
  final int stressLevel; // 1-10 scale
  final int socialAnxiety; // 1-10 scale
  final SleepQuality sleepQuality;
  final List<TriggerEvent> triggers;
  final List<CopingStrategy> copingStrategies;
  final int relationshipSatisfaction; // 1-10 scale
  final String notes; // Privacy-safe user notes
}
```

#### **Mental Health Components:**

**MoodLevel Enum:**
- `excellent`, `good`, `neutral`, `low`, `depressed`, `anxious`, `angry`, `excited`

**Emotion Tags (16 detailed emotions):**
- `happy`, `sad`, `angry`, `anxious`, `excited`, `grateful`, `lonely`, `content`, `frustrated`, `overwhelmed`, `calm`, `worried`, `hopeful`, `disappointed`, `confused`, `focused`

**Trigger Events:**
- `work_pressure`, `relationship_conflict`, `financial_stress`, `health_concerns`, `family_issues`, `social_pressure`, `lack_of_communication`, `misunderstanding`, `loneliness`, `rejection`, `criticism`

**Coping Strategies:**
- `meditation`, `exercise`, `breathing_exercises`, `journaling`, `talking_to_friends`, `professional_help`, `music`, `reading`, `nature_walk`, `creative_activity`, `deep_conversation`, `quality_time`, `physical_affection`

### **3. Offline AI Analysis Model** (`lib/models/offline_ai_analysis.dart`)

Complete AI analysis system जो relationship और mental health data को correlate करता है:

```dart
class OfflineAIAnalysis {
  final RelationshipInsight relationshipInsight;
  final MentalHealthInsight mentalHealthInsight;
  final CorrelationAnalysis correlationAnalysis;
  final List<AIRecommendation> recommendations;
  final double confidenceScore; // 0.0 to 1.0
}
```

#### **AI Analysis Components:**

**RelationshipInsight:**
- Communication frequency patterns
- Intimacy score trends
- Relationship phase detection
- Response time analysis
- Dominant conversation themes

**MentalHealthInsight:**
- Mood score averaging and trends
- Stress level patterns
- Common trigger identification
- Effective coping strategy analysis
- Energy level correlations

**CorrelationAnalysis:**
- Mood-Communication correlation
- Stress-Intimacy relationships
- Energy-Frequency patterns
- Significant behavioral patterns

**AI Recommendations:**
- Communication improvement suggestions
- Mental health support strategies
- Relationship enhancement tips
- Stress management techniques

## 🤖 **AI-Powered Insights Generation**

### **Comprehensive Analysis Factory**

```dart
factory OfflineAIAnalysis.fromLogs({
  required String userId,
  required List<RelationshipLog> relationshipLogs,
  required List<MentalHealthLog> mentalHealthLogs,
  required DateTime periodStart,
  required DateTime periodEnd,
}) {
  // Advanced correlation analysis
  final relationshipInsight = RelationshipInsight.fromLogs(relationshipLogs, periodStart, periodEnd);
  final mentalHealthInsight = MentalHealthInsight.fromLogs(mentalHealthLogs, periodStart, periodEnd);
  final correlationAnalysis = CorrelationAnalysis.analyze(relationshipLogs, mentalHealthLogs);
  
  // AI recommendation generation
  final recommendations = _generateRecommendations(
    relationshipInsight,
    mentalHealthInsight,
    correlationAnalysis,
  );

  return OfflineAIAnalysis(/* ... */);
}
```

### **AI Recommendation Examples**

**बातचीत बढ़ाने के लिए:**
```dart
AIRecommendation(
  type: RecommendationType.communication,
  priority: RecommendationPriority.high,
  title: 'बातचीत बढ़ाएं',
  description: 'आपकी communication frequency कम है। दिन में कम से कम एक बार अपने प्रिय व्यक्ति से बात करने की कोशिश करें।',
  actionSteps: [
    'सुबह एक good morning message भेजें',
    'दिन में एक छोटा call करें',
    'शाम को दिन की घटनाओं को share करें',
  ],
  confidenceScore: 0.8,
)
```

**मानसिक स्वास्थ्य के लिए:**
```dart
AIRecommendation(
  type: RecommendationType.mentalHealth,
  title: 'रिश्ते का मूड पर प्रभाव',
  description: 'आपके relationship communication patterns आपके mood को negatively affect कर रहे हैं।',
  actionSteps: [
    'Open communication practice करें',
    'Misunderstandings को जल्दी resolve करें',
    'Quality time spend करने की कोशिश करें',
  ],
)
```

## 🛡️ **Privacy & Security Features**

### **Privacy-First Data Collection**

1. **No Personal Content Storage:**
   - ❌ Message content never stored
   - ❌ Call recordings never saved
   - ❌ Personal conversations not accessed
   - ✅ Only metadata and patterns stored

2. **Demo Mode Enforcement:**
   ```dart
  if (isPrivacyMode()) {
  return RelationshipLog.generateSampleData(contactId, contactName);
   }
   ```

3. **Local Encryption:**
   - All Hive boxes encrypted locally
   - Sensitive notes encrypted before storage
   - No cloud synchronization of personal data

4. **Anonymized Analysis:**
   - Contact IDs used instead of names
   - Keywords extracted without context
   - Statistical patterns only

## 🔄 **Data Flow Architecture**

### **Communication Tracking Flow**

```
Native Platform (Android/iOS)
       ↓
Platform Channel Communication
       ↓
Privacy Service (Permission Management)
       ↓
RelationshipLog Creation (Metadata Only)
       ↓
Hive Local Storage (Encrypted)
       ↓
AI Analysis Engine (On-Device)
       ↓
Insight Generation (Privacy-Safe)
```

### **Mental Health Integration**

```
User Input (Mood/Emotions)
       ↓
MentalHealthLog Creation
       ↓
Local Storage (Encrypted)
       ↓
Correlation Analysis with Communication Data
       ↓
AI Recommendations Generation
       ↓
User-Friendly Insights Display
```

## 📊 **Data Models Summary**

| Model | Type ID | Purpose | Key Features |
|-------|---------|---------|--------------|
| **RelationshipLog** | 7 | Communication tracking | Enhanced with AI fields, privacy-safe |
| **InteractionType** | 8 | Communication classification | Call, message, video, voice |
| **EmotionalTone** | 9 | Sentiment analysis | AI-analyzed emotional context |
| **CommunicationStats** | 10 | Aggregated analytics | Statistical summaries |
| **MentalHealthLog** | 11 | Mood tracking | Comprehensive emotional data |
| **MoodLevel** | 12 | Primary mood states | 8 distinct mood categories |
| **EmotionTag** | 13 | Granular emotions | 16 detailed emotion types |
| **SleepQuality** | 14 | Sleep tracking | 5-level quality scale |
| **TriggerEvent** | 15 | Stress triggers | 12 common trigger types |
| **CopingStrategy** | 16 | Coping mechanisms | 14 proven strategies |
| **MentalHealthAnalytics** | 17 | Mental health insights | Trend analysis |
| **OfflineAIAnalysis** | 18 | Comprehensive AI analysis | Full relationship insights |
| **RelationshipPhase** | 20 | Relationship stages | 6 relationship phases |
| **RelationshipInsight** | 22 | Communication insights | Pattern analysis |
| **MentalHealthInsight** | 23 | Mental health analysis | Mood trend insights |
| **CorrelationAnalysis** | 24 | Cross-domain analysis | Relationship-mental health correlation |
| **AIRecommendation** | 25 | AI suggestions | Actionable recommendations |

## 🚀 **Implementation Steps**

### **1. Generate Hive Adapters**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### **2. Enable Models in main.dart**
Uncomment adapter registrations after generation:
```dart
_registerAdapterSafely<RelationshipLog>(7, () => RelationshipLogAdapter());
_registerAdapterSafely<MentalHealthLog>(11, () => MentalHealthLogAdapter());
_registerAdapterSafely<OfflineAIAnalysis>(18, () => OfflineAIAnalysisAdapter());
// ... and all other models
```

### **3. Usage Example**
```dart
// Create relationship analysis
final analysis = OfflineAIAnalysis.fromLogs(
  userId: 'user_123',
  relationshipLogs: await privacyService.getLogSummaryForAI(contactId),
  mentalHealthLogs: await mentalHealthService.getRecentLogs(),
  periodStart: DateTime.now().subtract(Duration(days: 30)),
  periodEnd: DateTime.now(),
);

// Display insights
print(analysis.toUserSummaryString());

// Get recommendations
for (final rec in analysis.recommendations) {
  print('${rec.title}: ${rec.description}');
}
```

## 📈 **AI Analysis Capabilities**

### **Relationship Pattern Recognition**
- Communication frequency trends
- Response time patterns
- Intimacy level changes
- Conversation theme analysis
- Relationship phase transitions

### **Mental Health Correlation**
- Mood-communication relationships
- Stress impact on relationships
- Energy levels and social interaction
- Trigger event identification
- Coping strategy effectiveness

### **Predictive Insights**
- Relationship health scoring
- Mental health trend prediction
- Communication breakdown warnings
- Stress level forecasting
- Personalized improvement suggestions

यह comprehensive model system TrueCircle को powerful offline AI capabilities प्रदान करता है जो users के privacy को protect करते हुए meaningful relationship insights देता है।