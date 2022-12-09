clear all,close all,clc

[fileName, pathName] = uigetfile('*');  %load the image via GUI
srcImage = imread(strcat(pathName, fileName));

test_v = [0;0.0002;0.0003;0.0004;0.0005;0.0007;0.0008;0.0009;0.001;0.0011;0.0013;0.0014;0.0015;0.0016;0.0018;0.0019;0.002];
%test_v 是逃逸概率集合
for i = 1:length(test_v)
      generate_code_book(2, srcImage, i, test_v(i));
end


function coding_table = generate_code_book(mode, arr, id, escape_prob)
% mode: 1-单符号      2-双符号
% arr: Huffman编码的图片矩阵
% id: 码表的序号，最后单符号码表的文件名为'table_{id}.txt'
% escpae_prob: 逃逸概率
    id = string(id);
    [~,coding_table,~,~,~] = my_huff1(arr, mode, escape_prob);
    fin_num = coding_table{1};
    fin_coding = coding_table{2};
    escape_code = coding_table{3};
    
    if mode == 1
        catstring = "table_";
        filename = strcat(catstring,id,".txt");
        fileID = fopen(filename,'w');
        for i = 1:length(fin_num)
            fprintf(fileID, '%d %s\r\n',fin_num(i),fin_coding(i));
        end
        fprintf(fileID, '%s',escape_code);
    else
        catstring = "table2_";
        filename = strcat(catstring,id,".txt");
        fileID = fopen(filename,'w');
        for i = 1:length(fin_num)
            temp = fin_num{i};
            fprintf(fileID, '%d %d %s\r\n',temp(1),temp(2),fin_coding(i));
        end
        fprintf(fileID, '%s',escape_code);
    end
end

function [coded_data,coding_table,escape_code,tab_length,total_cost] = my_huff1(qd, mode, escape_prob)
    
    qd = qd';
    
    rqd = reshape(qd,1,size(qd,1)*size(qd,2));
    
    if (mode == 1) % single
        
        freq_tab = tabulate(rqd);
        freq_tab = [freq_tab(:,1),freq_tab(:,3)];
        stay_idx = find(freq_tab(:,2));
        freq_tab = freq_tab(stay_idx,:);
        
        freq_tab(:,2) = freq_tab(:,2)/sum(freq_tab(:,2)); % 归一化
        
        freq_tab = generate_escape_tab(freq_tab,escape_prob);
        mat = generate_huffman_tree(freq_tab);
        
        % generate table
       [fin_num,fin_coding,escape_code] = generate_huffman_table(mat);
        
        %coding table最后要存在文件中(还没存)
        coding_table = {fin_num,fin_coding,escape_code};
        
        coded_data = huffman_coding_data(rqd,fin_num,fin_coding,escape_code);
        
        tab_length = 0;
        for i = 1:length(fin_num)
            if(fin_num(i)~=256)
                tab_length = tab_length + length(dec2bin(fin_num(i)));
            end
        end 
        tab_length = tab_length + length(escape_code);
        for i = 1:length(fin_coding)
            tab_length = tab_length + length(char(fin_coding(i)));
        end

    else % two pixels
        
        %generate freq table, find the equivalent num array
        n_data = length(rqd)/2;
        tabling = {};
        freq = [];
        for i = 1:n_data
            temp = rqd((i-1)*2+1:i*2);
            [bo,id] = check_exist(temp,tabling);
            if bo == 0
                tabling(end+1) = {temp};
                freq = [freq 1];
            else
                freq(id) = freq(id)+1;
            end  
        end
        
        [srted,srted_id] = sort(freq);
        tabling = tabling(srted_id);
        
        eq_num = 1:length(tabling);
        freq_tab = [eq_num' srted'];
        freq_tab(:,2) = freq_tab(:,2)/sum(freq_tab(:,2)); % 归一化
        
        [freq_tab,cut,esc_num] = two_bit_generate_escape_tab(freq_tab,escape_prob,length(eq_num));
        
        mat = generate_huffman_tree(freq_tab);
        
        % generate table
        [fin_num,fin_coding,escape_code] = two_bit_generate_huffman_table(mat,esc_num);
        
        [~,s_id] = sort(fin_num);
        fin_coding = fin_coding(s_id);
        
        
        if ~isempty(cut)
            tabling = tabling(cut+1:end);
        end
        
        coding_table = {tabling,fin_coding,escape_code};
        
        % coding the sequence:
        coded_data = "";
        
        
        for i = 1:n_data
            slice = rqd((i-1)*2+1:i*2);
            [ex_or_not, ex_idx] = check_exist(slice,tabling);

            if ex_or_not == 1
                coded_data = strcat(coded_data,fin_coding(ex_idx));
            else
                esc = strcat(escape_code, dec2bin(slice(1),8),dec2bin(slice(2),8));
                coded_data = strcat(coded_data, esc);
            end
        end
        
        tab_length = 0;
        for i = 1:length(tabling)
            temp = tabling{i};
            tab_length = tab_length + length(dec2bin(temp(1)))+length(dec2bin(temp(2)));
        end 
        tab_length = tab_length + length(escape_code);
        for i = 1:length(fin_coding)
            tab_length = tab_length + length(char(fin_coding(i)));
        end
    end
    

    total_cost = tab_length + length(char(coded_data));
end

function [y,id] = check_exist(temp, tabling)
    l = length(tabling);
    y = 0;
    id = 0;
    if l == 0
        y = 0;
    else
        for i = 1:l
            if isequal(temp,tabling{i})
                y = 1;
                id = i;
            end
        end
    end
end



function mat = generate_huffman_tree(freq_tab)
        mat = [];
        i = 1;
        while (size(freq_tab,1) > 1)
            s_freq_tab = sortrows(freq_tab,2,"ascend");
        
            mat(i,1) = s_freq_tab(1,1);
            mat(i,2) = s_freq_tab(2,1);
            
            temp = [-i,s_freq_tab(1,2)+s_freq_tab(2,2)];
            if (size(freq_tab,1) >= 3)
                freq_tab = [temp;s_freq_tab(3:end,:)];
            else
                freq_tab = temp;
            end
            
            i = i + 1;
            
        end
end

function [fin_num,fin_coding,escape_code] = generate_huffman_table(mat)
        n = size(mat,1);
        check_num = [];
        coding = [];
        for i = 1:n
            check_num = [check_num mat(n-i+1,1) mat(n-i+1,2)];
            idx = find(check_num == -(n-i+1),1);
            if(~isempty(idx))
                coding = [coding strcat(coding(idx),"0") strcat(coding(idx),"1")];
            else
                coding = [coding "0" "1"];
            end
            
        end
        
        fin_idx = find(check_num >= 0 & check_num ~= 256);
        fin_num = check_num(fin_idx);
        fin_coding = coding(fin_idx);
        
        escape_code = coding(find(check_num == 256,1));

end

function coded_data = huffman_coding_data(rqd,fin_num,fin_coding,escape_code)
        coded_data = "";
        
        for i = 1:length(rqd)
            find_idx = find(fin_num == rqd(i),1);
            if ~isempty(find_idx)
                coded_data = strcat(coded_data,fin_coding(find_idx));
            else
                esc = strcat(escape_code, dec2bin(rqd(i),8));
                coded_data = strcat(coded_data, esc);
            end
        end
end

function [new_freq_tab,cut] = generate_escape_tab(freq_tab,escape_prob)
    esc = 256;
    s_freq_tab = sortrows(freq_tab,2,"ascend");
    
    prob_r = s_freq_tab(:,2)';
    
    cut = find(prob_r<escape_prob,1,'last');
    
    if isempty(cut)
        new_freq_tab = s_freq_tab;
        return;
    end
    esc_prob = sum(prob_r(1:cut));
    
    escape_word = [esc esc_prob];
    
    new_freq_tab = [s_freq_tab(cut+1:end,:);escape_word];


end

function [new_freq_tab,cut,esc] = two_bit_generate_escape_tab(freq_tab,escape_prob,l)
    esc = l+1;
    s_freq_tab = sortrows(freq_tab,2,"ascend");
    
    prob_r = s_freq_tab(:,2)';
    
    cut = find(prob_r<escape_prob,1,'last');
    
    if isempty(cut)
        new_freq_tab = s_freq_tab;
        return;
    end
    esc_prob = sum(prob_r(1:cut));
    
    escape_word = [esc esc_prob];
    
    new_freq_tab = [s_freq_tab(cut+1:end,:);escape_word];


end

function [fin_num,fin_coding,escape_code] = two_bit_generate_huffman_table(mat,esc_num)
        n = size(mat,1);
        check_num = [];
        coding = [];
        for i = 1:n
            check_num = [check_num mat(n-i+1,1) mat(n-i+1,2)];
            idx = find(check_num == -(n-i+1),1);
            if(~isempty(idx))
                coding = [coding strcat(coding(idx),"0") strcat(coding(idx),"1")];
            else
                coding = [coding "0" "1"];
            end
            
        end
        
        fin_idx = find(check_num >= 0 & check_num ~= esc_num);
        fin_num = check_num(fin_idx);
        fin_coding = coding(fin_idx);
        
        escape_code = coding(find(check_num == esc_num,1));

end
