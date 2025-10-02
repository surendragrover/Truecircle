import Flutter
import UIKit
import CoreML
import NaturalLanguage

/// TrueCircle iOS Core ML Handler
/// 
/// This class manages Core ML model loading and inference for offline AI functionality.
/// It provides privacy-first AI processing using Apple's Core ML framework and
/// Natural Language framework for sentiment analysis.
/// 
/// Features:
/// - Lightweight LLM model loading and inference
/// - Native sentiment analysis using iOS Natural Language framework
/// - Hardware-optimized processing with Neural Engine support
/// - Privacy-focused offline AI processing
class IosCoreMLHandler {
    
    // MARK: - Properties
    private var coreMLModel: MLModel?
    private var isModelLoaded = false
    private let modelName = "TrueCircle_LLM" // Name of the .mlmodel file in the app bundle
    
    // MARK: - Model Initialization
    
    /// Initialize and load the Core ML model from the app bundle
    /// 
    /// This method loads a lightweight LLM model optimized for iOS devices.
    /// The model should be in .mlmodel format and included in the app bundle.
    /// 
    /// - Parameter completion: Callback with success status and error message
    func initializeModel(completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(false, "Handler instance deallocated")
                }
                return
            }
            
            do {
                // Attempt to load the Core ML model from the app bundle
                guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "mlmodel") else {
                    DispatchQueue.main.async {
                        completion(false, "Core ML model file not found in app bundle")
                    }
                    return
                }
                
                // Load the model
                self.coreMLModel = try MLModel(contentsOf: modelURL)
                self.isModelLoaded = true
                
                print("TrueCircle Core ML model loaded successfully")
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
                
            } catch {
                print("Error loading Core ML model: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    completion(false, "Failed to load Core ML model: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - AI Response Generation
    
    /// Generate offline AI response using the loaded Core ML model
    /// 
    /// This method processes user prompts through the loaded LLM model to generate
    /// contextual responses for Dr. Iris chatbot functionality.
    /// 
    /// - Parameter prompt: User input text for AI processing
    /// - Returns: Generated AI response or fallback message
    func generateOfflineResponse(prompt: String) -> String {
        guard isModelLoaded, let model = coreMLModel else {
            return generateFallbackResponse(for: prompt)
        }
        
        do {
            // Prepare input for the Core ML model
            // Note: This implementation depends on your specific model's input format
            let inputFeatures = try MLDictionaryFeatureProvider(dictionary: [
                "input_text": MLFeatureValue(string: prompt)
            ])
            
            // Perform inference
            let prediction = try model.prediction(from: inputFeatures)
            
            // Extract response from model output
            // Note: Output key depends on your model's configuration
            if let responseFeature = prediction.featureValue(for: "output_text"),
               let response = responseFeature.stringValue {
                return response
            } else {
                return generateFallbackResponse(for: prompt)
            }
            
        } catch {
            print("Error during Core ML inference: \(error.localizedDescription)")
            return generateFallbackResponse(for: prompt)
        }
    }
    
    /// Generate contextual fallback responses when Core ML model is unavailable
    /// 
    /// - Parameter prompt: User input to analyze for contextual response
    /// - Returns: Appropriate fallback response based on prompt content
    private func generateFallbackResponse(for prompt: String) -> String {
        let lowercasePrompt = prompt.lowercased()
        
        // Analyze prompt content for contextual responses
        switch true {
        case lowercasePrompt.contains("stress"):
            return "Dr. Iris (Privacy Mode): I understand you're feeling stressed. Take deep breaths and remember that it's okay to take breaks when needed."
            
        case lowercasePrompt.contains("sad") || lowercasePrompt.contains("depressed"):
            return "Dr. Iris (Privacy Mode): I hear you're going through a difficult time. Your feelings are valid, and it's important to be gentle with yourself."
            
        case lowercasePrompt.contains("anxious") || lowercasePrompt.contains("anxiety"):
            return "Dr. Iris (Privacy Mode): Anxiety can be overwhelming. Try grounding yourself by focusing on 5 things you can see around you."
            
        case lowercasePrompt.contains("happy") || lowercasePrompt.contains("good"):
            return "Dr. Iris (Privacy Mode): I'm glad you're feeling positive! It's wonderful when we can appreciate good moments in life."
            
        case lowercasePrompt.contains("sleep") || lowercasePrompt.contains("tired"):
            return "Dr. Iris (Privacy Mode): Good sleep is essential for well-being. Try establishing a consistent bedtime routine."
            
        case lowercasePrompt.contains("relationship") || lowercasePrompt.contains("friend"):
            return "Dr. Iris (Privacy Mode): Relationships require nurturing. Consider having open, honest conversations with those you care about."
            
        default:
            return "Dr. Iris (Privacy Mode): Thank you for sharing. I'm here to support you through whatever you're experiencing."
        }
    }
    
    // MARK: - Sentiment Analysis
    
    /// Analyze sentiment and stress level using iOS Natural Language framework
    /// 
    /// This method uses Apple's built-in Natural Language framework to provide
    /// accurate sentiment analysis without requiring additional model loading.
    /// 
    /// - Parameter text: Text entry to analyze
    /// - Returns: Formatted analysis result with sentiment and stress level
    func analyzeSentimentAndStress(text: String) -> String {
        guard !text.isEmpty else {
            return "Sentiment: Neutral, Stress Level: Low, Confidence: 0.0"
        }
        
        // Use iOS 13+ Natural Language framework for sentiment analysis
        if #available(iOS 13.0, *) {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = text
            
            let (sentimentScore, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
            
            let score = Double(sentimentScore?.rawValue ?? "0") ?? 0.0
            
            // Determine sentiment label
            let sentimentLabel: String
            if score > 0.1 {
                sentimentLabel = "Positive"
            } else if score < -0.1 {
                sentimentLabel = "Negative"
            } else {
                sentimentLabel = "Neutral"
            }
            
            // Determine stress level based on sentiment score
            let stressLevel: String
            if score < -0.3 {
                stressLevel = "High"
            } else if score < 0 {
                stressLevel = "Medium"
            } else {
                stressLevel = "Low"
            }
            
            let confidence = min(abs(score), 1.0)
            
            return "Sentiment: \(sentimentLabel), Stress Level: \(stressLevel), Confidence: \(String(format: "%.2f", confidence))"
            
        } else {
            // Fallback for iOS versions before 13.0
            return performBasicSentimentAnalysis(text: text)
        }
    }
    
    /// Basic sentiment analysis for iOS versions before 13.0
    /// 
    /// - Parameter text: Text to analyze
    /// - Returns: Basic sentiment analysis result
    private func performBasicSentimentAnalysis(text: String) -> String {
        let lowercaseText = text.lowercased()
        
        let positiveKeywords = ["happy", "good", "great", "amazing", "wonderful", "excited", "joy", "love", "excellent"]
        let negativeKeywords = ["sad", "bad", "terrible", "awful", "stressed", "angry", "frustrated", "worried", "anxious"]
        
        var positiveCount = 0
        var negativeCount = 0
        
        for keyword in positiveKeywords {
            if lowercaseText.contains(keyword) {
                positiveCount += 1
            }
        }
        
        for keyword in negativeKeywords {
            if lowercaseText.contains(keyword) {
                negativeCount += 1
            }
        }
        
        let sentiment: String
        let stressLevel: String
        
        if positiveCount > negativeCount {
            sentiment = "Positive"
            stressLevel = "Low"
        } else if negativeCount > positiveCount {
            sentiment = "Negative"
            stressLevel = negativeCount > 2 ? "High" : "Medium"
        } else {
            sentiment = "Neutral"
            stressLevel = "Low"
        }
        
        return "Sentiment: \(sentiment), Stress Level: \(stressLevel), Confidence: 0.75"
    }
    
    // MARK: - Support and Capability Checks
    
    /// Check if Core ML and required frameworks are supported on this device
    /// 
    /// - Returns: True if device supports Core ML functionality
    func isSupported() -> Bool {
        // Check iOS version compatibility
        guard #available(iOS 11.0, *) else {
            return false
        }
        
        // Check device capabilities
        let memorySize = ProcessInfo.processInfo.physicalMemory
        let hasMinimumMemory = memorySize >= 2_000_000_000 // 2GB minimum
        
        // Check if device is capable of running AI models
        let deviceCapable = UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad
        
        return hasMinimumMemory && deviceCapable
    }
    
    /// Check if device has Neural Engine for hardware acceleration
    /// 
    /// - Returns: True if device likely has Neural Engine (A12+)
    func hasNeuralEngine() -> Bool {
        // Neural Engine is available on A12 Bionic and later
        // This is a simplified check based on memory size
        let memorySize = ProcessInfo.processInfo.physicalMemory
        return memorySize >= 3_000_000_000 // 3GB+ usually indicates A12 or later
    }
    
    /// Get device capabilities for AI processing
    /// 
    /// - Returns: Dictionary with device capability information
    func getDeviceCapabilities() -> [String: Any] {
        return [
            "coreMLSupported": isSupported(),
            "neuralEngine": hasNeuralEngine(),
            "memorySize": ProcessInfo.processInfo.physicalMemory,
            "iOSVersion": UIDevice.current.systemVersion,
            "deviceModel": UIDevice.current.model,
            "naturalLanguageSupported": true
        ]
    }
    
    // MARK: - Model Management
    
    /// Clear loaded model and free memory
    func clearModel() {
        coreMLModel = nil
        isModelLoaded = false
        print("Core ML model cleared from memory")
    }
    
    /// Check if model is currently loaded
    /// 
    /// - Returns: True if Core ML model is loaded and ready
    func isModelReady() -> Bool {
        return isModelLoaded && coreMLModel != nil
    }
}