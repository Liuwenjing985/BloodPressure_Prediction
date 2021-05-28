clc; clear all;
fs = 500;
% 按自然顺序读取文件
path = 'F:\Project-342B\血压预测\Data\dataset';
filelist = dir(fullfile(path, '*.mat'));
dir = struct2cell(filelist); 
dir_cell = sort_nat(dir(1,:));

% 读取血压值
file_bp = xlsread(fullfile(path, 'BloodPressure.xlsx'));
sbp = file_bp(:,1);
dbp = file_bp(:,2);
hr = file_bp(:,3);

% 依次读取每个样本signal
% for i = 1: length(dir_cell)
dim = 2;
nsamples = length(dir_cell); 
fea_ptt_max = [];
fea_ptt_min = [];
fea_hr = [];
SBP = [];
DBP = [];
for i = 1: nsamples
    % 读取每个样本的ecg和reg
    signal_struct = load(fullfile(path, dir_cell{i}));
    signal = signal_struct.signal;
    ecg = signal(1,:);
    reg = signal(2,:);
    
    if length(ecg) > 30*fs
        N_seg = 3;   % 一段ecg分为N_seg段
    else
        N_seg = 2; 
    end
    
    % 分段
    idx_start = 1;
    for ii = 1:N_seg
        idx_end = idx_start + 10 * fs - 1;
        ecg_seg = ecg(idx_start:idx_end);
        reg_seg = reg(idx_start:idx_end);
        idx_start = idx_end + 1;
        
        % 提取特征
        PTT = fea_PTT(ecg_seg, reg_seg, fs);
        fea_ptt_max = [fea_ptt_max; PTT(1)];
        fea_ptt_min = [fea_ptt_min; PTT(2)];
        fea_hr = [fea_hr; hr(i)];
        SBP = [SBP; sbp(i)];
        DBP = [DBP; dbp(i)];
    end
    
end

% 划分训练集和测试集
fea_0 = [fea_hr];
fea_1 = [fea_ptt_max, fea_hr];
fea_2 = [fea_ptt_max, fea_hr, fea_ptt_max.*fea_hr];
array = [fea_1, SBP];
% array = [fea_1, DBP];
randIndex = randperm(size(array,1));
array_new = array(randIndex,:);
x_train = array_new(1:70,1:size(array,2)-1);
y_train = array_new(1:70,size(array,2));
x_test = array_new(71:106,1:size(array,2)-1);
y_test = array_new(71:106,size(array,2));

% 训练
X_train = [ones(length(x_train),1), x_train];
[b2,bint2,r2,rint2,stats2] = regress(y_train,X_train);

% 测试
% y_pred = b2(1).*ones(length(x_test),1) + b2(2).*x_test(:,1);
y_pred = b2(1).*ones(length(x_test),1) + b2(2).*x_test(:,1) + b2(3).*x_test(:,2);
% y_pred = b2(1).*ones(length(x_test),1) + b2(2).*x_test(:,1) + b2(3).*x_test(:,2) + b2(4).*x_test(:,3);

% 计算误差
err_all = abs(y_pred - y_test);
err_mean = mean(err_all);
err_std = std(err_all);


