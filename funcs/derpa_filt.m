function [EEG,deverp] = derpa_filt(deverp, EEG)
%UNTITLED4 Filter DevERP datasets
%   DEVERP DevERP struct
%   EEG EEGLAB 'EEG' struct

% filter parameters
highpass = [0.01, 0.1, 0.25, 0.50, 0.75, 1];
highpass_str = {'pt01', 'pt1', 'pt25', 'pt5', 'pt75', '1'};

%% Filter

% filter parameters
highpass = [0.01, 0.1, 0.25, 0.50, 0.75, 1];
highpass_str = {'pt01', 'pt1', 'pt25', 'pt5', 'pt75', '1'};
numparams = length(highpass);

for i = 1:numparams
    
    eeglab nogui

    for s=1:numsubjects
        subject = deverp.subjectlist.subjects{s};

        % load in datasets
        EEG = pop_loadset([deverp.dirs.workdir filesep [subject '_chansrm_.set']]);

        % filter the data
        EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff', [ highpass(i) 30], ...
                'Design', 'butter', 'Filter', 'bandpass', 'Order',4 );

        % save dataset
        EEG = pop_saveset( EEG, [deverp.dirs.workdir filesep [subject '_highpass_' highpass_str{i} '.set']]);
    end
end

%% Epoch filter data

EEG = epochWrapper(deverp, EEG,ALLEEG, CURRENTSET, 'filter', subject_list, workdir, txtdir, erpdir);

%% Make ERP list for filter data

highpass_str = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};
erpnames = {'1_erplist.txt', 'pt1_erplist.txt', 'pt01_erplist.txt', 'pt25_erplist.txt', 'pt5_erplist.txt', 'pt75_erplist.txt'};

for j = 1:numparams
    fileID = fopen([deverp.dirs.txtdir filesep erpnames{j}], 'w');
    for i = 1:numsubjects
        subject = deverp.subjectlist.subjects{i};
        data = fullfile(erpdir, [subject '_highpass_' highpass_str{j} '.erp']);
        fprintf(fileID, '%s\n', data);
    end
    fclose(fileID);
end

%% Analyze SME for filtered data

% set variables
erpnames = {'1_erplist.txt', 'pt1_erplist.txt', 'pt01_erplist.txt', 'pt25_erplist.txt', 'pt5_erplist.txt', 'pt75_erplist.txt'};
strnames = {'1', 'pt1', 'pt01', 'pt25', 'pt5', 'pt75'};

%analyze winner
analyzeSME2(ALLERP, erpnames, strnames, txtdir, erpdir)

filt_winner = winner2;

filter_winner = ['_highpass_' filt_winner];

end