package com.example.truecircle

import android.content.res.AssetFileDescriptor
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

class MainActivity : FlutterActivity() {
	private val channelName = "truecircle_ai_channel"
	private var interpreter: Interpreter? = null

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"isAltModelSupported" -> {
						// Low-end support: Android 8.0+ और 64-bit preferred, पर हम न्यूनतम API पर भी true लौटाएँगे
						val supported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
						result.success(supported)
					}
					"initializeAltModel" -> {
						try {
							if (interpreter == null) {
								val model = loadModelFile("models/TrueCircle.tflite")
								interpreter = Interpreter(model)
							}
							result.success(true)
						} catch (e: Exception) {
							e.printStackTrace()
							result.success(false)
						}
					}
					"generateResponse" -> {
						val args = call.arguments as? Map<*, *>
						val prompt = args?.get("prompt") as? String ?: ""
						val reply = try {
							val resp = runModel(prompt)
							if (resp.isNullOrBlank()) safeFallback(prompt) else resp
						} catch (e: Exception) {
							safeFallback(prompt)
						}
						result.success(reply)
					}
					else -> result.notImplemented()
				}
			}
	}

	private fun loadModelFile(assetPath: String): MappedByteBuffer {
		// Flutter assets के लिए AFD प्राप्त करें
		val afd: AssetFileDescriptor = assets.openFd(assetPath)
		FileInputStream(afd.fileDescriptor).use { fis ->
			val fileChannel: FileChannel = fis.channel
			val startOffset = afd.startOffset
			val declaredLength = afd.declaredLength
			return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
		}
	}

	private fun runModel(prompt: String): String? {
		val tflite = interpreter ?: return null
		// Based on provided IO:
		// Inputs (int64): attention_mask [1, L], input_ids [1, L], token_type_ids [1, L]
		// Outputs (float32): [1, L, 512] and pooled [1, 512]
		// We'll implement a tiny, deterministic tokenizer to produce token ids from the prompt.
		val tokens: LongArray = basicTokenize(prompt, maxLen = 32)
		val seqLen = tokens.size
		if (seqLen <= 0) return null

		// Prepare attention mask (1s) and token_type_ids (0s)
		val attention = LongArray(seqLen) { 1L }
		val tokenTypes = LongArray(seqLen) { 0L }

		try {
			// Resize dynamic inputs to [1, seqLen]
			tflite.resizeInput(0, intArrayOf(1, seqLen)) // attention_mask
			tflite.resizeInput(1, intArrayOf(1, seqLen)) // input_ids
			tflite.resizeInput(2, intArrayOf(1, seqLen)) // token_type_ids
			tflite.allocateTensors()

			// Build inputs as 2D arrays matching [1, L]
			val inAttention: Array<LongArray> = arrayOf(attention)
			val inInputIds: Array<LongArray> = arrayOf(tokens)
			val inTokenTypes: Array<LongArray> = arrayOf(tokenTypes)
			val inputs: Array<Any> = arrayOf(inAttention, inInputIds, inTokenTypes)

			// Prepare outputs: [1, L, 512] and [1, 512]
			val outSeq: Array<Array<FloatArray>> = Array(1) { Array(seqLen) { FloatArray(512) } }
			val outPooled: Array<FloatArray> = Array(1) { FloatArray(512) }
			val outputs = hashMapOf<Int, Any>(
				0 to outSeq,
				1 to outPooled
			)

			// Run inference
			tflite.runForMultipleInputsOutputs(inputs, outputs)

			val pooled: FloatArray = outPooled[0]
			// Convert pooled vector into a short, safe suggestion so reply varies with the model output.
			return synthesizeReply(prompt, pooled)
		} catch (e: Exception) {
			e.printStackTrace()
			return null
		}
	}

	// Very small, deterministic tokenizer (placeholder). Produces stable ids without network.
	// It does NOT claim semantic compatibility with the original model's vocab.
	private fun basicTokenize(text: String, maxLen: Int = 32): LongArray {
		val cleaned = text.trim()
		if (cleaned.isEmpty()) return longArrayOf(101L) // CLS-like fallback
		val parts = cleaned.split(Regex("\\s+"))
		val ids = ArrayList<Long>(maxLen)
		for (w in parts) {
			val h = w.lowercase().hashCode()
			// Map to positive range; use a pseudo vocab size and offset to avoid zeros
			val id = 100L + (h.toLong() and 0x7FFFFFFF) % 30000L
			ids.add(id)
			if (ids.size >= maxLen) break
		}
		if (ids.isEmpty()) ids.add(101L)
		return ids.toLongArray()
	}

	// Turn pooled embedding into a short, neutral suggestion.
	private fun synthesizeReply(prompt: String, pooled: FloatArray): String {
		if (pooled.isEmpty()) return safeFallback(prompt)
		// Compute simple scores from first few dimensions
		fun score(idx: Int): Float = if (idx in pooled.indices) pooled[idx] else 0f
		val sBreath = score(0) + score(5) - score(10)
		val sJournal = score(1) + score(6) - score(11)
		val sGround = score(2) + score(7) - score(12)
		val sKindness = score(3) + score(8) - score(13)
		val sPlan = score(4) + score(9) - score(14)
		val best = listOf(
			"breath" to sBreath,
			"journal" to sJournal,
			"ground" to sGround,
			"kindness" to sKindness,
			"plan" to sPlan
		).maxByOrNull { it.second }?.first ?: "breath"

		val suggestion = when (best) {
			"breath" -> "Slow, deep breaths 4‑4 cycles — relax shoulders and jaw."
			"journal" -> "Write for 2 minutes: bullet your thoughts — only as much as feels okay."
			"ground" -> "5‑4‑3‑2‑1 grounding: notice sights‑touch‑sounds‑scents‑taste and come back to the present."
			"kindness" -> "A kind line to yourself: ‘I did the best I could.’"
			else -> "Pick one tiny next step — water, a brief walk, or a support note."
		}
		return "I read your message with care. One small step: $suggestion"
	}

	private fun safeFallback(prompt: String): String {
		// Neutral, calm fallback (educational). Overridden when real model output is available.
		return "I'm listening offline on your device. Try one small step: slow breathing, water, 2‑minute jot — ‘What matters for me right now?’"
	}
}
