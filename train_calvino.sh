#!/bin/bash

export CUDA_VISIBLE_DEVICES=0
export OUTPUT=gpt2/calvino
export TRAIN=corpus/Calvino.txt
export VALID=corpus/Calvino_valid.txt
export BS=1
export LR=2e-5

for i in {1..6}; do
    python run_lm_finetuning.py \
        --output_dir=gpt2/calvino/output \
        --model_type=gpt2 \
        --model_name_or_path=$OUTPUT \
        --do_train \
        --train_data_file=$TRAIN \
        --per_gpu_train_batch_size $BS \
        --save_steps=10000 \
        --logging_steps=1 \
        --fp16 \
        --fp16_opt_level O3 \
        --warmup_samples 40 \
        --learning_rate $LR \
        --overwrite_output_dir \
        --tokenizer_class YTEncoder \
        --tokenizer_name $OUTPUT/encoder.model \
        --lr_decay \
        --do_eval \
        --evaluate_during_training \
        --eval_steps 500 \
        --line_by_line \
        --per_gpu_eval_batch_size 1 \
        --eval_data_file=$VALID
    sleep 1
done

# 0 2 * * * /home/u/ru_transformers/poetry/train_poet.sh