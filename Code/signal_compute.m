% data_arr_3ch：原始测量数据的三个通道
% 第一通道：总电压 vs
% 第二通道：人体两端电压 vr
% 第三通道：ECG

function signal = signal_compute(data_arr_3ch)
    % 返回的signal第一行是ecg，第二行是reg
    fs_raw = 100000; % 采样频率
    
    v_s_raw = data_arr_3ch(:,1); 
    v_r_raw = data_arr_3ch(:,2); 

    N = 200;        % 分段点数（每段200点，2毫秒）
    fs = fs_raw/N;  % 分段后的采样频率（500Hz）

    % 分段平均：
    A_vs = []; 
    A_vr = [];
    Phi_vs = [];
    Phi_vr = [];
    for ii = 1:length(v_s_raw)/N
        point_start = 1 + (ii-1)*N;
        point_end = ii*N;
        v_s_segment = v_s_raw(point_start:point_end); % 2000个点
        v_r_segment = v_r_raw(point_start:point_end);

        % 使用100个点估计幅值和相位
        [As, Phis] = Frequency_estimate(v_s_segment, fs_raw);
        [Ar, Phir] = Frequency_estimate(v_r_segment, fs_raw);

        A_vs = [A_vs, As];
        A_vr = [A_vr, Ar];
        Phi_vs = [Phi_vs, Phis];
        Phi_vr = [Phi_vr, Phir];
    end
    tmp1 = A_vs./A_vr;
    tmp2 = Phi_vs - Phi_vr;
    tmp3 = zeros(1, length(tmp2));
    for ii = 1:length(tmp2)
        if(tmp2(ii) > 2*pi)
            tmp2(ii) = tmp2(ii) - 2*pi;
        end
        tmp3(ii) = tmp1(ii)*exp(tmp2(ii).*i);
    end
    Imped = (tmp3 - 1)*10000;  % 计算出的脑阻抗信号（复阻抗）

    % 脑阻抗的模
    Imped_abs = abs(Imped);

    % 2. 对心电信号分段平均（滤除10kHz干扰）
    ecg_raw = data_arr_3ch(:,3); 
    % 分段平均：
    ecg_seg = [];
    for ii = 1:length(ecg_raw)/N
        point_start = 1 + (ii-1)*N;
        point_end = ii*N;
        ecg_segment = ecg_raw(point_start:point_end); % 100个点

        % 求均值
        ecg_segment_mean = mean(ecg_segment);
        ecg_seg = [ecg_seg, ecg_segment_mean];
    end

    % 3.平滑滤波
    % (1). REG
    Sx_Imped = smoothf(Imped_abs,3,10*100+1);
    Imped_filted = Imped_abs - Sx_Imped;  % 平滑滤波后的脑阻抗
    % (2). ECG
    Sx_ecg = smoothf(ecg_seg,3,10*100+1);
    ecg = ecg_seg - Sx_ecg;            % 平滑滤波后的ecg

    % 4.脑阻抗带通滤波
    f1 = 0.5;
    f2 = 10;
    b = fir1(1000,[f1/fs f2/fs]);
    reg = filtfilt(b, 1, Imped_filted);

    % 5.ecg带通滤波
    f1 = 0.1;
    f2 = 50;
    b = fir1(1000,[f1/fs f2/fs]);
    ecg = filtfilt(b, 1, ecg);

    signal = [ecg; reg];
end