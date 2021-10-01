#!/bin/tcsh
#PBS -l mem=40gb,walltime=24:00:00
#PBS -m abe -M liuaal@bc.edu
conda activate py37_dev
module load python/3.6.3
cd /gsfs0/data/liuaal/careful/

module load cuda10.0/toolkit/10.0.130


python3 code/testing_crf.py --input russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100
python3 code/testing_crf.py --input russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 500
python3 code/testing_crf.py --input russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 1000

python3 code/testing_crf.py --input russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 3 --r without --k 100
python3 code/testing_crf.py --input russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 3 --r without --k 500
python3 code/testing_crf.py --input russian/500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 3 --r without --k 1000

python3 code/testing_crf.py --input russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100
python3 code/testing_crf.py --input russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 500
python3 code/testing_crf.py --input russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 1000

python3 code/testing_crf.py --input russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 100
python3 code/testing_crf.py --input russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 500
python3 code/testing_crf.py --input russian/1000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 1000

python3 code/testing_crf.py --input russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100
python3 code/testing_crf.py --input russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 500
python3 code/testing_crf.py --input russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 1000

python3 code/testing_crf.py --input russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 100
python3 code/testing_crf.py --input russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 500
python3 code/testing_crf.py --input russian/1500/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 1000

python3 code/testing_crf.py --input russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100
python3 code/testing_crf.py --input russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 500
python3 code/testing_crf.py --input russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 1000

python3 code/testing_crf.py --input russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 3 --r without --k 100
python3 code/testing_crf.py --input russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 3 --r without --k 500
python3 code/testing_crf.py --input russian/2000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 3 --r without --k 1000

python3 code/testing_crf.py --input russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100
python3 code/testing_crf.py --input russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 500
python3 code/testing_crf.py --input russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 1000

python3 code/testing_crf.py --input russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 100
python3 code/testing_crf.py --input russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 500
python3 code/testing_crf.py --input russian/3000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 1000

python3 code/testing_crf.py --input russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 100
python3 code/testing_crf.py --input russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 500
python3 code/testing_crf.py --input russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r with --k 1000

python3 code/testing_crf.py --input russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 100
python3 code/testing_crf.py --input russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 500
python3 code/testing_crf.py --input russian/4000/ --data resources/NeuralMorphemeSegmentation/data/ --lang ru --n 100 --order 4 --r without --k 1000



python3 code/testing_crf.py --input persian/500/ --data resources/ --lang persian --n 100 --order 1 --r with --k 50
python3 code/testing_crf.py --input persian/500/ --data resources/ --lang persian --n 100 --order 1 --r with --k 100

python3 code/testing_crf.py --input persian/500/ --data resources/ --lang persian --n 100 --order 1 --r without --k 50
python3 code/testing_crf.py --input persian/500/ --data resources/ --lang persian --n 100 --order 1 --r without --k 100
python3 code/testing_crf.py --input persian/500/ --data resources/ --lang persian --n 100 --order 1 --r without --k 500
python3 code/testing_crf.py --input persian/500/ --data resources/ --lang persian --n 100 --order 1 --r without --k 1000

python3 code/testing_crf.py --input persian/1000/ --data resources/ --lang persian --n 100 --order 3 --r with --k 50
python3 code/testing_crf.py --input persian/1000/ --data resources/ --lang persian --n 100 --order 3 --r with --k 100
python3 code/testing_crf.py --input persian/1000/ --data resources/ --lang persian --n 100 --order 3 --r with --k 500
python3 code/testing_crf.py --input persian/1000/ --data resources/ --lang persian --n 100 --order 3 --r with --k 1000

python3 code/testing_crf.py --input persian/1000/ --data resources/ --lang persian --n 100 --order 1 --r without --k 50
python3 code/testing_crf.py --input persian/1000/ --data resources/ --lang persian --n 100 --order 1 --r without --k 100
python3 code/testing_crf.py --input persian/1000/ --data resources/ --lang persian --n 100 --order 1 --r without --k 500
python3 code/testing_crf.py --input persian/1000/ --data resources/ --lang persian --n 100 --order 1 --r without --k 1000

python3 code/testing_crf.py --input persian/1500/ --data resources/ --lang persian --n 100 --order 1 --r with --k 50
python3 code/testing_crf.py --input persian/1500/ --data resources/ --lang persian --n 100 --order 1 --r with --k 100
python3 code/testing_crf.py --input persian/1500/ --data resources/ --lang persian --n 100 --order 1 --r with --k 500
python3 code/testing_crf.py --input persian/1500/ --data resources/ --lang persian --n 100 --order 1 --r with --k 1000

python3 code/testing_crf.py --input persian/1500/ --data resources/ --lang persian --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input persian/1500/ --data resources/ --lang persian --n 100 --order 4 --r without --k 100
python3 code/testing_crf.py --input persian/1500/ --data resources/ --lang persian --n 100 --order 4 --r without --k 500
python3 code/testing_crf.py --input persian/1500/ --data resources/ --lang persian --n 100 --order 4 --r without --k 1000

python3 code/testing_crf.py --input persian/2000/ --data resources/ --lang persian --n 100 --order 1 --r with --k 50
python3 code/testing_crf.py --input persian/2000/ --data resources/ --lang persian --n 100 --order 1 --r with --k 100
python3 code/testing_crf.py --input persian/2000/ --data resources/ --lang persian --n 100 --order 1 --r with --k 500
python3 code/testing_crf.py --input persian/2000/ --data resources/ --lang persian --n 100 --order 1 --r with --k 1000

python3 code/testing_crf.py --input persian/2000/ --data resources/ --lang persian --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input persian/2000/ --data resources/ --lang persian --n 100 --order 3 --r without --k 100
python3 code/testing_crf.py --input persian/2000/ --data resources/ --lang persian --n 100 --order 3 --r without --k 500
python3 code/testing_crf.py --input persian/2000/ --data resources/ --lang persian --n 100 --order 3 --r without --k 1000

python3 code/testing_crf.py --input persian/3000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input persian/3000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 100
python3 code/testing_crf.py --input persian/3000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 500
python3 code/testing_crf.py --input persian/3000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 1000

python3 code/testing_crf.py --input persian/3000/ --data resources/ --lang persian --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input persian/3000/ --data resources/ --lang persian --n 100 --order 3 --r without --k 100
python3 code/testing_crf.py --input persian/3000/ --data resources/ --lang persian --n 100 --order 3 --r without --k 500
python3 code/testing_crf.py --input persian/3000/ --data resources/ --lang persian --n 100 --order 3 --r without --k 1000

python3 code/testing_crf.py --input persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 100
python3 code/testing_crf.py --input persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 500
python3 code/testing_crf.py --input persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r with --k 1000

python3 code/testing_crf.py --input persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r without --k 100
python3 code/testing_crf.py --input persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r without --k 500
python3 code/testing_crf.py --input persian/4000/ --data resources/ --lang persian --n 100 --order 4 --r without --k 1000

#!/bin/tcsh
#PBS -l mem=30gb,walltime=24:00:00,advres=gpgpu2
#PBS -m abe -M liuaal@bc.edu
conda activate py37_dev
module load python/3.6.3
cd /gsfs0/data/liuaal/careful/

python3 code/testing_seq2seq.py --input german/1500/ --data resources/supplement/seg/ --lang ger --n 100 --r with --k 100


python3 code/testing_seq2seq.py --input zulu/4000/ --data resources/supplement/seg/ --lang zul --n 100 --r with --k 1000


python3 code/testing_seq2seq.py --input zulu/4000/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 500
python3 code/testing_seq2seq.py --input zulu/4000/ --data resources/supplement/seg/ --lang zul --n 100 --r without --k 1000



python3 code/testing_crf.py --input zulu/500/ --data resources/supplement/seg/ --lang zul --n 100 --order 3 --r with --k 50
python3 code/testing_crf.py --input zulu/500/ --data resources/supplement/seg/ --lang zul --n 100 --order 3 --r with --k 100

python3 code/testing_crf.py --input zulu/500/ --data resources/supplement/seg/ --lang zul --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input zulu/500/ --data resources/supplement/seg/ --lang zul --n 100 --order 3 --r without --k 100



#!/bin/tcsh
#PBS -l mem=30gb,walltime=24:00:00,advres=gpgpu2
#PBS -m abe -M liuaal@bc.edu
module load cuda10.0/toolkit/10.0.130
conda activate py37_dev
cd /gsfs0/data/liuaal/careful/

python3 code/testing_seq2seq.py --input indonesian/3000/ --data resources/supplement/seg/ --lang ind --n 100 --r with --k 50
python3 code/testing_seq2seq.py --input indonesian/3000/ --data resources/supplement/seg/ --lang ind --n 100 --r with --k 100
python3 code/testing_seq2seq.py --input indonesian/3000/ --data resources/supplement/seg/ --lang ind --n 100 --r with --k 500
python3 code/testing_seq2seq.py --input indonesian/3000/ --data resources/supplement/seg/ --lang ind --n 100 --r with --k 1000



python3 code/testing_crf.py --input indonesian/500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input indonesian/500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input indonesian/500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input indonesian/500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input indonesian/1000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input indonesian/1000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input indonesian/1000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input indonesian/1000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input indonesian/1500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input indonesian/1500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input indonesian/1500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input indonesian/1500/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input indonesian/2000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input indonesian/2000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input indonesian/2000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input indonesian/2000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 100


python3 code/testing_crf.py --input indonesian/3000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input indonesian/3000/ --data resources/supplement/seg/ --lang ind --n 100 --order 4 --r without --k 100




#!/bin/tcsh
#PBS -l mem=40gb,walltime=24:00:00
#PBS -m abe -M liuaal@bc.edu
conda activate py37_dev
module load python/3.6.3
cd /gsfs0/data/liuaal/careful/

python3 code/testing_crf.py --input english/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 1 --order 3 --r with --k 50

python3 code/testing_crf.py --input english/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 3 --r with --k 100

python3 code/testing_crf.py --input english/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 50

python3 code/testing_crf.py --input english/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input english/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r with --k 50

python3 code/testing_crf.py --input english/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input english/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 50

python3 code/testing_crf.py --input english/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without —k 100

python3 code/testing_crf.py --input english/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r with --k 50

python3 code/testing_crf.py --input english/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input english/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 50

python3 code/testing_crf.py --input english/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang eng --n 100 --order 4 --r without --k 100















python3 code/testing_crf.py --input finnish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r with --k 50
python3 code/testing_crf.py --input finnish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r with --k 100

python3 code/testing_crf.py --input finnish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input finnish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r without --k 100

python3 code/testing_crf.py --input finnish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input finnish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input finnish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input finnish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 3 --r without --k 100

python3 code/testing_crf.py --input finnish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input finnish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input finnish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 2 --r without --k 50
python3 code/testing_crf.py --input finnish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang fin --n 100 --order 2 --r without --k 100




python3 code/testing_crf.py --input turkish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 3 --r with --k 50
python3 code/testing_crf.py --input turkish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 3 --r with --k 100

python3 code/testing_crf.py --input turkish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 2 --r without --k 50
python3 code/testing_crf.py --input turkish/500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 2 --r without --k 100

python3 code/testing_crf.py --input turkish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 3 --r with --k 50
python3 code/testing_crf.py --input turkish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 3 --r with --k 100

python3 code/testing_crf.py --input turkish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input turkish/1000/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 3 --r without --k 100

python3 code/testing_crf.py --input turkish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 2 --r without --k 50
python3 code/testing_crf.py --input turkish/1500/ --data resources/NeuralMorphemeSegmentation/morphochal10data/ --lang tur --n 100 --order 2 --r without --k 100




python3 code/testing_crf.py --input german/500/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input german/500/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input german/500/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input german/500/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r without --k 100

python3 code/testing_crf.py --input german/1000/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input german/1000/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input german/1000/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r without --k 50
python3 code/testing_crf.py --input german/1000/ --data resources/supplement/seg/ --lang ger --n 100 --order 4 --r without --k 100


python3 code/testing_crf.py --input german/1500/ --data resources/supplement/seg/ --lang ger --n 100 --order 3 --r without --k 50
python3 code/testing_crf.py --input german/1500/ --data resources/supplement/seg/ --lang ger --n 100 --order 3 --r without --k 100


python3 code/testing_crf.py --input wixarika/500/ --data resources/ --lang wixarika --n 100 --order 2 --r with --k 50
python3 code/testing_crf.py --input wixarika/500/ --data resources/ --lang wixarika --n 100 --order 2 --r with --k 100

python3 code/testing_crf.py --input wixarika/500/ --data resources/ --lang wixarika --n 100 --order 2 --r without --k 50
python3 code/testing_crf.py --input wixarika/500/ --data resources/ --lang wixarika --n 100 --order 2 --r without --k 100

python3 code/testing_crf.py --input wixarika/1000/ --data resources/ --lang wixarika --n 100 --order 4 --r with --k 50
python3 code/testing_crf.py --input wixarika/1000/ --data resources/ --lang wixarika --n 100 --order 4 --r with --k 100

python3 code/testing_crf.py --input wixarika/1000/ --data resources/ --lang wixarika --n 100 --order 2 --r without --k 50
python3 code/testing_crf.py --input wixarika/1000/ --data resources/ --lang wixarika --n 100 --order 2 --r without --k 100

module load cuda10.0/toolkit/10.0.130