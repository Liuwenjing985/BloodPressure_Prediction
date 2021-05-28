function PTT = fea_PTT(ecg, reg, fs)
    N_segment_ecg = 450;
    % R�����
    % ��1�ײ��
    dif = diff(ecg,1);    % �����ǰ��
    % �Ҳ��������ֵ
    N_for = floor(length(ecg)/N_segment_ecg); % ����ѭ���Ķ���
    start = 1;            % ��ʼ�ֶ����
    last = N_segment_ecg; % ��ʼ�ֶ��յ�
    difmax_index = [];    % �洢��������ֵ�±�
    for jj = 1:N_for-1
        dif_segment = dif(start:last);       % ecg�����ÿ�������Ƭ��
        [m, index] = max(dif_segment);       % ecg���������ֵ�±�
        difmax_index = [difmax_index, index+start-1];
        start = start + N_segment_ecg;
        last = last + N_segment_ecg;
    end

    N_dif = 0.1*fs;
    R_index = [];
    for jj = difmax_index
        % ����ecgÿ�����Ƭ�Σ�ȡ���������ֵ�±��ǰ��0.1s
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

    % ����R��Ѱ�����迹��һ������ֵ
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
        % ����ź�Ϊ0��ʱ�̼�Ϊ��Сֵʱ��
        x_segment_dif = diff(x_segment,1);        % ��֣������ǰ��
        flag = 0;kk = 1;
        while(kk<length(x_segment_dif) && flag == 0)
            if (x_segment_dif(kk)>0 && x_segment_dif(kk+1)<0 && x_segment(kk)>0)
                flag = 1;
                index = kk;
            end
            kk = kk+1;
        end
        Imped_index = [Imped_index, index+start-1]; % ��һ����Сֵ
    end

    % ����R�������迹��Сֵ��ʱ���tao
    PTT_max_vec = (Imped_index - R_index )/fs;


    % �������迹��һ������ֵѰ��ǰһ����Сֵ
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
        % ����ź�Ϊ0��ʱ�̼�Ϊ��Сֵʱ��
        x_segment_dif = diff(x_segment,1);        % ��֣������ǰ��
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
        Imped_index2 = [Imped_index2, index+last-1]; % ��Сֵ
    end
    PTT_min_vec = (Imped_index(2:end) - Imped_index2 )/fs;
    
    PTT_max = median(PTT_max_vec);
    PTT_min = median(PTT_min_vec);
    
    PTT = [PTT_max, PTT_min];
end