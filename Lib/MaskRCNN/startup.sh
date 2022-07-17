source ~/.zshrc
conda activate circle_virtual_environment
cd samples/nucleus/
python nucleus.py --weights=../../best_weights.h5 --subset=../../data detect
cd ../../
conda deactivate