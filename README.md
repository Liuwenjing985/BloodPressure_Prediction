# BloodPressure_Prediction

运行main.m 或者 main_seg.m文件

main.m 是不分段进行血压估计，即每个样本是30s长度的信号，样本量为38

main_seg.m 是分段后进行血压估计，每个样本是10s长度的信号，样本量为109



data_prepare.m：将原始记录的3通道数据进行预处理，将预处理后的ecg和reg存在signal矩阵，并存储在目标文件夹中。处理后的数据按已有文件个数排序，存储在目标文件夹path_output中。

fea_PTT.m：基于ecg和reg信号计算PTT特征

signal_compute.m：基于原始记录的3通道数据计算ecg和reg

sort_nat.m：将当前文件夹下的文件名按照自然顺序读取