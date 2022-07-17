source ~/.zshrc
conda activate DSB_2018-master
cd samples/nucleus/
python nucleus.py --weights=../../best_weights.h5 --subset=../../data detect
cd ../../
conda deactivate