%% Basic instruction
%  ? Put this script in the same folder as your MUSCA data (this script works 
%  for data obtained using CstV format on a Biologic(Brand) Potentiostat.)
%  ? Input the file name in line 6
%  ? Double chekc line 16 to make sure the data input has the correct number
%  of columns and proper designation of integer and fraction numbers.
%  ? Check the sweep rates you wanted between line 57 and 64
%  ? A text filed named "Calculated Voltammograms.txt" will be generated
%  that contains all the data.
%% Script
    % Load files
    textFileName = char('file name.txt'); % convert the name of the i-th file into a string format readable by Matlab
    FileName = textFileName(1:end-4);
    fileID = fopen(textFileName,'rt');% open the i-th file for getting headerline and sweep rate infos
    D = textscan(fileID,'%s','Delimiter','\n');% scan the text in the i-th file and save to D
    fclose(fileID);% close the file
    Headerlines_Num = str2num(D{1}{2}(19))*10+str2num(D{1}{2}(20));% Find the number of headerlines in the 2nd row of D{1} which are stored in the 19th and 20th positions and convert the string format to a number format

    % to read the columns
    fileID = fopen(textFileName,'rt');% open the i-th file for getting actual data
    Raw_Data = textscan(fileID,'%d %d %d %d %d %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','Headerlines',Headerlines_Num);% obtain data, %d is space holder for integers, and %f is space holder for fraction numbers
    fclose(fileID);% close the file
    Raw_time = double(Raw_Data{7});
    Raw_Ewe = double(Raw_Data{9});
    Raw_I = double(Raw_Data{10});
    
    % find the index that potential goes to the next step
    Cycle_Index = [];
    j = 1;
    for i = 2:1:numel(Raw_time)
        if abs(Raw_Ewe(i) - Raw_Ewe(i-1))> 0.025
            Cycle_Index(j) = i;
            j = j + 1;
        end
    end
    

    % sort the columns
    No_Row = max(diff(Cycle_Index));
    No_Col = numel(Cycle_Index);
    time = nan(No_Row,No_Col);
    Ewe = nan(No_Row,No_Col);
    I = nan(No_Row,No_Col);
    for i = 2:numel(Cycle_Index)
        time(1:Cycle_Index(i)-Cycle_Index(i-1),i-1) = Raw_time(Cycle_Index(i-1):Cycle_Index(i)-1);
        Ewe(1:Cycle_Index(i)-Cycle_Index(i-1),i-1) = Raw_Ewe(Cycle_Index(i-1):Cycle_Index(i)-1);
        I(1:Cycle_Index(i)-Cycle_Index(i-1),i-1) = Raw_I(Cycle_Index(i-1):Cycle_Index(i)-1);
        if i == numel(Cycle_Index)
            time(1:numel(Raw_time)-Cycle_Index(i)+1,i) = Raw_time(Cycle_Index(i):end);
            Ewe(1:numel(Raw_time)-Cycle_Index(i)+1,i) = Raw_Ewe(Cycle_Index(i):end);
            I(1:numel(Raw_time)-Cycle_Index(i)+1,i) = Raw_I(Cycle_Index(i):end);
        end
    end
    
    % MUSCA
    Time_Interval = round(time(1,2)-time(1,1)); %unit: S
    Potential_Step = round(abs(Ewe(1,2)-Ewe(1,1))*1000); % unit: mV
    Slowest_Rate = Potential_Step/Time_Interval;
    Sweep_rates = [Slowest_Rate, ...
        Slowest_Rate*2, ...
        Slowest_Rate*4, ...
        Slowest_Rate*10, ...
        Slowest_Rate*20, ...
        Slowest_Rate*40, ...
        Slowest_Rate*100,...
        Slowest_Rate*200];
    E_MUSCA = nan(numel(Cycle_Index),numel(Sweep_rates));
    I_MUSCA = nan(numel(Cycle_Index),numel(Sweep_rates));
    
    for i = 1:numel(Sweep_rates)
        t_MUSCA = Potential_Step/Sweep_rates(i);
        for j = 1:numel(Cycle_Index)
            It_Select = [I((time(:,j)-round(time(1,j)))<=t_MUSCA,j),time((time(:,j)-round(time(1,j)))<=t_MUSCA,j)];
            E_MUSCA(j,i) = round(Ewe(1,j)*100)/100;
            I_MUSCA(j,i) = trapz(It_Select(:,2),It_Select(:,1))/t_MUSCA;
        end
    end
    
    figure(13)
plot(E_MUSCA,I_MUSCA)
xlabel('Potential V vs. Ag wire')
ylabel('Current (mA) Reconstructed')
title('Simulated CV with MUSCA')

%% text file output
% Sweep_rates_output = nan(1,numel(Sweep_rates));
% EI_MUSCA = nan(numel(Cycle_Index),1+numel(Sweep_rates));
EI_MUSCA = [E_MUSCA(:,1),I_MUSCA];
% for i = 1:numel(Sweep_rates)
%     Sweep_rates_output(2*i-1) = Sweep_rates(i);
%     Sweep_rates_output(2*i) = Sweep_rates(i);
% end
% potential and current
New_fileName = ['Calculated Voltammograms.txt'];% create new file names
fileID = fopen(char(New_fileName), 'w');% create a file
for i = 1:numel(Sweep_rates)
    if i == 1
        fprintf(fileID,'%s\t%s\t','Potential','Current');
    elseif i ~= numel(Sweep_rates)
        fprintf(fileID,'%s\t','Current');
    else
        fprintf(fileID,'%s\r\n','Current');
    end
end
for i = 1:numel(Sweep_rates)
    
    if i == 1
        fprintf(fileID,'%s\t%s\t','V','mA');
    elseif i ~= numel(Sweep_rates)
        fprintf(fileID,'%s\t','mA');
    else
        fprintf(fileID,'%s\r\n','mA');
    end
end
for i = 1:numel(Sweep_rates)
    
    if i == 1
        fprintf(fileID,'%s\t%s\t',' ',[num2str(Sweep_rates(i)),' mV/s']);
    elseif i ~= numel(Sweep_rates)
        fprintf(fileID,'%s\t',[num2str(Sweep_rates(i)),' mV/s']);
    else
        fprintf(fileID,'%s\r\n',[num2str(Sweep_rates(i)),' mV/s']);
    end
end
value_holder = [];
for i = 1:numel(Sweep_rates)
    
    if i == 1
        value_holder = [value_holder, '%.4f\t%.4f\t'];
    elseif i ~= numel(Sweep_rates)
        value_holder = [value_holder, '%.4f\t'];
    else
        value_holder = [value_holder, '%.4f\r\n'];
    end
end

fprintf(fileID,value_holder, EI_MUSCA');
fclose(fileID);% close the file
