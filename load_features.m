
function [fts, fts_train] = load_features(attrDir, files, trainFiles)
fts = load(fullfile(attrDir, 'predict_features.txt'));
fts = fts(1:min(size(fts,1), length(files)), :);
fts_train = load(fullfile(attrDir, 'predict_features_train.txt'));
fts_train = fts_train(1:min(size(fts_train,1), length(trainFiles)), :);

end