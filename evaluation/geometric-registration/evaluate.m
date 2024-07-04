% Script to evaluate .log files for the geometric registration benchmarks,
% in the same spirit as Choi et al 2015. Please see:
%
% http://redwood-data.org/indoor/regbasic.html
% https://github.com/qianyizh/ElasticReconstruction/tree/master/Matlab_Toolbox

methodName = 'FCGF'; % 3dmatch, spin, fpfh

% Locations of evaluation files
dataPath = '../../data/fragments';

% Locations of obtained registration files
% Remember to add the output of the tested method in this directory
resultPath = 'registration_output';

% % Synthetic data benchmark
% sceneList = {'iclnuim-livingroom1-evaluation' ...
%              'iclnuim-livingroom2-evaluation' ...
%              'iclnuim-office1-evaluation' ...
%              'iclnuim-office2-evaluation'};
         
% Real data benchmark
sceneList = {'7-scenes-redkitchen', ...
             'sun3d-home_at-home_at_scan1_2013_jan_1', ...
             'sun3d-home_md-home_md_scan9_2012_sep_30', ...
             'sun3d-hotel_uc-scan3', ...
             'sun3d-hotel_umd-maryland_hotel1', ...
             'sun3d-hotel_umd-maryland_hotel3', ...
             'sun3d-mit_76_studyroom-76-1studyroom2', ...
             'sun3d-mit_lab_hj-lab_hj_tea_nov_2_2012_scan1_erika'};
         
% Load Elastic Reconstruction toolbox
addpath(genpath('external'));

% Compute precision and recall
totalRecall = []; totalPrecision = [];
for sceneIdx = 1:length(sceneList)
    scene_gtPath = fullfile(dataPath,sprintf('%s-%s',sceneList{sceneIdx},'evaluation'));
    scene_resultPath = fullfile(resultPath,sprintf('%s_%s.log',sceneList{sceneIdx},methodName));
    
    % Loads .info and .log files
    [gt, ~] = mrLoadLog(fullfile(scene_gtPath,'gt.log'));
    gt_info = mrLoadInfo(fullfile(scene_gtPath,'gt.info'));
    [result, sucess] = mrLoadLog(scene_resultPath);

    % Check if any valid transformation was found
    if ~sucess
        disp(['Skipping scene because no valid transformations were found for: ', sceneList{sceneIdx}]);
        % Append NaN to totalRecall and totalPrecision
        totalRecall = [totalRecall; NaN];
        totalPrecision = [totalPrecision; NaN];
        continue    % skips to next scene
    end

    % Compute registration error
    [recall,precision] = mrEvaluateRegistration(result,gt,gt_info);
    totalRecall = [totalRecall;recall];
    totalPrecision = [totalPrecision;precision];
end

% Create table for CSV export
T = table(sceneList', ...
          cellstr(num2str(totalRecall, '%.4f')), ...
          cellstr(num2str(totalPrecision, '%.4f')), ...
          'VariableNames', {'Scene', 'Recall', 'Precision'});

% Calculate TOTAL averages
totalAvgRecall = mean(totalRecall(~isnan(totalRecall)));
totalAvgPrecision = mean(totalPrecision(~isnan(totalPrecision)));

% Add TOTAL row
T(end+1, :) = {'TOTAL', num2str(totalAvgRecall, '%.4f'), num2str(totalAvgPrecision, '%.4f')};

% Write table to CSV
writetable(T, 'registration_evaluation.csv');

% Display total averages
fprintf('Total average registration recall: %.4f\n', mean(totalRecall(~isnan(totalRecall))));
fprintf('Total average registration precision: %.4f\n', mean(totalPrecision(~isnan(totalPrecision))));