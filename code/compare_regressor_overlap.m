function [condTable, regOverlap] = compare_regressor_overlap(id, options)


%% Get subject details
details = compi_get_subject_details(id, options); % subject-specific information

fileDesignMatrix = fullfile(details.dirs.preproc, 'design.mat');

% load design
design      = getfield(load(fileDesignMatrix), 'design');

%% get epsilon2 indices
peValues_epsi2 = design.epsilon2;

nValues         = length(peValues_epsi2);

epsilon2      = NaN(1, nValues);
epsilon2(:)   = 0;

% get the number of low and high indeces
nLow    = round(options.eeg.erp.percentPe/100 *nValues);
nHigh   = nLow -1;

% sort regressor values
[sortedPE, sortIdx] = sort(peValues_epsi2);

% get 20% lowest and 20% highest indeces
lowIdcs     = sortIdx(1: nLow);
highIdcs    = sortIdx(end-nHigh: end);

% mark low and high indeces in new vector
epsilon2(lowIdcs)   = -1;
epsilon2(highIdcs)   = 1;

epsilon2 = epsilon2';

%% get epsilon3 indices
peValues_epsi3 = design.epsilon3;

nValues         = length(peValues_epsi3);

epsilon3      = NaN(1, nValues);
epsilon3(:)   = 0;

nLow    = round(options.eeg.erp.percentPe/100 *nValues);
nHigh   = nLow -1;

[sortedPE, sortIdx] = sort(peValues_epsi3);


lowIdcs     = sortIdx(1: nLow);
highIdcs    = sortIdx(end-nHigh: end);

epsilon3(lowIdcs)   = -1;
epsilon3(highIdcs)   = 1;

epsilon3 = epsilon3';

%% get delta1 indices
peValues_delta1 = design.delta1;

nValues         = length(peValues_delta1);

delta1      = NaN(1, nValues);
delta1(:)   = 0;

nLow    = round(options.eeg.erp.percentPe/100 *nValues);
nHigh   = nLow -1;

[sortedPE, sortIdx] = sort(peValues_delta1);


lowIdcs     = sortIdx(1: nLow);
highIdcs    = sortIdx(end-nHigh: end);

delta1(lowIdcs)   = -1;
delta1(highIdcs)   = 1;

delta1 = delta1';

%% get delta2 indices
peValues_delta2 = design.delta2;

nValues         = length(peValues_delta2);

delta2      = NaN(1, nValues);
delta2(:)   = 0;

nLow    = round(options.eeg.erp.percentPe/100 *nValues);
nHigh   = nLow -1;

[sortedPE, sortIdx] = sort(peValues_delta2);


lowIdcs     = sortIdx(1: nLow);
highIdcs    = sortIdx(end-nHigh: end);

delta2(lowIdcs)   = -1;
delta2(highIdcs)   = 1;

delta2 = delta2';

%% get oddball indices
oddball_val = getfield(load(fullfile(options.roots.config,  ...
    'oddball_tones_weber.mat')), 'oddball_tones');

oddball      = NaN(1, nValues);
oddball(:)   = 0;

for i=1:numel(oddball_val)
    if strcmp(oddball_val{i}, 'standard')
        oddball(i)    = -1;
    elseif strcmp(oddball_val{i}, 'deviant')
        oddball(i)    = 1;
    end
end

oddball = oddball';

edges = unique(oddball);
counts = histc(oddball(:), edges);

% oddball = tones';

%% convert to table
condTable = array2table([epsilon2 epsilon3 delta1 delta2 oddball]);
condTable.Properties.VariableNames = {'epsilon2', 'epsilon3', 'delta1', 'delta2', 'oddball'};

%% Calculate overlap COMPI
factorNames = {'epsilon2', 'epsilon3', 'delta1', 'delta2'};

for i_fac = 1: length(factorNames)
    standLow    = 0;
    standOther  = 0;
    standHigh   = 0;

    devLow      = 0;
    devOther    = 0;
    devHigh     = 0;

    for i=1:length(condTable.oddball)
        % if oddball is standard...
        if condTable.oddball(i) == -1

            % if regressor is low/other/high
            if condTable.(factorNames{i_fac})(i) == -1 %low
                standLow = standLow + 1;
            elseif condTable.(factorNames{i_fac})(i) == 0 %other
                standOther = standOther + 1;
            elseif condTable.(factorNames{i_fac})(i) == 1 %high
                standHigh = standHigh + 1;
            end

        % if oddball is deviant...
        elseif condTable.oddball(i) == 1
            if condTable.(factorNames{i_fac})(i) == -1
                devLow = devLow + 1;
            elseif condTable.(factorNames{i_fac})(i) == 0
                devOther = devOther + 1;
            elseif condTable.(factorNames{i_fac})(i) == 1
                devHigh = devHigh + 1;
            end
        end
    end

    % standard
    regOverlap.(factorNames{i_fac}).standard.Low.total = standLow;
    regOverlap.(factorNames{i_fac}).standard.Low.percentage = standLow / 106;
    regOverlap.(factorNames{i_fac}).standard.Other.total = standOther;
    regOverlap.(factorNames{i_fac}).standard.Other.percentage = standOther / 106;
    regOverlap.(factorNames{i_fac}).standard.High.total = standHigh;
    regOverlap.(factorNames{i_fac}).standard.High.percentage = standHigh / 106;

    % deviant
    regOverlap.(factorNames{i_fac}).deviant.Low.total = devLow;
    regOverlap.(factorNames{i_fac}).deviant.Low.percentage = devLow / 119;
    regOverlap.(factorNames{i_fac}).deviant.Other.total = devOther;
    regOverlap.(factorNames{i_fac}).deviant.Other.percentage = devOther / 119;
    regOverlap.(factorNames{i_fac}).deviant.High.total = devHigh;
    regOverlap.(factorNames{i_fac}).deviant.High.percentage = devHigh / 119;

end

%%

factorNames = {'epsilon2', 'epsilon3', 'delta1', 'delta2'};

for i_fac = 1: length(factorNames)
    standLow    = 0;
    standOther  = 0;
    standHigh   = 0;

    devLow      = 0;
    devOther    = 0;
    devHigh     = 0;

    otherLow    = 0;
    otherOther  = 0;
    otherHigh   = 0;

    for i=1:length(condTable.oddball)
        % standards
        if condTable.oddball(i) == -1
            if condTable.(factorNames{i_fac})(i) == -1
                standLow = standLow + 1;
            elseif condTable.(factorNames{i_fac})(i) == 0
                standOther = standOther + 1;
            elseif condTable.(factorNames{i_fac})(i) == 1
                standHigh = standHigh + 1;
            end
        elseif condTable.oddball(i) == 1
            if condTable.(factorNames{i_fac})(i) == -1
                devLow = devLow + 1;
            elseif condTable.(factorNames{i_fac})(i) == 0
                devOther = devOther + 1;
            elseif condTable.(factorNames{i_fac})(i) == 1
                devHigh = devHigh + 1;
            end
        elseif condTable.oddball(i) == 0
            if condTable.(factorNames{i_fac})(i) == -1
                otherLow = otherLow + 1;
            elseif condTable.(factorNames{i_fac})(i) == 0
                otherOther = otherOther + 1;
            elseif condTable.(factorNames{i_fac})(i) == 1
                otherHigh = otherHigh + 1;
            end
        end
    end

    % standard
    regOverlap.(factorNames{i_fac}).standard.Low.total = standLow;
    regOverlap.(factorNames{i_fac}).standard.Low.percentage = standLow / 106;
    regOverlap.(factorNames{i_fac}).standard.Other.total = standOther;
    regOverlap.(factorNames{i_fac}).standard.Other.percentage = standOther / 106;
    regOverlap.(factorNames{i_fac}).standard.High.total = standHigh;
    regOverlap.(factorNames{i_fac}).standard.High.percentage = standHigh / 106;

    % deviant
    regOverlap.(factorNames{i_fac}).deviant.Low.total = devLow;
    regOverlap.(factorNames{i_fac}).deviant.Low.percentage = devLow / 119;
    regOverlap.(factorNames{i_fac}).deviant.Other.total = devOther;
    regOverlap.(factorNames{i_fac}).deviant.Other.percentage = devOther / 119;
    regOverlap.(factorNames{i_fac}).deviant.High.total = devHigh;
    regOverlap.(factorNames{i_fac}).deviant.High.percentage = devHigh / 119;

    % other
    regOverlap.(factorNames{i_fac}).other.Low.total = otherLow;
    regOverlap.(factorNames{i_fac}).other.Low.percentage = otherLow / 1575;
    regOverlap.(factorNames{i_fac}).other.Other.total = otherOther;
    regOverlap.(factorNames{i_fac}).other.Other.percentage = otherOther / 1575;
    regOverlap.(factorNames{i_fac}).other.High.total = otherHigh;
    regOverlap.(factorNames{i_fac}).other.High.percentage = otherHigh / 1575;
end



%% Figure

x = 1:1800;

figure;
scatter(x, condTable.epsilon2, 'b', 'filled');
hold on;
scatter(x, condTable.oddball, 'r', 'filled');
hold off;
legend;









