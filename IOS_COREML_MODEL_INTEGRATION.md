# iOS Core ML Model Integration Guide

This guide explains how to integrate a lightweight Large Language Model (LLM) with Core ML for offline AI functionality in TrueCircle iOS app.

## Overview

Since Apple doesn't have an official equivalent to Google's Gemini Nano, we use Apple's Core ML framework with a lightweight open-source model to maintain privacy-first offline AI processing on iOS devices.

## Model Selection and Preparation

### Recommended Models
1. **Gemma 2B** - Google's lightweight model, optimized for mobile
2. **Llama 3.2 1B/3B** - Meta's efficient small models
3. **Phi-3 Mini** - Microsoft's 3.8B parameter mobile-optimized model
4. **TinyLlama 1.1B** - Ultra-lightweight model for resource-constrained devices

### Model Conversion Process

#### Step 1: Convert to Core ML Format
```bash
# Using coremltools (Python)
pip install coremltools transformers torch

# Convert HuggingFace model to Core ML
python convert_to_coreml.py --model_name "microsoft/Phi-3-mini-4k-instruct" --output_path "TrueCircle_LLM.mlmodel"
```

#### Step 2: Optimize for iOS
```python
import coremltools as ct

# Load the converted model
model = ct.models.MLModel('TrueCircle_LLM.mlmodel')

# Optimize for iOS deployment
model = ct.optimize.coreml.optimize_weights(model)

# Save optimized model
model.save('TrueCircle_LLM_Optimized.mlmodel')
```

#### Step 3: Add to iOS Project
1. Drag the `.mlmodel` file into your Xcode project
2. Ensure it's added to the target
3. Xcode will automatically generate Swift classes for the model

## Implementation Architecture

### Core Components

1. **IosCoreMLHandler.swift** - Manages model loading and inference
2. **AppDelegate.swift** - Handles Flutter platform channel communication
3. **TrueCircle_LLM.mlmodel** - The Core ML model file
4. **IosCoreMLService.dart** - Flutter service interface

### Model Loading Process

```swift
func initializeModel(completion: @escaping (Bool, String?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        do {
            // Load model from app bundle
            guard let modelURL = Bundle.main.url(forResource: "TrueCircle_LLM", withExtension: "mlmodel") else {
                completion(false, "Model file not found")
                return
            }
            
            // Initialize Core ML model
            self?.coreMLModel = try MLModel(contentsOf: modelURL)
            self?.isModelLoaded = true
            
            DispatchQueue.main.async {
                completion(true, nil)
            }
        } catch {
            DispatchQueue.main.async {
                completion(false, error.localizedDescription)
            }
        }
    }
}
```

### Inference Implementation

```swift
func generateOfflineResponse(prompt: String) -> String {
    guard isModelLoaded, let model = coreMLModel else {
        return generateFallbackResponse(for: prompt)
    }
    
    do {
        // Prepare input features
        let inputFeatures = try MLDictionaryFeatureProvider(dictionary: [
            "input_text": MLFeatureValue(string: prompt),
            "max_length": MLFeatureValue(int64: 512)
        ])
        
        // Perform inference
        let prediction = try model.prediction(from: inputFeatures)
        
        // Extract response
        if let responseFeature = prediction.featureValue(for: "output_text"),
           let response = responseFeature.stringValue {
            return response
        }
        
        return generateFallbackResponse(for: prompt)
        
    } catch {
        print("Core ML inference error: \(error)")
        return generateFallbackResponse(for: prompt)
    }
}
```

## Performance Optimization

### Hardware Acceleration

#### Neural Engine Utilization (A12+)
```swift
// Configure model for Neural Engine
let configuration = MLModelConfiguration()
configuration.computeUnits = .cpuAndNeuralEngine

let model = try MLModel(contentsOf: modelURL, configuration: configuration)
```

#### GPU Acceleration
```swift
// Use GPU for computation-heavy tasks
configuration.computeUnits = .cpuAndGPU
```

### Memory Management

#### Model Caching Strategy
```swift
class ModelCache {
    private static var cachedModel: MLModel?
    
    static func getCachedModel() -> MLModel? {
        return cachedModel
    }
    
    static func cacheModel(_ model: MLModel) {
        cachedModel = model
    }
    
    static func clearCache() {
        cachedModel = nil
    }
}
```

#### Lazy Loading
```swift
private lazy var coreMLModel: MLModel? = {
    guard let modelURL = Bundle.main.url(forResource: "TrueCircle_LLM", withExtension: "mlmodel") else {
        return nil
    }
    return try? MLModel(contentsOf: modelURL)
}()
```

## Model Input/Output Configuration

### Input Format
```swift
// Text input configuration
let inputDescription = MLFeatureDescription(
    name: "input_text",
    type: .string
)

// Token limit configuration
let maxLengthDescription = MLFeatureDescription(
    name: "max_length", 
    type: .int64
)
```

### Output Processing
```swift
func processModelOutput(_ prediction: MLFeatureProvider) -> String {
    // Extract text output
    if let textOutput = prediction.featureValue(for: "generated_text")?.stringValue {
        return cleanupResponse(textOutput)
    }
    
    // Handle token-based output
    if let tokenIds = prediction.featureValue(for: "token_ids")?.multiArrayValue {
        return decodeTokens(tokenIds)
    }
    
    return "Unable to process model output"
}

func cleanupResponse(_ response: String) -> String {
    // Remove special tokens and clean up formatting
    return response
        .replacingOccurrences(of: "<|endoftext|>", with: "")
        .replacingOccurrences(of: "<pad>", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
}
```

## Error Handling and Fallbacks

### Graceful Degradation
```swift
func generateOfflineResponse(prompt: String) -> String {
    // Try Core ML inference first
    if let response = tryModelInference(prompt: prompt) {
        return response
    }
    
    // Fall back to rule-based responses
    return generateFallbackResponse(for: prompt)
}

private func tryModelInference(prompt: String) -> String? {
    guard isModelLoaded, let model = coreMLModel else {
        return nil
    }
    
    do {
        let prediction = try model.prediction(from: prepareInput(prompt))
        return extractResponse(from: prediction)
    } catch {
        print("Model inference failed: \(error)")
        return nil
    }
}
```

### Context-Aware Fallbacks
```swift
private func generateFallbackResponse(for prompt: String) -> String {
    let lowercasePrompt = prompt.lowercased()
    
    // Emotional support responses
    if lowercasePrompt.contains("stress") || lowercasePrompt.contains("anxious") {
        return "I understand you're going through a challenging time. Remember to take deep breaths and be patient with yourself."
    }
    
    // Relationship advice
    if lowercasePrompt.contains("relationship") || lowercasePrompt.contains("friend") {
        return "Relationships require understanding and communication. Consider having an open conversation about your feelings."
    }
    
    // Default supportive response
    return "Thank you for sharing with me. I'm here to support you through whatever you're experiencing."
}
```

## Testing and Validation

### Unit Testing
```swift
class CoreMLHandlerTests: XCTestCase {
    var handler: IosCoreMLHandler!
    
    override func setUp() {
        super.setUp()
        handler = IosCoreMLHandler()
    }
    
    func testModelInitialization() {
        let expectation = XCTestExpectation(description: "Model initialization")
        
        handler.initializeModel { success, error in
            XCTAssertTrue(success, "Model should initialize successfully")
            XCTAssertNil(error, "No error should occur during initialization")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testResponseGeneration() {
        // Test with sample prompts
        let response = handler.generateOfflineResponse(prompt: "I'm feeling stressed about work")
        XCTAssertFalse(response.isEmpty, "Response should not be empty")
        XCTAssertTrue(response.contains("stress") || response.contains("Dr. Iris"), "Response should be contextual")
    }
}
```

### Performance Testing
```swift
func testInferencePerformance() {
    measure {
        let _ = handler.generateOfflineResponse(prompt: "How can I improve my relationships?")
    }
}

func testMemoryUsage() {
    let initialMemory = getMemoryUsage()
    
    // Load model
    handler.initializeModel { _, _ in }
    
    let loadedMemory = getMemoryUsage() 
    let memoryIncrease = loadedMemory - initialMemory
    
    XCTAssertLessThan(memoryIncrease, 500_000_000, "Model should use less than 500MB")
}
```

## Deployment Considerations

### App Store Guidelines
- Ensure model size doesn't exceed reasonable limits (< 2GB recommended)
- Include privacy policy explaining on-device processing
- No special permissions required for offline AI
- Models are bundled with app, no external downloads

### Model Versioning
```swift
struct ModelVersion {
    static let current = "1.0.0"
    static let minimumSupported = "1.0.0"
    
    static func isCompatible(_ version: String) -> Bool {
        // Version compatibility logic
        return version >= minimumSupported
    }
}
```

### Configuration Management
```swift
struct CoreMLConfig {
    static let modelName = "TrueCircle_LLM"
    static let maxInputLength = 512
    static let maxOutputLength = 256
    static let timeoutSeconds: TimeInterval = 30.0
    
    static let computeUnits: MLComputeUnits = {
        if hasNeuralEngine() {
            return .cpuAndNeuralEngine
        } else {
            return .cpuAndGPU  
        }
    }()
}
```

## Security and Privacy

### Model Protection
- Models are encrypted within the app bundle
- No model data leaves the device
- Inference happens in secure sandbox
- No logging of sensitive prompts/responses

### Data Handling
```swift
func processSecurely(_ prompt: String) -> String {
    // Sanitize input
    let sanitizedPrompt = sanitizeInput(prompt)
    
    // Process without logging
    let response = generateResponse(sanitizedPrompt)
    
    // Clear sensitive data from memory
    defer {
        clearSensitiveData()
    }
    
    return response
}
```

This implementation provides a robust, privacy-first offline AI solution for iOS devices using Core ML framework.