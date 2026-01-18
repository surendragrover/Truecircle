import numpy as np
import torch
import torch.nn as nn
from transformers import Wav2Vec2Config, Wav2Vec2Model

from onnxruntime.quantization import (
    quantize_static,
    CalibrationDataReader,
    QuantFormat,
    QuantType,
)

IN_PATH = r"C:\Users\suren\flutter_app\Truecircle_AI\truecircle_app\assets\models\Brain_A\Brain_A.pt"

ONNX_FP_PATH = r"C:\Users\suren\flutter_app\Truecircle_AI\truecircle_app\assets\models\Brain_A\Brain_A_fp32.onnx"
ONNX_INT8_PATH = r"C:\Users\suren\flutter_app\Truecircle_AI\truecircle_app\assets\models\Brain_A\Brain_A_int8.onnx"


class BrainAWrapper(nn.Module):
    """
    Checkpoint keys are prefixed with 'wav2vec.*'
    so the wrapper must expose self.wav2vec = Wav2Vec2Model(...)
    """
    def __init__(self, cfg):
        super().__init__()
        self.wav2vec = Wav2Vec2Model(cfg)

    def forward(self, input_values):
        out = self.wav2vec(input_values)
        return out.last_hidden_state


def infer_num_layers(sd):
    layer_ids = set()
    for k in sd.keys():
        if k.startswith("wav2vec.encoder.layers."):
            parts = k.split(".")
            if len(parts) > 3 and parts[3].isdigit():
                layer_ids.add(int(parts[3]))
    return max(layer_ids) + 1 if layer_ids else 12


def infer_hidden_size(sd):
    for k, v in sd.items():
        if k.endswith("attention.q_proj.weight"):
            return v.shape[0]
    return 768


def infer_intermediate_size(sd):
    for k, v in sd.items():
        if k.endswith("feed_forward.intermediate_dense.weight"):
            return v.shape[0]
    return 3072


class AudioCalibrationDataReader(CalibrationDataReader):
    """
    Static quantization needs calibration data.
    We use random audio-like float32 tensors as calibration samples.
    """
    def __init__(self, num_samples=25, sample_len=16000):
        self.data = []
        for _ in range(num_samples):
            x = np.random.randn(1, sample_len).astype(np.float32)
            self.data.append({"input_values": x})
        self._iter = iter(self.data)

    def get_next(self):
        return next(self._iter, None)


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

    model = BrainAWrapper(cfg)

    missing, unexpected = model.load_state_dict(sd, strict=False)
    print("Missing keys:", len(missing))
    print("Unexpected keys:", len(unexpected))
    if len(unexpected) > 0:
        print("First unexpected keys:", unexpected[:10])

    model.eval()

    # Dummy audio input (1 sec at 16kHz)
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
        opset_version=18
    )

    print("Exported ONNX:", ONNX_FP_PATH)

    # Calibration data
    dr = AudioCalibrationDataReader(num_samples=25, sample_len=16000)

    quantize_static(
        model_input=ONNX_FP_PATH,
        model_output=ONNX_INT8_PATH,
        calibration_data_reader=dr,
        quant_format=QuantFormat.QOperator,
        activation_type=QuantType.QUInt8,
        weight_type=QuantType.QInt8,
    )

    print("Saved INT8 ONNX:", ONNX_INT8_PATH)


if __name__ == "__main__":
    main()
