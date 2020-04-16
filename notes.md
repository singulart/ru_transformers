##### Fine-tuning GPT2 with my custom dataset
```
python run_language_modeling.py --line_by_line --output_dir=Output --model_type=gpt2-large --do_train --train_data_file=corpus\snowden.txt --per_gpu_train_batch_size %BS% --save_steps=10000 --logging_steps=10 --fp16 --fp16_opt_level O3 --warmup_steps 16000 --learning_rate %LR% --overwrite_output_dir --do_eval --evaluate_during_training --eval_data_file=corpus/snowden_valid.txt  --save_total_limit 30 --num_train_epochs 1000.0 --tokenizer_name D:\projects\ai\gpt2\gpt2-large --model_name_or_path gpt2\774M-torch-converted 
```
For me, OOM was ovecome only by setting ```--fp16_opt_level O3``` unlike @mgrankin ru_transformers where it was 02 

Problem: perplexity = tensor(nan)

__________________________________________

##### Converting GPT2 from TensorFlow to PyTorch

Step 1. Download GPT2 model
I used 774M variant:
  
In Linux: clone https://github.com/nshepperd/gpt-2, after install dependencies and run download script
``` 
python3 download_model.py 774M
```

This will produce a directory with several files. I copied it to ru_transformers\gpt2
because I was lazy to set up a whole new conda env. 

Step 2. Download and save the configs for the GPT2. All possible options are listed here:
https://raw.githubusercontent.com/huggingface/transformers/master/src/transformers/configuration_gpt2.py
Warning: rename downloaded file to config.json

Step 3. Download and save the files for GPT2 Tokenizer. All possible options are listed here:
https://raw.githubusercontent.com/huggingface/transformers/master/src/transformers/tokenization_gpt2.py
Warning: rename downloaded files to vocab.json and merges.txt

Step 4. Run the conversion script from the root of ru_transformers project:
```
python convert_gpt2_original_tf_checkpoint_to_pytorch.py --gpt2_checkpoint_path gpt2\774M --pytorch_dump_folder_path gpt2\774M-torch-converted --gpt2_config_file ..\gpt2\gpt2-large\config.json 
```
Warning: without --gpt2_config_file I got AssertionError, because Gpt@Config was initialized improp


##### Strange yttm vocabulary contents

While inspecting the yttm vocab like this:
```
from yt_encoder import YTEncoder
enc_pelevin_s = YTEncoder.from_pretrained('gpt2/pelevin/s_checkpoint-1900280)
'красота' in enc_pelevin_s.bpe.vocab()
```
I didn't find the common words in it. Instead, the vocabulary has strange incomplete words like 
``` 
  '▁чув',
 '▁пло',
 '▁жизни',
 '▁Они',
 'ением',
 '▁которые',
 '▁объ',
 '▁буду',
 '▁кре',
 'чка',
 '▁ост',
 'но.',
 '▁обо',
 'обра',
 'ит',
 'нец',
 '▁случа',
 '▁моло',
 '▁други',
 '▁нибудь',
 '▁вам',
 'жду',
 'дол',
 'р,',
 'стра',
 'ника',
 '▁дет',
 '▁могу',
 'чет',
 '▁Когда 
```
Finding: seems that this is how YTTM dictionary is organized. Question: how to query the word is in this dictionary?

-------------------------------------------------------------

##### [SOLVED] Bad encoding (Windows only)
```
yttm vocab --verbose --model bpe/yt.model 
```
spits out IBM866 encoded strings
``` 
50247   тЦБ╨║╤В╨╛.=тЦБ╨║╤В╨╛+.                                      732+29
50248   ╨╗╨╕╨░╨╜╤В╨░=╨╗╨╕+╨░╨╜╤В╨░                                    194+2691
50249   тЦБ╤Б╤В╨╛╨╣╨║╨╛╨╣=тЦБ╤Б╤В╨╛╨╣+╨║╨╛╨╣                                5775+394
50250   ╤И╨░╤В╤М.=╤И╨░+╤В╤М.                                      359+571
50251   тЦБ╨╕╤Б╤В╨╛╤А╨╕╨║╨╕=тЦБ╨╕╤Б╤В╨╛╤А╨╕+╨║╨╕                              1333+215
50252   ╤А╨╛╨▓-=╤А╨╛╨▓+-                                        519+40
50253   тЦБ╨Ю╨Ю╨Ю=тЦБ╨Ю+╨Ю╨Ю                                        264+43850
50254   тЦБ╤Б╨┐╨╛╨║╨╛╨╡╨╜.=тЦБ╤Б╨┐╨╛╨║╨╛+╨╡╨╜.                              20083+5088
50255   тЦБ╨┐╤А╨╛╤Ж╨╡╤Б╤Б╨░,=тЦБ╨┐╤А╨╛╤Ж╨╡╤Б╤Б╨░+,                            11285+21
50256   тЦБ╨Ъ╨╛╤В╨╛╤А╨░╤П=тЦБ╨Ъ╨╛╤В╨╛+╤А╨░╤П                                8631+930
```
which is equivalent to (used http://www.online-decoder.com to convert to utf-8)
``` 
50247 ▁кто.=▁кто+. 732+29
50248 лианта=ли+анта 194+2691
50249 ▁стойкой=▁стой+кой 5775+394
50250 шать.=ша+ть. 359+571
50251 ▁историки=▁истори+ки 1333+215
50252 ров-=ров+- 519+40
50253 ▁ООО=▁О+ОО 264+43850
50254 ▁спокоен.=▁споко+ен. 20083+5088
50255 ▁процесса,=▁процесса+, 11285+21
50256 ▁Которая=▁Кото+рая 8631+930
```

Solution: for some reason default encoding in Powershell is ```cp866```. To solve the problem, run ```chcp 65001``` 
which will set the encoding to UTF-8