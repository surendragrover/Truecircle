/// CBT Educational Content Repository (static, offline, bilingual-ready placeholders where applicable)
/// This file encapsulates structured descriptions of core CBT techniques (cognitive + behavioral)
/// so UI pages (micro lessons, guided coaches) can source consistent text.
/// Privacy-first: purely local, no network calls.
/// NOTE: Keep content concise; extended explanations should be paginated in UI.
library;

class CBTEducationContent {
  CBTEducationContent._();

  // Cognitive Distortions list used in thought record dropdowns / psychoeducation tiles.
  static const List<Map<String, String>> cognitiveDistortions = [
    {
      'key': 'all_or_nothing',
      'title': 'All-or-Nothing Thinking',
      'en':
          'Viewing situations in black-or-white extremes (perfection vs. failure).',
      'hi': 'स्थितियों को केवल चरम सीमाओं में देखना (संपूर्ण या असफलता).',
    },
    {
      'key': 'overgeneralization',
      'title': 'Overgeneralization',
      'en':
          'Drawing a sweeping rule from a single event ("It failed once, it always will").',
      'hi':
          'एक घटना से व्यापक निष्कर्ष निकालना ("एक बार असफल हुआ तो हमेशा होगा").',
    },
    {
      'key': 'catastrophizing',
      'title': 'Catastrophizing',
      'en': 'Exaggerating how bad a setback is; expecting disaster.',
      'hi':
          'किसी छोटी समस्या को बहुत बड़ा बना देना और विपत्ति की अपेक्षा करना.',
    },
    {
      'key': 'should_statements',
      'title': '"Should" Statements',
      'en':
          'Rigid rules about how you or others must act leading to guilt or anger.',
      'hi': '"चाहिए" वाले कठोर नियम जो अपराधबोध या क्रोध ला सकते हैं.',
    },
    {
      'key': 'mind_reading',
      'title': 'Mind Reading',
      'en': 'Assuming you know what others think without evidence.',
      'hi': 'बिना प्रमाण के मान लेना कि अन्य लोग क्या सोच रहे हैं.',
    },
  ];

  // Core cognitive techniques (succinct summary, can expand in detail view).
  static const List<Map<String, String>> cognitiveTechniques = [
    {
      'key': 'cognitive_restructuring',
      'title': 'Cognitive Restructuring',
      'en':
          'Identify automatic negative thoughts, examine evidence, replace with balanced alternative.',
      'hi':
          'स्वचालित नकारात्मक विचार पहचानें, साक्ष्य जाँचें, संतुलित विकल्प अपनाएँ.',
    },
    {
      'key': 'socratic_questioning',
      'title': 'Socratic Questioning',
      'en':
          'Guided discovery using curious, evidence-focused questions to shift perspective.',
      'hi':
          'जिज्ञासु और साक्ष्य-केन्द्रित प्रश्नों से दृष्टिकोण बदलने की मार्गदर्शित प्रक्रिया.',
    },
    {
      'key': 'downward_arrow',
      'title': 'Downward Arrow',
      'en':
          'Repeatedly ask what a thought would mean if true to reveal underlying core belief.',
      'hi':
          'यदि विचार सही होता तो इसका क्या अर्थ होता—यह पूछकर मूल विश्वास तक पहुंचना.',
    },
  ];

  // Behavioral techniques.
  static const List<Map<String, String>> behavioralTechniques = [
    {
      'key': 'behavioral_activation',
      'title': 'Behavioral Activation',
      'en':
          'Schedule mastery and pleasure activities to counter withdrawal and improve mood.',
      'hi':
          'गतिविधियों (कौशल + आनंद) को निर्धारित कर मूड सुधारें और निष्क्रियता तोड़ें.',
    },
    {
      'key': 'exposure_therapy',
      'title': 'Exposure Therapy',
      'en':
          'Gradual, repeated contact with feared cues to reduce avoidance and anxiety.',
      'hi': 'भयकारी स्थितियों से क्रमिक संपर्क द्वारा परिहार और चिंता कम करना.',
    },
    {
      'key': 'problem_solving',
      'title': 'Problem-Solving Training',
      'en':
          'Define, brainstorm, evaluate, implement, review solutions systematically.',
      'hi':
          'समस्या को परिभाषित, विकल्प सूचीबद्ध, मूल्यांकन, लागू और समीक्षा करना.',
    },
    {
      'key': 'relaxation',
      'title': 'Relaxation & Stress Reduction',
      'en':
          'Breathing, muscle relaxation or grounding to reduce physiological arousal.',
      'hi':
          'श्वास, मांसपेशी शिथिलीकरण या ग्राउंडिंग से शारीरिक उत्तेजना घटाना.',
    },
    {
      'key': 'assertiveness',
      'title': 'Role-Play & Assertiveness',
      'en':
          'Rehearse boundary-setting and confident communication in safe context.',
      'hi': 'सीमाएँ तय करने और आत्मविश्वासी संवाद का सुरक्षित अभ्यास.',
    },
  ];

  static Map<String, List<Map<String, String>>> categorized() => {
        'cognitive': cognitiveTechniques,
        'behavioral': behavioralTechniques,
        'distortions': cognitiveDistortions,
      };
}
