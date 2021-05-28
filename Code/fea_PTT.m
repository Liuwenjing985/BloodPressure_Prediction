function PTT = fea_PTT(ecg, reg, fs)
    N_segment_ecg = 450;
    % R波检测
    % 求1阶差分
    dif = diff(ecg,1);    % 后项减前项
    % 找差分域的最大值
    N_for = floor(length(ecg)/N_segment_ecg); % 用于循环的段数
    start = 1;            % 初始分段起点
    last = N_segment_ecg; % 初始分段终点
    difmax_index = [];    % 存储差分域最大值下标
    for jj = 1:N_for-1
        dif_segment = dif(start:last);       % ecg差分域每个间隔的片段
        [m, index] = max(dif_segment);       % ecg差分域的最大值下标
        difmax_index = [difmax_index, index+start-1];
        start = start + N_segment_ecg;
        last = last + N_segment_ecg;
    end

    N_dif = 0.1*fs;
    R_index = [];
    for jj = difmax_index
        % 对于ecg每个间隔片段，取其差分域最大值下标的前后0.1s
        if(jj-N_dif<=0)
            start = 1;
        else
            start = jj-N_dif;
        end 
        x_segment = ecg(start:jj+N_dif);  
        [m, index] = max(x_segment);
        R_index = [R_index, index+jj-N_dif-1];
    end
    if (R_index(1) <= 0)
        R_index(1) = [];
        N_for = N_for - 1;
    end

    % 基于R波寻找脑阻抗第一个极大值
    Imped_index = [];
    N_segment = 0.5*fs;
    for k = 1:N_for-1
        start = R_index(k);
        if start<0
            start = 1;
        end
        last = R_index(k) + N_segment;
        if last>length(reg)
            last = length(reg);
        end
        x_segment = reg(start:last);
        % 差分信号为0的时刻即为极小值时刻
        x_segment_dif = diff(x_segment,1);        % 差分，后项减前项
        flag = 0;kk = 1;
        while(kk<length(x_segment_dif) && flag == 0)
            if (x_segment_dif(kk)>0 && x_segment_dif(kk+1)<0 && x_segment(kk)>0)
                flag = 1;
                index = kk;
            end
            kk = kk+1;
        end
        Imped_index = [Imped_index, index+start-1]; % 第一个极小值
    end

    % 计算R波与脑阻抗最小值的时间差tao
    PTT_max_vec = (Imped_index - R_index )/fs;


    % 基于脑阻抗第一个极大值寻找前一个极小值
    Imped_index2 = [];
    N_segment = 0.5*fs;
    for k = 2:N_for-1
        start = Imped_index(k);
        if start<0
            start = 1;
        end
        last = Imped_index(k) - N_segment;
        if last>length(reg)
            last = length(reg_filted);
        end
        x_segment = reg(last:start);
        % 差分信号为0的时刻即为极小值时刻
        x_segment_dif = diff(x_segment,1);        % 差分，后项减前项
        flag = 0;kk = length(x_segment_dif)-1;
        while(kk<length(x_segment_dif) && flag == 0)
            if (x_segment_dif(kk)<0 && x_segment_dif(kk+1)>0 && x_segment(kk)<0)
                flag = 1;
                index = kk;
            end
            kk = kk-1;
            if kk < 1
                break;
            end
        end
        Imped_index2 = [Imped_index2, index+last-1]; % 极小值
    end
    PTT_min_vec = (Imped_index(2:end) - Imped_index2 )/fs;
    
    PTT_max = median(PTT_max_vec);
    PTT_min = median(PTT_min_vec);
    
    PTT = [PTT_max, PTT_min];
end