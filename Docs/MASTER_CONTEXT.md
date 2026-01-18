# TrueCircle - Master Context (Surendra Grover)

## Goal
Build TrueCircle multi-brain offline AI system with dynamic prompt management (YAML), CBT content, and voice pipeline.

## Brains
### Brain_1 (Text / BERT-based)
- Training checkpoint: assets/models/Brain_1/multitask_g20.pt
- Deployment INT8: assets/models/Brain_1/multitask_g20_int8.pt
- CBT assets:
  - assets/models/Brain_1/truecircle_cbt
  - assets/models/Brain_1/truecircle_cbt_embeddings.pt
  - assets/models/Brain_1/truecircle_cbt_meta.json

### Brain_A (Audio / wav2vec2-based)
- Training checkpoint: assets/models/Brain_A/Brain_A.pt (dict with state_dict)
- Deployment INT8 ONNX: assets/models/Brain_A/Brain_A_int8.onnx
- Output shape test OK: (1, 49, 768)

### Brain_2 (GPT2-based)
- Already quantized to INT4 (approx 128MB)

## Prompt System (Dynamic YAML)
- prompts/modifiers/constraints.yaml
- prompts/states/S0.yaml
- prompts/states/S1.yaml
- prompts/states/S2.yaml
- prompts/system/
- prompts/tasks/

## Architecture
- core/state_machine.py
- orchestration/prompt_manager.py
- run.py
- docs/ARCHITECTURE.md
