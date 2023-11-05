function [ perform, meanRT, errors, misses ] = compi_calculate_visTask_performance( MMN )
% -------------------------------------------------------------------------
% COMPI_CALCULATE_VISTASK_PERFORMANCE Calculates performance score for the 
% visual task. This function calculates and returns the performance score 
% (higher is better, minimum is zero, maximum around 0.6), the mean 
% reaction time (RT), and counts the number of error presses and misses in 
% visual events.
%   IN:    MMN      Behavior results structure containing stimulus and
%                   response data.
%   OUT:   perform  Performance score.
%          meanRT   Mean reaction time.
%          errors   Number of error presses.
%          misses   Number of misses in visual events.
% -------------------------------------------------------------------------

% Settings
minRT = 100 / 1000;     % Minimum acceptable reaction time in seconds.
maxRT = 2000 / 1000;    % Maximum acceptable reaction time in seconds.
ansButtons = {1, 2};    % Possible correct response buttons.
minPerform = 0;         % Minimum performance score.

% Initialize result variables
reactTime = [];
misses = 0;
errors = 0;
rts = [];

% Find indices of trials where something happened
idxVis = find(MMN.stimuli.visSequence);

% Calculate the number of visual stimuli and button presses
nVis = length(idxVis);
nButtons = length(MMN.responses.times);

% Loop through all stimuli except the last one
for vis = 1:nVis
    % Get stimulus presentation time and type
    presTime = MMN.stimuli.visTimes(idxVis(vis));
    presType = MMN.stimuli.visSequence(idxVis(vis));
    corrButton = ansButtons{presType};
    
    % Determine acceptable range of reaction times
    minTime = presTime + minRT;
    maxTimeRT = presTime + maxRT;
    
    if vis == nVis
        maxTime = maxTimeRT;
    else
        presRange = MMN.stimuli.visTimes(idxVis(vis + 1)) - presTime;
        maxTimeRange = presTime + presRange;
        maxTime = min(maxTimeRT, maxTimeRange);
    end
    
    % Collect potential reaction times
    potRTs = [];
    for butt = 1:nButtons
        pressTime = MMN.responses.times(butt);
        respButton = MMN.responses.dummy(butt);
        
        % Save potential RTs
        if pressTime > minTime && pressTime < maxTime && respButton == corrButton
            potRTs = [potRTs, pressTime];
        end
    end
    
    % If there were no valid responses, mark it as a miss
    if isempty(potRTs)
        misses = misses + 1;
        reactTime(vis) = NaN;
        rts(vis) = NaN;
    else
        % Choose the first correct response as the reaction time
        reactTime(vis) = min(potRTs);
        rts(vis) = reactTime(vis) - presTime;
    end
end

% Check for button presses that have not been assigned to a stimulus
for butt = 1:nButtons
    pressTime = MMN.responses.times(butt);
    if ~ismember(pressTime, reactTime)
        errors = errors + 1;
    end
end

% Calculate performance score
meanRT = mean(rts(~isnan(rts)));
faults = misses + errors;
perform = 1 - (meanRT + faults / nVis) + 0.2;

% Ensure performance is not below the minimum
if perform < minPerform
    perform = minPerform;
end

end