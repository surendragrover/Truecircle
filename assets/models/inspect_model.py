#!/usr/bin/env python3
"""
Inspect the TFLite model in this folder and print input/output specs.

Default target: TrueCircle.tflite (override with --model <path>)

Usage (from this folder):
  python inspect_model.py
  # or from anywhere
  python C:/Users/suren/flutter_app/truecircle/TC/assets/models/inspect_model.py --model C:/Users/suren/flutter_app/truecircle/TC/assets/models/TrueCircle.tflite
"""
import argparse
import os
import sys

try:
    import tensorflow as tf  # type: ignore
except Exception:
    print("TensorFlow not available. Install one of:\n  pip install tensorflow\n  pip install tensorflow-cpu", file=sys.stderr)
    sys.exit(1)


def print_details(title, tensors):
    print(f"\n{title} ({len(tensors)})")
    print("-" * 60)
    for i, d in enumerate(tensors):
        name = d.get("name")
        shape = list(d.get("shape", []))
        dtype = d.get("dtype")
        idx = d.get("index")
        qp = d.get("quantization_parameters", {})
        scales = qp.get("scales")
        zeros = qp.get("zero_points")
        axis = qp.get("quantized_dimension")
        print(f"[{i}] name={name}")
        print(f"     index={idx}")
        print(f"     shape={shape}  dtype={dtype}")
        if scales is not None or zeros is not None:
            print(f"     quantization: scales={list(scales) if scales is not None else None}, zero_points={list(zeros) if zeros is not None else None}, axis={axis}")
        else:
            print("     quantization: None")


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    default_model = os.path.join(here, "TrueCircle.tflite")

    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default=default_model, help="Path to .tflite model (default: TrueCircle.tflite in this folder)")
    args = parser.parse_args()

    model_path = args.model
    if not os.path.exists(model_path):
        print(f"ERROR: Model not found: {model_path}", file=sys.stderr)
        sys.exit(1)

    print(f"Loading model: {model_path}")
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()

    ins = interpreter.get_input_details()
    outs = interpreter.get_output_details()

    print_details("Inputs", ins)
    print_details("Outputs", outs)

    # hint for dynamic shapes
    if any(any(dim <= 0 for dim in t.get("shape", [])) for t in ins):
        ex = [1 if x <= 0 else int(x) for x in ins[0]["shape"]]
        print("\nNote: Dynamic input shape detected. Example to set a concrete shape:")
        print(f"  interpreter.resize_tensor_input({ins[0]['index']}, {ex})")
        print("  interpreter.allocate_tensors()")


if __name__ == "__main__":
    main()
