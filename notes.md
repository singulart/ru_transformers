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

##### Bad encoding (Windows only)
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