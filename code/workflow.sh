#!/bin/tcsh
#PBS -l mem=30gb,walltime=24:00:00,advres=gpgpu2
#PBS -m abe -M liuaal@bc.edu
module load cuda10.0/toolkit/10.0.130
module load intel/2020 gnu_gcc/9.2.0 kaldi/5.5.6gpu
#module load pytorch/1.2.0gpu
conda activate py37_dev
#cd /gsfs0/data/liuaal/
cd /gsfs0/data/liuaal/espnet/tools/kaldi/egs/ALFFA_PUBLIC/ASR/WOLOF

#python3 try.py --output csv/batch7/
steps/train_deltas.sh --boost-silence 1.25 --cmd utils/run.pl 4200 40000 data/train data/lang exp/system1/mono_ali exp/system1/tri1


### Mayo

### Generating data ###

python3 code/segmentation_data.py --input resources/ --output experiments/mayo/ --lang mayo --r with --k 500

python3 code/segmentation_data.py --input resources/ --output experiments/mayo/ --lang mayo --r without --k 500

### Training morfessor models ###

python3 code/morfessor/morfessor.py --input experiments/zulu/1000/with/ --lang zul

python3 code/morfessor/morfessor.py --input experiments/zulu/1000/without/ --lang zul

### Generating evaluation scripts for morfessor model results ###

python3 code/morf_shell.py --input experiments/zulu/1000/ --lang zul

### Evaluating morfessor model results ###

bash zul_1000_morf_eval.sh 

mv experiments/zulu/1000/with/*eval_morf* experiments/zulu/1000/with/morfessor/
mv experiments/zulu/1000/with/*pred_morf* experiments/zulu/1000/with/morfessor/

mv experiments/zulu/1000/without/*eval_morf* experiments/zulu/1000/without/morfessor/
mv experiments/zulu/1000/without/*pred_morf* experiments/zulu/1000/without/morfessor/


### Generating CRF shell script ###

python3 code/crf_order.py --input experiments/mayo/500/ --lang mayo --r with --order 3

### Construct crf_train.pbs ###



### Generate configuration *.yaml files ###

python3 code/yaml.py --input experiments/mayo/500/ --lang mayo --r with

python3 code/yaml.py --input experiments/mayo/500/ --lang mayo --r without


### Generate pbs file for Seq2seq modesl ###

python3 code/sirius.py --input experiments/mayo/500/ --lang mayo --r with

python3 code/sirius.py --input experiments/mayo/500/ --lang mayo --r without


### Create higher_orders, higher_orders/models folders for CRF results ###


### Testing ###


python3 code/testing_crf.py --input experiments/wixarika/500/ --data resources/ --lang wixarika --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/wixarika/500/ --data resources/ --lang wixarika --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/wixarika/500/ --data resources/ --lang wixarika --n 100 --order 2 --r without --k 50
python3 code/testing_crf.py --input experiments/wixarika/500/ --data resources/ --lang wixarika --n 100 --order 2 --r without --k 100

#!/bin/tcsh
#PBS -l mem=50gb,walltime=48:00:00,advres=gpgpu2
#PBS -m abe -M liuaal@bc.edu
module load cuda10.0/toolkit/10.0.130
conda activate py37_dev
cd /gsfs0/data/liuaal/model_generalizability


python3 code/testing_seq2seq.py --input experiments/wixarika/1000/ --data resources/ --lang wixarika --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/wixarika/1000/ --data resources/ --lang wixarika --n 100 --r with --k 100



python3 code/testing_crf.py --input experiments/english/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/english/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/english/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/english/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input experiments/english/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/english/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/english/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/english/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 100

python3 code/testing_seq2seq.py --input experiments/english/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/english/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --r with --k 100

python3 code/testing_crf.py --input experiments/english/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/english/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 100



python3 code/testing_crf.py --input experiments/german/500/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/german/500/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/german/500/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/german/500/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input experiments/german/1000/ --data resources/supplement/seg/ --lang ger --n 100 --order 3 --r with --k 50
python3 code/testing_crf.py --input experiments/german/1000/ --data resources/supplement/seg/ --lang ger --n 100 --order 3 --r with --k 100

python3 code/testing_crf.py --input experiments/german/1000/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/german/1000/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r without --k 100

python3 code/testing_seq2seq.py --input experiments/german/1500/ --data resources/supplement/seg/ --lang ger --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/german/1500/ --data resources/supplement/seg/ --lang ger --n 100 --r with --k 100

python3 code/testing_crf.py --input experiments/german/1500/ --data resources/supplement/seg/ --lang ger --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input experiments/german/1500/ --data resources/supplement/seg/ --lang ger --n 100 --order 3 --r without --k 100




python3 code/testing_crf.py --input experiments/indonesian/500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/indonesian/500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/indonesian/500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/indonesian/500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input experiments/indonesian/1000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/indonesian/1000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/indonesian/1000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/indonesian/1000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input experiments/indonesian/1500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/indonesian/1500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/indonesian/1500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/indonesian/1500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 100


python3 code/testing_seq2seq.py --input experiments/indonesian/2000/ --data resources/supplement/seg/ --lang ind --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/indonesian/2000/ --data resources/supplement/seg/ --lang ind --n 100 --r with --k 100

python3 code/testing_crf.py --input experiments/indonesian/2000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/indonesian/2000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 100

python3 code/testing_seq2seq.py --input experiments/indonesian/3000/ --data resources/supplement/seg/ --lang ind --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/indonesian/3000/ --data resources/supplement/seg/ --lang ind --n 100 --r with --k 100

python3 code/testing_seq2seq.py --input experiments/indonesian/3000/ --data resources/supplement/seg/ --lang ind --n 100 --r without --k 50
python3 code/testing_seq2seq.py --input experiments/indonesian/3000/ --data resources/supplement/seg/ --lang ind --n 100 --r without --k 100


python3 code/testing_crf.py --input experiments/finnish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r with --k 50
python3 code/testing_crf.py --input experiments/finnish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r with --k 100

python3 code/testing_crf.py --input experiments/finnish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input experiments/finnish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r without --k 100

python3 code/testing_crf.py --input experiments/finnish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r with --k 50
python3 code/testing_crf.py --input experiments/finnish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r with --k 100

python3 code/testing_crf.py --input experiments/finnish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 2 --r without --k 50
python3 code/testing_crf.py --input experiments/finnish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 2 --r without --k 100

python3 code/testing_seq2seq.py --input experiments/finnish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/finnish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --r with --k 100

python3 code/testing_seq2seq.py --input experiments/finnish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --r without --k 50
python3 code/testing_seq2seq.py --input experiments/finnish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --r without --k 100




#!/bin/tcsh
#PBS -l mem=40gb,walltime=48:00:00
#PBS -m abe -M liuaal@bc.edu
conda activate py37_dev
cd /gsfs0/data/liuaal/model_generalizability


python3 code/testing_crf.py --input experiments/turkish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 3 --r with --k 50

python3 code/testing_crf.py --input experiments/turkish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 3 --r with --k 100

python3 code/testing_crf.py --input experiments/turkish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 2 --r without --k 50

python3 code/testing_crf.py --input experiments/turkish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 2 --r without --k 100

python3 code/testing_crf.py --input experiments/turkish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 4 --r with --k 50

python3 code/testing_crf.py --input experiments/turkish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/turkish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 3 --r without --k 50

python3 code/testing_crf.py --input experiments/turkish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 3 --r without --k 100

python3 code/testing_seq2seq.py --input experiments/turkish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --r with --k 50

python3 code/testing_seq2seq.py --input experiments/turkish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --r with --k 100

python3 code/testing_seq2seq.py --input experiments/turkish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --r without --k 50

python3 code/testing_seq2seq.py --input experiments/turkish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --r without --k 100





python3 code/testing_crf.py --input experiments/persian/500/ --data resources/ --lang persian --n 100 --order 1 --r with --k 50
python3 code/testing_crf.py --input experiments/persian/500/ --data resources/ --lang persian --n 100 --order 1 --r with --k 100

python3 code/testing_crf.py --input experiments/persian/500/ --data resources/ --lang persian --n 100 --order 1 --r without --k 50
python3 code/testing_crf.py --input experiments/persian/500/ --data resources/ --lang persian --n 100 --order 1 --r without --k 100

python3 code/testing_crf.py --input experiments/persian/1000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/persian/1000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/persian/1000/ --data resources/ --lang persian --n 100 --order 1 --r without --k 50
python3 code/testing_crf.py --input experiments/persian/1000/ --data resources/ --lang persian --n 100 --order 1 --r without --k 100

python3 code/testing_crf.py --input experiments/persian/1500/ --data resources/ --lang persian --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/persian/1500/ --data resources/ --lang persian --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/persian/1500/ --data resources/ --lang persian --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input experiments/persian/1500/ --data resources/ --lang persian --n 100 --order 3 --r without --k 100

python3 code/testing_crf.py --input experiments/persian/2000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/persian/2000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/persian/2000/ --data resources/ --lang persian --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/persian/2000/ --data resources/ --lang persian --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input experiments/persian/3000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/persian/3000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/persian/3000/ --data resources/ --lang persian --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/persian/3000/ --data resources/ --lang persian --n 100 --order 4 --r without --k 100


python3 code/testing_crf.py --input experiments/persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input experiments/persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input experiments/persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r without --k 100



#!/bin/tcsh
#PBS -l mem=40gb,walltime=48:00:00,advres=gpgpu2
#PBS -m abe -M liuaal@bc.edu
module load cuda10.0/toolkit/10.0.130
conda activate py37_dev
cd /gsfs0/data/liuaal/model_generalizability


python3 code/testing_crf.py --input experiments/russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50

python3 code/testing_crf.py --input experiments/russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 500

python3 code/testing_crf.py --input experiments/russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 1000


python3 code/testing_crf.py --input experiments/russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 2 --r without --k 50

python3 code/testing_crf.py --input experiments/russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 2 --r without --k 100

python3 code/testing_crf.py --input experiments/russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 2 --r without --k 500

python3 code/testing_crf.py --input experiments/russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 2 --r without --k 1000


python3 code/testing_crf.py --input experiments/russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50

python3 code/testing_crf.py --input experiments/russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 500

python3 code/testing_crf.py --input experiments/russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 1000


python3 code/testing_crf.py --input experiments/russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 50

python3 code/testing_crf.py --input experiments/russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input experiments/russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 500

python3 code/testing_crf.py --input experiments/russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 1000


python3 code/testing_crf.py --input experiments/russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50

python3 code/testing_crf.py --input experiments/russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 50

python3 code/testing_crf.py --input experiments/russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 100


python3 code/testing_crf.py --input experiments/russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50

python3 code/testing_crf.py --input experiments/russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 50

python3 code/testing_crf.py --input experiments/russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 100


python3 code/testing_crf.py --input experiments/russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50

python3 code/testing_crf.py --input experiments/russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 50

python3 code/testing_crf.py --input experiments/russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 100


python3 code/testing_crf.py --input experiments/russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50

python3 code/testing_crf.py --input experiments/russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input experiments/russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 50

python3 code/testing_crf.py --input experiments/russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 100





python3 code/testing_seq2seq.py --input experiments/zulu/500/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 50

python3 code/testing_seq2seq.py --input experiments/zulu/500/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 100


python3 code/testing_seq2seq.py --input experiments/zulu/500/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/500/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 100

python3 code/testing_seq2seq.py --input experiments/zulu/1000/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/1000/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 100


python3 code/testing_seq2seq.py --input experiments/zulu/1000/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/1000/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 100


python3 code/testing_seq2seq.py --input experiments/zulu/1500/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/1500/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 100

python3 code/testing_seq2seq.py --input experiments/zulu/1500/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/1500/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 100


python3 code/testing_seq2seq.py --input experiments/zulu/2000/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/2000/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 100

python3 code/testing_seq2seq.py --input experiments/zulu/2000/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/2000/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 100


python3 code/testing_seq2seq.py --input experiments/zulu/3000/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/3000/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 100

python3 code/testing_seq2seq.py --input experiments/zulu/3000/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/3000/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 100


python3 code/testing_seq2seq.py --input experiments/zulu/4000/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/4000/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 100

python3 code/testing_seq2seq.py --input experiments/zulu/4000/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 50
python3 code/testing_seq2seq.py --input experiments/zulu/4000/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 100


