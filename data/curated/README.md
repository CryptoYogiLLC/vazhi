# Curated Dataset Backups

Each subdirectory mirrors a HuggingFace dataset revision. These are local backups of the computed training datasets — the source of truth is on HuggingFace.

## To recreate a dataset from HuggingFace

```bash
# Download a specific revision
huggingface-cli download CryptoYogi/vazhi-tamil-sft-v4_0 --revision <sha> --local-dir data/curated/v4_0/

# Or download the latest
huggingface-cli download CryptoYogi/vazhi-tamil-sft-v4_0 --local-dir data/curated/v4_0/
```

## To create a new dataset

Run the Dataset Factory notebook on Kaggle/Colab:
```
notebooks/Vazhi_Dataset_Factory_v4_0.ipynb
```

This constructs the dataset from `data/sources/` and uploads to HuggingFace. Then download the backup here.

## Directory structure

```
curated/
  v4_0/
    train.jsonl    # Training split (gitignored — large file)
    validation.jsonl  # Eval split (gitignored — large file)
    dataset_info.json # Metadata from HF
```

See [ADR-010](../docs/adr/010-data-pipeline-architecture.md) for the full pipeline architecture.
