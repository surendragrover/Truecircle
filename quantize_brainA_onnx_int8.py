import torch
from transformers import Wav2Vec2Config, Wav2Vec2Model
from onnxruntime.quantization import quantize_dynamic, QuantType

IN_PATH = r"C:\Users\suren\flutter_app\Truecircle_AI\truecircle_app\assets\models\Brain_A\Brain_A.pt"

ONNX_FP_PATH = r"C:\Users\suren\flutter_app\Truecircle_AI\truecircle_app\assets\models\Brain_A\Brain_A_fp32.onnx"
ONNX_INT8_PATH = r"C:\Users\suren\flutter_app\Truecircle_AI\truecircle_app\assets\models\Brain_A\Brain_A_int8.onnx"

def infer_num_layers(sd):
    layer_ids = set()
    for k in sd.keys():
        if k.startswith("wav2vec.encoder.layers."):
            # wav2vec.encoder.layers.{i}.*
            parts = k.split(".")
            if len(parts) > 3 and parts[3].isdigit():
                layer_ids.add(int(parts[3]))
    return max(layer_ids) + 1 if layer_ids else 12

def infer_hidden_size(sd):
    # q_proj.weight shape: [hidden, hidden]
    for k, v in sd.items():
        if k.endswith("attention.q_proj.weight"):
            return v.shape[0]
    return 768

def infer_intermediate_size(sd):
    # feed_forward.intermediate_dense.weight shape: [intermediate, hidden]
    for k, v in sd.items():
        if k.endswith("feed_forward.intermediate_dense.weight"):
            return v.shape[0]
    return 3072

def main():
    ckpt = torch.load(IN_PATH, map_location="cpu")
    sd = ckpt["state_dict"]

    hidden_size = infer_hidden_size(sd)
    num_hidden_layers = infer_num_layers(sd)
    intermediate_size = infer_intermediate_size(sd)

    print("Inferred config:")
    print("  hidden_size:", hidden_size)
    print("  num_hidden_layers:", num_hidden_layers)
    print("  intermediate_size:", intermediate_size)

    cfg = Wav2Vec2Config(
        hidden_size=hidden_size,
        num_hidden_layers=num_hidden_layers,
        intermediate_size=intermediate_size,
    )

    model = Wav2Vec2Model(cfg)

    missing, unexpected = model.load_state_dict(sd, strict=False)
    print("Missing keys:", len(missing))
    print("Unexpected keys:", len(unexpected))

    if len(missing) > 0:
        print("First missing keys:", missing[:10])
    if len(unexpected) > 0:
        print("First unexpected keys:", unexpected[:10])

    model.eval()

    # Dummy audio input: 1 second @ 16kHz
    dummy = torch.randn(1, 16000, dtype=torch.float32)

    torch.onnx.export(
        model,
        (dummy,),
        ONNX_FP_PATH,
        input_names=["input_values"],
        output_names=["last_hidden_state"],
        dynamic_axes={
            "input_values": {0: "batch", 1: "time"},
            "last_hidden_state": {0: "batch", 1: "time"},
        },
        opset_version=17
    )

    print("Exported ONNX:", ONNX_FP_PATH)

    quantize_dynamic(
        model_input=ONNX_FP_PATH,
        model_output=ONNX_INT8_PATH,
        weight_type=QuantType.QInt8
    )

    print("Saved INT8 ONNX:", ONNX_INT8_PATH)

if __name__ == "__main__":
    main()
