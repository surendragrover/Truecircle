import torch
import torch.nn as nn
from transformers import BertConfig, BertModel

IN_PATH = r"C:\Users\suren\flutter_app\Truecircle_AI\truecircle_app\assets\models\Brain_1\multitask_g20.pt"
OUT_PATH = r"C:\Users\suren\flutter_app\Truecircle_AI\truecircle_app\assets\models\Brain_1\multitask_g20_int8.pt"

class Brain1Model(nn.Module):
    def __init__(self):
        super().__init__()
        self.backbone = None

    def build_from_state_dict(self, sd):
        vocab_size, hidden_size = sd["backbone.embeddings.word_embeddings.weight"].shape

        layer_ids = set()
        for k in sd.keys():
            if k.startswith("backbone.encoder.layer."):
                parts = k.split(".")
                if len(parts) > 3 and parts[3].isdigit():
                    layer_ids.add(int(parts[3]))
        num_hidden_layers = max(layer_ids) + 1 if layer_ids else 12

        intermediate_size = sd["backbone.encoder.layer.0.intermediate.dense.weight"].shape[0]

        cfg = BertConfig(
            vocab_size=vocab_size,
            hidden_size=hidden_size,
            num_hidden_layers=num_hidden_layers,
            intermediate_size=intermediate_size,
        )
        self.backbone = BertModel(cfg)

    def forward(self, input_ids, attention_mask=None, token_type_ids=None):
        return self.backbone(
            input_ids=input_ids,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids,
        )

def main():
    ckpt = torch.load(IN_PATH, map_location="cpu")
    sd = ckpt["model"]

    model = Brain1Model()
    model.build_from_state_dict(sd)

    missing, unexpected = model.load_state_dict(sd, strict=False)
    print("Missing keys:", len(missing))
    print("Unexpected keys:", len(unexpected))

    model.eval()

    qmodel = torch.quantization.quantize_dynamic(
        model,
        {nn.Linear},
        dtype=torch.qint8
    )

    torch.save(
        {
            "model": qmodel.state_dict(),
            "group": ckpt.get("group", None),
            "quantization": "dynamic_int8_linear",
        },
        OUT_PATH
    )
    print("Saved:", OUT_PATH)

if __name__ == "__main__":
    main()
